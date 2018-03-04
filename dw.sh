#!/bin/bash

set -x

mkdir -p ./province
mkdir -p ./tmp

curl -sL "http://elezioni.interno.gov.it/assets/enti/camerasenato_territoriale_italia.json" >./camerasenato_territoriale_italia.json

jq '[.enti[]]' ./camerasenato_territoriale_italia.json | in2csv -I -f json >./camerasenato_territoriale_italia.csv

csvcut -c 1 ./camerasenato_territoriale_italia.csv | grep -E '[^0]0000$' >./tmp/campioneProvince.csv

csvgrep -c "id" -r "[^0]0000$" ./camerasenato_territoriale_italia.csv >./anagraficaProvince.csv

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
		-H 'x-requested-with: XMLHttpRequest' | jq '[.righe[]|{provincia:("'"$codice"'" + "0000"),livello,ente,href,comuni_perv,comuni,perc_ore12,perc_ore19,perc_ore2,percprec_ore233}]' >./province/votantiCI"$codice".json
done <./tmp/campioneProvince.csv

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
		-H 'x-requested-with: XMLHttpRequest' | jq '[.righe[]|{provincia:("'"$codice"'" + "0000"),livello,ente,href,comuni_perv,comuni,perc_ore12,perc_ore19,perc_ore2,percprec_ore233}]' >./province/votantiSI"$codice".json
done <./tmp/campioneProvince.csv

jq -s add ./province/votantiCI*.json >./votantiCIprovinceRaw.json

in2csv <./votantiCIprovinceRaw.json -I -f json >./votantiCIprovince_tmp.csv

csvgrep <./votantiCIprovince_tmp.csv -c "livello" -r "^2$" >./votantiCIComuni.csv
csvgrep <./votantiCIprovince_tmp.csv -c "livello" -r "^1$" >./votantiCIprovince.csv

jq -s add ./province/votantiCI*.json >./votantiSIprovinceRaw.json

in2csv <./votantiSIprovinceRaw.json -I -f json >./votantiSIprovince_tmp.csv

csvgrep <./votantiSIprovince_tmp.csv -c "livello" -r "^2$" >./votantiSIComuni.csv
csvgrep <./votantiSIprovince_tmp.csv -c "livello" -r "^1$" >./votantiSIprovince.csv

rm *_tmp*
