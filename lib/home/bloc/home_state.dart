part of 'home_bloc.dart';

@immutable
abstract class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<PlacesSearchResult> places;
  final String message;
  final String googleApiKey;

  const HomeLoaded({this.places, this.googleApiKey,this.message});
}

class HomeError extends HomeState {
  final String error;
  const HomeError(this.error);
}