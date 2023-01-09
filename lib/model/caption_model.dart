// To parse this JSON data, do
//
//     final caption = captionFromJson(jsonString);

import 'dart:convert';

Caption captionFromJson(String str) => Caption.fromJson(json.decode(str));

String captionToJson(Caption data) => json.encode(data.toJson());

class Caption {
  Caption({
    required this.id,
    required this.caption,
  });

  int id;
  String caption;

  factory Caption.fromJson(Map<String, dynamic> json) => Caption(
        id: json["id"],
        caption: json["caption"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "caption": caption,
      };

  @override
  String toString() => caption;
}
