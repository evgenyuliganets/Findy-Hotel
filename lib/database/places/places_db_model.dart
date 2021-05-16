import 'dart:typed_data';
class PlacesDbDetail{
  final String icon;
  final String name;
  final bool openNow;
  final List<Uint8List> photos;
  final String placeId;
  final String priceLevel;
  final num rating;
  final List<String> types;
  final String vicinity;
  final String formattedAddress;
  final bool weekday;
  final String reference;
  final String website;
  final num utcOffset;
  final String formattedPhoneNumber;
  final String internationalPhoneNumber;
  final String id;


  PlacesDbDetail({
    this.icon,
    this.name,
    this.openNow,
    this.photos,
    this.placeId,
    this.priceLevel,
    this.rating,
    this.types,
    this.vicinity,
    this.formattedAddress,
    this.weekday,
    this.reference,
    this.website,
    this.utcOffset,
    this.formattedPhoneNumber,
    this.internationalPhoneNumber,
    this.id,
  });
  factory PlacesDbDetail.fromDatabaseJson(Map<String, dynamic> data) => PlacesDbDetail(
    id: data['id'],
    icon:data['icon'],
    name:data['name'],
    openNow:data['openNow'],
    photos:data['photos'],
    placeId:data['placeId'],
    priceLevel:data['priceLevel'],
    rating:data['rating'],
    types:data['types'],
    vicinity:data['vicinity'],
    formattedAddress:data['formattedAddress'],
    weekday:data['weekday'],
    reference:data['reference'],
    website:data['website'],
    utcOffset:data['utcOffset'],
    formattedPhoneNumber:data['formattedPhoneNumber'],
    internationalPhoneNumber:data['internationalPhoneNumber'],
  );
  Map<String, dynamic> toDatabaseJson() => {
    "id": this.id,
    "icon": this.icon,
    "name": this.name,
    "openNow": this.openNow,
    "photos": this.photos,
    "placeId": this.placeId,
    "priceLevel": this.priceLevel,
    "rating": this.rating,
    "types": this.types,
    "vicinity": this.vicinity,
    "formattedAddress": this.formattedAddress,
    "weekday": this.weekday,
    "reference": this.reference,
    "website": this.website,
    "utcOffset": this.utcOffset,
    "formattedPhoneNumber": this.formattedPhoneNumber,
    "internationalPhoneNumber": this.internationalPhoneNumber,
  };
}