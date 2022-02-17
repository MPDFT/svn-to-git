# Migração para o Git

Script para migração de repositórios SVN para o git

## Requisitos

```
docker
```

## Configuração
Abrir o arquivo .env e preencher as variáveis de ambiente. 
AUTHOR_EMAIL e AUTHOR_NAME devem preenchidos com os dados do usuário atual - que está fazendo a migração - sem isso a ferramenta não consegue baixar as tags do projeto.
Recomendo que mantenha a variável PUSH_REPOSITORY como false - não faça o push após a migração - assim o repositório é gerado localmente dentro da pasta ./workspace e você pode conferir se deu certo antes de fazer o push.
Após finalizar, verifique o histórico do repositório git e as tags convertidas com os comandos

```
git log
git tag --list
```

## Execução

```
./start-migration.sh
```

É possível migrar vários projetos ao mesmo tempo, basta alterar o arquivo .env e executar o script que um container diferente será criado no docker para realizar a migração
