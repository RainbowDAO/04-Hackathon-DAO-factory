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
