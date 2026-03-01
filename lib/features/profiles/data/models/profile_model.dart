import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/profile.dart';

part 'profile_model.freezed.dart';
part 'profile_model.g.dart';

@freezed
class ProfileModel with _$ProfileModel {
  const factory ProfileModel({
    required String id,
    String? role,
  }) = _ProfileModel;

  const ProfileModel._();

  Profile toEntity() => Profile(
        id: id,
        role: role ?? 'customer',
      );

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);
}
