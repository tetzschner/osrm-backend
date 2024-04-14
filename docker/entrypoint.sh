#!/bin/bash

OSRM_PBF_URL=${OSRM_PBF_URL:=""}
OSRM_UPDATE_DATA_TAG=${OSRM_UPDATE_DATA_TAG:=OSRM_UPDATE_DATA_TAG}
REPLICA_NUMBER=${REPLICA_NUMBER:=1}
OSRM_PATH=/osrm-data/${REPLICA_NUMBER}

mkdir -p ${OSRM_PATH}
touch ${OSRM_PATH}/data.osrm.starting.timestamp

touch ${OSRM_PATH}/data.osrm.updated.tag
export OSRM_UPDATED_DATA_TAG=$(<${OSRM_PATH}/data.osrm.updated.tag)

echo "if ${OSRM_UPDATE_DATA_TAG} != ${OSRM_UPDATED_DATA_TAG}"

if [ "$OSRM_UPDATE_DATA_TAG" != "$OSRM_UPDATED_DATA_TAG" ]; then
    echo "Updating OSRM Data now..."
    rm ${OSRM_PATH}/* \
        && curl -L --insecure $OSRM_PBF_URL --create-dirs -o ${OSRM_PATH}/data.osm.pbf \
        && osrm-extract -p /opt/car.lua ${OSRM_PATH}/data.osm.pbf \
        && rm ${OSRM_PATH}/data.osm.pbf \
        && osrm-partition ${OSRM_PATH}/data.osrm \
        && osrm-customize ${OSRM_PATH}/data.osrm \
        && touch ${OSRM_PATH}/data.osrm.updated.timestamp

    # Unset the IS_UPDATE variable
    #unset IS_UPDATEING
    echo $OSRM_UPDATE_DATA_TAG > ${OSRM_PATH}/data.osrm.updated.tag
fi

touch ${OSRM_PATH}/data.osrm.starting2.timestamp
echo "Starting OSRM now..."
osrm-routed --algorithm mld ${OSRM_PATH}/data.osrm
