part of 'favorite_bloc.dart';

@immutable
abstract class FavoriteEvent {}

class RefreshPage extends FavoriteEvent {
  final FavoriteEvent event;
  RefreshPage(this.event);
}

class GetFavoritePlaces extends FavoriteEvent {
  GetFavoritePlaces();
}

class GetNearestPlaces extends FavoriteEvent {
  GetNearestPlaces();
}
