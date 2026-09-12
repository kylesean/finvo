import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

Object? _readPhone(Map<dynamic, dynamic> json, String key) =>
    json['phone'] ?? json['mobile'];

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    String? username,
    String? email,
    @JsonKey(readValue: _readPhone) String? phone,
    String? avatarUrl,
    String? timezone,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
