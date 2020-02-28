# wd-bitcoin-cryptolib
Implémentation de **ECDSA** secp256k1 ( la signature numérique à clé publique de Bitcoin ) en **WLangage**.

Utilise des routines en assembleurs pour les performances (1 ms en 64 bits pour vérifier une signature).

API principales :
* Créer une paire de clés :
  * **créePaireCléPrivéePublique**()
* Signer un message :
  * **signeBuffer**( sMessage, cléPrivée )
* Vérifier une signature :
  * **vérifieSignatureBuffer**( sMessage, cléPublique, signature)

 
 Génère un composant utilisable en 32 ou 64 bits dans un projet WINDEV 25.
 
 Le code assembleur est intégré via le compoant WD-Assembleur
