# Desapegaí

Aplicativo mobile desenvolvido em **Flutter**, com o objetivo de facilitar a doação e a reutilização de itens usados, conectando pessoas interessadas em doar e receber objetos gratuitamente.

Projeto desenvolvido como Trabalho de Graduação do curso de Análise e Desenvolvimento de Sistemas da Fatec Itapetininga.

O Desapegaí é uma plataforma voltada exclusivamente a **doações gratuitas**. Não contempla venda de produtos, trocas ou intermediação de pagamentos.

## Status do desenvolvimento

O projeto está em desenvolvimento incremental. A autenticação, o gerenciamento de sessão e o gerenciamento de perfis estão integrados ao Firebase Authentication e ao Cloud Firestore.

O cadastro de publicações está implementado, incluindo armazenamento dos dados no Cloud Firestore, upload de imagens pelo Cloudinary e preenchimento da localização por GPS.

A tela inicial está integrada ao Firestore, exibindo publicações reais de outros usuários em tempo real. A listagem possui busca, filtros por categoria em ordem predefinida e imagens armazenadas no Cloudinary.

A tela de detalhes das publicações também está implementada, permitindo visualizar as informações completas do item, navegar pelas imagens e consultar os dados públicos do doador. A interface de demonstração de interesse está implementada visualmente, mas ainda não possui persistência no Firestore.

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
- Logout pelo método `signOut()` do Firebase Authentication.
- Retorno imediato à tela de Login após o encerramento da sessão.

O widget `AuthGate` observa o estado de autenticação e decide qual tela deve ser apresentada. Dessa forma, a exibição da tela de Login ou da Home depende da sessão do Firebase.

### 5. Tela inicial (Home)

A `HomeScreen` apresenta:

- Cabeçalho com identificação do Desapegaí.
- Saudação personalizada com o nome recuperado do perfil do usuário.
- Cidade informada no cadastro, carregada do Cloud Firestore.
- Indicador de carregamento e mensagens para falhas ou ausência do perfil.
- Campo de busca de publicações.
- Filtros por categoria na ordem: Todos, Roupas, Livros, Móveis, Calçados, Utensílios, Eletrônicos e Outros.
- Exibição dos filtros somente quando existe pelo menos uma publicação disponível na respectiva categoria.
- Listagem de publicações reais armazenadas no Cloud Firestore.
- Exibição do título, categoria, estado de conservação e cidade de cada publicação.
- Exibição da primeira imagem cadastrada na publicação.
- Abertura da tela de detalhes ao selecionar uma publicação.
- Quantidade de itens encontrados.
- Mensagens para listas vazias ou resultados que não correspondem à busca e aos filtros.

A listagem utiliza o método `acompanharPublicacoes()` do `PublicacaoControl`, que consulta os documentos da coleção `publicacoes` por meio de `snapshots()`. Dessa forma, novas publicações podem aparecer automaticamente na Home sem que o usuário precise reiniciar o aplicativo.

São exibidas somente publicações com status `ativa`, excluindo as publicações criadas pelo próprio usuário autenticado.

A busca é realizada sobre os dados recebidos do Firestore e considera título, descrição, categoria e cidade. Os filtros de categoria seguem uma ordem predefinida e são exibidos dinamicamente conforme as categorias presentes nas publicações disponíveis.

O filtro de distância exibido na interface ainda não possui cálculo geográfico implementado.

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
- Preenchimento da localização.
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

### 9. Tela de detalhes da publicação

A `DetalhesPublicacaoScreen` apresenta as informações completas de uma publicação selecionada na tela inicial.

Funcionalidades implementadas:

- Navegação da Home para a tela de detalhes ao selecionar um card.
- Galeria de imagens com navegação horizontal entre as fotos.
- Indicador da posição atual na galeria e da quantidade de imagens.
- Barra superior fixa com opção de voltar e botão de denúncia.
- Exibição do título, categoria, estado de conservação, cidade e descrição do item.
- Exibição do nome do doador.
- Seção com orientações de segurança para o usuário.
- Botão "Tenho interesse".
- Após demonstrar interesse, exibição das opções "Cancelar interesse" e "Conversar".

A tela recebe os dados da publicação selecionada, evitando a necessidade de realizar uma nova consulta ao Firestore para carregar as informações já disponíveis na Home.

A interação de demonstração de interesse está implementada apenas no estado local da interface. Ainda não existe registro do interesse no Firestore ou notificação ao doador.

O botão de denúncia está presente na interface, mas o fluxo de registro e gerenciamento de denúncias ainda será desenvolvido.

### 10. Navegação inferior

A aplicação apresenta cinco opções na navegação inferior:

