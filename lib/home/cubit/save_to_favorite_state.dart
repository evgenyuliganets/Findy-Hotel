part of 'save_to_favorite_cubit.dart';

@immutable
abstract class SaveToFavoriteState {}

class SaveToFavoriteInitial extends SaveToFavoriteState {}

class SaveToFavoriteLoading extends SaveToFavoriteState {
   SaveToFavoriteLoading();
}

class SaveToFavoriteLoaded extends SaveToFavoriteState {
  final bool ifExist;
  final String message;
  SaveToFavoriteLoaded({this.ifExist,this.message});
}

class SaveToFavoriteError extends SaveToFavoriteState {
  final String error;
  SaveToFavoriteError(this.error);
}