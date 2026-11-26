import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/product_api.dart';
import 'details_state.dart';

class DetailsCubit extends Cubit<DetailsState> {
  DetailsCubit(this._api) : super(const DetailsLoading());

  final ProductApi _api;

  Future<void> load(int id) async {
    emit(const DetailsLoading());
    try {
      final product = await _api.getProduct(id);
      if (!isClosed) emit(DetailsLoaded(product));
    } on ApiException catch (error) {
      if (!isClosed) emit(DetailsError(error.message));
    }
  }
}
