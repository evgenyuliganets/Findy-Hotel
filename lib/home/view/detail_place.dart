import 'package:find_hotel/home/model/places_detail_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


Card buildPlaceDetail(PlacesDetail place,String googleApiKey) {
  return Card(
    child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (place.photos.isNotEmpty)
            Image(
              image: place.photos.first,
              height: 150,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent loadingProgress) {
                if (loadingProgress == null)
                  return child;
                return Container(color: Colors.black12, height: 150, width: 150,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.black26),
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes
                            : null,
                      ),
                    )
                );
              },
            ),
          ListTile(
            leading: Image.network(place.icon),
            title: place.name == null
                ? Container()
                : RichText(text: TextSpan(text: '  ${place.name}',
                style: TextStyle(color: Color(0xff212121)))),
            subtitle: place.vicinity == null ? Container(
              padding: EdgeInsets.all(0),) : RichText(
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                text: TextSpan(style: TextStyle(color: Color(
                    0xff5a5a5a)), text: place.vicinity)),
          ),
          Container(height: 5,),
        ]
    ),
  );
}