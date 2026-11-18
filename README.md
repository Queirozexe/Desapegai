# Desapegaí

Aplicativo mobile desenvolvido em **Flutter**, com o objetivo de facilitar a doação e a reutilização de itens usados, conectando pessoas interessadas em doar e receber objetos gratuitamente.

Projeto desenvolvido como Trabalho de Graduação do curso de Análise e Desenvolvimento de Sistemas da Fatec Itapetininga.

O Desapegaí é uma plataforma voltada exclusivamente a **doações gratuitas**. Não contempla venda de produtos, trocas ou intermediação de pagamentos.

## Status do desenvolvimento

O projeto está em desenvolvimento incremental. A autenticação e o gerenciamento de sessão estão integrados ao Firebase. Os perfis dos usuários são armazenados no Cloud Firestore, enquanto as publicações exibidas na tela inicial ainda são demonstrativas.

## Funcionalidades implementadas

### 1. Cadastro de usuários

- Cadastro com nome, e-mail, cidade e senha.
- Validação dos campos obrigatórios e do formato do e-mail.
- Criação de contas pelo Firebase Authentication.
- Criação do perfil do usuário no Cloud Firestore após o cadastro.
- Exibição de mensagens de validação e de erros.
- Indicador de carregamento durante a operação.

### 2. Login

- Autenticação com e-mail e senha pelo Firebase Authentication.
- Validação dos campos de e-mail e senha.
- Tratamento de erros de autenticação.
- Indicador de carregamento durante o login.

### 3. Recuperação de senha

- Validação do e-mail informado.
- Solicitação de redefinição de senha pelo Firebase Authentication.
- Envio de link de recuperação por e-mail.
- Tratamento de erros e apresentação de mensagens ao usuário.

### 4. Gerenciamento de sessão

- Monitoramento do estado de autenticação com `authStateChanges()`.
- Verificação automática da sessão ao abrir o aplicativo.
- Exibição da tela de Login quando não há usuário autenticado.
- Exibição da Home quando existe uma sessão válida.
- Restauração da sessão após fechar e abrir novamente o aplicativo.
- Logout real pelo método `signOut()` do Firebase Authentication.

O widget `AuthGate` observa o estado de autenticação e decide qual tela deve ser apresentada. Dessa forma, o login e o logout não dependem de navegação manual entre Login e Home.

### 5. Tela inicial (Home)

A `HomeScreen` apresenta atualmente:

- Cabeçalho com identificação do Desapegaí.
- Saudação personalizada com o nome recuperado do perfil do usuário.
- Cidade informada no cadastro, carregada do Cloud Firestore.
- Indicador de carregamento e mensagens para falhas ou ausência do perfil.
- Campo de busca de itens.
- Filtros por categoria.
- Listagem de publicações demonstrativas.
- Informações sobre nome, categoria, estado de conservação e localização dos itens.
- Quantidade de resultados encontrados.
- Mensagem quando nenhum item corresponde aos filtros.
- Botão de logout integrado ao Firebase Authentication.

As publicações exibidas na Home ainda são mantidas em uma lista definida no próprio código; elas não são carregadas do Firestore.

### 6. Navegação inferior

A tela inicial apresenta cinco opções:

- Início
- Minhas publicações
- Doar
- Mensagens
- Perfil

Atualmente, a opção **Início** está implementada. As demais opções serão desenvolvidas em etapas posteriores.

## Autenticação e armazenamento

### Firebase Authentication

O Firebase Authentication é utilizado para criar contas, autenticar usuários, solicitar redefinição de senha e encerrar sessões.

O aplicativo observa o estado de autenticação por meio de `authStateChanges()`. Ao iniciar, o `AuthGate` apresenta a tela adequada conforme exista ou não um usuário autenticado.

### Cloud Firestore

Após a criação da conta no Authentication, o aplicativo utiliza o UID gerado pelo Firebase para criar o perfil do usuário na coleção `usuarios`.

