
class TransactionLogWithId {
  final String id;
  final String username;
  final int amount;
  final String type;
  final String datetime;
  final int mainAmount;
  final String description;
  bool showDetails;

  TransactionLogWithId({
    required this.id,
    required this.username,
    required this.amount,
    required this.type,
    required this.datetime,
    required this.mainAmount,
    required this.description,
    this.showDetails = false,
  });
}

