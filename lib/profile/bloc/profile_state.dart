part of 'profile_bloc.dart';

@immutable
abstract class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final List<PlacesDetail> places;
  final String message;
  final String username;

  const ProfileLoaded({this.places, this.username,this.message});
}

class ProfileError extends ProfileState {
  final String error;
  const ProfileError(this.error);
}