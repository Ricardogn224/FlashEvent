part of 'admin_feature_bloc.dart';

@immutable
sealed class AdminFeatureEvent {}

class AdminFeatureLoaded extends AdminFeatureEvent {}

class UpdateFeatureStatus extends AdminFeatureEvent {
  final Feature feature;
  final bool newVal;

  UpdateFeatureStatus({required this.feature, required this.newVal});
}
