import 'package:find_hotel/login/bloc/login_bloc.dart';
import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';


final List<AssetImage> imgList = [
  AssetImage('assets/pic1.jpg'),
  AssetImage('assets/pic2.jpg'),
  AssetImage('assets/pic3.jpg'),
  AssetImage('assets/pic4.jpg'),
  AssetImage('assets/pic5.jpg')
];

class LoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status.isSubmissionFailure) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Authentication Failure')),
            );
        }
      },
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container( height: 500,child: VerticalSliderDemo()),
                _UsernameInput(),
                const Padding(padding: EdgeInsets.all(5)),
                _LoginButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VerticalSliderDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(height: 500,
          child: CarouselSlider(
            options: CarouselOptions(
              height: 500,
              aspectRatio: 2.0,
              autoPlayInterval: Duration(seconds: 3),
              enlargeCenterPage: true,
              scrollDirection: Axis.horizontal,
              autoPlay: true,
            ),
            items: imageSliders,
          )
      ),
    );
  }
}

final List<Widget> imageSliders = imgList.map((item) =>Container(child: Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    Container(
    height: 400,
    margin: EdgeInsets.all(5.0),
    child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        child: Stack(
          children: <Widget>[
            Image(image: item, ),
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(200, 0, 0, 0),
                      Color.fromARGB(0, 0, 0, 0)
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
          ],
        ),
    ),
    ),

    Flexible(
    child:
     Text(
      switchableText(imgList.indexOf(item)),
      style: TextStyle(
        color: Colors.black,
        fontSize: 25.0,
        fontWeight: FontWeight.bold,
      ),
    ),),
  ]
))).toList();

// ignore: missing_return
String switchableText(int val){
  if (val!=null){
  switch (val){
    case 0:
      return '1';
      break;
    case 1:
      return '2';
      break;
    case 2:
      return '3';
      break;
    case 3:
      return '4';
      break;
    case 4:
      return '5';
      break;
  }}
  else return 'No Info';
}

class _UsernameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.username != current.username,
      builder: (context, state) {
        return TextField(
          key: const Key('loginForm_usernameInput_textField'),
          onChanged: (username) =>
              context.read<LoginBloc>().add(LoginUsernameChanged(username)),
          decoration: InputDecoration(
            focusColor: Color(0xffe8f0fe),
            fillColor: Color(0xffe1e4e8),
            icon: Icon(Icons.login),
            labelText: 'Username',
            errorText: state.username.invalid ? 'Invalid username' : null,
          ),
        );
      },
    );
  }
}


class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return state.status.isSubmissionInProgress
            ? const CircularProgressIndicator()
            : RaisedButton(
          key: const Key('loginForm_continue_raisedButton'),
          child: const Text('Login'),
          onPressed: state.status.isValidated
              ? () {
            context.read<LoginBloc>().add(const LoginSubmitted());
          }
              : null,
        );
      },
    );
  }
}