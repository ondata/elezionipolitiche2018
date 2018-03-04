#!/bin/bash

### requisiti ###
# jq https://stedolan.github.io/jq/
# csvkit https://csvkit.readthedocs.io
### requisiti ###

set -x

mkdir -p ./province
mkdir -p ./tmp
mkdir -p ./scrutini

# scarico i dati anagrafici
curl "http://elezioni.interno.gov.it/assets/enti/camera_geopolitico_italia.json" | jq . >./camera_geopolitico_italia.json

# li converto in CSV
jq '[.enti[]]' ./camera_geopolitico_italia.json | in2csv -I -f json >./camera_geopolitico_italia.csv

csvcut <./camera_geopolitico_italia.csv -c 1 >./camera_geopolitico_italia_tmp.csv

# estraggo i codici dei Comuni
ack '^...[^0](?!0000000)' ./camera_geopolitico_italia_tmp.csv >./scrutini/comuni.csv

# estraggo i codici dei colleggi uninominali
grep <./camera_geopolitico_italia_tmp.csv -E '...[^0]0000000' >./scrutini/colleggiUninominali.csv

# estraggo i codici dei colleggi plurinominali
grep <./camera_geopolitico_italia_tmp.csv -E '^..[^0]00000000' >./scrutini/colleggiPlurinominali.csv

# estraggo i codici delle circoscrizioni
grep <./camera_geopolitico_italia_tmp.csv -E '^.[^0]0{9}' >./scrutini/circoscrizioni.csv

# scarico i dettagli sui votanti alla Camera
while read p; do
	curl -X GET \
		http://elezioni.interno.gov.it/politiche/camera20180304/scrutiniCI"$p" \
		-H 'accept: application/json, text/javascript, */*; q=0.01' \
		-H 'accept-encoding: gzip, deflate' \
		-H 'accept-language: it,en-US;q=0.9,en;q=0.8' \
		-H 'cache-control: no-cache' \
		-H 'content-type: application/json' \
		-H 'postman-token: b8b67cdf-9521-4e07-2e63-99b28b20c2be' \
		-H 'referer: http://elezioni.interno.gov.it/camera/scrutini/20180304/scrutiniCI'"$p"'' \
		-H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.106 Safari/537.36' \
		-H 'x-requested-with: XMLHttpRequest' | jq '[.righe[]|{circoscrizione:"'"$p"'",tipo_riga,cand_descr_riga,img_lista,descr_lista,link_cand_lista,voti,perc,eletto,perc_voti_liste,cifra_el,perc_cifra_el,seggi}]' >./scrutini/scrutiniCI_c"$p".json
done <./scrutini/circoscrizioni.csv

jq -s add ./scrutini/scrutiniCI_c*.json >./scrutini/scrutiniCI_c.json

<./scrutini/scrutiniCI_c.json in2csv -I -f json >./scrutiniCI_c.csv

while read p; do
	curl -X GET \
		http://elezioni.interno.gov.it/politiche/camera20180304/scrutiniCI"$p" \
		-H 'accept: application/json, text/javascript, */*; q=0.01' \
		-H 'accept-encoding: gzip, deflate' \
		-H 'accept-language: it,en-US;q=0.9,en;q=0.8' \
		-H 'cache-control: no-cache' \
		-H 'content-type: application/json' \
		-H 'postman-token: b8b67cdf-9521-4e07-2e63-99b28b20c2be' \
		-H 'referer: http://elezioni.interno.gov.it/camera/scrutini/20180304/scrutiniCI'"$p"'' \
		-H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.106 Safari/537.36' \
		-H 'x-requested-with: XMLHttpRequest' | jq '[.righe[]|{collegioPlurinominale:"'"$p"'",tipo_riga,cand_descr_riga,img_lista,descr_lista,link_cand_lista,voti,perc,eletto,perc_voti_liste,cifra_el,perc_cifra_el,seggi}]' >./scrutini/scrutiniCI_p"$p".json
done <./scrutini/colleggiPlurinominali.csv

jq -s add ./scrutini/scrutiniCI_p*.json >./scrutini/scrutiniCI_p.json

<./scrutini/scrutiniCI_p.json in2csv -I -f json >./scrutiniCI_p.csv

while read p; do
	curl -X GET \
		http://elezioni.interno.gov.it/politiche/camera20180304/scrutiniCI"$p" \
		-H 'accept: application/json, text/javascript, */*; q=0.01' \
		-H 'accept-encoding: gzip, deflate' \
		-H 'accept-language: it,en-US;q=0.9,en;q=0.8' \
		-H 'cache-control: no-cache' \
		-H 'content-type: application/json' \
		-H 'postman-token: b8b67cdf-9521-4e07-2e63-99b28b20c2be' \
		-H 'referer: http://elezioni.interno.gov.it/camera/scrutini/20180304/scrutiniCI'"$p"'' \
		-H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.106 Safari/537.36' \
		-H 'x-requested-with: XMLHttpRequest' | jq '[.righe[]|{collegioPlurinominale:"'"$p"'",tipo_riga,cand_descr_riga,img_lista,descr_lista,link_cand_lista,voti,perc,eletto,perc_voti_liste,cifra_el,perc_cifra_el,seggi}]' >./scrutini/scrutiniCI_u"$p".json
done <./scrutini/colleggiUninominali.csv

jq -s add ./scrutini/scrutiniCI_u*.json >./scrutini/scrutiniCI_u.json

<./scrutini/scrutiniCI_u.json in2csv -I -f json >./scrutiniCI_u.csv
