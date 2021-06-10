part of 'map_bloc.dart';

@immutable
abstract class MapEvent {}

class RefreshPage extends MapEvent {
  final MapEvent event;
  RefreshPage({this.event});
}
class GetPlacesOnMap extends MapEvent {
  final LatLng latlng;
  final String textFieldText;
  final SearchFilterModel filters;
  final bool mainSearchMode;
  final Marker marker;
  GetPlacesOnMap({this.marker, this.latlng,this.textFieldText, this.mainSearchMode, this.filters});
}
class GetMapPlacesFromDB extends MapEvent {
}
class MapInitialAndAppBarCreation extends MapEvent {
  final String textFieldText;
  final String googleApiKey;

  MapInitialAndAppBarCreation({this.textFieldText, this.googleApiKey});
}
class GetMapUserPlaces extends MapEvent {
  final bool mainSearchMode;
  final SearchFilterModel filters;
  GetMapUserPlaces({this.mainSearchMode,this.filters});
}

class GetMapDetailedPlace extends MapEvent {

  final String placeId;
  GetMapDetailedPlace(this.placeId);
}