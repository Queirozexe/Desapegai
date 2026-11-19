# Desapegaí

Aplicativo mobile desenvolvido em **Flutter**, com o objetivo de facilitar a doação e a reutilização de itens usados, conectando pessoas interessadas em doar e receber objetos gratuitamente.

Projeto desenvolvido como Trabalho de Graduação do curso de Análise e Desenvolvimento de Sistemas da Fatec Itapetininga.

O Desapegaí é uma plataforma voltada exclusivamente a **doações gratuitas**. Não contempla venda de produtos, trocas ou intermediação de pagamentos.

## Status do desenvolvimento

O projeto está em desenvolvimento incremental. A autenticação, o gerenciamento de sessão e o gerenciamento de perfis estão integrados ao Firebase Authentication e ao Cloud Firestore.

O cadastro de publicações também está implementado, com armazenamento dos dados no Cloud Firestore, upload de imagens pelo Cloudinary e preenchimento da localização por GPS.

A listagem de publicações na tela inicial ainda utiliza dados demonstrativos e será integrada ao Firestore em uma próxima etapa.

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
- Navegação para a tela de perfil pela barra de navegação inferior.

As publicações exibidas na Home ainda são mantidas em uma lista definida no próprio código; elas não são carregadas do Firestore.

### 6. Tela de perfil

A `ProfileScreen` permite visualizar os dados do usuário autenticado:

- Nome e iniciais do usuário.
- Cidade.
- E-mail da conta.
- Descrição pessoal.
- Área de estatísticas de doações, ainda sem dados reais.
- Opções de menu para histórico de doações, ajuda e segurança e painel administrativo.
- Opção de sair da conta.

A tela consulta os dados do usuário no Cloud Firestore por meio do `UsuarioControl`, utilizando o UID da conta autenticada.

### 7. Edição de perfil

A `EditProfileScreen` permite atualizar os dados pessoais do usuário:

- Edição do nome.
- Edição da cidade.
- Edição da descrição pessoal.
- Preenchimento inicial dos campos com os dados já cadastrados.
- Validação dos campos obrigatórios.
- Salvamento das alterações no Cloud Firestore.
- Atualização dos dados apresentados na tela de perfil.

O e-mail é exibido no perfil, mas não é editável por essa funcionalidade.

### 8. Cadastro de publicações

A `CadastroPublicacaoScreen` permite que usuários autenticados cadastrem itens para doação gratuita.

Funcionalidades implementadas:

- Cadastro de título e descrição do item.
- Seleção de categoria.
- Seleção do estado de conservação.
- Preenchimento manual da cidade e localização.
- Obtenção da localização atual por GPS.
- Seleção de até três imagens pela galeria.
- Obrigatoriedade de pelo menos uma imagem.
- Pré-visualização e remoção das imagens selecionadas.
- Validação dos campos obrigatórios.
- Upload das imagens para o Cloudinary.
- Armazenamento dos dados da publicação no Cloud Firestore.
- Associação da publicação ao UID do usuário autenticado.

Os estados de conservação disponíveis são:

- Novo.
- Seminovo.
- Bom estado.
- Estado razoável.
- Para Retirada de Peças / Com Defeito.

As imagens são armazenadas no Cloudinary, enquanto suas URLs são registradas no documento da publicação no Firestore.

### 9. Navegação inferior

A tela inicial apresenta cinco opções:

- Início.
- Minhas publicações.
- Doar.
- Mensagens.
- Perfil.

Atualmente, as opções **Início**, **Perfil** e **Doar** possuem telas ou fluxos implementados. As demais opções serão desenvolvidas em etapas posteriores.

## Autenticação e armazenamento

### Firebase Authentication

O Firebase Authentication é utilizado para criar contas, autenticar usuários, solicitar redefinição de senha e encerrar sessões.

O aplicativo observa o estado de autenticação por meio de `authStateChanges()`. Ao iniciar, o `AuthGate` apresenta a tela adequada conforme exista ou não um usuário autenticado.

### Cloud Firestore

O Cloud Firestore é utilizado para armazenar os dados dos usuários e as publicações cadastradas no aplicativo.

