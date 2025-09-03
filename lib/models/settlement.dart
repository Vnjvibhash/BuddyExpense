import 'dart:convert';

class SettlementModel {
  final String id;
  final String groupId;
  final String fromUserId;
  final String toUserId;
  final double amount;
  final DateTime createdAt;

  const SettlementModel({required this.id, required this.groupId, required this.fromUserId, required this.toUserId, required this.amount, required this.createdAt});

  Map<String, dynamic> toJson() => {
        'id': id,
        'groupId': groupId,
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'amount': amount,
        'createdAt': createdAt.toIso8601String(),
      };

  static SettlementModel fromJson(Map<String, dynamic> json) => SettlementModel(
        id: json['id'] as String,
        groupId: json['groupId'] as String,
        fromUserId: json['fromUserId'] as String,
        toUserId: json['toUserId'] as String,
        amount: (json['amount'] as num).toDouble(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  static List<SettlementModel> listFromJsonString(String s) {
    final decoded = jsonDecode(s) as List<dynamic>;
    return decoded.map((e) => SettlementModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  static String listToJsonString(List<SettlementModel> list) => jsonEncode(list.map((e) => e.toJson()).toList());
}
