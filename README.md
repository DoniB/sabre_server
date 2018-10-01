# README

Repositório oficial SABRE_server.

SABRE é um sistema colaborativo de receitas em desenvolvimento como Trabalho de Conclusão de Curso na Universidade Tecnológica Federal do Paraná - UTFPR.

## Requisitos / Dependências

* Ruby 2.5
* Rails 5.2
  * rspec-rails 3.8
  * bcrypt
  * factory_bot_rails
  * faker
* PostgreSQL 10.4


## API

### Criar usuário
```
POST example.com/api/v1/users
{
    username: 'username',
    email; 'email@example.com',
    password: 'password',
    password_confirmation: 'password' # não obrigatório
}
```

### Sign In / Token de acesso
```
POST example.com/api/v1/sign_in
{
    email; 'email@example.com',
    password: 'password'
}
```

