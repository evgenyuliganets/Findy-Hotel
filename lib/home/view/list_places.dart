import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


ListView buildListOfPlaces(List<PlacesSearchResult> places,String googleApiKey) {
  bool val;
  String buildPhotoURL(String photoReference) {
    return "https://maps.googleapis.com/maps/api/place/photo?maxwidth=700&photoreference=$photoReference&key=$googleApiKey";
  }
  return ListView.builder(//ListView
    shrinkWrap: true,
    itemCount: places.length,
    itemBuilder:(BuildContext context, int index) {
        return Card(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading:Image.network(places[index].icon),
                  title:places[index].name==null
                      ?Container()
                      :RichText(text:TextSpan(text:'  ${places[index].name}',style: TextStyle(color:Color(0xff212121)))),
                  subtitle:places[index].vicinity==null? Container(padding: EdgeInsets.all(0),) : RichText(overflow: TextOverflow.ellipsis,maxLines: 2, text:TextSpan(style: TextStyle(color: Color(
                      0xff5a5a5a)),text:places[index].vicinity)),
                ),
                if (places[index].photos!= null)
                  Image.network(
                    buildPhotoURL(places[index].photos.first.photoReference),
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                      if (loadingProgress == null)
                        return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                              : null,
                        ),
                      );
                    },
                  ),
              ]
          ),
        );
    },
  );
}