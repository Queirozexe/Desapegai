# Desapegaí

Aplicativo mobile desenvolvido em **Flutter**, com o objetivo de facilitar a doação e a reutilização de itens usados, conectando pessoas interessadas em doar e receber objetos gratuitamente.

Projeto desenvolvido como Trabalho de Graduação do curso de Análise e Desenvolvimento de Sistemas da Fatec Itapetininga.

O Desapegaí é uma plataforma voltada exclusivamente a **doações gratuitas**. Não contempla venda de produtos, trocas ou intermediação de pagamentos.

## Status do desenvolvimento

O projeto está em desenvolvimento incremental. A autenticação já está integrada ao Firebase e os perfis dos usuários são armazenados no Cloud Firestore. A tela inicial ainda utiliza publicações demonstrativas.

### Funcionalidades implementadas

- Cadastro de usuários com e-mail e senha.
- Validação dos dados obrigatórios do cadastro.
- Criação de contas pelo Firebase Authentication.
- Persistência do perfil do usuário no Cloud Firestore.
- Login com e-mail e senha pelo Firebase Authentication.
- Recuperação de senha por e-mail, com link enviado pelo Firebase.
- Exibição de mensagens de validação e de erros.
- Estados de carregamento durante as operações de autenticação.
- Tela inicial com publicações demonstrativas, busca e filtros por categoria.

### Funcionalidades em desenvolvimento ou planejadas

- Gerenciamento automático da sessão de autenticação.
- Redirecionamento inicial conforme o estado de autenticação.
- Logout integrado ao Firebase Authentication.
- Carregamento do perfil do usuário a partir do Firestore.
- Tratamento de perfis que ainda não possuam documento no banco.
- Detalhes e gerenciamento de publicações.
- Mensagens, notificações e demais funcionalidades sociais.

## Autenticação e armazenamento

### Firebase Authentication

O Firebase Authentication é utilizado para:

- Criar contas com e-mail e senha.
- Autenticar usuários cadastrados.
- Solicitar a redefinição de senha por e-mail.

O cadastro utiliza validação dos campos, tratamento de erros e indicação visual de carregamento. O login também verifica as credenciais diretamente no Firebase.

### Cloud Firestore

Após a criação da conta no Authentication, o aplicativo utiliza o UID gerado pelo Firebase para criar o perfil do usuário na coleção `usuarios`.

Cada documento utiliza o próprio UID como identificador e armazena os seguintes campos:

| Campo | Descrição |
|---|---|
| `uid` | Identificador único do usuário no Firebase Authentication |
| `nome` | Nome informado no cadastro |
| `email` | E-mail da conta |
| `cidade` | Cidade informada no cadastro |

As regras do Firestore restringem a criação e a consulta do documento ao usuário autenticado correspondente ao UID. A listagem geral e a exclusão de documentos não são permitidas pelas regras atuais.

### Conta para demonstração

O ambiente de desenvolvimento possui uma conta destinada a testes da aplicação:

- **E-mail:** `usuario@desapegai.com`
- **Senha:** `12345678`

Utilize essa conta somente para demonstrações e testes. Não utilize dados pessoais ou informações reais nessa conta.

## Tela inicial

A `HomeScreen` apresenta atualmente:

- Cabeçalho com identificação do Desapegaí.
- Localização demonstrativa em Itapetininga, SP.
- Campo de busca de itens.
- Filtros por categoria.
- Listagem de publicações demonstrativas.
- Informações sobre nome, categoria, estado de conservação e localização dos itens.
- Quantidade de resultados encontrados.
- Mensagem quando nenhum item corresponde aos filtros.

**Categorias disponíveis:**

- Todos
- Roupas
- Livros
- Móveis
- Utensílios
- Calçados
- Outros

Os itens exibidos na tela inicial são demonstrativos e ainda não são carregados do Firestore.

### Navegação inferior

A tela inicial apresenta cinco opções:

- Início
- Minhas publicações
- Doar
- Mensagens
- Perfil

Atualmente, a funcionalidade principal implementada é a tela **Início**. As demais opções serão desenvolvidas nas próximas etapas.

## Estrutura do projeto

