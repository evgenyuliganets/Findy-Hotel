
import 'package:find_hotel/app.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'package:flutter/material.dart';
void main() {
  runApp(App(authenticationRepository:AuthenticationRepository(),
    userRepository: UserRepository(),));
}