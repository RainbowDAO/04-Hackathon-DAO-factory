# Documentation on how to run the project

# Getting Started

## Dependencies

- Linux or Mac
- node ≥ 16


## Installing

```bash
git clone https://github.com/RainbowDAO/04-Hackathon-DAO-factory.git
npm install
```

**Note**: Only the Metamask wallet is available for this demo


## Deploy Contracts
```bash 
truffle compile && truffle migrate
```
You will deploy contracts
- Vault
- Authority
- DaoMain
- DaoManage
- ERC20Factory


When the deployment is finished, the address of the deployed contracts will be displayed on the console as follows.
```
DaoMain:  0x...
```

## Create a DAO
The creatDao in the DaoMain contract creates a DAO of its own, defining names, logos, and symbols
```
function creatDao()
```

### Contracts

1. Make sure you have node,npm and truffle installed.
2. Clone this repository.
3. Run ```npm install```
5. To run compile, run ```truffle compile```
6. To deploy the contracts, first open hardhat.config.js and change the accounts variables to your own private keys. Then change the defaultNetwork accordingly
   , deploy on your own network,run ```truffle migrate --network your network```
