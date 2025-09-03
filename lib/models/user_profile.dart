import 'dart:convert';

class UserProfileModel {
  final String id;
  final String name;
  final String avatarEmoji; // simple avatar for now

  const UserProfileModel({required this.id, required this.name, this.avatarEmoji = '😊'});

  UserProfileModel copyWith({String? id, String? name, String? avatarEmoji}) => UserProfileModel(id: id ?? this.id, name: name ?? this.name, avatarEmoji: avatarEmoji ?? this.avatarEmoji);

  Map<String, dynamic> toJson() => {"id": id, "name": name, "avatarEmoji": avatarEmoji};

  static UserProfileModel fromJson(Map<String, dynamic> json) => UserProfileModel(id: json['id'] as String, name: json['name'] as String, avatarEmoji: json['avatarEmoji'] as String? ?? '😊');

  static List<UserProfileModel> listFromJsonString(String s) {
    final decoded = jsonDecode(s) as List<dynamic>;
    return decoded.map((e) => UserProfileModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  static String listToJsonString(List<UserProfileModel> list) => jsonEncode(list.map((e) => e.toJson()).toList());
}
