// To parse this JSON data, do
//
//     final userData = userDataFromJson(jsonString);

import 'dart:convert';

UserData userDataFromJson(String str) => UserData.fromJson(json.decode(str));

String userDataToJson(UserData data) => json.encode(data.toJson());

class UserData {
  UserData({
    required this.data,
  });

  Data data;

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
      };
}

class Data {
  Data({
    required this.id,
    required this.name,
    required this.email,
    required this.emailVerifiedAt,
    required this.twoFactorConfirmedAt,
    required this.currentTeamId,
    required this.profilePhotoPath,
    required this.roles,
    required this.createdAt,
    required this.updatedAt,
    required this.profilePhotoUrl,
  });

  int id;
  String name;
  String email;
  dynamic emailVerifiedAt;
  dynamic twoFactorConfirmedAt;
  dynamic currentTeamId;
  dynamic profilePhotoPath;
  String roles;
  DateTime createdAt;
  DateTime updatedAt;
  String profilePhotoUrl;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        emailVerifiedAt: json["email_verified_at"],
        twoFactorConfirmedAt: json["two_factor_confirmed_at"],
        currentTeamId: json["current_team_id"],
        profilePhotoPath: json["profile_photo_path"],
        roles: json["roles"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        profilePhotoUrl: json["profile_photo_url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "email_verified_at": emailVerifiedAt,
        "two_factor_confirmed_at": twoFactorConfirmedAt,
        "current_team_id": currentTeamId,
        "profile_photo_path": profilePhotoPath,
        "roles": roles,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "profile_photo_url": profilePhotoUrl,
      };
}