A aplicação também consulta o documento correspondente ao UID do usuário autenticado por meio do `UsuarioControl`. Os dados encontrados são convertidos para o modelo `Usuario` e utilizados na Home para apresentar o nome e a cidade. Se o documento não existir, a consulta retorna `null` e a interface apresenta uma mensagem alternativa, sem interromper a Home. Falhas na consulta são tratadas separadamente pela interface.

Cada documento utiliza o próprio UID como identificador e armazena os seguintes campos:

| Campo | Descrição |
|---|---|
| `uid` | Identificador único do usuário no Firebase Authentication |
| `nome` | Nome informado no cadastro |
| `email` | E-mail da conta |
| `cidade` | Cidade informada no cadastro |

As regras versionadas em `firestore.rules` restringem a criação, consulta e atualização do documento ao usuário autenticado correspondente ao UID. A listagem geral e a exclusão de documentos não são permitidas pelas regras atuais.

### Conta para demonstração

O ambiente de desenvolvimento possui uma conta destinada a testes da aplicação:

- **E-mail:** `usuario@desapegai.com`
- **Senha:** `12345678`

Utilize essa conta somente para demonstrações e testes. Não utilize dados pessoais ou informações reais nessa conta. As contas dos integrantes da equipe não são documentadas neste README.

## Estrutura do projeto

```text
desapegai/
├── android/
│   └── app/
│       └── google-services.json
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── firebase_options.dart
│   ├── controller/
│   │   ├── cadastro_control.dart
│   │   ├── login_control.dart
│   │   ├── recuperacao_senha_control.dart
│   │   ├── sessao_control.dart
│   │   └── usuario_control.dart
│   ├── model/
│   │   └── usuario.dart
│   ├── screens/
│   │   ├── auth_gate.dart
│   │   ├── home_screen.dart
│   │   ├── login_screen.dart
│   │   ├── recover_password_screen.dart
│   │   └── register_screen.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── widgets/
│       ├── auth_layout.dart
│       ├── botoes.dart
│       ├── imagens.dart
│       ├── input.dart
│       └── texto.dart
├── firebase.json
├── firestore.rules
├── pubspec.yaml
└── README.md
```

O projeto mantém a separação entre telas (`screens`), controladores (`controller`), modelo de dados (`model`), tema (`theme`) e componentes reutilizáveis (`widgets`).

## Navegação

O fluxo inicial é controlado pelo `AuthGate`, configurado como tela principal em `lib/app.dart`.

| Destino | Tela ou comportamento |
|---|---|
| Inicialização do aplicativo | `AuthGate` verifica o estado de autenticação |
| Sem sessão autenticada | `LoginScreen` |
| Com sessão autenticada | `HomeScreen` |
| `/cadastro` | `RegisterScreen` |
| `/recuperar-senha` | `RecoverPasswordScreen` |

A Home não depende de uma navegação manual para uma rota `/inicio`: ela é apresentada pelo `AuthGate` quando o Firebase informa que existe um usuário autenticado.

## Tecnologias

- **Flutter:** desenvolvimento da aplicação mobile.
- **Dart:** linguagem de programação.
- **Firebase Core:** inicialização do Firebase no aplicativo.
- **Firebase Authentication:** cadastro, login, recuperação de senha e gerenciamento de sessão.
- **Cloud Firestore:** armazenamento dos perfis dos usuários.
- **Material Design:** componentes de interface.
- **Android Studio:** ambiente de desenvolvimento e execução Android.
- **Git e GitHub:** versionamento do código.

## Executando o projeto

### Requisitos

- Flutter SDK instalado.
- Android Studio configurado.
- Android SDK instalado.
- Emulador Android ou dispositivo físico com depuração USB ativada.
- Acesso ao projeto Firebase configurado para o aplicativo.

### Instalação

Clone o repositório:

```bash
git clone https://github.com/Queirozexe/Desapegai.git
cd Desapegai
```

