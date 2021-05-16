part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {}
class GetPlaces extends HomeEvent {
  final LatLng latlng;
  GetPlaces(this.latlng);
}

class GetUserPlaces extends HomeEvent {
}

class GetDetailedPlace extends HomeEvent {
  final String placeId;
  GetDetailedPlace(this.placeId);
}