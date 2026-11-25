# Desapegaí

Aplicativo mobile desenvolvido em **Flutter**, com o objetivo de facilitar a doação e a reutilização de itens usados, conectando pessoas interessadas em doar e receber objetos gratuitamente.

Projeto desenvolvido como Trabalho de Graduação do curso de Análise e Desenvolvimento de Sistemas da Fatec Itapetininga.

O Desapegaí é uma plataforma voltada exclusivamente a **doações gratuitas**. Não contempla venda de produtos, trocas ou intermediação de pagamentos.

## Status do desenvolvimento

O projeto está em desenvolvimento incremental. A autenticação, o gerenciamento de sessão e o gerenciamento de perfis estão integrados ao Firebase Authentication e ao Cloud Firestore.

O aplicativo possui recuperação de perfis ausentes. Quando um usuário autenticado não possui um documento correspondente no Firestore, o sistema apresenta uma tela para completar os dados do perfil antes de liberar o acesso à Home.

As regras de segurança dos perfis restringem as operações ao próprio usuário autenticado, protegendo os campos de identificação e permitindo a atualização somente das informações pessoais autorizadas.

O cadastro, a edição e a remoção de publicações estão implementados. O aplicativo permite cadastrar itens para doação gratuita, armazenar suas informações no Firestore e enviar imagens ao Cloudinary.

A tela inicial está integrada ao Firestore, exibindo publicações disponíveis em tempo real. A listagem possui busca, filtros por categoria e distância geográfica, além de imagens armazenadas no Cloudinary.

A tela de detalhes permite visualizar as informações completas de uma publicação, navegar pelas imagens, consultar os dados públicos do doador e demonstrar ou cancelar interesse. Ao demonstrar interesse, o usuário pode enviar uma mensagem personalizada e iniciar uma conversa com o doador.

A tela **Minhas publicações** permite acompanhar as publicações cadastradas, filtrar por situação, editar e remover itens e acessar o gerenciamento dos interessados.

A tela **Interessados** apresenta as pessoas interessadas, incluindo nome, cidade, data e mensagem enviada. O doador pode escolher um interessado, desfazer a escolha e concluir a doação.

O gerenciamento dos estados da publicação está implementado, incluindo as situações disponível, em andamento e concluída, com possibilidade de reabrir uma doação concluída.

O histórico de doações está implementado. A tela permite consultar separadamente as doações feitas e as doações recebidas pelo usuário autenticado. Cada conclusão gera um registro na coleção `doacoes` do Cloud Firestore, preservando informações da publicação, do doador, do beneficiário e da data de conclusão. Quando uma doação é reaberta, o registro correspondente recebe o status `reaberta`, mantendo o histórico da conclusão desfeita. Caso a doação seja concluída novamente, um novo registro é criado, sem sobrescrever o anterior.

A tela também apresenta o botão "Avaliar" nas doações concluídas. Por enquanto, o botão está implementado somente na parte visual, sem funcionalidade de avaliação.

A comunicação entre usuários está implementada. Cada pessoa interessada pode conversar individualmente com o doador da publicação, independentemente de ter sido escolhida para receber a doação. As conversas são armazenadas no Cloud Firestore, com envio e recebimento de mensagens em tempo real.

A tela Mensagens apresenta as conversas do usuário autenticado, incluindo o nome do outro participante, a publicação relacionada e a prévia da última mensagem.

O sistema de denúncias está implementado. Os usuários podem denunciar publicações e também denunciar outros participantes de uma conversa, permitindo que tanto o doador quanto o interessado realizem denúncias. Os registros são armazenados no Cloud Firestore para futura análise administrativa.

O sistema de notificações está implementado. O aplicativo gera notificações internas para eventos relacionados a interesses, escolha de beneficiários, conclusão e reabertura de doações e envio de mensagens. As notificações são armazenadas no Cloud Firestore, vinculadas ao usuário destinatário, e atualizadas em tempo real. A Home apresenta um indicador da quantidade de notificações não lidas, e o usuário pode acessar a tela de notificações, visualizar os registros e marcá-los como lidos.

A tela **Ajuda e segurança** está implementada e pode ser acessada pela opção correspondente no perfil. Ela apresenta o processo de doação em quatro passos e perguntas frequentes com orientações sobre o funcionamento das doações, cuidados durante as conversas, retirada segura, transporte, denúncias e privacidade. Também apresenta orientações sobre como denunciar e bloquear participantes.

O bloqueio de usuários está implementado. A funcionalidade permite bloquear e desbloquear participantes pelo diálogo de denúncia, consultar a lista de usuários bloqueados no perfil e ocultar publicações e desativar mensagens entre contas bloqueadas, preservando o histórico das conversas.

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
- Exibição da Home quando existe uma sessão válida e o perfil correspondente está disponível no Firestore.
- Restauração da sessão após fechar e abrir novamente o aplicativo.
- Logout pelo método `signOut()` do Firebase Authentication.
- Retorno imediato à tela de Login após o encerramento da sessão.

O widget `AuthGate` observa o estado de autenticação e decide qual tela deve ser apresentada. Dessa forma, a exibição da tela de Login ou da Home depende da sessão do Firebase.

Quando existe uma sessão autenticada, o `AuthGate` também verifica a existência do perfil correspondente no Cloud Firestore. Caso o documento não exista, o aplicativo apresenta a `CompletarPerfilScreen`, permitindo que o usuário informe seu nome e cidade.

O e-mail é recuperado diretamente do Firebase Authentication. Após o preenchimento, o documento é criado sem sobrescrever um perfil existente, utilizando uma transação do Firestore. Somente após a confirmação da criação o usuário é direcionado à Home.

Falhas na consulta do perfil são tratadas separadamente da ausência do documento, permitindo uma nova tentativa sem direcionar incorretamente o usuário para a recuperação.

### 5. Tela inicial (Home)

A `HomeScreen` apresenta:

- Cabeçalho com identificação do Desapegaí.
- Saudação personalizada com o nome recuperado do perfil do usuário.
- Cidade informada no cadastro, carregada do Cloud Firestore.
- Indicador de carregamento e tratamento de falhas na consulta do perfil.
- Campo de busca de publicações.
- Painel de filtros de distância acessível pelo ícone de ajustes ao lado da pesquisa.
- Opções de distância máxima: 5, 10, 25 e 50 km, além da opção Qualquer.
- Filtros por categoria na ordem: Todos, Roupas, Livros, Móveis, Calçados, Utensílios, Eletrônicos e Outros.
- Exibição dos filtros de categoria somente quando existe pelo menos uma publicação disponível na respectiva categoria.
- Listagem de publicações reais armazenadas no Cloud Firestore.
- Exibição do título, categoria, estado de conservação e cidade de cada publicação.
- Exibição da primeira imagem cadastrada na publicação.
- Abertura da tela de detalhes ao selecionar uma publicação.
- Quantidade de itens encontrados.
- Mensagens para listas vazias ou resultados que não correspondem à busca e aos filtros.

