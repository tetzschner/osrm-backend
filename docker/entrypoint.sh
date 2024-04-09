#!/bin/bash

OSRM_PBF_URL=${OSRM_PBF_URL:=""}
OSRM_UPDATE_DATA_TAG=${OSRM_UPDATE_DATA_TAG:=OSRM_UPDATE_DATA_TAG}

mkdir -p /osrm-data
touch /osrm-data/data.osrm.starting.timestamp

touch /osrm-data/data.osrm.updated.tag
export OSRM_UPDATED_DATA_TAG=$(</osrm-data/data.osrm.updated.tag)

if [ "$OSRM_UPDATE_DATA_TAG" != "$OSRM_UPDATED_DATA_TAG" ]; then
    rm /osrm-data/* \
        && curl -L --insecure $OSRM_PBF_URL --create-dirs -o /osrm-data/data.osm.pbf \
        && osrm-extract -p /opt/car.lua /osrm-data/data.osm.pbf \
        && rm /osrm-data/data.osm.pbf \
        && osrm-partition /osrm-data/data.osrm \
        && osrm-customize /osrm-data/data.osrm \
        && touch /osrm-data/data.osrm.updated.timestamp

    # Unset the IS_UPDATE variable
    #unset IS_UPDATEING
    echo $OSRM_UPDATE_DATA_TAG > /osrm-data/data.osrm.updated.tag
fi

touch /osrm-data/data.osrm.starting2.timestamp
osrm-routed --algorithm mld /osrm-data/data.osrm
