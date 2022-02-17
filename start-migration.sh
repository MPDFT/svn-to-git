#!/bin/bash

cd $(dirname "$0")

PROJECT_NAME_KEY='PROJECT_NAME'
PROJECT_NAME=$(cat .env | grep -e "$PROJECT_NAME_KEY" | sed "s/$PROJECT_NAME_KEY=//")

WORKSPACE_DIR="./workspace-$PROJECT_NAME/"
GIT_REPO_DIR="$WORKSPACE_DIR/git-repo/"
if [ -d "$WORKSPACE_DIR" ]
then
    echo "Re-criando workspace $WORKSPACE_DIR ..."
    rm -rf $WORKSPACE_DIR
    if [ $? -ne 0 ]
    then
        echo "Tentando apagar a pasta $WORKSPACE_DIR com sudo ..."
        sudo rm -rf $WORKSPACE_DIR
    fi
else
    echo "Criando workspace $WORKSPACE_DIR ..."
fi
mkdir -p $GIT_REPO_DIR
cp ./docker-compose.yml "$WORKSPACE_DIR/"
cp ./Dockerfile "$WORKSPACE_DIR/"
cp ./migrate.sh "$WORKSPACE_DIR/"
cp ./openssl.cnf "$WORKSPACE_DIR/"
cp ./.env "$WORKSPACE_DIR/"

cd $WORKSPACE_DIR

if [ "${OSTYPE//[0-9.]/}" == "darwin" ]
then
    echo "MacOS detected... "
    docker compose up --build --build -d
    docker ps
else
    echo "Other OS detected... "
    sudo docker-compose up --build -d
    sudo docker ps
fi
echo "Migração do $PROJECT_NAME iniciada"