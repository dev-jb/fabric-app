Red='\033[0;31m'
Green='\033[0;32m'
Color_Off='\033[0m'


export CA_IMAGE=1.5
export ROOT_DIR=$PWD/..

export ICA_NAME=$1
export ICA_HOST=$2
export ICA_PORT=$3
export ICA_USER_NAME=$4
export ICA_PASSWORD=$5
export HOST_NAME=$6
export ROOT_CA_PSWD=$7
export RCA_PORT=$8

createIntermediateCa(){
    docker exec root.ca.$HOST_NAME fabric-ca-client register -d --id.name $ICA_NAME.$ICA_HOST --id.attrs 'hf.IntermediateCA=true' --id.secret $ICA_PASSWORD -u https://root.ca.$HOST_NAME:$RCA_PORT --tls.certfiles /etc/hyperledger/fabric-ca-server/crypto/tls-cert.pem
    sleep 5
    mkdir $ROOT_DIR/$ICA_NAME.$ICA_HOST
    cp $ROOT_DIR/samples/intermediate.ca-sample.yaml $ROOT_DIR/$ICA_NAME.$ICA_HOST/docker-compose.yaml

    mkdir -p $ROOT_DIR/$ICA_NAME.$ICA_HOST/fabric-ca-intermediate/crypto
    cd $ROOT_DIR/$ICA_NAME.$ICA_HOST/fabric-ca-intermediate/crypto
    cp $ROOT_DIR/root.ca/fabric-ca/crypto/tls-cert.pem $ROOT_DIR/$ICA_NAME.$ICA_HOST/fabric-ca-intermediate/tls-cert.pem
}

startICA(){
    cd $ROOT_DIR/$ICA_NAME.$ICA_HOST
    docker-compose up -d 
}

enrollAdmin(){
    #enrolling the admin to iCA
    echo -e "${Green}"
    echo "-------------------------------------------------------"
    echo "-------------------------------------------------------"
    echo "Enrolling Admin to Intermediate Certification Authority"
    echo "-------------------------------------------------------"
    echo "-------------------------------------------------------"
    echo -e "${Color_Off}"
    cd $ROOT_DIR
    mkdir admin admin/msp admin/msp/admincerts
    cp $ROOT_DIR/$ORGICAHOST/fabric-ca-intermediate/crypto/ca-cert.pem ./admin/ca-cert.pem
    set -x
    enrollToCA $ROOT_DIR/admin $ROOT_DIR/admin/msp $ROOT_DIR/admin/ca-cert.pem $CA_ADMIN_USER_ENROLLMENT_ID $CA_ADMIN_USER_ENROLLMENT_PW $ORGICAURL $ORGICAPORT 0.0.0.0 admin
    set +x

    cp $ROOT_DIR/admin/msp/signcerts/cert.pem $ROOT_DIR/admin/msp/admincerts/admin-cert.pem
}

createIntermediateCa
startICA