#!/bin/bash

### requisiti ###
# jq https://stedolan.github.io/jq/
# csvkit https://csvkit.readthedocs.io
### requisiti ###

set -x

mkdir -p ./province
mkdir -p ./tmp
mkdir -p ./scrutini
mkdir -p ./rawData

# scarico i dati anagrafici
curl "http://elezioni.interno.gov.it/assets/enti/camera_geopolitico_italia.json" | jq . >./camera_geopolitico_italia.json

# li converto in CSV
jq '[.enti[]]' ./camera_geopolitico_italia.json | in2csv -I -f json >./camera_geopolitico_italia.csv

csvcut <./camera_geopolitico_italia.csv -c 1 >./camera_geopolitico_italia_tmp.csv

# estraggo i codici dei Comuni
ack '^...[^0](?!0000000)' ./camera_geopolitico_italia_tmp.csv >./scrutini/comuni.csv

# estraggo i codici dei collegi uninominali
grep <./camera_geopolitico_italia_tmp.csv -E '...[^0]0000000' >./scrutini/colleggiUninominali.csv

# estraggo i codici dei collegi plurinominali
grep <./camera_geopolitico_italia_tmp.csv -E '^..[^0]00000000' >./scrutini/colleggiPlurinominali.csv

# estraggo i codici delle circoscrizioni
grep <./camera_geopolitico_italia_tmp.csv -E '^.[^0]0{9}' >./scrutini/circoscrizioni.csv

# scarico i dettagli sugli scrutini alla Camera per Circoscrizione
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
		-H 'x-requested-with: XMLHttpRequest' | tee ./rawData/scrutiniCI_c"$p".json | jq '[.righe[]|{assemblea:"Camera",codice:"'"$p"'",tipo:"circoscrizione",tipo_riga,cand_descr_riga,img_lista,descr_lista,link_cand_lista,voti:.voti|gsub("\\.";""),perc,eletto,perc_voti_liste,cifra_el:.cifra_el|gsub("\\.";""),perc_cifra_el,seggi}]' >./scrutini/scrutiniCI_c"$p".json
done <./scrutini/circoscrizioni.csv

jq -s add ./scrutini/scrutiniCI_c*.json >./scrutini/scrutiniCI_c.json

in2csv <./scrutini/scrutiniCI_c.json -I -f json >./scrutiniCI_c.csv

# scarico i dettagli sugli scrutini alla Camera per Collegio Plurinominale
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
		-H 'x-requested-with: XMLHttpRequest' | tee ./rawData/scrutiniCI_p"$p".json | jq '[.righe[]|{assemblea:"Camera",codice:"'"$p"'",tipo:"colleggioPlurinominale",tipo_riga,cand_descr_riga,img_lista,descr_lista,link_cand_lista,voti:.voti|gsub("\\.";""),perc,eletto,perc_voti_liste,cifra_el:.cifra_el|gsub("\\.";""),perc_cifra_el,seggi}]' >./scrutini/scrutiniCI_p"$p".json
done <./scrutini/colleggiPlurinominali.csv

jq -s add ./scrutini/scrutiniCI_p*.json >./scrutini/scrutiniCI_p.json

in2csv <./scrutini/scrutiniCI_p.json -I -f json >./scrutiniCI_p.csv

# scarico i dettagli sugli scrutini alla Camera per Collegio Uninominale
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
		-H 'x-requested-with: XMLHttpRequest' | tee ./rawData/scrutiniCI_u"$p".json | jq '[.righe[]|{assemblea:"Camera",codice:"'"$p"'",tipo:"colleggioUninominale",tipo_riga,cand_descr_riga,img_lista,descr_lista,link_cand_lista,voti:.voti|gsub("\\.";""),perc,eletto,perc_voti_liste,cifra_el:.cifra_el|gsub("\\.";""),perc_cifra_el,seggi}]' >./scrutini/scrutiniCI_u"$p".json
done <./scrutini/colleggiUninominali.csv

jq -s add ./scrutini/scrutiniCI_u*.json >./scrutini/scrutiniCI_u.json

in2csv <./scrutini/scrutiniCI_u.json -I -f json >./scrutiniCI_u.csv

### SENATO ###

curl -sL "http://elezioni.interno.gov.it/assets/enti/senato_geopolitico_italia.json" | jq . >./senato_geopolitico_italia.json

# li converto in CSV
jq '[.enti[]]' ./senato_geopolitico_italia.json | in2csv -I -f json >./senato_geopolitico_italia.csv

csvcut <./senato_geopolitico_italia.csv -c 1 >./senato_geopolitico_italia_tmp.csv

# estraggo i codici dei Comuni
ack '^...[^0](?!0000000)' ./senato_geopolitico_italia_tmp.csv >./scrutini/comuniSI.csv

# estraggo i codici dei collegi uninominali
grep <./senato_geopolitico_italia_tmp.csv -E '...[^0]0000000' >./scrutini/colleggiUninominaliSI.csv

# estraggo i codici dei collegi plurinominali
grep <./senato_geopolitico_italia_tmp.csv -E '^..[^0]00000000' >./scrutini/colleggiPlurinominaliSI.csv

# estraggo i codici delle circoscrizioni
grep <./senato_geopolitico_italia_tmp.csv -E '^.[^0]0{9}' >./scrutini/circoscrizioniSI.csv

