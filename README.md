# README
[![Build Status](https://travis-ci.org/DoniB/sabre_server.svg?branch=master)](https://travis-ci.org/DoniB/sabre_server)
[![Maintainability](https://api.codeclimate.com/v1/badges/e5ef7a4e22677fbf4cea/maintainability)](https://codeclimate.com/github/DoniB/sabre_server/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/e5ef7a4e22677fbf4cea/test_coverage)](https://codeclimate.com/github/DoniB/sabre_server/test_coverage)

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
POST example.com/api/v1/user
{
    username: 'username',
    email: 'email@example.com',
    password: 'password',
    password_confirmation: 'password' # não obrigatório
}
```

### Sign In / Token de acesso
```
POST example.com/api/v1/sign_in
{
    email: 'email@example.com',
    password: 'password'
}
```

### Informações de usuário
```
GET example.com/api/v1/user

HEADER 'X-Secure-Token: token'
```

### Enviar receita
```
POST example.com/api/v1/users/recipe
{
    name: 'name',
    ingredients: 'ingredients',
    directions: 'directions'
}

HEADER 'X-Secure-Token: token'
```

### Atualizar receita
```
PATCH example.com/api/v1/users/recipe/:id
{
    name: 'name',
    ingredients: 'ingredients',
    directions: 'directions',
    status: status_number
}

HEADER 'X-Secure-Token: token'

status só será aceito por usuários administrativos
administradores podem editar receitas de qualquer usuário
```

### Listar receita
```
GET example.com/api/v1/users/recipe
{
    name: 'name',
    ingredients: 'ingredients',
    directions: 'directions'
}

HEADER 'X-Secure-Token: token'

retorna receitas do usuário
se '?status=waiting_activation' retorna todas as receitas pendentes de ativação, de todos os usuários (tem que ser administrador)
```
