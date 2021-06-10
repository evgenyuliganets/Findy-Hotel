import 'package:find_hotel/home/bloc/home_bloc.dart';
import 'package:find_hotel/home/model/search_filters_model.dart';
import 'package:find_hotel/home/view/filters.dart';
import 'package:find_hotel/map/bloc/map_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';


class MapTextField extends StatefulWidget{
  final String apiKey;
  final String textFieldText;
  final SearchFilterModel searchFilterModel;
  final bool checkMainSearchMode;
  MapTextField(this.apiKey,{this.textFieldText='',this.searchFilterModel, this.checkMainSearchMode=false});

  _MapTextFieldState createState() => _MapTextFieldState();
}
class _MapTextFieldState extends State<MapTextField> {
  TextEditingController controller;
  SearchFilterModel filters;
  @override
  void initState() {
    super.initState();
    controller= TextEditingController(text: widget.textFieldText);
    filters = widget.searchFilterModel;

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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: IconButton(
                color: Colors.black45,
                icon: Icon(Icons.search),
                onPressed: (){
                  if(widget.checkMainSearchMode==true){
                    _handleSearchByName(widget.apiKey,controller.text);
                  }
                  else print (null);
                },
              ),
            ),
            Expanded(
                child: TextField(
                  onTap: () {
                    if(widget.checkMainSearchMode==false){
                      _handleSearchByPlace(widget.apiKey,widget.textFieldText,widget.checkMainSearchMode);
                    }
                    else print (null);
                  },
                  decoration: InputDecoration(hintText: 'Search'),
                  controller: controller,
                  readOnly: !widget.checkMainSearchMode,
                )),
            Ink(

                decoration: const ShapeDecoration(
                  color: Color(0xff636e86),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                ),
                child: IconButton(
                  onPressed: () async {
                    var bloc = BlocProvider.of<MapBloc>(context);
                    var finalFilters = await filtersDialog(context, bloc.getFilterModel());
                    filters= finalFilters??SearchFilterModel();
                    bloc.setFiltersParameters(finalFilters??SearchFilterModel());
                  },
                  icon: Icon(
                    Icons.filter_list,
                    color: Color(0xffd2d2d2),
                  ),
                  iconSize: 22,
                  color: Colors.blueGrey,
                )),
          ],
        ));
  }
  void onError(PlacesAutocompleteResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }


  Future<void> _handleSearchByPlace(String apiKey, String textFieldText,bool mainSearchMode) async {
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
          latLng:LatLng(place.result.geometry.location.lat,
              place.result.geometry.location.lng),
        textFieldText: place.result.addressComponents.first.shortName,
        filters: filters,
        mainSearchMode: widget.checkMainSearchMode,
    );
    } catch (e) {
      print(e);
      return null;
    }
  }
  Future<void> _handleSearchByName(String apiKey, String textFieldText) async {
    try {
      submitNameSearch(
        textFieldText: textFieldText,
        mainSearchMode: widget.checkMainSearchMode,
        filters: filters,
      );
    } catch (e) {
      print('MY'+e);
      return null;
    }
  }

  void submitPlaceSearch({LatLng latLng, String textFieldText, SearchFilterModel filters,bool mainSearchMode}) {
    final mapBloc = context.read<MapBloc>();
    mapBloc.add(GetPlacesOnMap(latlng:latLng,textFieldText:textFieldText, mainSearchMode: mainSearchMode,filters: filters));
    void dispose() {
      mapBloc.close();
    }
  }
  void submitNameSearch({String textFieldText, SearchFilterModel filters,bool mainSearchMode}) {
    final mapBloc = context.read<MapBloc>();
    mapBloc.add(GetPlacesOnMap(textFieldText:textFieldText, mainSearchMode: mainSearchMode,filters: filters));
    void dispose() {
      mapBloc.close();
    }
  }
}
