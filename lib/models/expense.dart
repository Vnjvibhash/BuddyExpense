import 'dart:convert';

class ExpenseModel {
  final String id;
  final String groupId;
  final String paidByUserId;
  final String description;
  final double amount;
  final DateTime createdAt;
  final Map<String, double> shares; // userId -> share amount
  final String currency;

  const ExpenseModel({required this.id, required this.groupId, required this.paidByUserId, required this.description, required this.amount, required this.createdAt, required this.shares, this.currency = 'USD'});

  Map<String, dynamic> toJson() => {
        'id': id,
        'groupId': groupId,
        'paidByUserId': paidByUserId,
        'description': description,
        'amount': amount,
        'createdAt': createdAt.toIso8601String(),
        'shares': shares,
        'currency': currency,
      };

  static ExpenseModel fromJson(Map<String, dynamic> json) => ExpenseModel(
        id: json['id'] as String,
        groupId: json['groupId'] as String,
        paidByUserId: json['paidByUserId'] as String,
        description: json['description'] as String,
        amount: (json['amount'] as num).toDouble(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        shares: (json['shares'] as Map<String, dynamic>).map((key, value) => MapEntry(key, (value as num).toDouble())),
        currency: json['currency'] as String? ?? 'USD',
      );

  static List<ExpenseModel> listFromJsonString(String s) {
    final decoded = jsonDecode(s) as List<dynamic>;
    return decoded.map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  static String listToJsonString(List<ExpenseModel> list) => jsonEncode(list.map((e) => e.toJson()).toList());
}
