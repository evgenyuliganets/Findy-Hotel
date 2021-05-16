part of 'profile_bloc.dart';

@immutable
abstract class ProfileEvent {}

class GetPlaces extends ProfileEvent {
  final LatLng latlng;
  GetPlaces(this.latlng);
}
class GetUserPlaces extends ProfileEvent {
}