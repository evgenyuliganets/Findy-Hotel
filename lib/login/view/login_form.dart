import 'package:find_hotel/login/bloc/login_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formz/formz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';


final List<AssetImage> imgList = [
  AssetImage('assets/pic1.jpg'),
  AssetImage('assets/pic2.jpg'),
  AssetImage('assets/pic3.jpg'),
  AssetImage('assets/pic4.jpg'),
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
      child: Container(
        alignment: Alignment.centerLeft,
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _WelcomeView(),
                const Padding(padding: EdgeInsets.all(5)),
                Container( height: 360,child: CarouselWithIndicator()),
                const Padding(padding: EdgeInsets.all(10  )),
                _LoginHeader(),
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
class CarouselWithIndicator extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CarouselWithIndicatorState();
  }
}
class _WelcomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [Text(
          'Welcome to Findy Hotel!',
          style: TextStyle(
            fontFamily: 'Times New Roman',
            fontWeight: FontWeight.bold,
            color: Color(0xff424242),
            fontSize: 25.0,
          ),
        ),
      ]),
    );
  }
}
class _CarouselWithIndicatorState extends State<CarouselWithIndicator> {
  int _current = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [ CarouselSlider(
            options: CarouselOptions(
              height: 330,
              aspectRatio: 2.0,
              autoPlayInterval: Duration(seconds: 4),
              enlargeCenterPage: true,
              scrollDirection: Axis.horizontal,
              autoPlay: true,
                onPageChanged: (index, reason) {setState(() {
                  _current = index;
                });}
            ),
            items: imageSliders,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: imgList.map((url) {
              int index = imgList.indexOf(url);
              return Container(
                width: 8.0,
                height: 8.0,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _current == index
                      ? Color.fromRGBO(0, 0, 0, 0.9)
                      : Color.fromRGBO(0, 0, 0, 0.4),
                ),
              );
            }).toList(),
          ),
      ]),
    );
  }
}

final List<Widget> imageSliders = imgList.map((item) =>Container(child: Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    Container(
    height: 250,
    margin: EdgeInsets.all(5.0),
    child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        child: Stack(
          children: <Widget>[
            Image(image: item,fit: BoxFit.fill, width: 500,),
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
    Container(
      width: 200,
    child: Text(
      switchableText(imgList.indexOf(item)),
      style: TextStyle(
        fontStyle: FontStyle.italic,
        color: Color(0xff424242),
        fontSize: 20.0,
      ),
    ),),),
  ]
))).toList();

// ignore: missing_return
String switchableText(int val){
  if (val!=null){
  switch (val){
    case 0:
      return 'Find hotels through search';
      break;
    case 1:
      return 'Get full info about selected hotel';
      break;
    case 2:
      return 'Save selected hotels to database to view information later';
      break;
    case 3:
      return 'Browse hotels near you on the map';
      break;
  }}
  else return 'No Info';
}

class _LoginHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(
            'Write your Name and lets get started!',
            style: TextStyle(
              color: Color(0xff424242),
              fontSize: 15.0,
              fontFamily: 'Times New Roman'
            ),
          ),
            const Padding(padding: EdgeInsets.all(3)),
          ]),
    );
  }
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
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.greenAccent, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black26, width: 1.5),
            ),
            prefixIcon: Icon(Icons.edit_outlined,color: Color(0xff212121),),
            labelText: 'Name',
            errorText: state.username.invalid ? 'Invalid name' : null,
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
        return state.status.isSubmissionInProgress ?
        const CircularProgressIndicator() :
        ButtonTheme(
            minWidth: 200.0,
            height: 40.0,
            child:
        OutlineButton(
          borderSide: BorderSide(color: Color(0xff686868), width: 1.5),
          disabledBorderColor: Color(0xff959595),
          child: const Text('Login'),
          onPressed: state.status.isValidated
              ? () {context.read<LoginBloc>().add(const LoginSubmitted());}
              : null,
        ));
      },
    );
  }
}