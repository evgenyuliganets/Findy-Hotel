part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {}

class RefreshPage extends HomeEvent {
  final HomeEvent event;
  RefreshPage({this.event});
}
class GetPlaces extends HomeEvent {
  final LatLng latlng;
  final String textFieldText;
  final SearchFilterModel filters;
  final bool mainSearchMode;
  GetPlaces({this.latlng,this.textFieldText, this.mainSearchMode, this.filters});
}

class GetUserPlaces extends HomeEvent {
  final String textFieldText;
  final bool mainSearchMode;
  final SearchFilterModel filters;
  GetUserPlaces({this.mainSearchMode,this.filters,this.textFieldText, });
}

class GetDetailedPlace extends HomeEvent {
  final String placeId;
  GetDetailedPlace(this.placeId);
}

