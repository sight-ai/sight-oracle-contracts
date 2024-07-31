# Sight Ai Oracle Project

## install sight ai oracle contracts as dependency in your repository.

```shell
pnpm i -D "@sight-ai/contracts@github:sight-ai/fhe-oracle#v0.0.1&path:contracts" @openzeppelin/contracts
```

## read the _`src/UseCaseExample.sol`_ to use it.

## supported operations in library RequestBuilder at _`contracts/RequestBuilder.sol`_

# for this repo's UseCaseExample.sol

```shell
ln -sf `pwd` node_modules/@sight-ai
pnpm hardhat node
pnpm hardhat ignition deploy ./ignition/modules/Oracle.ts # deployed by hardhat
# set env:
# ORACLE_ADDR as it shows above
# PRIVATE_KEY as node console improves
# RPC_URL as http://localhost:8545
ORACLE_ADDR= PRIVATE_KEY= forge script --rpc-url ${RPC_URL} --broadcast script/UseCaseExample.s.sol # deployed by foundry
```
