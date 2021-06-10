  import 'dart:async';
import 'package:find_hotel/database/database.dart';
import 'package:find_hotel/database/places/places_db_model.dart';
class PlacesDao {
  final dbProvider = DatabaseProvider.dbProvider;

  Future<int> createPlaces(PlacesDbDetail placesDbDetail) async {
    final db = await dbProvider.database;
    var result = db.insert(placesTABLE, placesDbDetail.toDatabaseJson());
    return result;
  }

  Future<List<PlacesDbDetail>> getPlaces({List<String> columns, String query}) async {
    final db = await dbProvider.database;

    List<Map<String, dynamic>> result;
    if (query != null) {
      if (query.isNotEmpty)
        result = await db.query(placesTABLE);
    } else {
      result = await db.query(placesTABLE, columns: columns);
    }

    List<PlacesDbDetail> places = result.isNotEmpty
        ? result.map((item) => PlacesDbDetail.fromDatabaseJson(item)).toList()
        : [];
    return places;
  }

  /*Future <List<PlacesDbDetail>> getUserPlaces(String owner) async {
    final db = await dbProvider.database;
    var queryResult = await db.rawQuery('SELECT * FROM Places WHERE owner="$owner"') ;
    var res = queryResult.toList();
    if (queryResult!=null) {
      var j = 0;
      List<PlacesDbDetail> list = new List<PlacesDbDetail>(res.length);
      list.forEach((element) {
        list[j] = PlacesDbDetail(
            icon:res[j].values.elementAt(1),
            name:res[j].values.elementAt(2),
            openNow:res[j].values.elementAt(3),
            weekDay: res[j].values.elementAt(4),
            latitude: res[j].values.elementAt(5),
            longitude: res[j].values.elementAt(6),
            photos_and_type_:res[j].values.elementAt(7),
            placeId:res[j].values.elementAt(8),
            priceLevel:res[j].values.elementAt(9),
            rating:res[j].values.elementAt(10),
            types:res[j].values.elementAt(11),
            vicinity:res[j].values.elementAt(12),
            formattedAddress:res[j].values.elementAt(13),
            openingHours: res[j].values.elementAt(14),
            website:res[j].values.elementAt(15),
            utcOffset:res[j].values.elementAt(16),
            formattedPhoneNumber:res[j].values.elementAt(17),
            internationalPhoneNumber:res[j].values.elementAt(18),
        );
        j++;});
      return list;
    }
    else return List<PlacesDbDetail>.empty(growable: true);
  }*/

  Future<PlacesDbDetail> getPlace(String placeId) async {
    final db = await dbProvider.database;
    var queryResult = await db.rawQuery('SELECT * FROM Places WHERE placeId="$placeId"') ;
    var res = queryResult.toList();
    if (queryResult!=null){
      print(queryResult.toString());
      return PlacesDbDetail(
        icon:res.first.values.elementAt(1),
        name:res.first.values.elementAt(2),
        openNow:res.first.values.elementAt(3),
        latitude: res.first.values.elementAt(4),
        longitude: res.first.values.elementAt(5),
        placeId:res.first.values.elementAt(6),
        priceLevel:res.first.values.elementAt(7),
        rating:res.first.values.elementAt(8),
        vicinity:res.first.values.elementAt(9),
        formattedAddress:res.first.values.elementAt(10),
        openingHours: res.first.values.elementAt(11),
        website:res.first.values.elementAt(12),
        utcOffset:res.first.values.elementAt(13),
        formattedPhoneNumber:res.first.values.elementAt(14),
        internationalPhoneNumber:res.first.values.elementAt(15),
      );
    }
    else return PlacesDbDetail();
  }

  Future<int> updatePlace(PlacesDbDetail place) async {
    final db = await dbProvider.database;
    var queryResult = await db.rawQuery('SELECT * FROM Places WHERE placeId="${place.placeId}"');
    var res = queryResult.toList();
    place.id = res.first.values.elementAt(0);
    var result = await db.update(placesTABLE, place.toDatabaseJson(),
        where: 'id = ${res.first.values.elementAt(0)}');
    print(result);
    return result;
  }

  Future<bool> checkIfExist(String placeId) async {
    final db = await dbProvider.database;

    var queryResult = await db.rawQuery('SELECT * FROM Places WHERE placeId="$placeId"');
    if (queryResult.isNotEmpty)
      return true;
    else
      return false;
  }

  Future<int> deletePlace(String placeId) async {
    final db = await dbProvider.database;
    var result = await db.delete(placesTABLE, where: 'placeId = ?', whereArgs: [placeId]);

    return result;
  }

  Future deleteAllPlaces() async {
    final db = await dbProvider.database;
    var result = await db.delete(
      placesTABLE,
    );

    return result;
  }
}