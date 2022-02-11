#!/bin/bash
WORKSPACE_MAPPING="./workspace"
if [ -d "$WORKSPACE_MAPPING" ]
then
    rm -rf $WORKSPACE_MAPPING
    mkdir -p $WORKSPACE_MAPPING
fi
docker compose up --force-recreate --build
