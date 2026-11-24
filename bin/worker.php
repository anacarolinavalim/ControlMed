<?php
declare(strict_types=1);
require_once __DIR__.'/../config/bootstrap.php';
require_once __DIR__.'/../vendor/autoload.php';
use Minishlink\WebPush\WebPush;
use Minishlink\WebPush\Subscription;
$auth=['VAPID'=>['subject'=>envv('VAPID_SUBJECT'),'publicKey'=>VAPID_PUBLIC_KEY,'privateKey'=>VAPID_PRIVATE_KEY]];
if(!VAPID_PUBLIC_KEY||!VAPID_PRIVATE_KEY)exit("VAPID não configurado.".PHP_EOL);
$push=new WebPush($auth);
$low=$pdo->query("SELECT m.id,m.user_id,m.name,m.quantity,m.minimum_quantity FROM medications m LEFT JOIN medication_alerts a ON a.medication_id=m.id AND a.type='low_stock' AND a.status='open' WHERE m.active=1 AND m.quantity<=m.minimum_quantity AND a.id IS NULL");
$alert=$pdo->prepare("INSERT INTO medication_alerts(medication_id,user_id,type,message) VALUES(?,?,?,?)");
$notif=$pdo->prepare("INSERT INTO notifications(title,body,category,scheduled_at) VALUES(?,?,?,NOW())");
$queue=$pdo->prepare("INSERT INTO notification_queue(notification_id,user_id,kind,payload,available_at) VALUES(?,?,?,?,NOW())");
foreach($low as $item){$message='Estoque baixo: '.$item['name'].' ('.$item['quantity'].' restantes).';$alert->execute([$item['id'],$item['user_id'],'low_stock',$message]);$notif->execute(['Estoque baixo',$message,'reminder']);$nid=(int)$pdo->lastInsertId();$queue->execute([$nid,$item['user_id'],'low_stock',json_encode(['title'=>'Estoque baixo','body'=>$message,'url'=>'./'])]);}
$exp=$pdo->query("SELECT m.id,m.user_id,m.name,m.expiry_date FROM medications m LEFT JOIN medication_alerts a ON a.medication_id=m.id AND a.type='expiry' AND a.status='open' WHERE m.active=1 AND m.expiry_date IS NOT NULL AND m.expiry_date<=DATE_ADD(CURDATE(),INTERVAL 30 DAY) AND a.id IS NULL");
foreach($exp as $item){$message='Validade próxima: '.$item['name'].' vence em '.date('d/m/Y',strtotime($item['expiry_date']));$alert->execute([$item['id'],$item['user_id'],'expiry',$message]);$notif->execute(['Validade próxima',$message,'reminder']);$nid=(int)$pdo->lastInsertId();$queue->execute([$nid,$item['user_id'],'expiry',json_encode(['title'=>'Validade próxima','body'=>$message,'url'=>'./'])]);}
$jobs=$pdo->query("SELECT q.*,s.id subscription_id,s.endpoint,s.p256dh,s.auth,s.content_encoding FROM notification_queue q JOIN push_subscriptions s ON s.user_id=q.user_id WHERE q.processed_at IS NULL AND q.available_at<=NOW() AND q.attempts<5 ORDER BY q.id LIMIT 100");
foreach($jobs as $job){$pdo->prepare('UPDATE notification_queue SET attempts=attempts+1 WHERE id=?')->execute([$job['id']]);try{$sub=Subscription::create(['endpoint'=>$job['endpoint'],'publicKey'=>$job['p256dh'],'authToken'=>$job['auth'],'contentEncoding'=>$job['content_encoding']]);$push->queueNotification($sub,$job['payload']);foreach($push->flush() as $result){$ok=$result->isSuccess();$pdo->prepare('INSERT INTO notification_logs(notification_id,subscription_id,user_id,status,response_code,error_message,sent_at) VALUES(?,?,?,?,?,?,?)')->execute([$job['notification_id'],$job['subscription_id'],$job['user_id'],$ok?'sent':($result->isSubscriptionExpired()?'invalid':'failed'),$result->getResponse()?->getStatusCode(),$ok?null:(string)$result->getReason(),$ok?date('Y-m-d H:i:s'):null]);if($result->isSubscriptionExpired())$pdo->prepare('DELETE FROM push_subscriptions WHERE id=?')->execute([$job['subscription_id']]);}$pdo->prepare('UPDATE notification_queue SET processed_at=NOW() WHERE id=?')->execute([$job['id']]);}catch(Throwable $e){$pdo->prepare('UPDATE notification_queue SET last_error=? WHERE id=?')->execute([$e->getMessage(),$job['id']]);}}
