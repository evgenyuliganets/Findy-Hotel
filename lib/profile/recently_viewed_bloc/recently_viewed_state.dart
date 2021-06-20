part of 'recently_viewed_bloc.dart';

@immutable
abstract class RecentlyViewedState {
  const RecentlyViewedState();
}

class RecentlyViewedInitial extends RecentlyViewedState {}

class RecentlyViewedLoading extends RecentlyViewedState {
  const RecentlyViewedLoading();
}

class RecentlyViewedLoaded extends RecentlyViewedState {
  final List<PlacesDetail> places;
  final String message;

  const RecentlyViewedLoaded({this.places, this.message});
}

class RecentlyViewedError extends RecentlyViewedState {
  final String error;
  const RecentlyViewedError(this.error);
}