A listagem utiliza o método `acompanharPublicacoes()` do `PublicacaoControl`, que consulta os documentos da coleção `publicacoes` por meio de `snapshots()`. Dessa forma, novas publicações podem aparecer automaticamente na Home sem que o usuário precise reiniciar o aplicativo.

São exibidas somente publicações com status `ativa`, excluindo as publicações criadas pelo próprio usuário autenticado.

A busca é realizada sobre os dados recebidos do Firestore e considera título, descrição, categoria e cidade. Os filtros de categoria seguem uma ordem predefinida e são exibidos dinamicamente conforme as categorias presentes nas publicações disponíveis.

O filtro de distância utiliza a localização atual do dispositivo, obtida pelo `LocalizacaoService`, e calcula a distância entre o usuário e as coordenadas de cada publicação por meio do método `Geolocator.distanceBetween`.

Como as coordenadas das publicações são armazenadas com duas casas decimais, as distâncias calculadas são estimativas e podem apresentar diferenças de algumas centenas de metros em relação à distância real, especialmente quando a publicação está próxima do limite selecionado.

As opções de distância máxima são 5, 10, 25 e 50 km. A opção `Qualquer` desativa o filtro geográfico e permite visualizar todas as publicações disponíveis, inclusive aquelas que não possuem coordenadas cadastradas.

O filtro de distância é combinado com a pesquisa por texto e a categoria selecionada. Quando uma distância específica está ativa, publicações sem coordenadas não são exibidas, pois não é possível calcular sua distância geográfica.

A localização atual do usuário é mantida somente em memória durante a utilização do filtro, sem ser armazenada no Cloud Firestore.

### 6. Tela de perfil

A `ProfileScreen` permite visualizar os dados do usuário autenticado:

- Nome e iniciais do usuário.
- Cidade.
- E-mail da conta.
- Descrição pessoal.
- Área de estatísticas de doações, ainda sem dados reais.
- Opções de menu para histórico de doações, ajuda e segurança e painel administrativo.
- Opção de sair da conta.
- Lista de usuários bloqueados, exibida quando há usuários bloqueados, com opção de desbloqueio.

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
- Armazenamento de coordenadas geográficas aproximadas para utilização no filtro de distância.
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

A `DetalhesPublicacaoScreen` apresenta as informações completas de uma publicação selecionada.

Funcionalidades implementadas:

- Navegação da Home ou da tela Minhas publicações para a tela de detalhes.
- Galeria de imagens com navegação horizontal entre as fotos.
- Indicador da posição atual na galeria e da quantidade de imagens.
- Barra superior com opção de voltar.
- Exibição do título, categoria, estado de conservação, cidade e descrição do item.
- Exibição do nome do doador.
- Seção com orientações de segurança para o usuário.
- Verificação de interesse do usuário autenticado.
- Registro de interesse no Cloud Firestore.
- Exibição das opções "Cancelar interesse" e "Conversar" após o registro.
- Cancelamento do interesse com remoção do respectivo documento no Firestore.
- Opção de bloquear ou desbloquear o doador pelo diálogo de denúncia.
- Ocultação dos detalhes e das ações da publicação quando existe bloqueio entre os usuários.

A tela identifica se a publicação pertence ao usuário autenticado por meio da comparação entre o UID da sessão e o campo `usuarioId` da publicação.

Quando a publicação pertence ao próprio usuário, os controles de demonstração de interesse e denúncia não são exibidos. Para publicações de outros usuários, as ações correspondentes ao interesse permanecem disponíveis.

Os interesses são armazenados em uma subcoleção da publicação, utilizando o UID do usuário autenticado como identificador do documento. Dessa forma, cada usuário possui no máximo um registro de interesse por publicação.

O estado do interesse é recuperado do Firestore ao abrir a tela, permitindo manter a informação mesmo após sair e retornar à publicação.

Após demonstrar interesse, o usuário pode acessar a conversa com o doador pelo botão "Conversar". Caso a conversa já exista para aquela publicação e aquele interessado, ela é recuperada; caso contrário, é criada.

O botão de denúncia permite registrar reclamações sobre publicações de outros usuários. Ao selecioná-lo, o aplicativo apresenta um formulário com motivos predefinidos e um campo opcional para descrição adicional, limitado a 500 caracteres.

Os motivos disponíveis são: item proibido ou perigoso; cobrança de valores ou tentativa de venda; conduta inadequada ou ofensiva; informações falsas ou fotos que não correspondem; spam ou conteúdo repetido; e outro motivo.

Após o envio, a denúncia é registrada na coleção `denuncias` do Cloud Firestore, vinculada ao usuário autenticado e ao proprietário da publicação.

### 10. Tela de Minhas publicações

A `MinhasPublicacoesScreen` permite que o usuário autenticado visualize e gerencie suas próprias publicações.

Funcionalidades implementadas:

- Listagem das publicações associadas ao UID do usuário autenticado.
- Atualização em tempo real utilizando `snapshots()`.
- Filtros por situação: Disponíveis, Em andamento e Concluídas.
- Exibição da quantidade de publicações em cada filtro.
- Exibição da imagem, título e situação de cada publicação.
- Exibição da quantidade de pessoas interessadas em cada item.
- Abertura da tela de detalhes.
- Acesso à tela de interessados.
- Edição de publicações existentes.
- Remoção de publicações mediante confirmação.
- Reabertura de doações concluídas.

A listagem utiliza o método `acompanharMinhasPublicacoes()` do `PublicacaoControl`, que consulta as publicações do usuário autenticado no Cloud Firestore.

A quantidade de interesses de cada publicação é acompanhada em tempo real pelo `InteresseControl`.

O gerenciamento dos estados permite que o doador escolha um interessado, desfaça a escolha, conclua a doação e reabra uma publicação concluída.

Quando o doador edita uma publicação, o sistema também atualiza o título e a primeira imagem nas conversas relacionadas. Dessa forma, as informações apresentadas na tela Mensagens e no chat permanecem sincronizadas com os dados atuais da publicação.

Ao remover uma publicação, o sistema realiza a limpeza dos dados relacionados. Primeiro, identifica as conversas vinculadas à publicação e exclui as mensagens de cada conversa, utilizando lotes de até 500 operações. Em seguida, exclui os documentos das conversas, os registros de interesse e, por último, o documento da publicação.

A exclusão é realizada de forma sequencial. Caso alguma etapa falhe, as etapas seguintes não são executadas e a publicação não é removida, permitindo uma nova tentativa de limpeza.

