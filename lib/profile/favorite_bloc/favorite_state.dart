part of 'favorite_bloc.dart';

@immutable
abstract class FavoriteState {
  const FavoriteState();
}

class ProfileInitial extends FavoriteState {
  const ProfileInitial();
}

class FavoriteLoading extends FavoriteState {
  const FavoriteLoading();
}

class FavoriteLoaded extends FavoriteState {
  final List<PlacesDetail> places;
  final String message;

  const FavoriteLoaded({this.places, this.message});
}

class FavoriteError extends FavoriteState {
  final String error;
  const FavoriteError(this.error);
}

