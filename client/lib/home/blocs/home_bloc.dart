import 'package:flutter/foundation.dart';
import 'package:flutter_5iw2/core/exceptions/api_exception.dart';
import 'package:flutter_5iw2/core/models/product.dart';
import 'package:flutter_5iw2/core/services/api_services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<HomeDataLoaded>((event, emit) async {
      emit(HomeLoading());

      try {
        final products = await ApiServices.getProducts();
        emit(HomeDataLoadSuccess(products: products));
      } on ApiException catch (error) {
        emit(HomeDataLoadError(errorMessage: 'An error occurred.'));
      }
    });
  }
}
