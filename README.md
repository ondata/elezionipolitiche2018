<!-- TOC -->

- [Leggimi](#leggimi)
    - [Script](#script)
    - [Dati](#dati)
        - [Anagrafica codici Comuni, Ministero vs ISTAT](#anagrafica-codici-comuni-ministero-vs-istat)
        - [Anagrafica geografica](#anagrafica-geografica)
        - [Votanti](#votanti)
        - [Scrutini](#scrutini)
- [Note](#note)
- [Sitografia](#sitografia)

<!-- /TOC -->

## Leggimi

Degli script per scaricare i dati sulle **elezioni** politiche del **4 marzo 2018** in **Italia** e i dati stessi.

La fonte è [http://elezioni.interno.gov.it/eligendo](http://elezioni.interno.gov.it/eligendo).

### Script

Sono due script in bash:

- [dwVotanti.sh](./dwVotanti.sh) per scaricare i dati sui votanti di questa tornata elettorale;
- [dwScrutini.sh](./dwScrutini.sh) per scaricare i risultati di questa tornata elettorale.

### Dati

Tutti i CSV elencati a seguire utilizzano come separatore la `,` e l'*encoding* è `UTF-8`. 
<br>I dati **replicano** lo **schema di output originale** (con piccole modifiche):

- [questo](https://github.com/ondata/elezionipolitiche2018/blob/master/rawData/scrutiniCI_c01000000000.json) un file per come è esposto sul sito del ministero;
  - da qui estriamo la parte anagrafica in testa ad ogni file di output, per costruire un file di riepilogo (come [questo](https://github.com/ondata/elezionipolitiche2018/blob/master/dati/riepilogo.json))
  - estraiamo i dettagli (un [esempio](https://github.com/ondata/elezionipolitiche2018/blob/master/scrutini/scrutiniCI_c01000000000.json));
  - mettiamo insieme i file con i dettagli per creare  alcuni dei file di insieme indicati sotti.

#### Anagrafica codici Comuni, Ministero vs ISTAT

  - [comuniViminaleISTAT.csv](./risorse/comuniViminaleISTAT.csv), una tabella che mette in relazione i codici assegnati dal Ministero dell'Interno ai codici comunali di ISTAT.
#### Anagrafica geografica

- per la Camera: [camera_geopolitico_italia.csv](./dati/camera_geopolitico_italia.csv)
- per il Senato: [senato_geopolitico_italia.csv](./dati/senato_geopolitico_italia.csv)

Sotto un esempio della struttura gerarchica per la Camera.

**Nota Bene**: alla voce denominata "Comune" su Eligendo non corrispondono sempre in modo univoco dei comuni, ma per città grandi anche parte di esse (come `24120550510`, che non è il Comune di Palermo per intero, ma una sua parte).

| ID          | Nome                          | Livello gerarchico     | URI                                                                                                                                                            | 
|-------------|-------------------------------|------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------| 
| 24000000000 | SICILIA 1 | Circoscrizione | [http://elezioni.interno.gov.it/camera/scrutini/20180304/scrutiniCI24000000000](http://elezioni.interno.gov.it/camera/scrutini/20180304/scrutiniCI24000000000) | 
| 24100000000 | SICILIA 1 - 01 | Collegio plurinominale | [http://elezioni.interno.gov.it/camera/scrutini/20180304/scrutiniCI24100000000](http://elezioni.interno.gov.it/camera/scrutini/20180304/scrutiniCI24100000000) | 
| 24120000000 | 02 - PALERMO - LIBERTÀ | Collegio uninominale | [http://elezioni.interno.gov.it/camera/scrutini/20180304/scrutiniCI24120000000](http://elezioni.interno.gov.it/camera/scrutini/20180304/scrutiniCI24120000000) | 
| 24120550510 | PALERMO - SICILIA 1 - 01 - 02 | Comune | [http://elezioni.interno.gov.it/camera/scrutini/20180304/scrutiniCI24120550510](http://elezioni.interno.gov.it/camera/scrutini/20180304/scrutiniCI24120550510) | 



#### Votanti

- votanti per Comune Camera > [votantiCIComuni.csv](./dati/votantiCIComuni.csv)
- votanti per Comune Senato > [votantiSIComuni.csv](./dati/votantiSIComuni.csv)
- anagrafica con i codici delle province > [anagraficaProvince.csv](./dati/anagraficaProvince.csv)

**NOTA BENE**: manca la sezione Estero

#### Scrutini

- scrutini Camera per Circoscrizione: [scrutiniCI_c.csv](./dati/scrutiniCI_c.csv)
- scrutini Camera per Collegio Plurinominale: [scrutiniCI_p.csv](./dati/scrutiniCI_p.csv)
- scrutini Camera per Collegio Uninominale: [scrutiniCI_u.csv](./dati/scrutiniCI_u.csv)
- scrutini Camera per Comune (in realtà non sono strettamente i "Comuni", ma sono definiti come "Comuni" in Eligendo): [scrutiniCI_cm.csv](./dati/scrutiniCI_cm.csv)
- scrutini Senato per Circoscrizione: [scrutiniCI_c.csv](./dati/scrutiniSI_c.csv)
- scrutini Senato per Collegio Plurinominale: [scrutiniSI_p.csv](./dati/scrutiniSI_p.csv)
- scrutini Senato per Collegio Uninominale: [scrutiniSI_u.csv](./dati/scrutiniSI_u.csv)
- scrutini Senato per Comune: [scrutiniSI_cm.csv](./dati/scrutiniSI_cm.csv)
- dati di riepilogo: [riepilogo.csv](./dati/riepilogo.csv)


**NOTA BENE**: manca la sezione Estero

## Note

- i numeri interi sono in origine riportati come stringhe con un inutile ed errato separatore delle migliaia. Ad esempio `"sk_bianche": "2.698"` doveva essere `"sk_bianche": 2698`;
- i nomi dei candidati sono riportati come `Nome Cognome`, mentre nelle liste candidati di ["Elezioni trasparenti"](http://dait.interno.gov.it/elezioni/trasparenza) come `Cognome Nome`. Non essendoci un `ID candidato `è quindi impossibile fare JOIN (a meno di non riorganizzare complessivamente i dati);
- i codici dei collegi elettorali di ISTAT sono differenti da quelli utilizzati dal Ministero degli Interni  (vedi [qui](https://forum.italia.it/t/sui-dati-dei-collegi-elettorali/2625));
- alcuni candidati hanno il loro nome all'interno del campo "voti_cand" (vedi [#9](https://github.com/ondata/elezionipolitiche2018/issues/9));
- alcune liste hanno valori "NaN,00" per le percentuali di voto (vedi [#8](https://github.com/ondata/elezionipolitiche2018/issues/8));
- ci sono comuni con una percentuale di votanti superiore al 100% (vedi [#11](https://github.com/ondata/elezionipolitiche2018/issues/11));
- i dati originali non hanno alcun identificativo (vedi [#12](https://github.com/ondata/elezionipolitiche2018/issues/12)).

## Sitografia

Una raccolta di post che hanno a che fare con questi dati:

- "Politica e immigrazione: scopri i comuni colpiti dall’effetto Brexit" di [Riccardo Saporiti](https://twitter.com/sapomnia), [http://www.infodata.ilsole24ore.com/2018/03/09/politica-immigrazione-scopri-comuni-colpiti-dalleffetto-brexit/](http://www.infodata.ilsole24ore.com/2018/03/09/politica-immigrazione-scopri-comuni-colpiti-dalleffetto-brexit/)
- "the 4 italies" di [Filippo Mastroianni](https://twitter.com/FilMastroianni),  [https://public.tableau.com/profile/filippo.mastroianni#!/vizhome/TheFourItaliesItalyaftertheElection2018/The4Italies](https://public.tableau.com/profile/filippo.mastroianni#!/vizhome/TheFourItaliesItalyaftertheElection2018/The4Italies)
- "Elezioni 2018: mappe e grafici prima, durante e dopo il voto" di [Marianna Bruschi](https://twitter.com/MariannaBruschi), [https://medium.com/@MariannaBruschi/elezioni-2018-mappe-e-grafici-prima-durante-e-dopo-il-voto-143fd02e6db2](https://medium.com/@MariannaBruschi/elezioni-2018-mappe-e-grafici-prima-durante-e-dopo-il-voto-143fd02e6db2)
- "Le vere mappe delle Elezioni Italiane" di [Giuseppe Sollazzo](https://twitter.com/puntofisso) [https://medium.com/@puntofisso/le-vere-mappe-delle-elezione-italiane-a0cb89d27d9e](https://medium.com/@puntofisso/le-vere-mappe-delle-elezione-italiane-a0cb89d27d9e)
- "Elezioni e vaccini, il voto NoVax non esiste" di  [Riccardo Saporiti](https://twitter.com/sapomnia), [https://www.wired.it/attualita/politica/2018/03/08/elezioni-vaccini-voto-novax/](https://www.wired.it/attualita/politica/2018/03/08/elezioni-vaccini-voto-novax/);
- "Italia, i quattro volti e i quattro colori post elezioni" di [Filippo Mastroianni](https://twitter.com/FilMastroianni), [http://www.infodata.ilsole24ore.com/2018/03/12/italia-quattro-volti-quattro-colori-post-elezioni/](http://www.infodata.ilsole24ore.com/2018/03/12/italia-quattro-volti-quattro-colori-post-elezioni/);
- "Non è (solo) la disoccupazione giovanile ad aver spinto il M5S" di [Riccardo Saporiti](https://twitter.com/sapomnia), [http://www.infodata.ilsole24ore.com/2018/03/13/non-solo-la-disoccupazione-giovanile-ad-aver-spinto-m5s/](http://www.infodata.ilsole24ore.com/2018/03/13/non-solo-la-disoccupazione-giovanile-ad-aver-spinto-m5s/)
- "Elezioni politiche 2018" di [Guenter Richter](https://twitter.com/grichter), [http://exp.ixmaps.com.s3-website-eu-west-1.amazonaws.com/ixmaps/app/Elezioni%202018/index_2018_maps.html](http://exp.ixmaps.com.s3-website-eu-west-1.amazonaws.com/ixmaps/app/Elezioni%202018/index_2018_maps.html);
- "La sicurezza fa vincere le elezioni? Sì, ma solo se i reati sono in calo" di [Riccardo Saporiti](https://twitter.com/sapomnia), [http://www.infodata.ilsole24ore.com/2018/03/15/la-sicurezza-vincere-le-elezioni-si-solo-reati-calo/](http://www.infodata.ilsole24ore.com/2018/03/15/la-sicurezza-vincere-le-elezioni-si-solo-reati-calo/);
- "Analisi post-voto: il caso Lombardia" di [Filippo Mastroianni](https://twitter.com/FilMastroianni), [http://www.infodata.ilsole24ore.com/2018/03/15/analisi-post-voto-caso-lombardia/](http://www.infodata.ilsole24ore.com/2018/03/15/analisi-post-voto-caso-lombardia/)

---

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Licenza Creative Commons" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />Quest'opera è distribuita con Licenza <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribuzione 4.0 Internazionale</a>.
