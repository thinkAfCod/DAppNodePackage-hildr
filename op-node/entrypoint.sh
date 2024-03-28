#!/bin/sh

# If CUSTOM_L1_RPC is set, use it. Otherwise, use the proper value depending on the _DAPPNODE_GLOBAL_EXECUTION_CLIENT_MAINNET variable
if [ ! -z "$CUSTOM_L1_RPC" ]; then
  L1_RPC=$CUSTOM_L1_RPC
elif [ ! -z "$_DAPPNODE_GLOBAL_EXECUTION_CLIENT_MAINNET" ]; then
  case $_DAPPNODE_GLOBAL_EXECUTION_CLIENT_MAINNET in
  "geth.dnp.dappnode.eth")
    L1_RPC="http://geth.dappnode:8545"
    L1_WS_RPC="ws://geth.dappnode:8546"
    ;;
  "nethermind.public.dappnode.eth")
    L1_RPC="http://nethermind.public.dappnode:8545"
    L1_WS_RPC="ws://nethermind.public.dappnode:8546"
    ;;
  "erigon.dnp.dappnode.eth")
    L1_RPC="http://erigon.dappnode:8545"
    L1_WS_RPC="ws://erigon.dappnode:8546"
    ;;
  "besu.public.dappnode.eth")
    L1_RPC="http://besu.public.dappnode:8545"
    L1_WS_RPC="ws://besu.public.dappnode:8546"
    ;;
  *)
    echo "Unknown value for _DAPPNODE_GLOBAL_EXECUTION_CLIENT_MAINNET: $_DAPPNODE_GLOBAL_EXECUTION_CLIENT_MAINNET"
    sleep 60
    exit 1
    ;;
  esac
else
  echo "No L1_RPC value set"
  sleep 60
  exit 1
fi

# If CUSTOM_L1_BEACON_API is set, use it. Otherwise, use the proper value depending on the _DAPPNODE_GLOBAL_CONSENSUS_CLIENT_MAINNET variable

if [ ! -z "$CUSTOM_L1_BEACON_API" ]; then
  L1_BEACON_API=$CUSTOM_L1_BEACON_API
elif [ ! -z "$_DAPPNODE_GLOBAL_CONSENSUS_CLIENT_MAINNET" ]; then
  case $_DAPPNODE_GLOBAL_CONSENSUS_CLIENT_MAINNET in
  "lodestar.dnp.dappnode.eth")
    L1_BEACON_API="http://beacon-chain.lodestar.dappnode:3500"
    ;;
  "lighthouse.dnp.dappnode.eth")
    L1_BEACON_API="http://beacon-chain.lighthouse.dappnode:3500"
    ;;
  "prysm.dnp.dappnode.eth")
    L1_BEACON_API="http://beacon-chain.prysm.dappnode:3500"
    ;;
  "teku.dnp.dappnode.eth")
    L1_BEACON_API="http://beacon-chain.teku.dappnode:3500"
    ;;
  "nimbus.dnp.dappnode.eth")
    L1_BEACON_API="http://nimbus.dappnode:4500"
    ;;
  *)
    echo "Unknown value for _DAPPNODE_GLOBAL_CONSENSUS_CLIENT_MAINNET: $_DAPPNODE_GLOBAL_CONSENSUS_CLIENT_MAINNET"
    sleep 60
    exit 1
    ;;
  esac
else
  echo "No L1_BEACON_API value set"
  sleep 60
  exit 1
fi

case $_DAPPNODE_GLOBAL_OP_EXECUTION_CLIENT in
"op-geth.dnp.dappnode.eth")
  L2_RPC="http://op-geth.dappnode:8545"
  L2_ENGINE="http://op-geth.dappnode:8551"
  JWT_PATH="/security/op-geth/jwtsecret.hex"
  ;;
"op-erigon.dnp.dappnode.eth")
  L2_RPC="http://op-geth.dappnode:8545"
  L2_ENGINE="http://op-erigon.dappnode:8551"
  JWT_PATH="/security/op-erigon/jwtsecret.hex"
  ;;
*)
  echo "Unknown value for _DAPPNODE_GLOBAL_OP_EXECUTION_CLIENT: $_DAPPNODE_GLOBAL_OP_EXECUTION_CLIENT"
  sleep 60
  exit 1
  ;;
esac

while true; do
  java --enable-preview \
    --network=op-mainnet \
    --l1-rpc-url="$L1_RPC" \
    --l1-ws-rpc-url="$L1_WS_RPC" \
    --l1-beacon-url="$L1_BEACON_API" \
    --l2-rpc-url= "$L2_RPC" \
    --l2-engine-url="$L2_ENGINE" \
    --jwt-secret="$JWT_PATH" \
    --rpc.addr=0.0.0.0 \
    --rpc.port=9545 \
    --log-level INFO \
    --sync-mode full \
    ${EXTRA_FLAGS}

  STATUS=$?

  if [ $STATUS -ne 0 ]; then
    echo "[ERROR - entrypoint ] hildr command failed with status $STATUS. Retrying in 1 minute..."
    echo "[ERROR - entrypoint ] L2 Client might be unreachable or not ready yet (downloading chain data can take hours)"
    sleep 60
  else
    break
  fi
done
