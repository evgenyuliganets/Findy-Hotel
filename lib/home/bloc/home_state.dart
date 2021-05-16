part of 'home_bloc.dart';

@immutable
abstract class HomeState {
  const HomeState();
}
//PlacesList
class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<PlacesDetail> places;
  final String message;
  final String googleApiKey;

  const HomeLoaded({this.places, this.googleApiKey,this.message});
}

class HomeError extends HomeState {
  final String error;
  const HomeError(this.error);
}



class PlaceLoading extends HomeState {
  const PlaceLoading();
}

class PlaceLoaded extends HomeState {
  final PlacesDetail placesDetail;
  final String message;
  final String googleApiKey;

  const PlaceLoaded({this.placesDetail, this.googleApiKey,this.message});
}

class PlaceError extends HomeState {
  final String error;
  const PlaceError(this.error);
}