### 11. Tela de interessados

A `InteressadosScreen` permite ao doador visualizar e gerenciar as pessoas que demonstraram interesse em uma publicação de sua propriedade.

Funcionalidades implementadas:

- Abertura da tela pela opção "Ver interessados".
- Identificação da publicação selecionada.
- Listagem das pessoas interessadas.
- Exibição do nome e da cidade do interessado.
- Exibição da data e da mensagem enviada ao demonstrar interesse.
- Exibição de iniciais do usuário em um avatar.
- Ordenação dos interesses do mais recente para o mais antigo.
- Atualização em tempo real utilizando `snapshots()`.
- Escolha de uma pessoa interessada para receber a doação.
- Possibilidade de desfazer a escolha.
- Conclusão da doação após a escolha do interessado.
- Acesso à conversa individual com cada pessoa interessada.
- Abertura de conversas existentes ou criação de novas conversas.
- Possibilidade de conversar com qualquer interessado, independentemente de ele ter sido escolhido para receber a doação.

O `InteresseControl` recupera os dados necessários do perfil do usuário e os armazena junto ao registro de interesse.

O doador pode consultar as informações dos interessados e gerenciar o andamento da doação pela própria tela.

A consulta da lista é permitida somente ao proprietário da publicação, conforme as regras de segurança do Cloud Firestore.

O doador pode iniciar uma conversa com cada interessado diretamente pela tela. Cada conversa está vinculada à publicação e ao usuário interessado, permitindo que diferentes pessoas conversem individualmente com o doador sobre o mesmo item.


### 12. Tela de conversas e chat

A comunicação entre doadores e interessados é realizada por meio de conversas individuais relacionadas às publicações.

#### Tela de conversas

A `ConversasScreen` apresenta as conversas do usuário autenticado.

Funcionalidades implementadas:

- Listagem das conversas associadas ao usuário.
- Atualização em tempo real utilizando `snapshots()`.
- Exibição das iniciais e do nome do outro participante.
- Exibição do título da publicação relacionada à conversa.
- Prévia da última mensagem enviada.
- Identificação de mensagens enviadas pelo próprio usuário.
- Exibição da data ou horário da última mensagem.
- Abertura da conversa ao selecionar um card.
- Exibição de mensagens para situações de carregamento, erro ou ausência de conversas.

#### Tela de chat

A `ChatScreen` permite a troca de mensagens entre o doador e uma pessoa interessada.

Funcionalidades implementadas:

- Envio e recebimento de mensagens.
- Atualização das mensagens em tempo real pelo Cloud Firestore.
- Identificação visual das mensagens enviadas e recebidas.
- Exibição do horário de envio.
- Validação de mensagens vazias.
- Limite de até 1.000 caracteres por mensagem.
- Indicador de envio.
- Orientação de segurança durante a conversa.
- Acesso à publicação relacionada pelo título exibido no cabeçalho.
- Botão de denúncia disponível para os dois participantes da conversa.
- Identificação automática do outro participante como denunciado.
- Formulário de denúncia com motivos predefinidos e descrição opcional.
- Opção de bloquear ou desbloquear o outro participante pelo diálogo de denúncia.
- Desativação do envio de mensagens quando existe bloqueio entre os participantes.
- Preservação do histórico de mensagens durante o bloqueio.

O sistema permite denúncias recíprocas entre os participantes. O interessado pode denunciar o doador, e o doador pode denunciar o interessado. O título do formulário é ajustado conforme o usuário autenticado.

A denúncia pode ser registrada mesmo quando a conversa ainda não possui mensagens enviadas, pois a identificação dos participantes é armazenada no próprio documento da conversa.

#### Acesso às conversas

As conversas podem ser abertas por diferentes caminhos:

- Pela tela de detalhes da publicação, após o registro de interesse.
- Pela tela de interessados, a partir do card de cada interessado.
- Pela opção Mensagens da navegação inferior.

Cada conversa é individual e está vinculada a uma publicação e a um usuário interessado. Dessa forma, uma mesma publicação pode possuir conversas distintas com diferentes interessados.

O sistema utiliza um identificador determinístico baseado no ID da publicação e no UID do interessado, evitando a criação de várias conversas para a mesma combinação.

Quando o doador edita uma publicação, o título e a primeira imagem são atualizados nas conversas relacionadas. Assim, a listagem de mensagens e o cabeçalho do chat apresentam os dados atuais da publicação, sem alterar o histórico de mensagens.

### 13. Navegação inferior

A aplicação apresenta cinco opções na navegação inferior:

- Início.
- Minhas publicações.
- Doar.
- Mensagens.
- Perfil.

As cinco opções estão implementadas e integradas à navegação.

A opção Mensagens abre a `ConversasScreen`, que apresenta as conversas do usuário autenticado. Ao selecionar uma conversa, o aplicativo abre a `ChatScreen` correspondente.

A navegação também permite retornar às demais áreas do aplicativo sem perder a organização das telas.

### 14. Histórico de doações

A `HistoricoDoacoesScreen` permite que o usuário autenticado consulte o histórico das doações realizadas e recebidas.

Funcionalidades implementadas:

- Consulta separada de doações feitas e doações recebidas.
- Exibição do título e da imagem da publicação.
- Exibição do nome do beneficiário nas doações feitas.
- Exibição do nome do doador nas doações recebidas.
- Exibição da cidade do beneficiário nas doações feitas.
- Exibição da data de conclusão.
- Identificação do status da doação.
- Registro da data de reabertura quando uma conclusão é desfeita.
- Atualização do histórico em tempo real utilizando `snapshots()`.
- Acesso à tela pela opção "Histórico de doações" no perfil.

Cada conclusão gera um documento na coleção `doacoes` do Cloud Firestore. O mesmo registro é disponibilizado no histórico do doador e do beneficiário.

Quando uma doação é reaberta, o registro anterior permanece no histórico com o status `reaberta`, identificado na interface como "Conclusão desfeita". Caso a publicação seja concluída novamente, um novo documento é criado, preservando o registro anterior.

A consulta das doações utiliza o UID do usuário autenticado e a lista de participantes armazenada em cada documento.

Os cards também apresentam o botão "Avaliar" nas doações com status `concluida`. Atualmente, o botão está implementado somente visualmente, sem funcionalidade de avaliação.

### 15. Notificações

A `NotificacoesScreen` permite que o usuário autenticado consulte as notificações relacionadas às suas atividades no Desapegaí.

Funcionalidades implementadas:

