import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

import '../../../models/transaction_model.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardInitial()) {
    on<DashboardInitialFechEvent>(dashboardInitialFechEvent);
    on<DashboardDepositEvent>(dashboardDepositEvent);
    on<DashboardWithdrawEvent>(dashboardWithdrawEvent);
  }

  List<TransactionModel> transactions = [];
  Web3Client? _web3Client;
  late ContractAbi _abiCode;
  late EthereumAddress _contractAddress;
  late EthPrivateKey _creds;
  int balance = 0;

  // Functions
  late DeployedContract _deployedContract;
  late ContractFunction _deposit;
  late ContractFunction _withdraw;
  late ContractFunction _getBalance;
  late ContractFunction _getAllTransactions;

  FutureOr<void> dashboardInitialFechEvent(
      DashboardInitialFechEvent event, Emitter<DashboardState> emit) async {
    emit(DashboardLoadingState());
    try {
      String rpcUrl = "http://10.0.2.2:7545";
      String socketUrl = "ws://10.0.2.2:7545";
      String privateKey =
          "0x803872c14b35672efe494af2a8d2dc24c618fc51117954e261e400826828f945";

      _web3Client = Web3Client(
        rpcUrl,
        http.Client(),
        socketConnector: () {
          return IOWebSocketChannel.connect(socketUrl).cast<String>();
        },
      );

      // getABI
      String abiFile = await rootBundle
          .loadString('build/contracts/ExpenseManagerContract.json');
      var jsonDecoded = jsonDecode(abiFile);

      _abiCode = ContractAbi.fromJson(
          jsonEncode(jsonDecoded["abi"]), 'ExpenseManagerContract');

      _contractAddress =
          EthereumAddress.fromHex("0x8BeeAa21AF99a7412C7B71AbC3Ca01802Ff25E9b");

      _creds = EthPrivateKey.fromHex(privateKey);

      // get deployed contract
      _deployedContract = DeployedContract(_abiCode, _contractAddress);
      _deposit = _deployedContract.function("deposit");
      _withdraw = _deployedContract.function("withdraw");
      _getBalance = _deployedContract.function("getBalance");

      _getAllTransactions = _deployedContract.function("getAllTransactions");

      final transactionsData = await _web3Client!.call(
          contract: _deployedContract,
          function: _getAllTransactions,
          params: []);
      final balanceData = await _web3Client!
          .call(contract: _deployedContract, function: _getBalance, params: [
        EthereumAddress.fromHex("0x6aaC7Ea496834a01fcc48004a56c855751bf6372")
      ]);

      List<TransactionModel> trans = [];
      for (int i = 0; i < transactionsData[0].length; i++) {
        try {
          // Safely convert timestamp
          int timestampSeconds = transactionsData[3][i].toInt();
          DateTime timestamp;

          // Handle different timestamp formats
          if (timestampSeconds > 1000000000000) {
            // Already in milliseconds
            timestamp = DateTime.fromMillisecondsSinceEpoch(timestampSeconds);
          } else {
            // In seconds, convert to milliseconds
            timestamp =
                DateTime.fromMillisecondsSinceEpoch(timestampSeconds * 1000);
          }

          // Convert transaction type from BigInt to enum
          TransactionType transactionType = transactionsData[4][i].toInt() == 0
              ? TransactionType.deposit
              : TransactionType.withdrawal;

          TransactionModel transactionModel = TransactionModel(
              transactionsData[0][i].toString(),
              transactionsData[1][i].toInt(),
              transactionsData[2][i],
              timestamp,
              transactionType);
          trans.add(transactionModel);
        } catch (e) {
          log('Error processing transaction $i: $e');
          // Skip this transaction if there's an error
          continue;
        }
      }
      transactions = trans;

      int bal = balanceData[0].toInt();
      balance = bal;

      log('=== BALANCE DEBUG INFO ===');
      log('Contract address: $_contractAddress');
      log('Querying balance for account: 0x132D745A2d66713AA2408389fFA7E53B28E352e0');
      log('Balance response raw: ${balanceData.toString()}');
      log('Current balance: $balance');
      log('Number of transactions: ${transactions.length}');
      for (int i = 0; i < transactions.length; i++) {
        log('Transaction $i: ${transactions[i].type.name} - ${transactions[i].amount} ETH - ${transactions[i].reason}');
      }
      log('=== END BALANCE DEBUG ===');

      emit(DashboardSuccessState(transactions: transactions, balance: balance));
    } catch (e) {
      log(e.toString());
      emit(DashboardErrorState());
    }
  }

  FutureOr<void> dashboardDepositEvent(
      DashboardDepositEvent event, Emitter<DashboardState> emit) async {
    try {
      final transaction = Transaction.callContract(
          from: EthereumAddress.fromHex(
              "0x6aaC7Ea496834a01fcc48004a56c855751bf6372"),
          contract: _deployedContract,
          function: _deposit,
          parameters: [
            BigInt.from(event.transactionModel.amount),
            event.transactionModel.reason
          ],
          value: EtherAmount.inWei(BigInt.from(event.transactionModel.amount)));

      final result = await _web3Client!.sendTransaction(_creds, transaction,
          chainId: 1337, fetchChainIdFromNetworkId: false);
      log('Deposit transaction result: $result');

      // Wait a bit for the transaction to be mined
      await Future.delayed(Duration(seconds: 2));

      // Refresh the dashboard
      add(DashboardInitialFechEvent());
    } catch (e) {
      log(e.toString());
    }
  }

  FutureOr<void> dashboardWithdrawEvent(
      DashboardWithdrawEvent event, Emitter<DashboardState> emit) async {
    try {
      final transaction = Transaction.callContract(
        from: EthereumAddress.fromHex(
            "0x6aaC7Ea496834a01fcc48004a56c855751bf6372"),
        contract: _deployedContract,
        function: _withdraw,
        parameters: [
          BigInt.from(event.transactionModel.amount),
          event.transactionModel.reason
        ],
      );

      final result = await _web3Client!.sendTransaction(_creds, transaction,
          chainId: 1337, fetchChainIdFromNetworkId: false);
      log('Withdraw transaction result: $result');

      // Wait a bit for the transaction to be mined
      await Future.delayed(Duration(seconds: 2));

      // Refresh the dashboard
      add(DashboardInitialFechEvent());
    } catch (e) {
      log(e.toString());
    }
  }
}