- Início
- Minhas publicações
- Doar
- Mensagens
- Perfil

Atualmente, as telas e os fluxos de **Início**, **Doar** e **Perfil** estão implementados. As áreas de Minhas Publicações e Mensagens serão desenvolvidas em etapas posteriores.

## Autenticação e armazenamento

### Firebase Authentication

O Firebase Authentication é utilizado para criar contas, autenticar usuários, solicitar redefinição de senha e encerrar sessões.

O aplicativo observa o estado de autenticação por meio de `authStateChanges()`. Ao iniciar, o `AuthGate` apresenta a tela adequada conforme exista ou não um usuário autenticado.

### Cloud Firestore

O Cloud Firestore é utilizado para armazenar os dados dos usuários e das publicações.

#### Coleção `usuarios`

Após a criação da conta no Authentication, o aplicativo utiliza o UID gerado pelo Firebase para criar o perfil do usuário na coleção `usuarios`.

Cada documento utiliza o próprio UID como identificador e armazena os seguintes campos:

| Campo | Descrição |
|---|---|
| `uid` | Identificador único do usuário no Firebase Authentication |
| `nome` | Nome informado no cadastro |
| `email` | E-mail da conta |
| `cidade` | Cidade informada no cadastro |
| `sobreMim` | Descrição pessoal do usuário |

O `UsuarioControl` é responsável por consultar e atualizar os dados pessoais do usuário no Firestore.

#### Coleção `publicacoes`

Cada publicação é armazenada como um documento na coleção `publicacoes`.

Os principais campos são:

| Campo | Descrição |
|---|---|
| `usuarioId` | UID do usuário responsável pela publicação |
| `titulo` | Título do item |
| `descricao` | Descrição do item |
| `categoria` | Categoria selecionada |
| `estadoConservacao` | Estado de conservação informado |
| `cidade` | Cidade associada à publicação |
| `dataCriacao` | Data e horário de criação |
| `status` | Situação da publicação, inicialmente `ativa` |
| `imagens` | Lista de URLs das imagens armazenadas no Cloudinary |
| `nomeDoador` | Nome público do usuário responsável pela publicação |

O `PublicacaoControl` é responsável por cadastrar e consultar as publicações.

A Home utiliza uma consulta em tempo real com `snapshots()`, filtrando as publicações pelo status `ativa` e excluindo aquelas cujo `usuarioId` corresponde ao UID do usuário autenticado.

A consulta combinada utiliza um índice composto configurado no Cloud Firestore. Esse índice é necessário para executar os filtros utilizados na listagem da Home.

O campo `nomeDoador` armazena o nome público do usuário responsável pela publicação. Esse valor é obtido do perfil do usuário autenticado durante o cadastro e registrado diretamente no documento da publicação.

### Regras de segurança

O arquivo `firestore.rules` contém as regras de acesso às coleções `usuarios` e `publicacoes`.

As regras exigem autenticação para as operações permitidas e verificam a relação entre o usuário autenticado e o documento acessado.

Na coleção `publicacoes`, as regras controlam a criação, leitura, atualização e exclusão dos documentos, incluindo a verificação do UID do autor e o limite de até três imagens por publicação.

## Armazenamento de imagens

### Cloudinary

O Cloudinary é utilizado para armazenar e disponibilizar as imagens das publicações.

O aplicativo realiza o upload das imagens por meio de requisições HTTP multipart. Após o envio, o Cloudinary retorna uma URL segura, que é armazenada no documento correspondente no Firestore.

Validações implementadas no aplicativo:

- Limite de até 3 imagens por publicação.
- Tamanho máximo de 5 MB por imagem.
- Formatos permitidos: JPG, JPEG, PNG e WebP.
- Tratamento de falhas de conexão e tempo limite.
- Pré-visualização das imagens antes do cadastro.

O projeto utiliza um upload preset sem assinatura para o protótipo. Em uma versão de produção, recomenda-se implementar upload assinado por meio de um backend seguro e restringir as permissões de envio.

Não armazene chaves secretas do Cloudinary no aplicativo Flutter ou no repositório.

## Serviço de localização

O serviço `LocalizacaoService` utiliza o Geolocator para obter as coordenadas geográficas do dispositivo e o Geocoding para converter essas coordenadas em informações de localização.

A localização obtida é utilizada no preenchimento do campo correspondente durante o cadastro de publicações.

O aplicativo solicita as permissões de localização necessárias no Android.

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
│   │   ├── detalhes_publicacao_screen.dart
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
| Seleção de uma publicação na Home | `DetalhesPublicacaoScreen` |

