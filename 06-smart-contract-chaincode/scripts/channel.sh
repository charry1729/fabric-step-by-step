#!/bin/bash

MODE=$1
CHANNEL_NAME="c1"
CAFILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/demo.com/orderers/o4.demo.com/msp/tlscacerts/tlsca.demo.com-cert.pem
TAG="2.0.0"

# r1 env
R1MSP=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/r1.demo.com/users/Admin@R1.demo.com/msp
R1ADDR=peer0.r1.demo.com:7051
R1MSPID="R1"
R1CRT=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/r1.demo.com/peers/peer0.r1.demo.com/tls/ca.crt 

# r2 env
R2MSP=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/r2.demo.com/users/Admin@R2.demo.com/msp
R2ADDR=peer0.r2.demo.com:8051
R2MSPID="R2"
R2CRT=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/r2.demo.com/peers/peer0.r2.demo.com/tls/ca.crt 

function help(){
  echo "Usage: "
  echo "  channel.sh <cmd>"
  echo "cmd: "
  echo "  - channeltx"
  echo "  - channel"
  echo "  - join"
  echo "  - anchor"
  echo "  - info"
}

function genChanTx(){
  FABRIC_CFG_PATH=$PWD
  configtxgen -profile CC1 -outputCreateChannelTx ./channel-artifacts/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME
}

function createChan(){
  cli peer channel create \
    -o o4.demo.com:7050 \
    -c $CHANNEL_NAME \
    -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/${CHANNEL_NAME}.tx \
    --outputBlock /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/${CHANNEL_NAME}.block \
    --tls \
    --cafile $CAFILE
}

function joinChan(){
  # r1 join
  CORE_PEER_MSPCONFIGPATH=${R1MSP}
  CORE_PEER_ADDRESS=${R1ADDR}
  CORE_PEER_LOCALMSPID=${R1MSPID}
  CORE_PEER_TLS_ROOTCERT_FILE=${R1CRT}
  cli peer channel join \
    -b /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/${CHANNEL_NAME}.block

  # r2 join
  CORE_PEER_MSPCONFIGPATH=${R2MSP}
  CORE_PEER_ADDRESS=${R2ADDR}
  CORE_PEER_LOCALMSPID=${R2MSPID}
  CORE_PEER_TLS_ROOTCERT_FILE=${R2CRT}
    -b /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/${CHANNEL_NAME}.block
  # show info
  showChanInfo
}

function showChanInfo(){
  peer channel list
  peer channel getinfo -c ${CHANNEL_NAME}
}

function setAnchor(){
  # anchor tx
  configtxgen -profile CC1 \
    -outputAnchorPeersUpdate ./channel-artifacts/R1MSPanchors.tx \
    -channelID $CHANNEL_NAME \
    -asOrg R1
  configtxgen -profile CC1 \
    -outputAnchorPeersUpdate ./channel-artifacts/R2MSPanchors.tx \
    -channelID $CHANNEL_NAME \
    -asOrg R2
  # anchor update
  CORE_PEER_MSPCONFIGPATH=${R1MSP}
  CORE_PEER_ADDRESS=${R1ADDR}
  CORE_PEER_LOCALMSPID=${R1MSPID}
  CORE_PEER_TLS_ROOTCERT_FILE=${R1CRT}
  cli peer channel update \
    -o o4.demo.com:7050 \
    -c $CHANNEL_NAME \
    -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/R1MSPanchors.tx \
    --tls \
    --cafile $CAFILE

  CORE_PEER_MSPCONFIGPATH=${R2MSP}
  CORE_PEER_ADDRESS=${R2ADDR}
  CORE_PEER_LOCALMSPID=${R2MSPID}
  CORE_PEER_TLS_ROOTCERT_FILE=${R2CRT}
  cli peer channel update \
    -o o4.demo.com:7050 \
    -c $CHANNEL_NAME \
    -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/R2MSPanchors.tx \
    --tls \
    --cafile $CAFILE
  # show info
  showChanInfo
}

if [ "$MODE" == "channeltx" ]; then
  genChanTx
elif [ "$MODE" == "channel" ]; then
  createChan    
elif [ "$MODE" == "join" ]; then
  joinChan
elif [ "$MODE" == "anchor" ]; then
  setAnchor
elif [ "$MODE" == "info" ]; then
  showChanInfo
elif [ "$MODE" == "combine" ]; then
  genChanTx
  createChan
  joinChan
  setAnchor
  showChanInfo
else        
  help
  exit 1
fi