#### Usuários

Após a criação da conta no Authentication, o aplicativo utiliza o UID gerado pelo Firebase para criar o perfil do usuário na coleção `usuarios`.

A aplicação consulta e atualiza os dados por meio do `UsuarioControl`.

Cada documento utiliza o próprio UID como identificador e armazena os seguintes campos:

| Campo | Descrição |
|---|---|
| `uid` | Identificador único do usuário no Firebase Authentication |
| `nome` | Nome informado no cadastro |
| `email` | E-mail da conta |
| `cidade` | Cidade informada no cadastro |
| `sobreMim` | Descrição pessoal do usuário |

#### Publicações

As publicações são armazenadas na coleção `publicacoes` do Cloud Firestore.

Cada documento contém:

| Campo | Descrição |
|---|---|
| `usuarioId` | UID do usuário responsável pela publicação |
| `titulo` | Título do item |
| `descricao` | Descrição do item |
| `categoria` | Categoria selecionada |
| `estadoConservacao` | Estado de conservação do item |
| `cidade` | Localização informada |
| `dataCriacao` | Data e horário de criação |
| `status` | Situação da publicação |
| `imagens` | Lista de URLs das imagens armazenadas no Cloudinary |

O identificador do documento é gerado automaticamente pelo Firestore.

O `PublicacaoControl` é responsável pelo cadastro e pela consulta das publicações. O UID do responsável é obtido diretamente do Firebase Authentication.

As regras de segurança definidas em `firestore.rules` controlam a criação, leitura, atualização e exclusão dos documentos de publicações, restringindo as operações conforme a autenticação e a propriedade dos dados.

### Cloudinary

O Cloudinary é utilizado para armazenar e disponibilizar as imagens das publicações.

O aplicativo realiza o upload das imagens selecionadas pelo usuário e recebe as respectivas URLs. Essas URLs são armazenadas no documento da publicação no Cloud Firestore.

O limite atual é de três imagens por publicação, com tamanho máximo de 5 MB por arquivo.

### Localização

A localização pode ser preenchida manualmente ou obtida por meio do GPS do dispositivo.

O `LocalizacaoService` utiliza os recursos de geolocalização e geocodificação para obter as coordenadas do dispositivo e convertê-las em informações de endereço.

## Estrutura do projeto

```text
desapegai/
├── android/
│   └── app/
│       ├── src/
│       │   └── main/
│       │       └── AndroidManifest.xml
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
│   │   ├── usuario_control.dart
│   │   └── publicacao_control.dart
│   ├── model/
│   │   ├── usuario.dart
│   │   └── publicacao.dart
│   ├── screens/
│   │   ├── auth_gate.dart
│   │   ├── home_screen.dart
│   │   ├── login_screen.dart
│   │   ├── recover_password_screen.dart
│   │   ├── register_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── edit_profile_screen.dart
│   │   └── cadastro_publicacao_screen.dart
│   ├── services/
│   │   ├── cloudinary_service.dart
│   │   └── localizacao_service.dart
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
├── pubspec.lock
└── README.md
```

O projeto mantém a separação entre telas (`screens`), controladores (`controller`), modelos de dados (`model`), serviços (`services`), tema (`theme`) e componentes reutilizáveis (`widgets`).

## Navegação

O fluxo inicial é controlado pelo `AuthGate`, configurado como tela principal em `lib/app.dart`.

| Destino | Tela ou comportamento |
|---|---|
| Inicialização do aplicativo | `AuthGate` verifica o estado de autenticação |
| Sem sessão autenticada | `LoginScreen` |
| Com sessão autenticada | `HomeScreen` |
| `/cadastro` | `RegisterScreen` |
| `/recuperar-senha` | `RecoverPasswordScreen` |
| Opção Perfil na navegação inferior | `ProfileScreen` |
| Botão Editar perfil | `EditProfileScreen` |
| Opção Doar na navegação inferior | `CadastroPublicacaoScreen` |

A Home não depende de uma navegação manual para uma rota `/inicio`: ela é apresentada pelo `AuthGate` quando o Firebase informa que existe um usuário autenticado.

