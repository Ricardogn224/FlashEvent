part of 'admin_feature_bloc.dart';


enum AdminFeatureStatus { initial, loading, success, error }

class AdminFeatureState {
  final AdminFeatureStatus status;
  final List<Feature>? features;

  final String? errorMessage;

  AdminFeatureState({
    this.status = AdminFeatureStatus.initial,
    this.features,
    this.errorMessage,
  });

  AdminFeatureState copyWith({
    AdminFeatureStatus? status,
    List<Feature>? features,

    String? errorMessage,
  }) {
    return AdminFeatureState(
      status: status ?? this.status,
      features: features ?? this.features,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}