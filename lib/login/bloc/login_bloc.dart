import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:find_hotel/database/authentication/model.dart';
import 'package:find_hotel/database/authentication/users_repository.dart';
import 'package:formz/formz.dart';
import 'package:meta/meta.dart';
import 'package:find_hotel/login/model/username.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    @required AuthenticationRepository authenticationRepository,
  })  : assert(authenticationRepository != null),
        _authenticationRepository = authenticationRepository,
        super(const LoginState());
  final _userRepository = UsersRepository();
  final AuthenticationRepository _authenticationRepository;
  @override
  Stream<LoginState> mapEventToState(
      LoginEvent event,
      ) async* {
    if (event is LoginUsernameChanged) {
      yield _mapUsernameChangedToState(event, state);
    } else if (event is LoginSubmitted) {
      yield* _mapLoginSubmittedToState(event, state);
    }
  }
  LoginState _mapUsernameChangedToState(
      LoginUsernameChanged event,
      LoginState state,
      ) {
    final username = Username.dirty(event.username);
    return state.copyWith(
      username: username,
      status: Formz.validate([username]),
    );
  }

  Stream<LoginState> _mapLoginSubmittedToState(
      LoginSubmitted event,
      LoginState state,
      ) async* {
    if (state.status.isValidated) {
      yield state.copyWith(status: FormzStatus.submissionInProgress);
      try {
        await _authenticationRepository.logIn(
          username: state.username.value,
        );
        yield state.copyWith(status: FormzStatus.submissionSuccess);
        await _userRepository.deleteAllUsers();
        await _userRepository.insertUser(UserModel(id: 1,username: state.username.value));
      } on Error catch (_) {
        yield state.copyWith(status: FormzStatus.submissionFailure);
        print(_.toString());
      }
      on Exception catch (_) {
        yield state.copyWith(status: FormzStatus.submissionFailure);
        print(_.toString());
      }
    }
  }

}
