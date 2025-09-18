enum TransactionType { deposit, withdrawal }

class TransactionModel {
  final String address;
  final int amount;
  final String reason;
  final DateTime timestamp;
  final TransactionType type;

  TransactionModel(this.address, this.amount, this.reason, this.timestamp, this.type);
}