- Listagem das notificações recebidas pelo usuário autenticado.
- Atualização em tempo real utilizando `snapshots()`.
- Ordenação das notificações da mais recente para a mais antiga.
- Identificação visual de notificações lidas e não lidas.
- Marcação automática como lida ao selecionar uma notificação.
- Exibição de título, mensagem e data de criação.
- Indicador da quantidade de notificações não lidas na Home.
- Navegação para a tela correspondente ao evento da notificação.

O sistema contempla cinco tipos de notificações:

- `novo_interesse`: enviada ao doador quando uma pessoa demonstra interesse em uma publicação.
- `interessado_escolhido`: enviada ao beneficiário quando o doador o escolhe para receber a doação.
- `doacao_concluida`: enviada ao beneficiário quando o doador conclui a doação.
- `doacao_reaberta`: enviada ao beneficiário anterior quando o doador reabre uma doação concluída.
- `nova_mensagem`: enviada ao outro participante quando uma nova mensagem é registrada em uma conversa.

As notificações são criadas junto às operações correspondentes no Cloud Firestore, utilizando transações para manter os registros relacionados ao evento.

Ao selecionar uma notificação, o aplicativo identifica seu tipo e direciona o usuário para a tela correspondente. As notificações de novo interesse abrem a `InteressadosScreen`, as notificações de mensagem abrem a `ChatScreen` e as demais notificações relacionadas a publicações abrem a `DetalhesPublicacaoScreen`.

O sistema utiliza notificações internas armazenadas no Firestore, sem implementação de notificações push externas.

### 16. Ajuda e segurança

A `AjudaSegurancaScreen` apresenta informações e orientações para ajudar os usuários a utilizar o Desapegaí de forma segura.

Funcionalidades implementadas:

- Acesso pela opção "Ajuda e segurança" na tela de perfil.
- Apresentação do processo de doação em quatro passos.
- Seção de perguntas frequentes.
- Expansão e recolhimento individual das perguntas.
- Exibição inicial da primeira pergunta expandida.

Os quatro passos apresentados são:

1. Publique o item com fotos e descrição.
2. Veja quem demonstrou interesse.
3. Escolha uma pessoa e combine a entrega.
4. Conclua a doação e avalie a experiência.

A seção de perguntas frequentes apresenta orientações sobre:

- Como funciona uma doação.
- Cuidados durante a conversa.
- Como combinar a retirada com segurança.
- Transporte de itens.
- Como denunciar ou bloquear alguém.
- Privacidade e tratamento dos dados pessoais.

As orientações reforçam que todas as doações são gratuitas e que o Desapegaí não vende produtos nem intermedeia pagamentos.

A tela também explica que as denúncias podem ser registradas pela tela de detalhes da publicação ou pela conversa, além de apresentar orientações sobre como bloquear usuários.

## Autenticação e armazenamento

### Firebase Authentication

O Firebase Authentication é utilizado para criar contas, autenticar usuários, solicitar redefinição de senha e encerrar sessões.

O aplicativo observa o estado de autenticação por meio de `authStateChanges()`. Ao iniciar, o `AuthGate` apresenta a tela adequada conforme exista ou não um usuário autenticado.

### Cloud Firestore

O Cloud Firestore é utilizado para armazenar os dados dos usuários, das publicações, dos interesses demonstrados pelos usuários, dos bloqueios entre usuários, dos registros de doações concluídas, das conversas, das mensagens, das notificações e das denúncias.

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

#### Subcoleção `bloqueados`

Cada usuário possui uma subcoleção `bloqueados` dentro do próprio documento na coleção `usuarios`. Ela armazena os usuários bloqueados pela conta autenticada.

A estrutura é organizada da seguinte forma:

```text
usuarios/
  UID_DO_USUARIO/
    bloqueados/
      UID_DO_USUARIO_BLOQUEADO/
```

Os campos armazenados são:

| Campo | Descrição |
|---|---|
| `usuarioId` | UID do usuário bloqueado |
| `nome` | Nome do usuário bloqueado no momento do registro |
| `dataBloqueio` | Data e horário do bloqueio, definidos pelo servidor |

O `BloqueioControl` é responsável por bloquear, desbloquear e acompanhar os usuários bloqueados. A consulta considera tanto os usuários bloqueados pela conta atual quanto aqueles que bloquearam essa conta.

O acompanhamento utiliza atualizações em tempo real. A consulta por grupo da subcoleção `bloqueados` utiliza o campo `usuarioId` e requer um índice com escopo de grupo de coleções no Cloud Firestore.

#### Subcoleção `notificacoes`

Cada usuário possui uma subcoleção `notificacoes` dentro do próprio documento na coleção `usuarios`. Ela armazena as notificações destinadas à conta autenticada.

A estrutura é organizada da seguinte forma:

```text
usuarios/
  UID_DO_USUARIO/
    notificacoes/
      ID_DA_NOTIFICACAO/
```
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
| `status` | Situação da publicação: `ativa`, `em_andamento` ou `concluida` |
| `imagens` | Lista de URLs das imagens armazenadas no Cloudinary |
| `nomeDoador` | Nome público do usuário responsável pela publicação |
| `usuarioEscolhidoId` | UID do usuário escolhido para receber a doação |
| `dataConclusao` | Data e horário da conclusão atual da doação |
| `usuarioEscolhidoNome` | Nome público do usuário escolhido para receber a doação |
| `usuarioEscolhidoCidade` | Cidade do usuário escolhido para receber a doação |
| `doacaoAtualId` | Identificador do registro correspondente à conclusão atual na coleção `doacoes` |
| `coordenadas` | Campo opcional do tipo `GeoPoint`, contendo latitude e longitude aproximadas da publicação, arredondadas para duas casas decimais |

#### Subcoleção `interesses`

Cada publicação pode possuir uma subcoleção chamada `interesses`, responsável por armazenar os usuários que demonstraram interesse naquele item.

A estrutura utiliza o UID do usuário autenticado como identificador do documento:

```text
publicacoes/
  ID_DA_PUBLICACAO/
    interesses/
      UID_DO_USUARIO/
```

Os campos armazenados são:

| Campo | Descrição |
|---|---|
| `usuarioId` | UID do usuário que demonstrou interesse |
| `nomeUsuario` | Nome público recuperado do perfil do usuário |
| `dataCriacao` | Data e horário do registro, definidos pelo servidor |
| `cidade` | Cidade do usuário interessado |
| `mensagem` | Mensagem personalizada enviada ao demonstrar interesse, limitada a 250 caracteres |

O `InteresseControl` é responsável por registrar, consultar, cancelar e acompanhar os interesses das publicações.

A quantidade de interesses pode ser acompanhada em tempo real por meio de `snapshots()`.

A listagem completa dos interessados também utiliza `snapshots()`, sendo ordenada pela data de criação em ordem decrescente.

