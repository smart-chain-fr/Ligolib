# ligo_tutorial_betting

This repository is meant to illustrate the communication between contracts (with `get_entrypoint_opt` LIGO function) and lambda pattern which allows to modify a contract already deployed. It deals with implementing, deploying and interacting with Tezos smart contracts.


## The Fund and its advisor (i.e. "L'indice et le conseiller")

The `indice` contract represents a fund value and the `advisor` contract gives an advice on investing on this fund. 


### Transaction workflow (callbacks)

The `advisor` contract can be invoked to request the fund value to the `indice` contract (via a transaction). The `indice` contract receives the request (transaction) and sends back the requested value. When `advisor` contract receives the fund value it can apply the "algorithm" to check it is worth investing ! This algorithm relies on a single indice value.

![](indice&advisor.png)

The resulting advice is stored in the storage (in `result` field).

### Transaction workflow (on-chain views introduced by ithaca)

Since ithaca protocol, on-chain views have been introduced which replaces the callbacks pattern to retrieve a storage of another contract.

The `views_ithaca` directory illustrates the on-chain views pattern.

The `v2` directory illustrates the on-chain views pattern where the advisor contract requests many "indice_value" of multiple indice contracts.

![](Indices&advisor.png)

### Lambda pattern

The real business logic of the `advisor` smart contract lies in the lambda function which is defined in the storage. The storage is vowed to be modified so as for the business logic (lambda).

So an entrypoint `ChangeAlgorithm` is provided to modify the algorithm that computes the worth of investment. 


## Content

The `src` directory illustrates the old-style callback pattern and contains 3 implementations:
- cameligo: for smart contracts implementation in cameligo and `ligo` command lines for simulating all entrypoints
- jsligo: for smart contracts implementation in JSligo and `ligo` command lines for simulating all entrypoints
- pascaligo: for smart contracts implementation in pascaligo and `ligo` command lines for simulating all entrypoints

The `views_ithaca` directory illustrates the new on-chain views style and contains 2 implementations:
- cameligo: for smart contracts implementation in cameligo and `ligo` command lines for simulating all entrypoints
- jsligo: for smart contracts implementation in JSligo and `ligo` command lines for simulating all entrypoints

The `v2` directory illustrates an advisor interacting with multiple indices. This directory contains 2 implementations:
- cameligo: for smart contracts implementation in cameligo and `ligo` command lines for simulating all entrypoints
- jsligo: for smart contracts implementation in JSligo and `ligo` command lines for simulating all entrypoints

## Pre-requisites

You may need to install the following tools:
- node & npm
- typescript compiler - `npm install typescript --save-dev`
- docker
- pytezos