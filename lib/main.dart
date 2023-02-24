import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MMCoin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'MMCoin Wallet'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Client httpClient;
  late Web3Client ethClient;
  final myAddress = "0x0993284901597fDD30F4F548bEbDDE3BAfEA3D89";
  double _value = 0.0;
  int myAmount = 0;
  var myData;

  @override
  void initState() {
    super.initState();
    httpClient = Client();
    ethClient = Web3Client(
        "https://goerli.infura.io/v3/850bbd87f23c48119f22119992cb901e",
        httpClient);
    getBalance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(top: 50),
              child: Text('${myData} \MMCoin'),
            ),
            InkWell(
              child: Container(
                margin: const EdgeInsets.only(top: 50),
                height: 60,
                width: 200,
                color: Colors.greenAccent,
                child: Center(
                  child: Text(
                    'REFRESH',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ),
              onTap: () {
                getBalance();
              },
            ),
            const Divider(height: 50),
            SfSlider(
              min: 0.0,
              max: 10.0,
              value: _value,
              interval: 1,
              showTicks: true,
              showLabels: true,
              enableTooltip: true,
              minorTicksPerInterval: 1,
              onChanged: (dynamic value) {
                setState(() {
                  _value = value;
                  myAmount = value.round();
                });
              },
            ),
            InkWell(
              child: Container(
                margin: const EdgeInsets.only(top: 50),
                height: 40,
                width: 200,
                color: Colors.greenAccent,
                child: Center(
                  child: Text(
                    'DEPOSIT',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ),
              onTap: () {
                depositCoin();
              },
            ),
            InkWell(
              child: Container(
                margin: const EdgeInsets.only(top: 50),
                height: 40,
                width: 200,
                color: Colors.greenAccent,
                child: Center(
                  child: Text(
                    'WITHDRAW',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ),
              onTap: () {
                withdrawCoin();
              },
            ),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> getBalance() async {
    List<dynamic> result = await query("getBalance", []);
    myData = result[0];
    print("balance $myData");
    setState(() {});
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.call(
        contract: contract, function: ethFunction, params: args);
    return result;
  }

  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString("assets/abi.json");
    //print(abi);
    String contractAddress = "0xbF16FFA4860112707d387D12266f51bdC434b754";
    final contract = DeployedContract(ContractAbi.fromJson(abi, "MMCoin"),
        EthereumAddress.fromHex(contractAddress));
    return contract;
  }

  Future<String> withdrawCoin() async {
    print("widthdraw $myAmount");
    var bigAmount = BigInt.from(myAmount);
    var response = await submit("withdrawBalance", [bigAmount]);
    return response;
  }

  Future<String> depositCoin() async {
    print("deposit $myAmount");
    var bigAmount = BigInt.from(myAmount);
    var response = await submit("depositBalance", [bigAmount]);
    print(response.toString());
    return response;
  }

  Future<String> submit(String functionName, List<dynamic> args) async {
    EthPrivateKey credential = EthPrivateKey.fromHex(
        "Your wallet address private key");
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
}
