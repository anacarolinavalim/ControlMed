# MedControl PWA

### Seu tratamento organizado. Seus medicamentos sob controle.

O **MedControl** é um aplicativo PWA (Progressive Web App) desenvolvido para facilitar o gerenciamento de medicamentos, tratamentos, estoque, despesas e lembretes de horários.

Com uma interface responsiva e pensada para dispositivos móveis, a plataforma permite acompanhar tratamentos, registrar doses, controlar reposições e receber notificações personalizadas.

Uma solução para tornar o cuidado diário mais organizado, acessível e prático.

---

## Visão geral

O MedControl reúne funcionalidades essenciais para o gerenciamento de medicamentos em uma única plataforma.

**O que você pode fazer:**

- Organizar medicamentos e tratamentos.
- Acompanhar horários e próximas doses.
- Registrar medicamentos administrados ou esquecidos.
- Controlar estoque e validade.
- Registrar compras e reposições.
- Monitorar gastos com medicamentos.
- Receber lembretes por notificações Push.
- Gerenciar dispositivos e preferências de notificação.
- Administrar usuários e enviar comunicados.

---

## Funcionalidades

### 01. Dashboard inteligente

Tenha uma visão geral da sua rotina de medicamentos.

- Resumo dos tratamentos ativos.
- Próximos horários de administração.
- Medicamentos cadastrados.
- Alertas de estoque baixo.
- Informações sobre validade.
- Resumo de despesas.

### 02. Gestão de medicamentos

Cadastre e organize os medicamentos utilizados.

- Nome e identificação do medicamento.
- Dosagem e quantidade por administração.
- Horários e frequência.
- Data de início e término do tratamento.
- Controle de validade.
- Quantidade disponível em estoque.
- Preço e farmácia de compra.

### 03. Registro de doses

Acompanhe a administração dos medicamentos.

- Registro de doses administradas.
- Registro de doses esquecidas.
- Histórico de administração.
- Acompanhamento dos horários.
- Baixa automática do estoque somente após confirmação da administração.

### 04. Controle de estoque

Gerencie a disponibilidade dos medicamentos.

- Consulta de estoque atual.
- Registro de compras e reposições.
- Histórico de movimentações.
- Controle de validade.
- Identificação de estoque baixo.
- Atualização do saldo após movimentações.

### 05. Controle financeiro

Acompanhe os gastos relacionados aos medicamentos.

- Registro de compras.
- Histórico de despesas.
- Identificação de farmácias.
- Acompanhamento dos valores gastos.
- Organização das movimentações financeiras.

### 06. Notificações inteligentes

Receba lembretes e comunicados diretamente no dispositivo.

- Notificações de horários de medicamentos.
- Lembretes personalizados.
- Preferências individuais por usuário.
- Suporte a múltiplos dispositivos.
- Inscrições Web Push com VAPID.
- Fila persistente de notificações.
- Registro de envios e falhas.

### 07. Painel administrativo

Uma área dedicada ao gerenciamento da plataforma.

- Administração de usuários.
- Controle de permissões.
- Envio de comunicados.
- Notificações imediatas.
- Notificações agendadas.
- Acompanhamento dos registros de notificações.

---

## Experiência PWA

O MedControl foi desenvolvido como Progressive Web App, permitindo uma experiência semelhante à de um aplicativo instalado.

**Recursos disponíveis:**

- Interface mobile-first.
- Instalação na tela inicial.
- Web App Manifest.
- Service Worker.
- Notificações Web Push.
- Suporte a múltiplos dispositivos.
- Experiência responsiva em diferentes tamanhos de tela.

**Compatibilidade com iOS:** em versões compatíveis, o Web Push funciona quando o usuário adiciona o PWA à Tela de Início e concede permissão para notificações.

---

## Tecnologias utilizadas

| Tecnologia | Aplicação |
|---|---|
| PHP 8.2+ | Backend e regras de negócio |
| MariaDB 10.4+ | Banco de dados |
| MySQL / PDO | Comunicação com o banco |
| HTML5 | Estrutura da interface |
| CSS3 | Estilização responsiva |
| JavaScript | Interatividade |
| PWA | Instalação e experiência mobile |
| Service Worker | Recursos do aplicativo |
| Web Push / VAPID | Notificações |
| Minishlink Web Push | Envio de notificações pelo servidor |
| Composer | Gerenciamento de dependências |

**Arquitetura:** aplicação PHP com PDO, banco relacional e separação entre interface, API, configuração e processamento de notificações.

**Compatibilidade importante:** o projeto utiliza MariaDB 10.4+ ou MySQL compatível. No PHP, a conexão PDO deve utilizar o DSN `mysql:` mesmo quando o servidor de banco de dados for MariaDB.

---

## Segurança

A aplicação possui mecanismos de proteção para usuários, sessões e operações.

