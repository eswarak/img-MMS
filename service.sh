#!/bin/bash

# Very simple Horizon ML example using HZN MMS  to update ML model (index.js)
#ML model as tensorflow js
OBJECT_ID="index.js"
TEMP_DIR ="/tmp"
DESTINATION_PATH="${TEMP_DIR}/${OBJECT_ID}"
OBJECT_TYPE="js"
HT_DOCS="/var/www/localhost/htdocs/"


echo "DEBUG: *******  Started pulling ESS ..."

# ${HZN_ESS_AUTH} is mounted to this container and contains a json file with the credentials for authenticating to the ESS.
USER=$(cat ${HZN_ESS_AUTH} | jq -r ".id")
PW=$(cat ${HZN_ESS_AUTH} | jq -r ".token")

# Passing basic auth creds in base64 encoded form (-u).
AUTH="-u ${USER}:${PW} "

# ${HZN_ESS_CERT} is mounted to this container and contains the client side SSL cert to talk to the ESS API.
CERT="--cacert ${HZN_ESS_CERT} "

BASEURL='--unix-socket '${HZN_ESS_API_ADDRESS}' https://localhost/api/v1/objects/'
echo " auth, cert, baseURL: ${AUTH}${CERT}${BASEURL} ..."

#FILES=/tmp/*

hasData() {
	echo 'DEBUG: *******   New valid file was found in ESS'
        #cp /tmp/index.js /var/www/localhost/htdocs/index.js
				#$TEMP_DIR
				cp $DESTINATION_PATH $HT_DOCS/$OBJECT_ID
        echo 'DEBUG: *******  ESS Model updated ...'
}

noData() {
	echo "DEBUG: ******    ESS Model file exists but empty ..."
	#rm /tmp/index.js
}

checkUpdates() {
	for f in $TEMP_DIR
	do
	echo "DEBUG: ESS Processing $f file ..."
  	if [ -s $f ]
  	then
    		hasData
  	else
    		noData
  	fi
	done
}

while true; do
    echo "$HZN_DEVICE_ID is pulling ESS ..."
    sleep  30

    # read in new file from the ESS
    DATA=$(curl -sL -o ${DESTINATION_PATH} ${AUTH}${CERT}${BASEURL}${OBJECT_TYPE}/${OBJECT_ID}/data)

    #check updates
    checkUpdates
done
# see helloMMS for more details
# https://github.com/open-horizon/examples/tree/master/edge/services/helloMMS
