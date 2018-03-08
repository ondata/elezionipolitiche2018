#!/bin/bash

### requisiti ###
# jq https://stedolan.github.io/jq/
# csvkit https://csvkit.readthedocs.io
### requisiti ###

set -x

mkdir -p ./province
mkdir -p ./tmp

# scarico i dati anagrafici
#curl -sL "http://elezioni.interno.gov.it/assets/enti/camerasenato_territoriale_italia.json" >./dati/camerasenato_territoriale_italia.json

# li converto in CSV
jq '[.enti[]]' ./dati/camerasenato_territoriale_italia.json | in2csv -I -f json >./dati/camerasenato_territoriale_italia.csv

# estraggo la lista dei codici delle province
csvcut -c 1 ./dati/camerasenato_territoriale_italia.csv | grep -E '^.*0000$' | grep -v -E '.*000000$' >./tmp/campioneProvince.csv

# estraggo l'anagrafica dei codici delle province
csvgrep -c "id" -r "[^0]0000$" ./dati/camerasenato_territoriale_italia.csv >./anagraficaProvince.csv

# scarico i dettagli sui votanti alla Camera
while read p; do
	codice=$(echo "$p" | sed -r 's/0000$//g')
	echo "$codice"
	curl -X GET \
		http://elezioni.interno.gov.it/votanti/votanti20180304/votantiCI"$codice" \
		-H 'accept: application/json, text/javascript, */*; q=0.01' \
		-H 'accept-encoding: gzip, deflate' \
		-H 'accept-language: it,en-US;q=0.9,en;q=0.8' \
		-H 'cache-control: no-cache' \
		-H 'content-type: application/json' \
		-H 'postman-token: ead779f5-6125-4c7a-a9d2-46213fe299da' \
		-H 'referer: http://elezioni.interno.gov.it/camera/votanti/20180304/votantiCI'"$codice"'' \
		-H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.106 Safari/537.36' \
		-H 'x-requested-with: XMLHttpRequest' | jq '[.righe[]|{provincia:("'"$codice"'" + "0000"),livello,ente,href,comuni_perv,comuni,perc_ore12,perc_ore19,perc_ore23,percprec_ore23}]' >./province/votantiCI"$codice".json
done <./tmp/campioneProvince.csv

# scarico i dettagli sui votanti al Senato
while read p; do
	codice=$(echo "$p" | sed -r 's/0000$//g')
	echo "$codice"
	curl -X GET \
		http://elezioni.interno.gov.it/votanti/votanti20180304/votantiSI"$codice" \
		-H 'accept: application/json, text/javascript, */*; q=0.01' \
		-H 'accept-encoding: gzip, deflate' \
		-H 'accept-language: it,en-US;q=0.9,en;q=0.8' \
		-H 'cache-control: no-cache' \
		-H 'content-type: application/json' \
		-H 'postman-token: ead779f5-6125-4c7a-a9d2-46213fe299da' \
		-H 'referer: http://elezioni.interno.gov.it/camera/votanti/20180304/votantiSI'"$codice"'' \
		-H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.106 Safari/537.36' \
		-H 'x-requested-with: XMLHttpRequest' | jq '[.righe[]|{provincia:("'"$codice"'" + "0000"),livello,ente,href,comuni_perv,comuni,perc_ore23,percprec_ore23}]' >./province/votantiSI"$codice".json
done <./tmp/campioneProvince.csv



# faccio il merge dei dati sui votanti alla Camera
jq -s add ./province/votantiCI*.json >./votantiCIprovinceRaw.json
# converto in CSV il file di sopra
in2csv <./votantiCIprovinceRaw.json -I -f json >./votantiCIprovince_tmp.csv
# Estraggo i dati soltanto sui Comuni alla Camera
csvgrep <./votantiCIprovince_tmp.csv -c "livello" -r "^2$" >./votantiCIComuni.csv
# Estraggo i dati soltanto sulle Province alla Camera
csvgrep <./votantiCIprovince_tmp.csv -c "livello" -r "^1$" >./votantiCIprovince.csv

# faccio il merge dei dati sui votanti al Senato
jq -s add ./province/votantiSI*.json >./votantiSIprovinceRaw.json
# converto in CSV il file di sopra
in2csv <./votantiSIprovinceRaw.json -I -f json >./votantiSIprovince_tmp.csv
# Estraggo i dati soltanto sui Comuni al Senato
csvgrep <./votantiSIprovince_tmp.csv -c "livello" -r "^2$" >./votantiSIComuni.csv
# Estraggo i dati soltanto sulle Province al Senato
csvgrep <./votantiSIprovince_tmp.csv -c "livello" -r "^1$" >./votantiSIprovince.csv

rm *_tmp*

mv ./*.json ./dati
mv ./*.csv ./dati

#git add .
#git commit -am "update"
#git push
