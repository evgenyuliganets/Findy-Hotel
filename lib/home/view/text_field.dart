import 'dart:io';
import 'package:find_hotel/home/bloc/home_bloc.dart';
import 'package:find_hotel/home/model/search_filters_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';


class HomeTextField extends StatefulWidget{
  final String apiKey;
  final String textFieldText;
  final SearchFilterModel searchFilterModel;
  HomeTextField(this.apiKey,{this.textFieldText='',this.searchFilterModel});

  _HomeTextFieldState createState() => _HomeTextFieldState();
}
class _HomeTextFieldState extends State<HomeTextField> {
  TextEditingController controller;
  @override
  void initState() {
    super.initState();
    controller= TextEditingController(text: widget.textFieldText);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Color(0xfffcfcfc),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(5),
          topRight: Radius.circular(5),
          bottomRight: Radius.circular(5),
          bottomLeft: Radius.circular(5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            IconButton(
              color: Colors.black45,
              icon: Icon(Icons.search),
              onPressed: null,
            ),
            Expanded(
                child: Padding(
              child: TextField(
                onTap: () {
                  _handleSearch(widget.apiKey,widget.textFieldText);
                },
                decoration: InputDecoration(hintText: 'Search'),
                controller: controller,
                readOnly: true,
              ),
              padding: const EdgeInsets.only(left:5.0,right: 5.0),
            )),
          ],
        ));
  }
  void onError(PlacesAutocompleteResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }
  void editMainText(text){
      controller.text=text;
      print(controller.text);
  }

  Future<void> _handleSearch(String apiKey, String textFieldText) async {
    var countryCode = Localizations.localeOf(context);
    try {
      Prediction p = await PlacesAutocomplete.show(
        startText: textFieldText,
        components: [],
        context: context,
        strictbounds: false,
        decoration: InputDecoration(fillColor: Colors.white),
        apiKey: widget.apiKey,
        onError: onError,
        mode: Mode.overlay,
        types: ['(cities)'],
        language: countryCode.languageCode,
      );

      GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: apiKey);
      PlacesDetailsResponse place = await _places.getDetailsByPlaceId(p.placeId,
          language: countryCode.languageCode);
    submitPlaceSearch(
          context,
          LatLng(place.result.geometry.location.lat,
              place.result.geometry.location.lng),
        place.result.addressComponents.first.shortName);
    } catch (e) {
      print(e);
      return null;
    }
  }

  void submitPlaceSearch(BuildContext context, LatLng latLng, String textFieldText) {
    final homeBloc = context.read<HomeBloc>();
    homeBloc.add(GetPlaces(latLng,textFieldText));
    void dispose() {
      homeBloc.close();
    }
  }

}
