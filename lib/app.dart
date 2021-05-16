import 'package:authentication_repository/authentication_repository.dart';
import 'package:find_hotel/splash/view/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_hotel/authentication/bloc/authentication_bloc.dart';
import 'package:user_repository/user_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'database/authentication/users_repository.dart';
import 'bottom_navigation/view/main_navbar.dart';
import 'login/bloc/login_bloc.dart';
import 'login/view/login_page.dart';
class App extends StatelessWidget {
  const App({
    Key key,
    @required this.authenticationRepository,
    @required this.userRepository,
  })  : assert(authenticationRepository != null),
        assert(userRepository != null),
        super(key: key);

  final AuthenticationRepository authenticationRepository;
  final UserRepository userRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: authenticationRepository,
      child: BlocProvider(
        create: (_) => AuthenticationBloc(
          authenticationRepository: authenticationRepository,
          userRepository: userRepository,
        ),
        child: AppView(),
      ),
    );
  }
}

class AppView extends StatefulWidget {
  @override
  _AppViewState createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final AuthenticationRepository _authenticationRepository= AuthenticationRepository();
  LoginEvent loginEvent;
  final _userRepository = UsersRepository();
  NavigatorState get _navigator => _navigatorKey.currentState;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: [
        const Locale('en', ''),
        const Locale('es', ''),
        const Locale('uk', ''),
        const Locale('ru', ''),
      ],
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      builder: (context, child) {
        return
          BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) async {
            try {
              await _authenticationRepository.logIn(
                   username: await _userRepository.getAllUser().then((value) =>
                      value.first.username.toString()).timeout(Duration(seconds: 2),onTimeout: ()=>throw Error())).timeout(Duration(seconds: 2),onTimeout: ()=>throw Error());
              User user=User('1');
              state=AuthenticationState.authenticated(user);
            }
            catch (Error){
              print (Error);
            }
            switch (state.status) {
              case AuthenticationStatus.authenticated:
                _navigator.pushAndRemoveUntil<void>(
                  MainNavbar.route(),
                      (route) => false,
                );
                break;
              case AuthenticationStatus.unauthenticated:
                _navigator.pushAndRemoveUntil<void>(
                  LoginPage.route(),
                      (route) => false,
                );
                break;
              default:
                break;
            }
          },
          child: child,
        );
      },
      onGenerateRoute: (_) => SplashPage.route(),
    );
  }
}