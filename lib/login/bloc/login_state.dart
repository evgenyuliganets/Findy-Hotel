part of 'login_bloc.dart';

class LoginState extends Equatable {
  const LoginState({
    this.status = FormzStatus.pure,
    this.username = const Username.pure(),
  });
  final FormzStatus status;
  final Username username;
  LoginState copyWith({
    FormzStatus status,
    Username username,
  }) {
    return LoginState(
      status: status ?? this.status,
      username: username ?? this.username,
    );
  }

  @override
  List<Object> get props => [status, username];
}