# scarico i dettagli sugli scrutini al Senato per Circoscrizione
while read p; do
	curl -X GET \
		http://elezioni.interno.gov.it/politiche/senato20180304/scrutiniSI"$p" \
		-H 'accept: application/json, text/javascript, */*; q=0.01' \
		-H 'accept-encoding: gzip, deflate' \
		-H 'accept-language: it,en-US;q=0.9,en;q=0.8' \
		-H 'cache-control: no-cache' \
		-H 'content-type: application/json' \
		-H 'postman-token: d7765423-a0a9-6a75-eafb-965ef2e8aaf2' \
		-H 'referer: http://elezioni.interno.gov.it/senato/scrutini/20180304/scrutiniSI'"$p"'' \
		-H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.106 Safari/537.36' \
		-H 'x-requested-with: XMLHttpRequest' | tee ./rawData/scrutiniSI_c"$p".json | jq '[.righe[]|{assemblea:"Senato",codice:"'"$p"'",tipo:"circoscrizione",tipo_riga,cand_descr_riga,img_lista,descr_lista,link_cand_lista,voti:.voti|gsub("\\.";""),perc,eletto,perc_voti_liste,cifra_el:.cifra_el|gsub("\\.";""),perc_cifra_el,seggi}]' >./scrutini/scrutiniSI_c"$p".json
done <./scrutini/circoscrizioniSI.csv

jq -s add ./scrutini/scrutiniSI_c*.json >./scrutini/scrutiniSI_c.json

in2csv <./scrutini/scrutiniSI_c.json -I -f json >./scrutiniSI_c.csv

# scarico i dettagli sugli scrutini al Senato per Collegio Plurinominale
while read p; do
	curl -X GET \
		http://elezioni.interno.gov.it/politiche/senato20180304/scrutiniSI"$p" \
		-H 'accept: application/json, text/javascript, */*; q=0.01' \
		-H 'accept-encoding: gzip, deflate' \
		-H 'accept-language: it,en-US;q=0.9,en;q=0.8' \
		-H 'cache-control: no-cache' \
		-H 'content-type: application/json' \
		-H 'postman-token: d7765423-a0a9-6a75-eafb-965ef2e8aaf2' \
		-H 'referer: http://elezioni.interno.gov.it/senato/scrutini/20180304/scrutiniSI'"$p"'' \
		-H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.106 Safari/537.36' \
		-H 'x-requested-with: XMLHttpRequest' | tee ./rawData/scrutiniSI_p"$p".json | jq '[.righe[]|{assemblea:"Senato",codice:"'"$p"'",tipo:"colleggioPlurinominale",tipo_riga,cand_descr_riga,img_lista,descr_lista,link_cand_lista,voti:.voti|gsub("\\.";""),perc,eletto,perc_voti_liste,cifra_el:.cifra_el|gsub("\\.";""),perc_cifra_el,seggi}]' >./scrutini/scrutiniSI_p"$p".json
done <./scrutini/colleggiPlurinominaliSI.csv

jq -s add ./scrutini/scrutiniSI_p*.json >./scrutini/scrutiniSI_p.json

in2csv <./scrutini/scrutiniSI_p.json -I -f json >./scrutiniSI_p.csv

# scarico i dettagli sugli scrutini al Senato per Collegio Uninominale
while read p; do
	curl -X GET \
		http://elezioni.interno.gov.it/politiche/senato20180304/scrutiniSI"$p" \
		-H 'accept: application/json, text/javascript, */*; q=0.01' \
		-H 'accept-encoding: gzip, deflate' \
		-H 'accept-language: it,en-US;q=0.9,en;q=0.8' \
		-H 'cache-control: no-cache' \
		-H 'content-type: application/json' \
		-H 'postman-token: d7765423-a0a9-6a75-eafb-965ef2e8aaf2' \
		-H 'referer: http://elezioni.interno.gov.it/senato/scrutini/20180304/scrutiniSI'"$p"'' \
		-H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.106 Safari/537.36' \
		-H 'x-requested-with: XMLHttpRequest' | tee ./rawData/scrutiniSI_u"$p".json | jq '[.righe[]|{assemblea:"Senato",codice:"'"$p"'",tipo:"colleggioUninominale",tipo_riga,cand_descr_riga,img_lista,descr_lista,link_cand_lista,voti:.voti|gsub("\\.";""),perc,eletto,perc_voti_liste,cifra_el:.cifra_el|gsub("\\.";""),perc_cifra_el,seggi}]' >./scrutini/scrutiniSI_u"$p".json
done <./scrutini/colleggiUninominaliSI.csv

jq -s add ./scrutini/scrutiniSI_u*.json >./scrutini/scrutiniSI_u.json

in2csv <./scrutini/scrutiniSI_u.json -I -f json >./scrutiniSI_u.csv

mkdir -p ./rawData/tmp
for i in ./rawData/*.json; do
	nome=$(echo "$i" | sed 's|\./rawData/||g')
	codice=$(echo "$i" | sed -r 's|(\./)(.*)(_)(.)([0-9]{1,100})(\.json)|\5|g')
	assemblea=$(echo "$i" | sed -r 's|(\./rawData/)(.*)(_)(.)([0-9]{1,100})(\.json)|\2|g')
	jq '[{assemblea:"'"$assemblea"'",codice:"'"$codice"'",status,elettori:.elettori|gsub("\\.";""),votanti:.votanti|gsub("\\.";""),perc_votanti,aggiornamento,sezioni_perv:.sezioni_perv|gsub("\\.";""),sezioni:.sezioni|gsub("\\.";""),coll_uni_perv,coll_uni,sezioni_coll_uni_perv,sk_bianche,sk_nulle,sk_contestate,livello,fine_riparto}]' "$i" >./rawData/tmp/"$nome"
	echo "$nome"
done

jq -s add ./rawData/tmp/*.json >./riepilogo.json
in2csv <./riepilogo.json -I -f json >./riepilogo.csv

mv ./*.json ./dati
mv ./*.csv ./dati
