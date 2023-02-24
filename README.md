# mmcoin
A sample flutter dapp that interact with a solidity smart contract deployed on ethereum TestNet using web3dart package. 

## app ui 
The app use sample ui to show balance of MMCoin, deposit and withdraw in interaction of the smart contract.

## smart contract info
mmcoin.sol is a smart contract on ethereum TestNet I have compiled and deployed. The app will interact with that contract. 
Here is the whole contract code:

```solidity
    // SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
contract MMCoin{
    int balance;

    constructor(){
        balance = 0;
    }

    function getBalance() public view returns (int ) {
        return balance;
    }

    function depositBalance(int depositAmount) public{
        balance = balance + depositAmount;
    }

    function withdrawBalance(int withdrawAmount) public{
        balance = balance - withdrawAmount;
    }
}
```
## abi and smart contract address
Since the app interact with a smart contract, we needs abi of that smart contract to make interaction through.
We can find smart contract abi under assets folder named abi.json, you got it when you deployed a smart contract.
We also need the smart contract address. Using abi and smart contract address, flutter can load deployed smart contract.
Here is the code in flutter:

```dart
    Future<DeployedContract> loadContract() async {
  String abi = await rootBundle.loadString("assets/abi.json");
  //print(abi);
  String contractAddress = "0xbF16FFA4860112707d387D12266f51bdC434b754";
  final contract = DeployedContract(ContractAbi.fromJson(abi, "MMCoin"),
      EthereumAddress.fromHex(contractAddress));
  return contract;
}

```

## ethereum client
Since the app interact with smart contract on ethereum testnet, we need to access testnet through ethereum client name Infura.
web3dart will connect a JSON rpc API url of your project, you can create it on Infura. I used goerli testnet.  
Here is the code in flutter:
```dart
   @override
void initState() {
  super.initState();
  httpClient = Client();
  ethClient = Web3Client(
      "https://goerli.infura.io/v3/850bbd87f23c48119f22119992cb901e",
      httpClient);
}

```

## smart contract calls in app
To make a smart contract call with app, we need to change private key of your wallet address. 
Here is the code in flutter:
```dart
   Future<String> submit(String functionName, List<dynamic> args) async {
  EthPrivateKey credential = EthPrivateKey.fromHex(
      "your wallet address private key");
  DeployedContract contract = await loadContract();
  final ethFunction = contract.function(functionName);
  final result = await ethClient.sendTransaction(
      credential,
      Transaction.callContract(
        contract: contract,
        function: ethFunction,
        parameters: args,
        maxGas: 100000,
      ),
      chainId: 5);
  print(result.toString());
  return result;
}

```

- [Remix IDE](https://remix.ethereum.org/)
- [Infura](https://www.infura.io/)

I followed this tutorial, view the
[original tutorial](https://medium.com/geekculture/simple-dapp-using-flutter-and-solidity-b64f5267acf4), which offers a full reference.