Os dados armazenados na subcoleção incluem o UID, nome, cidade, mensagem e data do interesse. Essas informações permitem que o doador identifique os interessados e visualize a mensagem enviada, sem precisar acessar diretamente os dados privados do perfil.

O `PublicacaoControl` é responsável por cadastrar e consultar as publicações.

A Home utiliza uma consulta em tempo real com `snapshots()`, filtrando as publicações pelo status `ativa` e excluindo aquelas cujo `usuarioId` corresponde ao UID do usuário autenticado.

A tela Minhas publicações utiliza uma consulta em tempo real das publicações associadas ao usuário autenticado.

A consulta combinada utilizada na Home requer um índice composto configurado no Cloud Firestore.

O campo `nomeDoador` armazena o nome público do usuário responsável pela publicação. Esse valor é obtido do perfil do usuário autenticado durante o cadastro e registrado diretamente no documento da publicação.

#### Coleção `doacoes`

Cada conclusão de doação gera um documento na coleção `doacoes`, utilizando um identificador automático gerado pelo Cloud Firestore.

Os registros armazenam informações da publicação e dos participantes como um histórico da conclusão, permitindo que tanto o doador quanto o beneficiário consultem a mesma doação.

Os principais campos são:

| Campo | Descrição |
|---|---|
| `publicacaoId` | Identificador da publicação relacionada |
| `tituloPublicacao` | Título da publicação no momento da conclusão |
| `imagemPublicacao` | URL da imagem da publicação no momento da conclusão, quando disponível |
| `doadorId` | UID do usuário responsável pela doação |
| `doadorNome` | Nome público do doador |
| `beneficiarioId` | UID do usuário escolhido para receber a doação |
| `beneficiarioNome` | Nome público do beneficiário |
| `beneficiarioCidade` | Cidade do beneficiário |
| `participantes` | Lista contendo os UIDs do doador e do beneficiário |
| `dataConclusao` | Data e horário da conclusão, definidos pelo servidor |
| `status` | Situação do registro: `concluida` ou `reaberta` |
| `dataReabertura` | Data e horário da reabertura, definidos pelo servidor, quando aplicável |

O `DoacaoControl` é responsável por registrar as conclusões, reabrir doações e acompanhar os históricos de doações feitas e recebidas.

A conclusão é realizada em uma transação do Firestore, registrando o documento em `doacoes` e atualizando a publicação para apontar para o novo registro por meio de `doacaoAtualId`.

Quando uma doação é reaberta, o registro correspondente recebe o status `reaberta` e a data de reabertura. O histórico não é excluído. A publicação retorna ao estado `ativa`, removendo os dados da escolha e da conclusão atual.

Caso a mesma publicação seja concluída novamente, um novo documento é criado na coleção `doacoes`. Dessa forma, cada conclusão permanece registrada separadamente.

Os históricos são consultados por meio do campo `participantes`, permitindo que o doador visualize as doações feitas e o beneficiário visualize as doações recebidas.

Os registros de doações não são excluídos automaticamente quando uma publicação é removida, preservando as informações históricas da conclusão.

#### Coleção `conversas`

Cada conversa é armazenada como um documento na coleção `conversas`.

O identificador do documento é formado pela combinação do ID da publicação com o UID do interessado, garantindo uma conversa individual para cada pessoa interessada em determinada publicação.

A estrutura é organizada da seguinte forma:

```text
conversas/
  ID_DA_PUBLICACAO_UID_DO_INTERESSADO/
    mensagens/
      ID_DA_MENSAGEM/
```

Os principais campos do documento da conversa são:

| Campo | Descrição |
|---|---|
| `publicacaoId` | Identificador da publicação relacionada |
| `tituloPublicacao` | Título da publicação |
| `imagemPublicacao` | URL da primeira imagem da publicação |
| `doadorId` | UID do usuário responsável pela publicação |
| `doadorNome` | Nome público do doador |
| `interessadoId` | UID do usuário que demonstrou interesse |
| `interessadoNome` | Nome público do interessado |
| `participantes` | Lista de UIDs autorizados a participar da conversa |
| `dataCriacao` | Data e horário de criação da conversa |
| `ultimaMensagem` | Conteúdo da mensagem mais recente |
| `ultimaMensagemRemetenteId` | UID de quem enviou a última mensagem |
| `dataUltimaMensagem` | Data e horário da última mensagem |

#### Subcoleção `mensagens`

Cada conversa possui uma subcoleção `mensagens`, responsável por armazenar as mensagens trocadas entre os participantes.

Os campos de cada mensagem são:

| Campo | Descrição |
|---|---|
| `remetenteId` | UID do usuário que enviou a mensagem |
| `texto` | Conteúdo da mensagem, limitado a 1.000 caracteres |
| `dataEnvio` | Data e horário do envio, definidos pelo servidor |

O `ChatControl` é responsável por criar ou recuperar conversas, acompanhar as conversas do usuário, acompanhar as mensagens e enviar novas mensagens.

O `ChatControl` também sincroniza o título e a primeira imagem da publicação nos documentos das conversas quando o doador edita o item. Essa atualização é permitida pelas regras do Firestore somente ao proprietário da publicação e não modifica as mensagens já enviadas.

As consultas utilizam `snapshots()`, permitindo atualizar a listagem de conversas e o conteúdo do chat conforme novos dados são registrados no Firestore.

#### Coleção `denuncias`

Cada denúncia é armazenada como um documento na coleção `denuncias`, utilizando um identificador gerado pelo Firestore.

Os principais campos são:

| Campo | Descrição |
|---|---|
| `denuncianteId` | UID do usuário que realizou a denúncia |
| `denunciadoId` | UID do usuário ou proprietário da publicação denunciada |
| `tipo` | Tipo da denúncia: `publicacao` ou `usuario` |
| `publicacaoId` | Identificador da publicação relacionada |
| `tituloPublicacao` | Título da publicação no momento do registro |
| `conversaId` | Identificador da conversa relacionada, quando aplicável |
| `motivo` | Motivo selecionado no formulário |
| `descricao` | Detalhes adicionais informados pelo denunciante |
| `dataCriacao` | Data e horário do registro, definidos pelo servidor |
| `status` | Situação inicial da denúncia: `pendente` |

As denúncias de publicação são vinculadas ao proprietário do item denunciado. As denúncias de usuário são vinculadas à conversa e identificam o outro participante como denunciado.

O `DenunciaControl` valida os dados, identifica os participantes e registra as denúncias no Firestore. O formulário reutilizável `DialogoDenuncia` apresenta os motivos disponíveis e permite adicionar uma descrição complementar.

Os documentos são criados com status inicial `pendente`. A consulta e o gerenciamento administrativo das denúncias serão implementados posteriormente.