A Home é apresentada pelo `AuthGate` quando o Firebase informa que existe um usuário autenticado.

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
- Configuração de um projeto Cloudinary compatível com o serviço de upload utilizado.

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
7. Criar os índices necessários para as consultas utilizadas pela aplicação.

O arquivo `lib/firebase_options.dart` contém as opções utilizadas para inicializar o Firebase. O arquivo `android/app/google-services.json` contém a configuração do aplicativo Android. O `firebase.json` referencia as configurações do FlutterFire e o arquivo de regras do Firestore.

Para publicar as regras com o Firebase CLI, após configurar o projeto correto, utilize:

```bash
firebase deploy --only firestore:rules
```

Os índices do Firestore podem ser criados pelo Firebase Console ou configurados no arquivo de índices do projeto, conforme a necessidade.

### Configuração do Cloudinary

O serviço `CloudinaryService`, localizado em `lib/services/cloudinary_service.dart`, contém as configurações utilizadas para realizar o upload das imagens.

Para utilizar outro ambiente Cloudinary, configure o nome da nuvem e o upload preset correspondente no serviço.

O projeto utiliza um upload preset sem assinatura no protótipo. Não inclua o API Secret no aplicativo Flutter, em arquivos versionados ou em commits.

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
- [x] Retorno imediato à tela de Login ao sair pela tela de perfil.
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
- [x] Validação dos campos obrigatórios no cadastro de publicações.
- [x] Obrigatoriedade de pelo menos uma imagem.
- [x] Seleção e pré-visualização de até três imagens.
- [x] Upload de imagens para o Cloudinary.
- [x] Armazenamento das URLs das imagens no Firestore.
- [x] Obtenção da localização por GPS.
- [x] Validação das regras de segurança para publicações.
- [x] Listagem de publicações reais na Home.
- [x] Exclusão das próprias publicações da listagem da Home.
- [x] Atualização automática da listagem após novas publicações.
- [x] Exibição das imagens das publicações nos cards.
- [x] Busca por título, descrição, categoria e cidade.
- [x] Filtros dinâmicos por categoria.
- [x] Ordenação das publicações mais recentes primeiro.
- [x] Tratamento de carregamento, erro e lista vazia na listagem.
- [x] Abertura da tela de detalhes a partir de uma publicação na Home.
- [x] Exibição das informações da publicação na tela de detalhes.
- [x] Navegação horizontal entre as imagens da galeria.
- [x] Exibição do nome do doador na publicação.
- [x] Exibição dos filtros de categoria na ordem predefinida.
- [x] Alteração visual dos botões após demonstrar interesse.

A análise estática com `flutter analyze` foi executada. Atualmente, não apresenta erros, mas ainda existem avisos e informações do analisador relacionados a imports, widgets e componentes que poderão ser revisados em uma etapa de manutenção do código.

## Funcionalidades pendentes

- [ ] Definição do fluxo para contas autenticadas sem documento de perfil no Firestore.
- [ ] Edição de publicações.
- [ ] Remoção de publicações e tratamento das imagens correspondentes no Cloudinary.
- [ ] Tela de Minhas Publicações.
- [ ] Implementação de filtro de distância com cálculo geográfico real.
- [ ] Histórico de doações.
- [ ] Ajuda e segurança.
- [ ] Avaliações.
- [ ] Painel administrativo.
- [ ] Testes de interface em diferentes dispositivos Android.
- [ ] Aprimoramentos de segurança para o upload de imagens, incluindo a migração para upload assinado por backend.
- [ ] Persistência dos interesses demonstrados no Cloud Firestore.
- [ ] Notificação ao doador quando alguém demonstrar interesse.
- [ ] Implementação do fluxo de conversas entre usuários.
- [ ] Implementação do registro e gerenciamento de denúncias.

## Próximas etapas

### Publicações e doações

- Implementar edição e remoção de publicações.
- Desenvolver a tela de Minhas Publicações.
- Implementar a persistência e o gerenciamento dos interesses demonstrados.
- Desenvolver o fluxo de conversas entre doadores e interessados.
- Implementar notificações relacionadas às publicações.

### Funcionalidades posteriores

- Implementar filtro de distância com cálculo geográfico.
- Desenvolver histórico e acompanhamento de doações.
- Implementar ajuda e segurança.
- Desenvolver avaliações, denúncias e bloqueio.
- Implementar o painel administrativo.
- Aprimorar a segurança da infraestrutura e do upload de imagens.

A ordem das etapas poderá ser ajustada conforme a evolução do desenvolvimento.

## Observações

O Desapegaí é uma plataforma voltada exclusivamente a doações gratuitas. Não estão previstas funcionalidades de venda, troca de produtos ou intermediação de pagamentos.