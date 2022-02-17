#!/bin/bash

cd $(dirname "$0")

PROJECT_NAME_KEY='PROJECT_NAME'
PROJECT_NAME=$(cat .env | grep -e "$PROJECT_NAME_KEY" | sed "s/$PROJECT_NAME_KEY=//")

WORKSPACE_MAPPING="./workspace-$PROJECT_NAME"
if [ -d "$WORKSPACE_MAPPING" ]
then
    rm -rf $WORKSPACE_MAPPING
fi
echo "(Re) criando pasta $WORKSPACE_MAPPING ..."
mkdir -p $WORKSPACE_MAPPING

if [ "${OSTYPE//[0-9.]/}" == "darwin" ]
then
    echo "MacOS detected... "
    docker compose up --force-recreate --build
else
    echo "Other OS detected... "
    sudo docker-compose up --force-recreate --build
fi
