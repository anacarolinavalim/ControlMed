<?php
declare(strict_types=1);
$envFile = dirname(__DIR__).'/.env';
if (is_file($envFile)) { foreach (file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) { if (str_starts_with(trim($line),'#') || !str_contains($line,'=')) continue; [$k,$v]=explode('=',trim($line),2); $_ENV[$k]=trim($v," \t\n\r\0\x0B\""); } }
function envv(string $key, string $default=''): string { return (string)($_ENV[$key] ?? getenv($key) ?: $default); }
define('VAPID_PUBLIC_KEY', envv('VAPID_PUBLIC_KEY'));
define('VAPID_PRIVATE_KEY', envv('VAPID_PRIVATE_KEY'));
$secure = envv('APP_ENV','production') === 'production';
session_name(envv('SESSION_NAME','medcontrol_session'));
session_set_cookie_params(['httponly'=>true,'secure'=>$secure,'samesite'=>'Lax','path'=>'/']);
session_start();
if (!isset($_SESSION['csrf'])) $_SESSION['csrf'] = bin2hex(random_bytes(32));
setcookie('medcontrol_csrf', $_SESSION['csrf'], ['httponly'=>false,'secure'=>$secure,'samesite'=>'Lax','path'=>'/']);
$dsn = 'mysql:host='.envv('DB_HOST','127.0.0.1').';port='.envv('DB_PORT','3306').';dbname='.envv('DB_NAME','medcontrol').';charset='.envv('DB_CHARSET','utf8mb4');
try { $pdo = new PDO($dsn, envv('DB_USER'), envv('DB_PASSWORD'), [PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC,PDO::ATTR_EMULATE_PREPARES=>true]); } catch (Throwable $e) { error_log('MariaDB connection failed: '.$e->getMessage()); http_response_code(503); header('Content-Type: application/json; charset=utf-8'); echo json_encode(['error'=>'Banco de dados indisponível.']); exit; }