```text
desapegai/
├── android/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── firebase_options.dart
│   ├── controller/
│   │   ├── cadastro_control.dart
│   │   ├── login_control.dart
│   │   └── recuperacao_senha_control.dart
│   ├── model/
│   │   └── usuario.dart
│   ├── screens/
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
├── test/
├── pubspec.yaml
└── README.md
```

O projeto mantém a separação entre telas (`screens`), controladores (`controller`), modelo de dados (`model`), tema (`theme`) e componentes reutilizáveis (`widgets`).

## Rotas

As rotas estão configuradas em `lib/app.dart`.

| Rota | Tela | Estado |
|---|---|---|
| `/` | Login | Integrada ao Firebase Authentication |
| `/cadastro` | Cadastro | Integrado ao Authentication e ao Firestore |
| `/recuperar-senha` | Recuperação de senha | Integrada ao Firebase Authentication |
| `/inicio` | Home | Implementada com dados demonstrativos |

O gerenciamento automático da sessão e o logout integrado ainda estão pendentes.

## Tecnologias

- **Flutter:** desenvolvimento da aplicação mobile.
- **Dart:** linguagem de programação.
- **Firebase Core:** inicialização do Firebase no aplicativo.
- **Firebase Authentication:** cadastro, login e recuperação de senha.
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
- Projeto Firebase configurado para o aplicativo.

### Instalação

Clone o repositório:

```bash
git clone URL_DO_REPOSITORIO
cd desapegai
```

Instale as dependências:

```bash
flutter pub get
```

Verifique os dispositivos disponíveis:

```bash
flutter devices
```

Execute no dispositivo Android:

```bash
flutter run
```

Para selecionar um dispositivo específico:

```bash
flutter run -d ID_DO_DISPOSITIVO
```

### Configuração do Firebase

O aplicativo depende de um projeto Firebase configurado. Para executar a aplicação em outro ambiente, é necessário:

1. Configurar o aplicativo Android no projeto Firebase.
2. Habilitar o provedor de autenticação por e-mail e senha.
3. Criar o banco Cloud Firestore.
4. Configurar as opções do Firebase para o aplicativo usando o FlutterFire CLI.
5. Publicar regras do Firestore compatíveis com a estrutura de usuários do projeto.

O arquivo `lib/firebase_options.dart` contém as opções utilizadas para inicializar o Firebase. As configurações específicas do Android também precisam corresponder ao projeto Firebase utilizado.

## Testes

Testes funcionais realizados durante o desenvolvimento:

- [x] Cadastro de usuário no Firebase Authentication.
- [x] Gravação do perfil do usuário no Cloud Firestore.
- [x] Associação do documento do Firestore ao UID do Authentication.
- [x] Login com credenciais válidas.
- [x] Tratamento de credenciais inválidas.
- [x] Solicitação de recuperação de senha.
- [x] Recebimento do e-mail e redefinição de senha.

Testes e funcionalidades ainda pendentes:

- [ ] Restauração automática da sessão ao abrir o aplicativo.
- [ ] Logout integrado ao Firebase Authentication.
- [ ] Carregamento e exibição dos dados do perfil.
- [ ] Cadastro e gerenciamento de publicações no banco.
- [ ] Busca e filtros utilizando dados persistidos.
- [ ] Testes de interface em diferentes dispositivos Android.

A análise estática com `flutter analyze` foi executada. Ainda existem avisos e informações do analisador relacionados a widgets e imports que serão revisados em uma etapa de manutenção do código.

## Próximas etapas

### Gerenciamento de sessão

- Observar o estado de autenticação com `authStateChanges()`.
- Direcionar o usuário para a tela adequada ao abrir o aplicativo.
- Implementar o logout pelo Firebase Authentication.
- Carregar o perfil correspondente ao usuário autenticado.

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
- Perfil e histórico.
- Avaliações.
- Denúncias e bloqueio.
- Painel administrativo.
- Integrações externas e melhorias de segurança.

A ordem das etapas poderá ser ajustada conforme a evolução do desenvolvimento.

## Observações

O Desapegaí é uma plataforma voltada exclusivamente a doações gratuitas. Não estão previstas funcionalidades de venda, troca de produtos ou intermediação de pagamentos.
