#!/bin/bash

### requisiti ###
# jq https://stedolan.github.io/jq/
# csvkit https://csvkit.readthedocs.io
### requisiti ###

set -x

# scarico i dati anagrafici
curl -sL "http://elezioni.interno.gov.it/assets/enti/camerasenato_territoriale_italia.json" >./camerasenato_territoriale_italia.json

# li converto in CSV
jq '[.enti[]]' ./camerasenato_territoriale_italia.json | in2csv -I -f json >./camerasenato_territoriale_italia.csv

# estraggo la lista dei codici delle province
csvcut -c 1 ./camerasenato_territoriale_italia.csv | grep -E '[^0]0000$' >./tmp/campioneProvince.csv

# estraggo l'anagrafica dei codici delle province
csvgrep -c "id" -r "[^0]0000$" ./camerasenato_territoriale_italia.csv >./anagraficaProvince.csv