### Regras de segurança

O arquivo `firestore.rules` contém as regras de acesso às coleções `usuarios`, `publicacoes`, `doacoes`, `conversas`, `denuncias` e às subcoleções `interesses`, `mensagens`, `notificacoes` e `bloqueados`.

As regras exigem autenticação para as operações permitidas e verificam a relação entre o usuário autenticado e o documento acessado.

Na coleção `usuarios`, as regras restringem a consulta e a atualização do documento ao próprio usuário. A listagem geral e a exclusão de perfis são bloqueadas.

As regras da coleção `usuarios` validam os campos obrigatórios durante a criação do perfil. As atualizações são restritas aos campos `nome`, `cidade` e `sobreMim`, impedindo alterações no UID e no e-mail, bem como a inclusão de campos não previstos no modelo.

A subcoleção `bloqueados` possui regras específicas:

- Somente o proprietário da lista pode criar e excluir registros de bloqueio.
- A listagem da própria subcoleção é restrita ao proprietário.
- A consulta por grupo de coleções permite identificar documentos nos quais o usuário autenticado aparece como usuário bloqueado.
- A criação de registros valida o UID do usuário bloqueado, o nome e a data definida pelo servidor.

A subcoleção `notificacoes`, localizada dentro de `usuarios`, possui regras específicas:

- Somente o proprietário da conta pode consultar e listar suas notificações.
- A criação exige autenticação e validação dos dados do evento relacionado.
- O remetente deve corresponder ao usuário autenticado.
- O destinatário deve corresponder ao proprietário da subcoleção.
- Não é permitido criar notificações para o próprio remetente.
- Os tipos de notificação são validados conforme os eventos permitidos pelo sistema.
- O título possui limite de 100 caracteres e a mensagem possui limite de 300 caracteres.
- A data de criação deve corresponder ao horário do servidor.
- O usuário pode atualizar somente o campo `lida`, alterando seu valor de `false` para `true`.
- A exclusão das notificações é bloqueada pelas regras atuais.

Na coleção `publicacoes`, as regras controlam a criação, leitura, atualização e exclusão dos documentos, incluindo:

- Verificação do UID do autor.
- Verificação do nome público do doador com base no perfil cadastrado.
- Validação dos campos permitidos.
- Restrição do status inicial para `ativa`.
- Limite de até três imagens por publicação.
- Permissão de leitura de documentos individuais para publicações ativas, para o próprio autor, para o usuário escolhido ou para usuários que possuam um registro de interesse na publicação.
- As consultas de listagem seguem critérios específicos definidos nas regras de segurança.
- Restrição das alterações aos campos permitidos.
- Validação do campo opcional `coordenadas`, aceitando somente valores do tipo `GeoPoint` quando informado.

A subcoleção `interesses` possui regras específicas:

- O interessado pode consultar somente o próprio documento de interesse.
- Somente o proprietário da publicação pode listar os documentos da subcoleção.
- O usuário autenticado pode demonstrar interesse em publicações ativas de outros usuários.
- O UID e o nome registrados precisam corresponder à conta autenticada e ao perfil armazenado no Firestore.
- A data do registro deve corresponder ao horário do servidor.
- A alteração de documentos de interesse existentes é bloqueada.
- O usuário pode cancelar somente o próprio interesse.
- Validação da cidade conforme o perfil do usuário.
- Limitação da mensagem a até 250 caracteres.
- A criação de interesse é bloqueada quando existe um registro de bloqueio entre o interessado e o proprietário da publicação.

A coleção `doacoes` possui regras específicas:

- Somente usuários autenticados podem criar registros de doação.
- O doador registrado deve corresponder ao usuário autenticado.
- O beneficiário deve ser diferente do doador.
- Os participantes registrados devem corresponder aos UIDs do doador e do beneficiário.
- A criação do registro deve estar vinculada a uma publicação cuja conclusão esteja sendo realizada na mesma operação.
- A publicação deve apontar para o registro criado por meio do campo `doacaoAtualId`.
- Somente o doador e o beneficiário podem consultar os registros dos quais participam.
- Somente o doador pode reabrir um registro de doação concluída.
- A reabertura deve ocorrer em conjunto com a atualização correspondente da publicação.
- A atualização é restrita aos campos `status` e `dataReabertura`.
- A exclusão dos registros de doações é bloqueada.

A coleção `conversas` e sua subcoleção `mensagens` possuem regras específicas:

- Somente os participantes podem consultar e listar uma conversa.
- A criação de conversas exige uma publicação válida e um registro de interesse correspondente.
- O identificador da conversa deve corresponder à publicação e ao interessado.
- Somente os participantes podem enviar mensagens.
- O UID do remetente deve corresponder ao usuário autenticado.
- As mensagens possuem limite de 1.000 caracteres.
- A atualização das informações da última mensagem da conversa é restrita aos campos permitidos.
- A edição de mensagens existentes é bloqueada.
- Os participantes podem atualizar somente os campos relacionados à última mensagem.
- Somente o doador pode atualizar o título e a imagem da publicação nas conversas, desde que os novos valores correspondam aos dados registrados na publicação.
- Somente o doador pode excluir os documentos das conversas e suas mensagens.
- As atualizações das informações da publicação não permitem alterar os participantes ou os dados de identificação da conversa.
- A criação de conversas é bloqueada quando existe um bloqueio entre os participantes.
- O envio de mensagens e a atualização da última mensagem da conversa são bloqueados enquanto existir um bloqueio entre os participantes.
- A leitura das mensagens anteriores permanece permitida, preservando o histórico da conversa.

A coleção `denuncias` possui regras específicas:

- Somente usuários autenticados podem criar denúncias.
- O denunciante deve corresponder ao UID da conta autenticada.
- Não é permitido denunciar a própria conta.
- As denúncias de publicação devem corresponder ao proprietário e aos dados reais da publicação.
- As denúncias de usuário devem ser realizadas por um participante da conversa contra o outro participante.
- Os motivos devem corresponder às opções permitidas para cada tipo de denúncia.
- A data de criação deve corresponder ao horário do servidor.
- O status inicial deve ser `pendente`.
- A leitura, atualização e exclusão dos documentos são bloqueadas pelas regras atuais.

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

O serviço `LocalizacaoService` utiliza o Geolocator para obter as coordenadas geográficas do dispositivo e o Geocoding para converter essas coordenadas em informações de endereço.

O serviço é utilizado em duas situações:

- No cadastro e na edição de publicações, para preencher o endereço e armazenar coordenadas aproximadas.
- Na Home, para obter as coordenadas atuais do usuário e realizar os cálculos do filtro de distância.

