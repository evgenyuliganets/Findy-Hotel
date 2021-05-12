part of 'bottom_navigation_bloc.dart';

abstract class BottomNavigationState extends Equatable {
  const BottomNavigationState();

  @override
  List<Object> get props => [];
}

class CurrentIndexChanged extends BottomNavigationState {
  final int currentIndex;

  CurrentIndexChanged({@required this.currentIndex});

  @override
  String toString() => 'CurrentIndexChanged to $currentIndex';
}

class PageLoading extends BottomNavigationState {
  @override
  String toString() => 'PageLoading';
}

class HomePageLoaded extends BottomNavigationState {
  final String text;

  HomePageLoaded({@required this.text});

  @override
  String toString() => 'HomePageLoaded with text: $text';
}

class MapPageLoaded extends BottomNavigationState {
  final int number;

  MapPageLoaded({@required this.number});

  @override
  String toString() => 'MapPageLoaded with number: $number';
}

class ProfilePageLoaded extends BottomNavigationState {
  final int number;

  ProfilePageLoaded({@required this.number});

  @override
  String toString() => 'ProfilePageLoaded with number: $number';
}
class PageError extends BottomNavigationState {

  final String error;
  const PageError(this.error);
}