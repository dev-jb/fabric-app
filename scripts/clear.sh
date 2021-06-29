#!/bin/bash
# clear the previous setup network
ROOT_DIR=$PWD/..
function clearNetwork(){
    echo "Stopping all the containers"
    docker stop $(docker ps -q)
    sleep 10
    echo "Removing all the unused containers, volumes and networks"
    docker rm $(docker ps -aq)
    yes | docker volume prune
    yes | docker network prune
}

function clearFolders(){
    cd $ROOT_DIR/root.ca.test.com
    docker-compose down --volumes
    rm -rf fabric-ca/admin fabric-ca/msp fabric-ca/fabric-ca-client-config.yaml fabric-ca/crypto/msp fabric-ca/crypto/fabric-ca-server.db fabric-ca/crypto/IssuerPublicKey fabric-ca/crypto/fabric-ca-client-config.yaml fabric-ca/crypto/IssuerRevocationPublicKey fabric-ca/crypto/tls-cert.pem fabric-ca/crypto/ca fabric-ca/crypto/tlsca fabric-ca/crypto/ca-cert.pem
}

# clearNetwork
clearFolders
