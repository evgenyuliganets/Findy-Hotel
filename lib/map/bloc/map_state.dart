part of 'map_bloc.dart';

@immutable
abstract class MapState {
  const MapState();
}

class MapInitial extends MapState {
  final String googleApiKey;
  final String textFieldText;
  const MapInitial({this.googleApiKey, this.textFieldText});
}

class MapLoading extends MapState {
  const MapLoading({this.googleApiKey, this.loc, this.textFieldText});
  final String googleApiKey;
  final LatLng loc;
  final String textFieldText;
}

class MapLoaded extends MapState {
  final List<PlacesDetail> places;
  final String message;
  final String googleApiKey;
  final String textFieldText;
  final LatLng loc;
  final SearchFilterModel filters;
  final bool mainSearchMode;

  const MapLoaded({this.textFieldText,this.places, this.googleApiKey,this.message,this.loc, this.filters,this.mainSearchMode});
}

class MapError extends MapState {
  final String textFieldText;
  final String apiKey;
  final String error;

  const MapError(this.error, this.apiKey, {this.textFieldText});
}


class PlaceLoading extends MapState {
  const PlaceLoading();
}

class PlaceLoaded extends MapState {
  final PlacesDetail placesDetail;
  final String message;
  final String googleApiKey;

  const PlaceLoaded({this.placesDetail, this.googleApiKey,this.message});
}

class PlaceError extends MapState {
  final String error;
  final String apiKey;
  const PlaceError(this.error, this.apiKey);
}