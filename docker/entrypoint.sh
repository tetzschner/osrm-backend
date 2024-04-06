#!/bin/bash

curl -L --insecure https://download.geofabrik.de/europe/denmark-latest.osm.pbf --create-dirs -o /osrm-data/data.osm.pbf \
&& osrm-extract -p /opt/car.lua /osrm-data/data.osm.pbf \
&& rm /osrm-data/data.osm.pbf \
&& osrm-partition /osrm-data/data.osrm \
&& osrm-customize /osrm-data/data.osrm \
&& osrm-routed --algorithm mld /osrm-data/data.osrm
