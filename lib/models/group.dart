import 'dart:convert';

class GroupModel {
  final String id;
  final String name;
  final List<String> memberUserIds;
  final String currency;

  const GroupModel({required this.id, required this.name, required this.memberUserIds, this.currency = 'USD'});

  GroupModel copyWith({String? id, String? name, List<String>? memberUserIds, String? currency}) => GroupModel(id: id ?? this.id, name: name ?? this.name, memberUserIds: memberUserIds ?? this.memberUserIds, currency: currency ?? this.currency);

  Map<String, dynamic> toJson() => {"id": id, "name": name, "memberUserIds": memberUserIds, "currency": currency};

  static GroupModel fromJson(Map<String, dynamic> json) => GroupModel(id: json['id'] as String, name: json['name'] as String, memberUserIds: (json['memberUserIds'] as List).map((e) => e as String).toList(), currency: json['currency'] as String? ?? 'USD');

  static List<GroupModel> listFromJsonString(String s) {
    final decoded = jsonDecode(s) as List<dynamic>;
    return decoded.map((e) => GroupModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  static String listToJsonString(List<GroupModel> list) => jsonEncode(list.map((e) => e.toJson()).toList());
}