## Tecnologias

- **Flutter:** desenvolvimento da aplicação mobile.
- **Dart:** linguagem de programação.
- **Firebase Core:** inicialização do Firebase no aplicativo.
- **Firebase Authentication:** cadastro, login, recuperação de senha e gerenciamento de sessão.
- **Cloud Firestore:** armazenamento dos perfis dos usuários e das publicações.
- **Cloudinary:** armazenamento e disponibilização das imagens das publicações.
- **image_picker:** seleção de imagens pela galeria do dispositivo.
- **HTTP:** comunicação com a API do Cloudinary.
- **Geolocator:** obtenção da localização do dispositivo.
- **Geocoding:** conversão de coordenadas geográficas em informações de endereço.
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
- Configuração de uma conta e de um upload preset no Cloudinary.

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

### Configuração do Cloudinary

Para habilitar o envio de imagens, é necessário configurar uma conta no Cloudinary e criar um upload preset compatível com o aplicativo.

As configurações de Cloud Name e upload preset utilizadas pelo serviço devem corresponder às configurações da conta Cloudinary.

Não compartilhe chaves secretas ou credenciais privadas no repositório.

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
- [x] Carregamento do perfil do usuário autenticado pelo UID no Firestore.
- [x] Exibição do nome e da cidade do usuário na Home.
- [x] Tratamento de carregamento, falha de consulta e perfil inexistente sem interromper a Home.
- [x] Abertura da tela de perfil pela navegação inferior.
- [x] Exibição dos dados pessoais na tela de perfil.
- [x] Carregamento dos dados existentes nos campos de edição.
- [x] Validação dos campos obrigatórios na edição do perfil.
- [x] Atualização de nome, cidade e descrição pessoal no Firestore.
- [x] Persistência das alterações após logout e reinicialização do aplicativo.
- [x] Cadastro de publicações no Cloud Firestore.
- [x] Associação das publicações ao UID do usuário autenticado.
- [x] Validação dos campos obrigatórios.
- [x] Obrigatoriedade de pelo menos uma imagem.
- [x] Seleção e pré-visualização de até três imagens.
- [x] Upload de imagens para o Cloudinary.
- [x] Armazenamento das URLs das imagens no Firestore.
- [x] Obtenção da localização por GPS.
- [x] Validação das regras de segurança para publicações.

Funcionalidades ainda pendentes de implementação e teste:

- [ ] Listagem de publicações reais na tela inicial.
- [ ] Aplicação de busca e filtros sobre publicações do Firestore.
- [ ] Ocultar da Home as publicações criadas pelo próprio usuário.
- [ ] Tela de detalhes da publicação.
- [ ] Edição e remoção de publicações.
- [ ] Tela de Minhas Publicações.
- [ ] Testes de interface em diferentes dispositivos Android.
- [ ] Definição do fluxo para contas autenticadas sem documento de perfil no Firestore.

A análise estática com `flutter analyze` foi executada. Ainda existem avisos e informações do analisador relacionados a widgets, imports e componentes que serão revisados em uma etapa de manutenção do código. Atualmente, a análise não apresenta erros.

## Próximas etapas

### Publicações e doações

- Implementar a listagem de publicações reais na Home.
- Implementar busca e filtros utilizando dados do Firestore.
- Impedir que o usuário visualize suas próprias publicações na listagem principal.
- Implementar a tela de detalhes do item.
- Exibir informações completas do item e do doador.
- Implementar edição e remoção de publicações.
- Desenvolver a tela Minhas Publicações.

### Funcionalidades posteriores

- Gerenciamento de interessados.
- Acompanhamento de doações.
- Mensagens.
- Notificações.
- Histórico de doações.
- Ajuda e segurança.
- Avaliações.
- Denúncias e bloqueio.
- Painel administrativo.
- Integrações externas e melhorias de segurança.

A ordem das etapas poderá ser ajustada conforme a evolução do desenvolvimento.

## Observações

O Desapegaí é uma plataforma voltada exclusivamente a doações gratuitas. Não estão previstas funcionalidades de venda, troca de produtos ou intermediação de pagamentos.