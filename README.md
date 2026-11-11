# Desapegaí

Aplicativo mobile desenvolvido em **Flutter**, com o objetivo de facilitar a doação e a reutilização de itens usados, conectando pessoas interessadas em doar e receber objetos gratuitamente.

Projeto desenvolvido como Trabalho de Graduação do curso de Análise e Desenvolvimento de Sistemas da Fatec Itapetininga.

## Status do desenvolvimento

**Etapa 2 — Autenticação demonstrativa e Tela Inicial**

O projeto está em desenvolvimento incremental. Atualmente, possui quatro telas:

- `LoginScreen` — Login com validação simples.
- `RegisterScreen` — Cadastro visual de usuários.
- `RecoverPasswordScreen` — Recuperação de senha demonstrativa.
- `HomeScreen` — Tela inicial com publicações e filtros.

Nesta etapa, não existe integração com banco de dados, API ou serviço externo.

## Funcionalidades implementadas

### 1. Login

- Campos de e-mail e senha.
- Validação de preenchimento e formato.
- Comparação com credenciais fixas.
- Exibição de mensagens de erro.
- Redirecionamento para a Tela Inicial após login válido.
- Navegação para Cadastro e Recuperação de Senha.

**Credenciais de teste:**

- E-mail: `usuario@desapegai.com`
- Senha: `12345678`

A autenticação é exclusivamente demonstrativa e não deve ser utilizada em produção.

### 2. Cadastro

- Campos de cadastro.
- Interface seguindo o protótipo do Desapegaí.
- Navegação para a tela de Login.
- Botão de cadastro demonstrativo.

Os dados ainda não são armazenados.

### 3. Recuperação de senha

- Campo de e-mail.
- Botão para solicitar recuperação.
- Mensagem informativa sobre a funcionalidade futura.
- Navegação de retorno ao Login.

O envio de e-mails e a redefinição real de senha ainda não foram implementados.

### 4. Tela Inicial (Home)

Funcionalidades disponíveis:

- Cabeçalho com identificação do Desapegaí.
- Localização demonstrativa em Itapetininga, SP.
- Campo de busca de itens.
- Filtros por categoria.
- Listagem de publicações demonstrativas.
- Informações sobre nome, categoria, estado de conservação e localização dos itens.
- Exibição da quantidade de resultados encontrados.
- Mensagem quando nenhum item corresponde aos filtros.
- Botão de logout que retorna ao Login.

**Categorias disponíveis:**

- Todos
- Roupas
- Livros
- Móveis
- Utensílios
- Calçados
- Outros

Os itens são armazenados temporariamente em uma lista definida no próprio código.

### 5. Navegação inferior

A Tela Inicial possui cinco opções:

- Início
- Minhas publicações
- Doar
- Mensagens
- Perfil

Atualmente, apenas a opção **Início** está implementada. As demais apresentam mensagens informando que serão desenvolvidas posteriormente.

## Estrutura do projeto

```text
desapegai/
├── android/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   │
│   ├── core/
│   │   ├── theme/
│   │   │   └── app_theme.dart
│   │   └── widgets/
│   │       └── auth_layout.dart
│   │
│   └── features/
│       ├── auth/
│       │   └── screens/
│       │       ├── login_screen.dart
│       │       ├── register_screen.dart
│       │       └── recover_password_screen.dart
│       │
│       └── home/
│           └── screens/
│               └── home_screen.dart
│
├── pubspec.yaml
└── README.md
```

## Rotas

| Rota | Tela | Estado |
|---|---|---|
| `/` | Login | Implementada |
| `/cadastro` | Cadastro | Interface implementada |
| `/recuperar-senha` | Recuperação | Interface implementada |
| `/inicio` | Home | Implementada com dados demonstrativos |

As rotas estão configuradas no arquivo `lib/app.dart`.

## Tecnologias

- **Flutter:** desenvolvimento da aplicação mobile.
- **Dart:** linguagem de programação.
- **Material Design 3:** componentes de interface.
- **Android Studio:** ambiente de desenvolvimento.
- **Git e GitHub:** versionamento do código.

O SQLite está previsto para uma etapa posterior.

## Executando o projeto

### Requisitos

- Flutter SDK instalado.
- Android Studio configurado.
- Android SDK instalado.
- Emulador Android ou dispositivo físico com depuração USB ativada.

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

Caso a pasta nativa `android/` não exista, execute:

```bash
flutter create --template=app --platforms=android --project-name=desapegai .
```

## Testes previstos para a Etapa 2

- [ ] Login com credenciais corretas.
- [ ] Login com credenciais incorretas.
- [ ] Validação de campos obrigatórios.
- [ ] Navegação para Cadastro.
- [ ] Navegação para Recuperação de Senha.
- [ ] Redirecionamento para a Home.
- [ ] Busca de itens pelo nome.
- [ ] Filtros por categoria.
- [ ] Exibição de resultados vazios.
- [ ] Logout e retorno ao Login.
- [ ] Verificação da interface em dispositivo Android.

Os testes devem ser marcados após execução e validação.

## Próximas etapas

### Etapa 3 — Detalhes do item

- Implementar a tela de detalhes conforme o protótipo.
- Exibir informações completas do item.
- Apresentar informações do doador.
- Preparar o botão para demonstrar interesse.

### Etapa 4 — Publicações

- Criar a tela de publicação.
- Implementar o gerenciamento de publicações.
- Adicionar edição e remoção de itens.

### Etapa 5 — Persistência local

- Integrar SQLite.
- Criar a tabela de usuários.
- Implementar cadastro e autenticação utilizando dados persistidos.
- Substituir os dados demonstrativos por registros locais.

### Etapas posteriores

- Gerenciamento de interessados.
- Acompanhamento de doações.
- Mensagens.
- Notificações.
- Perfil e histórico.
- Avaliações.
- Denúncias e bloqueio.
- Painel administrativo.
- Integrações externas e segurança.

A ordem poderá ser ajustada conforme a evolução do desenvolvimento.

## Observações

O Desapegaí é uma plataforma voltada exclusivamente a doações gratuitas.

Não estão previstas funcionalidades de venda de produtos ou intermediação de pagamentos.