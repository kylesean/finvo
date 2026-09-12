import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    String? username,
    String? email,
    String? phone,
    String? avatarUrl,
    String? timezone,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final map = Map<String, dynamic>.from(json);
    if (map['phone'] == null && map['mobile'] != null) {
      map['phone'] = map['mobile'];
    }
    return _$UserModelFromJson(map);
  }
}
