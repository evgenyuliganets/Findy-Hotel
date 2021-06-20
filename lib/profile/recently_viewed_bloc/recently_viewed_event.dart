part of 'recently_viewed_bloc.dart';

@immutable
abstract class RecentlyViewedEvent {}

class GetRecentlyViewedPlaces extends RecentlyViewedEvent {
  GetRecentlyViewedPlaces();
}