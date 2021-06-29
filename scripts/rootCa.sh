Red='\033[0;31m'
Green='\033[0;32m'
Color_Off='\033[0m'

export CA_IMAGE=1.5
export ROOT_DIR=$PWD/..
export HOST_NAME=$1
export ROOT_CA_USER_NAME=$2
export ROOT_CA_PSWD=$3

 createRootCa(){
    echo -e "${Green}"
    echo "-------------------------------------------"
    echo "-------------------------------------------"
    echo "Setting up the Root Certification Authority"
    echo "-------------------------------------------"
    echo "-------------------------------------------"
    echo -e "${Color_Off}"
    # run the root Certification Authority
    cd $ROOT_DIR/root.ca
    docker-compose up -d 
    sleep 5
    docker exec root.ca.$HOST_NAME fabric-ca-client enroll -d -u https://$ROOT_CA_USER_NAME:$ROOT_CA_PSWD@root.ca.$HOST_NAME:7053 --tls.certfiles /etc/hyperledger/fabric-ca-server/crypto/tls-cert.pem
    # sleep 10
}

createRootCa

# echo "Hi There!"