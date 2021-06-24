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
  GetPlacesOnMap({ this.latlng,this.textFieldText, this.mainSearchMode, this.filters});
}


class GetMapUserPlaces extends MapEvent {
  final bool mainSearchMode;
  final SearchFilterModel filters;
  GetMapUserPlaces({this.mainSearchMode,this.filters});
}
