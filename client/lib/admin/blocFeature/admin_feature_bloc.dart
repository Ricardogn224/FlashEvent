import 'package:flutter/cupertino.dart';
import 'package:flutter_flash_event/core/exceptions/api_exception.dart';
import 'package:flutter_flash_event/core/models/feature.dart';
import 'package:flutter_flash_event/core/services/feature_services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'admin_feature_event.dart';
part 'admin_feature_state.dart';

class AdminFeatureBloc extends Bloc<AdminFeatureEvent, AdminFeatureState> {
  AdminFeatureBloc() : super(AdminFeatureState()) {
    on<AdminFeatureLoaded>((event, emit) async {
      emit(state.copyWith(status: AdminFeatureStatus.loading));

      try {
        final features = await FeatureServices.getFeatures();
        emit(state.copyWith(
          status: AdminFeatureStatus.success,
          features: features,
        ));
      } on ApiException catch (error) {
        emit(state.copyWith(
          status: AdminFeatureStatus.error,
          errorMessage: 'An error occurred',
        ));
      }
    });

    on<UpdateFeatureStatus>((event, emit) async {
      emit(state.copyWith(status: AdminFeatureStatus.loading));

      Feature feature = Feature(
          id: event.feature.id,
          name: event.feature.name,
          active: event.newVal
      );

      try {
        await FeatureServices.updateFeatureById(feature);
        final features = await FeatureServices.getFeatures();
        emit(state.copyWith(
          status: AdminFeatureStatus.success,
          features: features,
        ));
      } on ApiException catch (error) {
        emit(state.copyWith(
          status: AdminFeatureStatus.error,
          errorMessage: 'An error occurred while updating the feature',
        ));
      }
    });
  }
}