- Autenticação por sessão.
- Proteção CSRF.
- Consultas parametrizadas com PDO.
- Controle de autorização por perfil.
- Preferências de notificação individuais.
- Associação das inscrições Push à sessão autenticada.
- Chaves privadas VAPID protegidas no servidor.
- Configuração por variáveis de ambiente.

---

## Estrutura do projeto

```text
MedControl/
│
├── public/
│   ├── assets/
│   ├── manifest.json
│   ├── service-worker.js
│   ├── api.php
│   └── index.php
│
├── database/
│   └── schema.sql
│
├── bin/
│   ├── generate-vapid.php
│   └── worker.php
│
├── config/
│   └── configuração do ambiente
│
├── .env.example
├── composer.json
└── README.md
```

---

## Instalação

### Pré-requisitos

- PHP 8.2 ou superior.
- MariaDB 10.4+ ou MySQL compatível.
- Extensão PDO MySQL.
- Composer.
- Servidor Apache ou Nginx.
- HTTPS para notificações Push em produção.

### 1. Criar o banco de dados

Crie um banco MariaDB:

```sql
CREATE DATABASE medcontrol
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
```

Importe a estrutura:

```bash
mysql -u root -p medcontrol < database/schema.sql
```

### 2. Configurar o ambiente

Copie o arquivo de exemplo:

```bash
cp .env.example .env
```

Configure as credenciais do banco de dados e as demais variáveis necessárias.

### 3. Instalar dependências

Na raiz do projeto:

```bash
composer install
```

### 4. Gerar as chaves VAPID

Execute:

```bash
php bin/generate-vapid.php
```

Copie as chaves geradas para o arquivo `.env`.

A chave pública será utilizada pelo frontend. A chave privada deverá permanecer exclusivamente no servidor.

### 5. Configurar o servidor

Configure o document root para:

```text
MedControl/public/
```

A aplicação deve ser disponibilizada por HTTPS em produção.

O endereço `localhost` é permitido para desenvolvimento.

### 6. Configurar o worker

Execute o processador de notificações:

```bash
php bin/worker.php
```

Configure sua execução periódica por cron ou por um gerenciador de processos.

Exemplo com cron:

```cron
* * * * * cd /caminho/MedControl && php bin/worker.php
```

---

## Primeiro acesso

O projeto não cria um usuário fictício automaticamente.

Cadastre o primeiro usuário pela tela de acesso.

Para promovê-lo a administrador, utilize o banco de dados em um ambiente controlado:

```sql
UPDATE users
SET role = 'admin'
WHERE email = 'seu-email@exemplo.com';
```

Substitua o e-mail pelo endereço cadastrado.

---

## Configuração de notificações Push

O funcionamento das notificações depende da permissão concedida pelo usuário no navegador.

O processo ocorre da seguinte maneira:

1. O usuário acessa a aplicação autenticado.
2. Autoriza o recebimento de notificações.
3. O navegador gera uma inscrição Push.
4. O frontend envia os dados para a API.
5. O backend associa a inscrição ao usuário autenticado.
6. O worker processa a fila e realiza os envios.
7. Os resultados são registrados no sistema.

Endpoint de inscrição:

```text
/api.php?action=push.subscribe
```

**Importante:**

- Nunca disponibilize `VAPID_PRIVATE_KEY` no frontend.
- Utilize HTTPS.
- Respeite as permissões de notificação.
- Inscrições inválidas com respostas HTTP 404 ou 410 são removidas pelo worker.
- Monitore os registros em `notification_logs`.

---

## Segurança operacional

Antes de disponibilizar o MedControl em produção:

- Utilize HTTPS.
- Configure cookies Secure.
- Mantenha o arquivo `.env` fora do controle de versão.
- Utilize um usuário MySQL sem privilégios administrativos.
- Proteja as chaves privadas VAPID.
- Configure backups automáticos.
- Monitore a tabela `notification_logs`.
- Implemente políticas adequadas de retenção e exclusão de dados.
- Restrinja o acesso administrativo.
- Teste o envio de notificações em dispositivos reais.

---

## Roadmap

Possíveis evoluções para o MedControl:

- [ ] Relatórios avançados de tratamentos.
- [ ] Histórico exportável em PDF.
- [ ] Relatórios financeiros mensais.
- [ ] Compartilhamento autorizado de acompanhamento.
- [ ] Melhorias na experiência offline.
- [ ] Histórico de notificações por dispositivo.
- [ ] Personalização de lembretes.
- [ ] Indicadores de adesão aos tratamentos.

---

## Sobre o projeto

O **MedControl** nasceu com o objetivo de simplificar a organização da rotina de medicamentos, reunindo controle de tratamentos, estoque, despesas e notificações em uma única plataforma.

A proposta é transformar tarefas que normalmente ficam espalhadas entre anotações, alarmes e planilhas em uma experiência digital centralizada e acessível.

**MedControl — Mais organização para cuidar melhor.**

---

<sub>Desenvolvido com PHP, MariaDB, JavaScript, PWA e Web Push com VAPID.</sub>
