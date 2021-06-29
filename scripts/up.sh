Red='\033[0;31m'
Green='\033[0;32m'
Color_Off='\033[0m'

export CA_IMAGE=1.5

export ROOT_DIR=$PWD/..
export ICA_HOST_NAME=intermediate.ca.test.com

CA_ADMIN_USER_ENROLLMENT_ID=caAdmin
CA_ADMIN_USER_ENROLLMENT_PW=caAdmin@1234

#Environment variables for ICA
export ORG_ICA_HOST=intermediate.ca.test.com
export ORG_ICA_URL=0.0.0.0
export ORG_ICA_PORT=7054


# Enroll nodes/users to the Certification Authority for digital certificate or TLS certificates
enrollToCA(){
    #Assign variables
    HOME=$1
    MSPDIR=$2
    TLS_CERTFILES=$3
    ENROLLMENT_ID=$4
    ENROLLMENT_PASSWORD=$5
    CA_URL=$6
    CA_PORT=$7
    CSR_HOSTS=$8
    ID_TYPE=$9

    export FABRIC_CA_CLIENT_HOME=$HOME
    export FABRIC_CA_CLIENT_MSPDIR=$MSPDIR
    export FABRIC_CA_CLIENT_TLS_CERTFILES=$TLS_CERTFILES

    which fabric-ca-client
    if [ "$?" -ne 0 ]; then
        echo -e "${Red}"
        echo "-------------------------------"
        echo "-------------------------------"
        echo "Failed to find fabric-ca-client. Please verify fabric-ca-client exists on GO path bin folder"
        echo "-------------------------------"
        echo "-------------------------------"
        echo -e "${Color_Off}"
        exit 1
    fi

    set -x
    fabric-ca-client enroll -d -u https://$ENROLLMENT_ID:$ENROLLMENT_PASSWORD@$CA_URL:$CA_PORT --csr.hosts $CSR_HOSTS --enrollment.attrs "hf.Type:opt,hf.Registrar.Roles:opt" --id.type $ID_TYPE
    res=$?
    set +x
    if [ $res -ne 0 ]; then
        echo -e "${Red}"
        echo "----------------------------------------------"
        echo "----------------------------------------------"
        echo "Failed to enroll ${ENROLLMENT_ID} to CA Server ${CA_URL}:${CA_PORT}"
        echo "----------------------------------------------"
        echo "----------------------------------------------"
        echo -e "${Color_Off}"
        exit 1
    fi
    echo
}

function createRootCa(){
echo -e "${Green}"
    echo "-------------------------------------------"
    echo "-------------------------------------------"
    echo "Setting up the Root Certification Authority"
    echo "-------------------------------------------"
    echo "-------------------------------------------"
    echo -e "${Color_Off}"
    # run the root Certification Authority
    cd $ROOT_DIR/root.ca.test.com
    docker-compose up -d
    sleep 10
}


function registerICA(){
    echo -e "${Green}"
    echo "------------------------------------------"
    echo "------------------------------------------"
    echo "Registering Intermediate CA to the Root CA"
    echo "------------------------------------------"
    echo "------------------------------------------"
    echo -e "${Color_Off}"
    # register iCA to the certification authority
    set -x
    docker exec root.ca.test.com ./etc/hyperledger/registerICA.sh
    set +x
    sleep 10

    echo -e "${Green}"
    echo "---------------------------------------------------"
    echo "---------------------------------------------------"
    echo "Setting up the Intermediate Certification Authority"
    echo "---------------------------------------------------"
    echo "---------------------------------------------------"
    echo -e "${Color_Off}"
    #setting up the intermediate CA
    cd $ROOT_DIR/$ORGICAHOST/fabric-ca-intermediate/crypto
    cp $ROOT_DIR/root.ca.test.com/fabric-ca/crypto/tls-cert.pem $ROOT_DIR/$ORGICAHOST/fabric-ca-intermediate/tls-cert.pem

    cd $ROOT_DIR/$ORGICAHOST/
    docker-compose up -d
    sleep 5    

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



createRootCa