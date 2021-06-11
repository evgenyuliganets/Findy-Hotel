import 'dart:typed_data';
class PlacesDbDetail{
   int id;
   String icon;
   String name;
   String openNow;
   double latitude;
   double longitude;
   String placeId;
   String priceLevel;
   num rating;
   String types;
   String vicinity;
   String formattedAddress;
   String openingHours;
   String website;
   num utcOffset;
   String formattedPhoneNumber;
   String internationalPhoneNumber;


  PlacesDbDetail({
    this.id,
    this.icon,
    this.name,
    this.openNow,
    this.latitude,
    this.longitude,
    this.placeId,
    this.priceLevel,
    this.rating,
    this.types,
    this.vicinity,
    this.formattedAddress,
    this.openingHours,
    this.website,
    this.utcOffset,
    this.formattedPhoneNumber,
    this.internationalPhoneNumber,
  });
  factory PlacesDbDetail.fromDatabaseJson(Map<String, dynamic> data) => PlacesDbDetail(
    id: data['id'],
    icon:data['icon'],
    name:data['name'],
    openNow:data['openNow'],
    latitude: data['latitude'],
    longitude: data['longitude'],
    placeId:data['placeId'],
    priceLevel:data['priceLevel'],
    rating:data['rating'],
    types:data['types'],
    vicinity:data['vicinity'],
    formattedAddress:data['formattedAddress'],
    openingHours: data['openingHours'],
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
    "latitude": this.latitude,
    "longitude": this.longitude,
    "placeId": this.placeId,
    "priceLevel": this.priceLevel,
    "rating": this.rating,
    "types": this.types,
    "vicinity": this.vicinity,
    "formattedAddress": this.formattedAddress,
    "openingHours": this.openingHours,
    "website": this.website,
    "utcOffset": this.utcOffset,
    "formattedPhoneNumber": this.formattedPhoneNumber,
    "internationalPhoneNumber": this.internationalPhoneNumber,
  };
}