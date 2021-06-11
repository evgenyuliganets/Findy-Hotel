import 'dart:typed_data';

class PhotosDbDetail{
   int id;
   String placeId;
   Uint8List photo;
   String photosReference;


  PhotosDbDetail({
    this.id,
    this.placeId,
    this.photo,
    this.photosReference,
  });
  factory PhotosDbDetail.fromDatabaseJson(Map<String, dynamic> data) => PhotosDbDetail(
    id: data['id'],
    placeId:data['placeId'],
    photo:data['photo'],
    photosReference:data['photosReferences'],
  );
  Map<String, dynamic> toDatabaseJson() => {
    "id": this.id,
    "placeId": this.placeId,
    "photo": this.photo,
    "photosReference": this.photosReference,
  };
}