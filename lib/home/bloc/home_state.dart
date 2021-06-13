part of 'home_bloc.dart';

@immutable
abstract class HomeState {
  const HomeState();
}
//PlacesList
class HomeInitial extends HomeState {
  final String googleApiKey;
  final String textFieldText;
  const HomeInitial({this.googleApiKey, this.textFieldText});
}

class HomeLoading extends HomeState {
  const HomeLoading({this.googleApiKey, this.loc, this.textFieldText});
  final String googleApiKey;
  final LatLng loc;
  final String textFieldText;
}

class HomeLoaded extends HomeState {
  final List<PlacesDetail> places;
  final String message;
  final String googleApiKey;
  final String textFieldText;
  final LatLng loc;
  final SearchFilterModel filters;
  final bool mainSearchMode;

  const HomeLoaded({this.textFieldText,this.places, this.googleApiKey,this.message,this.loc, this.filters,this.mainSearchMode});
}

class HomeError extends HomeState {
  final String textFieldText;
  final String apiKey;
  final String error;

  const HomeError(this.error, this.apiKey, {this.textFieldText});
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
