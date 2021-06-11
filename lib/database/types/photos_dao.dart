  import 'dart:async';
import 'dart:typed_data';
import 'package:find_hotel/database/database.dart';
import 'package:find_hotel/database/types/photos_db_model.dart';

class PhotosDao {
  final dbProvider = DatabaseProvider.dbProvider;

  Future<int> createPhoto(PhotosDbDetail photosDbDetail) async {
    final db = await dbProvider.database;
    var result = db.insert(photosTABLE, photosDbDetail.toDatabaseJson());
    return result;
  }

  Future<List<PhotosDbDetail>> getPhotos({List<String> columns, String query}) async {
    final db = await dbProvider.database;

    List<Map<String, dynamic>> result;
    if (query != null) {
      if (query.isNotEmpty)
        result = await db.query(photosTABLE);
    } else {
      result = await db.query(photosTABLE, columns: columns);
    }

    List<PhotosDbDetail> places = result.isNotEmpty
        ? result.map((item) => PhotosDbDetail.fromDatabaseJson(item)).toList()
        : [];
    return places;
  }

  Future <List<PhotosDbDetail>> getSelectedPhotos(String placeId) async {
    final db = await dbProvider.database;
    var queryResult = await db.rawQuery('SELECT * FROM Photos WHERE placeId="$placeId"') ;
    var res = queryResult.toList();
    if (queryResult!=null) {
      var j = 0;
      List<PhotosDbDetail> list = new List<PhotosDbDetail>(res.length);
      list.forEach((element) {
        list[j] = PhotosDbDetail(
          placeId:res[j].values.elementAt(1),
          photo: res[j].values.elementAt(2),
          photosReference: res[j].values.elementAt(3),
        );
        j++;});
      return list;
    }
    else return List<PhotosDbDetail>.empty(growable: true);
  }

  Future<PhotosDbDetail> getPhoto(String placeId) async {
    final db = await dbProvider.database;
    var queryResult = await db.rawQuery('SELECT * FROM Photos WHERE placeId="$placeId"') ;
    var res = queryResult.toList();
    if (queryResult!=null){
      return PhotosDbDetail(
        placeId:res.first.values.elementAt(1),
        photo: res.first.values.elementAt(2),
        photosReference: res.first.values.elementAt(3),
      );
    }
    else return PhotosDbDetail();
  }

  Future<int> updatePhoto(PhotosDbDetail photo) async {
    final db = await dbProvider.database;
    var queryResult = await db.rawQuery('SELECT * FROM Photos WHERE placeId="${photo.placeId}" AND photosReference="${photo.photosReference}"');
    var res = queryResult.toList();
    photo.id = res.first.values.elementAt(0);
    var result = await db.update(photosTABLE, photo.toDatabaseJson(),
        where: 'id = ${res.first.values.elementAt(0)}');
    print(result);
    return result;
  }

  Future<bool> checkIfExist(String placeId, String photosReference) async {
    final db = await dbProvider.database;

    var queryResult = await db.rawQuery('SELECT * FROM Photos WHERE placeId="$placeId" AND photosReference="$photosReference"');
    if (queryResult.isNotEmpty)
      return true;
    else
      return false;
  }

  Future<int> deletePhoto(String placeId) async {
    final db = await dbProvider.database;
    var result = await db.delete(photosTABLE, where: 'placeId = ?', whereArgs: [placeId]);

    return result;
  }

  Future deleteAllPhotos() async {
    final db = await dbProvider.database;
    var result = await db.delete(
      photosTABLE,
    );

    return result;
  }
}