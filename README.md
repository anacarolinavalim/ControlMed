# MedControl PWA

O projeto usa MariaDB 10.4+ (ou MySQL compatível) através do PDO. No PHP, o DSN correto continua sendo `mysql:`; não troque por `mariadb:`.

PWA mobile-first para controle de medicamentos, estoque, gastos e lembretes com Web Push/VAPID.

## O que está incluído

- Dashboard responsivo com resumo do tratamento, próximos horários, estoque e gastos.
- Cadastro de medicamentos com dose, horários, validade, estoque, preço e farmácia.
- Registro de doses administradas ou esquecidas, com baixa de estoque somente após confirmação.
- Compras/reposições e movimentações de estoque.
- Preferências de notificações por usuário e múltiplos dispositivos.
- Service Worker, manifest e suporte a instalação na tela inicial.
- API PHP com autenticação por sessão, CSRF, PDO e autorização por perfil.
- Estrutura MySQL normalizada e fila de notificações VAPID.
- Central administrativa preparada para comunicados imediatos e agendados.

## Instalação rápida

1. Crie um banco MariaDB e importe `database/schema.sql`.
2. Copie `.env.example` para `.env` e preencha as credenciais.
3. Execute `composer install` na pasta do projeto.
4. Gere as chaves VAPID com `php bin/generate-vapid.php` e copie os valores para `.env`.
5. Publique a pasta em HTTPS (obrigatório para Push; `localhost` é aceito para desenvolvimento).
6. Configure o document root do servidor para `public/`.
7. Agende `php bin/worker.php` a cada minuto para processar a fila de notificações.

## Credenciais iniciais

Não há usuário fictício criado. Cadastre o primeiro usuário pela tela de acesso e promova-o a administrador diretamente no banco apenas em ambiente controlado:

```sql
UPDATE users SET role = 'admin' WHERE email = 'seu-email@exemplo.com';
```

## Push em produção

O navegador só libera Push após ação consciente do usuário. O frontend envia a inscrição para `/api.php?action=push.subscribe`; o backend associa o endpoint à sessão autenticada. A chave privada VAPID fica somente no `.env` do servidor.

Para envio real, o worker usa `minishlink/web-push` e remove inscrições que retornarem HTTP 404/410. Nunca coloque `VAPID_PRIVATE_KEY` no frontend.

## Estrutura

```text
public/       interface PWA, manifest, service worker e API PHP
database/     schema MySQL
bin/          geração de chaves e worker de notificações
config/       configuração segura por ambiente
```

## Segurança operacional

- Use HTTPS, cookies Secure e um usuário MySQL sem permissões administrativas.
- Mantenha `.env` fora do controle de versão.
- Faça backup do banco e monitore `notification_logs`.
- Para iOS, explique ao usuário que Web Push funciona em versões compatíveis quando o PWA é adicionado à Tela de Início.
