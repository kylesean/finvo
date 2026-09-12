import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:finvo/features/auth/models/user.dart';

part 'auth_response.freezed.dart';
part 'auth_response.g.dart';

@freezed
abstract class AuthResponseModel with _$AuthResponseModel {
  @JsonSerializable(explicitToJson: true)
  const factory AuthResponseModel({
    required UserModel user,
    required String token,
  }) = _AuthResponseModel;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);
}
