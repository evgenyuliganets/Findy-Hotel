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

class HomePageStarted extends BottomNavigationState {
  const HomePageStarted();
}

class MapPageStarted extends BottomNavigationState {
  const MapPageStarted();
}

class ProfilePageStarted extends BottomNavigationState {

  ProfilePageStarted();

}
class PageError extends BottomNavigationState {

  final String error;
  const PageError(this.error);
}