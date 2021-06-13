part of 'profile_bloc.dart';

@immutable
abstract class ProfileEvent {}

class RefreshPage extends ProfileEvent {
  final ProfileEvent event;
  RefreshPage(this.event);
}

class GetFavoritePlaces extends ProfileEvent {
  GetFavoritePlaces();
}

class GetNearestPlaces extends ProfileEvent {
  GetNearestPlaces();
}

class GetRecentlyViewedPlaces extends ProfileEvent {
  GetRecentlyViewedPlaces();
}