Instale as dependências:

```bash
flutter pub get
```

Verifique os dispositivos disponíveis:

```bash
flutter devices
```

Execute o aplicativo:

```bash
flutter run
```

Para selecionar um dispositivo específico:

```bash
flutter run -d ID_DO_DISPOSITIVO
```

### Configuração do Firebase

O aplicativo depende de um projeto Firebase configurado. Para utilizar outro projeto Firebase, é necessário:

1. Registrar o aplicativo Android no projeto Firebase.
2. Habilitar o provedor de autenticação por e-mail e senha.
3. Criar o banco Cloud Firestore.
4. Gerar as opções do Firebase para o Flutter usando o FlutterFire CLI.
5. Atualizar os arquivos de configuração correspondentes ao projeto.
6. Publicar as regras de segurança definidas em `firestore.rules`.

O arquivo `lib/firebase_options.dart` contém as opções utilizadas para inicializar o Firebase. O arquivo `android/app/google-services.json` contém a configuração do aplicativo Android. O `firebase.json` referencia as configurações do FlutterFire e o arquivo de regras do Firestore.

Para publicar as regras com o Firebase CLI, após configurar o projeto correto, utilize:

```bash
firebase deploy --only firestore:rules
```

## Testes

Testes funcionais realizados durante o desenvolvimento:

- [x] Cadastro de usuário no Firebase Authentication.
- [x] Gravação do perfil do usuário no Cloud Firestore.
- [x] Associação do documento do Firestore ao UID do Authentication.
- [x] Login com credenciais válidas.
- [x] Tratamento de credenciais inválidas.
- [x] Solicitação de recuperação de senha.
- [x] Recebimento do e-mail e redefinição de senha.
- [x] Verificação automática do estado de autenticação.
- [x] Redirecionamento para Login ou Home conforme a sessão.
- [x] Logout integrado ao Firebase Authentication.
- [x] Restauração da sessão após fechar e abrir o aplicativo.

Funcionalidades ainda pendentes de implementação e teste:

- [x] Carregamento do perfil do usuário autenticado pelo UID no Firestore.
- [x] Exibição do nome e da cidade do usuário na Home.
- [x] Tratamento de carregamento, falha de consulta e perfil inexistente sem interromper a Home.
- [ ] Definição do fluxo para contas autenticadas sem documento de perfil no Firestore.
- [ ] Cadastro e gerenciamento de publicações no banco.
- [ ] Busca e filtros utilizando dados persistidos.
- [ ] Testes de interface em diferentes dispositivos Android.

A análise estática com `flutter analyze` foi executada. Ainda existem avisos e informações do analisador relacionados a widgets, imports e componentes que serão revisados em uma etapa de manutenção do código. Atualmente, a análise não apresenta erros.

## Próximas etapas

### Perfil do usuário

- Criar a tela de Perfil para visualizar nome, e-mail e cidade.
- Implementar a edição dos dados pessoais.
- Salvar as alterações do perfil no Cloud Firestore.
- Definir o fluxo para usuários autenticados sem documento de perfil, quando necessário.

### Publicações e doações

- Implementar a tela de detalhes do item.
- Exibir informações completas do item e do doador.
- Criar e gerenciar publicações.
- Implementar edição e remoção de publicações.
- Persistir as publicações no Cloud Firestore.

### Funcionalidades posteriores

- Minhas publicações.
- Gerenciamento de interessados.
- Acompanhamento de doações.
- Mensagens.
- Notificações.
- Histórico.
- Avaliações.
- Denúncias e bloqueio.
- Painel administrativo.
- Integrações externas e melhorias de segurança.

A ordem das etapas poderá ser ajustada conforme a evolução do desenvolvimento.

## Observações

O Desapegaí é uma plataforma voltada exclusivamente a doações gratuitas. Não estão previstas funcionalidades de venda, troca de produtos ou intermediação de pagamentos.
