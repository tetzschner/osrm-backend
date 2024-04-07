#!/bin/bash

OSRM_PBF_URL=${OSRM_PBF_URL:=""}
IS_UPDATEING=${IS_UPDATEING:=true}

mkdir -p /osrm-data
touch /osrm-data/data.osrm.starting.timestamp

if [ "$IS_UPDATEING" = "true" ]; then
    rm /osrm-data/* \
        && curl -L --insecure $OSRM_PBF_URL --create-dirs -o /osrm-data/data.osm.pbf \
        && osrm-extract -p /opt/car.lua /osrm-data/data.osm.pbf \
        && rm /osrm-data/data.osm.pbf \
        && osrm-partition /osrm-data/data.osrm \
        && osrm-customize /osrm-data/data.osrm \
        && touch /osrm-data/data.osrm.updated.timestamp

    # Unset the IS_UPDATE variable
    unset IS_UPDATEING
fi

touch /osrm-data/data.osrm.starting2.timestamp
osrm-routed --algorithm mld /osrm-data/data.osrm
