# Desapegaí

Este pacote contém **apenas** três telas Flutter:

- `LoginScreen`
- `RegisterScreen`
- `RecoverPasswordScreen`

Campos são visuais. Os botões **Entrar**, **Criar conta** e **Solicitar recuperação** exibem apenas uma mensagem de funcionalidade futura. A navegação funciona entre as três telas.


## Organização

```text
lib/
  main.dart
  app.dart
  core/
    theme/app_theme.dart
    widgets/auth_layout.dart
  features/
    auth/
      screens/
        login_screen.dart
        register_screen.dart
        recover_password_screen.dart
```

## Rotas

- `/` — Login
- `/cadastro` — Cadastro
- `/recuperar-senha` — Recuperação

Os arquivos serão ampliados nas próximas etapas, quando for implementado o SQLite e as regras de autenticação.