As coordenadas das publicações são arredondadas para duas casas decimais antes de serem armazenadas no Cloud Firestore, reduzindo a precisão da localização registrada e preservando a privacidade dos usuários.

A localização atual utilizada pelo filtro é mantida somente em memória e não é armazenada no banco de dados.

O cálculo das distâncias é realizado pelo método `Geolocator.distanceBetween`, comparando as coordenadas atuais do usuário com as coordenadas aproximadas das publicações.

O serviço também verifica se a localização do dispositivo está ativada e solicita as permissões necessárias. Falhas na obtenção da localização são tratadas e apresentadas ao usuário.

Publicações antigas que não possuem coordenadas continuam compatíveis com o sistema e podem ser visualizadas normalmente quando o filtro de distância está desativado.

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
│   │   ├── bloqueio_control.dart
│   │   ├── cadastro_control.dart
│   │   ├── chat_control.dart
│   │   ├── denuncia_control.dart
│   │   ├── doacao_control.dart
│   │   ├── interesse_control.dart
│   │   ├── login_control.dart
│   │   ├── notificacao_control.dart
│   │   ├── publicacao_control.dart
│   │   ├── recuperacao_senha_control.dart
│   │   ├── sessao_control.dart
│   │   └── usuario_control.dart
│   ├── model/
│   │   ├── conversa.dart
│   │   ├── denuncia.dart
│   │   ├── doacao.dart
│   │   ├── interessado.dart
│   │   ├── mensagem.dart
│   │   ├── notificacao.dart
│   │   ├── publicacao.dart
│   │   ├── usuario.dart
│   │   └── usuario_bloqueado.dart
│   ├── screens/
│   │   ├── ajuda_seguranca_screen.dart
│   │   ├── auth_gate.dart
│   │   ├── cadastro_publicacao_screen.dart
│   │   ├── chat_screen.dart
│   │   ├── completar_perfil_screen.dart
│   │   ├── conversas_screen.dart
│   │   ├── detalhes_publicacao_screen.dart
│   │   ├── edit_profile_screen.dart
│   │   ├── historico_doacoes_screen.dart
│   │   ├── home_screen.dart
│   │   ├── interessados_screen.dart
│   │   ├── login_screen.dart
│   │   ├── minhas_publicacoes_screen.dart
│   │   ├── notificacoes_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── recover_password_screen.dart
│   │   └── register_screen.dart
│   ├── services/
│   │   ├── cloudinary_service.dart
│   │   └── localizacao_service.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── widgets/
│       ├── auth_layout.dart
│       ├── botoes.dart
│       ├── dialogo_denuncia.dart
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
| Com sessão autenticada e perfil existente | `HomeScreen` |
| Com sessão autenticada, mas sem perfil no Firestore | `CompletarPerfilScreen` |
| `/cadastro` | `RegisterScreen` |
| `/recuperar-senha` | `RecoverPasswordScreen` |
| Opção Início na navegação inferior | `HomeScreen` |
| Opção Minhas na navegação inferior | `MinhasPublicacoesScreen` |
| Opção Doar na navegação inferior | `CadastroPublicacaoScreen` |
| Opção Mensagens na navegação inferior | `ConversasScreen` |
| Opção Perfil na navegação inferior | `ProfileScreen` |
| Botão Editar perfil | `EditProfileScreen` |
| Seleção de publicação na Home ou em Minhas | `DetalhesPublicacaoScreen` |
| Botão Ver interessados | `InteressadosScreen` |
| Opção Histórico de doações na tela de perfil | `HistoricoDoacoesScreen` |
| Ícone de notificações na Home | `NotificacoesScreen` |
| Notificação de novo interesse | `InteressadosScreen` |
| Notificação de nova mensagem | `ChatScreen` |
| Notificações de escolha, conclusão e reabertura | `DetalhesPublicacaoScreen` |
| Opção Ajuda e segurança na tela de perfil | `AjudaSegurancaScreen` |

A Home é apresentada pelo `AuthGate` quando o Firebase informa que existe um usuário autenticado e o perfil correspondente está disponível no Firestore. Caso o perfil não exista, o aplicativo apresenta a `CompletarPerfilScreen` para sua recuperação.

## Tecnologias

