part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {}
class GetPlaces extends HomeEvent {
  final LatLng latlng;
  GetPlaces(this.latlng);
}