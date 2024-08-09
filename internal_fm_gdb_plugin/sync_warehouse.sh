#!/bin/bash

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <SSH_HOST> <MODEL_VER> <BASE_PATH>"
  exit 1
fi

SSH_HOST=$1
MODEL_VER=$2
BASE_PATH=$3

WH_BASE_PATH="/arm/warehouse/SysGen/PVModelLib"
MODEL_IRIS_PATH="external/Iris"

# Fetch the latest directory number
latestDir=$(ssh -o StrictHostKeyChecking=no $SSH_HOST ls -d ${WH_BASE_PATH}/${MODEL_VER}/*/ | grep -Eo '[0-9]+' | sort -n | tail -1)

mkdir -p ${BASE_PATH}/${MODEL_VER}/${latestDir}/${MODEL_IRIS_PATH}

rsync -avz $SSH_HOST:${WH_BASE_PATH}/${MODEL_VER}/${latestDir}/${MODEL_IRIS_PATH}/ ${BASE_PATH}/${MODEL_VER}/${latestDir}/${MODEL_IRIS_PATH}