- **Flutter:** desenvolvimento da aplicação mobile.
- **Dart:** linguagem de programação.
- **Firebase Core:** inicialização do Firebase no aplicativo.
- **Firebase Authentication:** cadastro, login, recuperação de senha e gerenciamento de sessão.
- **Cloud Firestore:** armazenamento dos perfis dos usuários, das publicações, dos interesses, dos bloqueios entre usuários, dos registros de doações, das conversas, das mensagens, das notificações e das denúncias.
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
- [x] Tratamento de falhas na consulta do perfil, diferenciando-as da ausência do documento.
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
- [x] Cadastro de publicações com coordenadas geográficas.
- [x] Cadastro de publicações sem coordenadas, utilizando endereço manual.
- [x] Armazenamento das coordenadas das publicações como `GeoPoint` no Firestore.
- [x] Preservação das coordenadas ao editar outros dados da publicação.
- [x] Remoção das coordenadas quando o endereço da publicação é alterado manualmente.
- [x] Compatibilidade com publicações antigas sem coordenadas.
- [x] Obtenção da localização atual para cálculo de distância.
- [x] Filtro geográfico com distância máxima de 5 km.
- [x] Filtro geográfico com distância máxima de 10 km.
- [x] Filtro geográfico com distância máxima de 25 km.
- [x] Filtro geográfico com distância máxima de 50 km.
- [x] Opção Qualquer, sem restrição de distância.
- [x] Combinação do filtro de distância com a pesquisa por texto.
- [x] Combinação do filtro de distância com as categorias.
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
- [x] Consulta do interesse do usuário ao abrir a publicação.
- [x] Registro de interesse no Cloud Firestore.
- [x] Prevenção de registros duplicados por usuário e publicação.
- [x] Persistência do interesse após fechar e reabrir a publicação.
- [x] Cancelamento do interesse com exclusão do documento no Firestore.
- [x] Ocultação das ações de interesse e denúncia nas próprias publicações.
- [x] Exibição das ações de interesse nas publicações de outros usuários.
- [x] Validação das regras de segurança da subcoleção `interesses`.
- [x] Listagem das próprias publicações.
- [x] Filtros de Minhas publicações por situação.
- [x] Exibição da quantidade de interessados nos cards.
- [x] Navegação de Minhas publicações para a tela de detalhes.
- [x] Abertura da tela de interessados pelo botão correspondente.
- [x] Registro do nome do interessado junto ao documento de interesse.
- [x] Listagem de interessados com nome e data.
- [x] Atualização em tempo real da lista de interessados.
- [x] Teste do fluxo de interesse utilizando duas contas distintas.
- [x] Verificação de que somente o proprietário da publicação consegue listar seus interessados.
- [x] Envio de mensagem personalizada ao demonstrar interesse.
- [x] Exibição da cidade e da mensagem na tela de interessados.
- [x] Escolha de um interessado para receber a doação.
- [x] Desfazer a escolha de um interessado.
- [x] Conclusão de uma doação.
- [x] Reabertura de uma doação concluída.
- [x] Edição de publicações existentes.
- [x] Remoção de publicações e dos registros de interesse associados.
- [x] Criação de conversas individuais entre doadores e interessados.
- [x] Recuperação de conversas existentes sem duplicação.
- [x] Abertura de conversas pela tela de detalhes da publicação.
- [x] Abertura de conversas pela tela de interessados.
- [x] Envio e recebimento de mensagens utilizando contas diferentes.
- [x] Persistência das mensagens no Cloud Firestore.
- [x] Exibição das mensagens enviadas e recebidas.
- [x] Atualização da última mensagem na listagem de conversas.
- [x] Acesso às conversas pela navegação inferior.
- [x] Abertura da publicação relacionada pelo cabeçalho do chat.
- [x] Exibição do botão de denúncia para ambos os participantes do chat.
- [x] Teste de denúncias nos dois sentidos: interessado contra doador e doador contra interessado.
- [x] Sincronização do título da publicação nas conversas após a edição.
- [x] Sincronização da primeira imagem da publicação nas conversas após a edição.
- [x] Preservação das mensagens existentes durante a edição da publicação.
- [x] Continuidade do envio de mensagens após a sincronização.
- [x] Teste de edição com múltiplas conversas relacionadas à mesma publicação.
- [x] Exclusão das conversas relacionadas ao remover uma publicação.
- [x] Exclusão das mensagens das conversas antes da remoção dos documentos das conversas.
- [x] Exclusão dos registros de interesse e da publicação após a limpeza das conversas.
- [x] Teste de remoção com múltiplos interessados e conversas.
- [x] Identificação de conta autenticada sem perfil no Firestore.
- [x] Exibição da tela de recuperação de perfil.
- [x] Criação do perfil ausente com os cinco campos obrigatórios.
- [x] Preservação de perfis existentes durante a recuperação.
- [x] Login direto na Home quando o perfil já existe.
- [x] Recuperação do perfil utilizando o e-mail do Firebase Authentication.
- [x] Atualização permitida somente dos campos autorizados do perfil.
- [x] Bloqueio da alteração do UID no perfil.
- [x] Bloqueio da alteração do e-mail no perfil.
- [x] Bloqueio da inclusão de campos não permitidos no perfil.
- [x] Registro de denúncias de publicações.
- [x] Registro de denúncias de usuários pelo interessado.
- [x] Registro de denúncias de usuários pelo doador.
- [x] Registro de denúncia em conversa sem mensagens anteriores.
- [x] Exibição dos motivos definidos no protótipo.
- [x] Validação dos dados registrados na coleção `denuncias`.
- [x] Registro da data de criação pelo servidor.
- [x] Definição do status inicial da denúncia como `pendente`.
- [x] Registro de uma conclusão na coleção `doacoes`.
- [x] Atualização do registro histórico para `reaberta` ao desfazer uma conclusão.
- [x] Preservação do registro anterior após a reabertura.
- [x] Criação de um novo registro ao concluir novamente uma publicação.
- [x] Associação do registro ao doador e ao beneficiário.
- [x] Consulta do histórico de doações feitas pela conta do doador.
- [x] Consulta do histórico de doações recebidas pela conta do beneficiário.
- [x] Exibição dos registros concluídos e reabertos no histórico.
- [x] Exibição das informações da publicação e dos participantes nos cards.
- [x] Integração da tela de histórico com a opção correspondente no perfil.
- [x] Aplicação das regras de segurança da coleção `doacoes`.
- [x] Criação de notificações de novo interesse.
- [x] Criação de notificações após a escolha de um beneficiário.
- [x] Criação de notificações após a conclusão de uma doação.
- [x] Criação de notificações após a reabertura de uma doação.
- [x] Criação de notificações após o envio de mensagens.
- [x] Verificação de que o remetente não recebe notificação da própria mensagem.
- [x] Consulta das notificações pela conta destinatária.
- [x] Atualização da lista de notificações em tempo real.
- [x] Atualização do contador de notificações não lidas na Home.
- [x] Marcação de notificações como lidas.
- [x] Navegação para os destinos correspondentes a cada notificação.
- [x] Abertura da tela de interessados ao selecionar uma notificação de novo interesse.
- [x] Abertura da conversa correta ao selecionar uma notificação de mensagem.
- [x] Validação das regras de segurança da subcoleção `notificacoes`.
- [x] Acesso à tela Ajuda e Segurança pela tela de perfil.
- [x] Exibição dos quatro passos do processo de doação.
- [x] Exibição das perguntas frequentes.
- [x] Expansão e recolhimento das perguntas.
- [x] Verificação de que a primeira pergunta começa expandida.
- [x] Navegação de retorno ao perfil.
- [x] Bloqueio e desbloqueio de usuários nos dois sentidos, utilizando duas contas.
- [x] Ocultação das publicações entre usuários bloqueados.
- [x] Desativação do envio de mensagens para ambos os participantes.
- [x] Preservação do histórico das conversas durante o bloqueio.
- [x] Exibição da lista de usuários bloqueados no perfil.
- [x] Restauração da visibilidade das publicações após o desbloqueio.
- [x] Restauração do envio de mensagens após o desbloqueio.

A análise estática com `flutter analyze` foi executada durante o desenvolvimento. Na verificação mais recente, não foram identificados erros. Permanecem apontamentos informativos e avisos de lint e depreciação no projeto.

## Funcionalidades pendentes

- [ ] Exclusão dos arquivos de imagem no Cloudinary ao remover uma publicação.
- [ ] Avaliações.
- [ ] Implementação do painel administrativo, incluindo consulta e gerenciamento das denúncias.
- [ ] Testes de interface em diferentes dispositivos Android.
- [ ] Aprimoramentos de segurança para o upload de imagens, incluindo a migração para upload assinado por backend.

## Próximas etapas

### Funcionalidades posteriores

- Desenvolver avaliações.
- Implementar o painel administrativo para consulta e gerenciamento das denúncias.
- Aprimorar a segurança da infraestrutura e do upload de imagens.

A ordem das etapas poderá ser ajustada conforme a evolução do desenvolvimento.

## Observações

O Desapegaí é uma plataforma voltada exclusivamente a doações gratuitas. Não estão previstas funcionalidades de venda, troca de produtos ou intermediação de pagamentos.