import 'dart:async';
import 'package:find_hotel/database/database.dart';
import 'package:find_hotel/database/photos/photos_db_model.dart';

class PhotosDao {
  final dbProvider = DatabaseProvider.dbProvider;

  Future<int> createPhoto(PhotosDbDetail photosDbDetail) async {
    final db = await dbProvider.database;
    var result = db.insert(photosTABLE, photosDbDetail.toDatabaseJson());
    return result;
  }

  Future<List<PhotosDbDetail>> getPhotos(
      {List<String> columns, String query}) async {
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
    var queryResult = await db.rawQuery(
        'SELECT * FROM Photos WHERE placeId="$placeId"');
    var res = queryResult.toList();
    if (queryResult != null) {
      var list = List<PhotosDbDetail>.empty(growable: true);
      res.forEach((element) {
        list.add(PhotosDbDetail(
          placeId: element.values.elementAt(1),
          photo: element.values.elementAt(2),
        ));});
      return list;
    }
    else
      return List<PhotosDbDetail>.empty(growable: true);
  }

  Future<PhotosDbDetail> getPhoto(String placeId) async {
    final db = await dbProvider.database;
    var queryResult = await db.rawQuery(
        'SELECT * FROM Photos WHERE placeId="$placeId"');
    var res = queryResult.toList();
    if (queryResult != null) {
      return PhotosDbDetail(
        placeId: res.first.values.elementAt(1),
        photo: res.first.values.elementAt(2),
      );
    }
    else
      return PhotosDbDetail();
  }

  Future<int> deleteSelected(String placeId) async {
    final db = await dbProvider.database;
    var result = await db.delete(
        photosTABLE, where: 'placeId = ?', whereArgs: [placeId]);

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