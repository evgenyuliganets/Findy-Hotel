part of 'save_to_favorite_cubit.dart';

@immutable
abstract class FavoriteState {}

class FavoriteInitial extends FavoriteState {}

class FavoriteLoading extends FavoriteState {
   FavoriteLoading();
}

class FavoriteLoaded extends FavoriteState {
  final bool ifExist;
  final String message;
  FavoriteLoaded({this.ifExist,this.message});
}

class FavoriteError extends FavoriteState {
  final String error;
  FavoriteError(this.error);
}