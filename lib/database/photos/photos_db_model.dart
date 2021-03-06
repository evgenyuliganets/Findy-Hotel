import 'dart:typed_data';

class PhotosDbDetail{
   int id;
   String placeId;
   Uint8List photo;

  PhotosDbDetail({
    this.id,
    this.placeId,
    this.photo,
  });
  factory PhotosDbDetail.fromDatabaseJson(Map<String, dynamic> data) => PhotosDbDetail(
    id: data['id'],
    placeId:data['placeId'],
    photo:data['photo'],
  );
  Map<String, dynamic> toDatabaseJson() => {
    "id": this.id,
    "placeId": this.placeId,
    "photo": this.photo,
  };
}