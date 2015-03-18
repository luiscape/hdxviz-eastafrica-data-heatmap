#!/bin/bash

# Script para baixar os dados geográficos do IBGE,
# e transformá-los em topojson.

# Configurações
filePath="data/geo/ce.zip"

# Baixando o arquivo
wget -O $filePath \
	ftp://geoftp.ibge.gov.br/malhas_digitais/municipio_2010/ce.zip

# Descomprimindo o arquivo.
unzip data/geo/ce.zip -d "data/geo"

## Transformando o arquivo em GeoJSON + TopoJSON.
# Estado GeoJSON
ogr2ogr \
  -f GeoJSON \
  data/geo/ce_niv0.json \
  data/geo/ce/23UFE250GC_SIR.shp

# Estado TopoJSON
topojson \
  -o data/geo/ce_niv0.topojson \
  data/geo/ce_niv0.json

# Regiões (?) GeoJSON
ogr2ogr \
  -f GeoJSON \
  data/geo/ce_niv1.json \
  data/geo/ce/23UFE250GC_SIR.shp

# Regiões TopoJSON
topojson \
  -o data/geo/ce_niv1.topojson \
  data/geo/ce_niv1.json

# Distritos (?) GeoJSON
ogr2ogr \
  -f GeoJSON \
  data/geo/ce_niv2.json \
  data/geo/ce/23MIE250GC_SIR.shp

# Distritos TopoJSON
topojson \
  -o data/geo/ce_niv2.topojson \
  data/geo/ce_niv2.json

# Municípios (?) GeoJSON
ogr2ogr \
  -f GeoJSON \
  data/geo/ce_niv3.json \
  data/geo/ce/23MUE250GC_SIR.shp

# Municípios TopoJSON
topojson \
  -o data/geo/ce_niv3.topojson \
  data/geo/ce_niv3.json

# Limpeza
# rm data/geo/*.json
rm -rf data/geo/ce