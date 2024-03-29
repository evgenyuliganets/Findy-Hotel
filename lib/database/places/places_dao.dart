import 'dart:async';
import 'package:find_hotel/database/database.dart';
import 'package:find_hotel/database/places/places_db_model.dart';

class PlacesDao {
  final dbProvider = DatabaseProvider.dbProvider;

  Future<int> createPlace(PlacesDbDetail placesDbDetail) async {
    final db = await dbProvider.database;
    var result = db.insert(placesTABLE, placesDbDetail.toDatabaseJson());
    return result;
  }

  Future<List<PlacesDbDetail>> getAllPlaces(
      {List<String> columns, String query}) async {
    final db = await dbProvider.database;

    List<Map<String, dynamic>> result;
    if (query != null) {
      if (query.isNotEmpty) result = await db.query(placesTABLE);
    } else {
      result = await db.query(placesTABLE, columns: columns);
    }

    List<PlacesDbDetail> places = result.isNotEmpty
        ? result.map((item) => PlacesDbDetail.fromDatabaseJson(item)).toList()
        : [];
    return places;
  }

  Future<List<PlacesDbDetail>> getUserNearestPlaces() async {
    final db = await dbProvider.database;
    var queryResult =
        await db.rawQuery('SELECT * FROM Places WHERE isNearest="true"');
    var res = queryResult.toList();
    if (queryResult != null) {
      var list = new List<PlacesDbDetail>.empty(growable: true);
      res.forEach((element) {
        list.add(PlacesDbDetail(
          icon: element.values.elementAt(1),
          isNearest: element.values.elementAt(2).toString(),
          isRecentlyViewed: element.values.elementAt(3).toString(),
          isFavorite: element.values.elementAt(4).toString(),
          name: element.values.elementAt(5),
          openNow: element.values.elementAt(6),
          latitude: element.values.elementAt(7),
          longitude: element.values.elementAt(8),
          placeId: element.values.elementAt(9),
          priceLevel: element.values.elementAt(10),
          rating: element.values.elementAt(11),
          types: element.values.elementAt(12),
          vicinity: element.values.elementAt(13),
          formattedAddress: element.values.elementAt(14),
          openingHours: element.values.elementAt(15),
          website: element.values.elementAt(16),
          utcOffset: element.values.elementAt(17),
          formattedPhoneNumber: element.values.elementAt(18),
          internationalPhoneNumber: element.values.elementAt(19),
        ));
      });
      return list;
    } else
      return List<PlacesDbDetail>.empty(growable: true);
  }

  Future<List<PlacesDbDetail>> getUserRecentlyViewedPlaces() async {
    final db = await dbProvider.database;
    var queryResult =
        await db.rawQuery('SELECT * FROM Places WHERE isRecentlyViewed="true"');
    var res = queryResult.toList();
    if (queryResult != null) {
      var list = new List<PlacesDbDetail>.empty(growable: true);
      res.forEach((element) {
        list.add(PlacesDbDetail(
          icon: element.values.elementAt(1),
          isNearest: element.values.elementAt(2).toString(),
          isRecentlyViewed: element.values.elementAt(3).toString(),
          isFavorite: element.values.elementAt(4).toString(),
          name: element.values.elementAt(5),
          openNow: element.values.elementAt(6),
          latitude: element.values.elementAt(7),
          longitude: element.values.elementAt(8),
          placeId: element.values.elementAt(9),
          priceLevel: element.values.elementAt(10),
          rating: element.values.elementAt(11),
          types: element.values.elementAt(12),
          vicinity: element.values.elementAt(13),
          formattedAddress: element.values.elementAt(14),
          openingHours: element.values.elementAt(15),
          website: element.values.elementAt(16),
          utcOffset: element.values.elementAt(17),
          formattedPhoneNumber: element.values.elementAt(18),
          internationalPhoneNumber: element.values.elementAt(19),
        ));
      });
      print(list);
      return list.reversed.toList();
    } else
      return List<PlacesDbDetail>.empty(growable: true);
  }

  Future<List<PlacesDbDetail>> getUserFavoritePlaces() async {
    final db = await dbProvider.database;
    var queryResult =
        await db.rawQuery('SELECT * FROM Places WHERE isFavorite="true"');
    var res = queryResult.toList();
    if (queryResult != null) {
      var list = new List<PlacesDbDetail>.empty(growable: true);
      res.forEach((element) {
        list.add(PlacesDbDetail(
          icon: element.values.elementAt(1),
          isNearest: element.values.elementAt(2).toString(),
          isRecentlyViewed: element.values.elementAt(3).toString(),
          isFavorite: element.values.elementAt(4).toString(),
          name: element.values.elementAt(5),
          openNow: element.values.elementAt(6),
          latitude: element.values.elementAt(7),
          longitude: element.values.elementAt(8),
          placeId: element.values.elementAt(9),
          priceLevel: element.values.elementAt(10),
          rating: element.values.elementAt(11),
          types: element.values.elementAt(12),
          vicinity: element.values.elementAt(13),
          formattedAddress: element.values.elementAt(14),
          openingHours: element.values.elementAt(15),
          website: element.values.elementAt(16),
          utcOffset: element.values.elementAt(17),
          formattedPhoneNumber: element.values.elementAt(18),
          internationalPhoneNumber: element.values.elementAt(19),
        ));
      });
      return list.reversed.toList();
    } else
      return List<PlacesDbDetail>.empty(growable: true);
  }

  Future<PlacesDbDetail> getPlace(String placeId) async {
    final db = await dbProvider.database;
    var queryResult =
        await db.rawQuery('SELECT * FROM Places WHERE placeId="$placeId"');
    var res = queryResult.toList();
    if (queryResult != null) {
      print(queryResult.toString());
      return PlacesDbDetail(
        icon: res.first.values.elementAt(1),
        isNearest: res.first.values.elementAt(2).toString(),
        isRecentlyViewed: res.first.values.elementAt(3).toString(),
        isFavorite: res.first.values.elementAt(4).toString(),
        name: res.first.values.elementAt(5),
        openNow: res.first.values.elementAt(6),
        latitude: res.first.values.elementAt(7),
        longitude: res.first.values.elementAt(8),
        placeId: res.first.values.elementAt(9),
        priceLevel: res.first.values.elementAt(10),
        rating: res.first.values.elementAt(11),
        types: res.first.values.elementAt(12),
        vicinity: res.first.values.elementAt(13),
        formattedAddress: res.first.values.elementAt(14),
        openingHours: res.first.values.elementAt(15),
        website: res.first.values.elementAt(16),
        utcOffset: res.first.values.elementAt(17),
        formattedPhoneNumber: res.first.values.elementAt(18),
        internationalPhoneNumber: res.first.values.elementAt(19),
      );
    } else
      return PlacesDbDetail();
  }

  Future<int> updatePlace(PlacesDbDetail place) async {
    final db = await dbProvider.database;
    var queryResult = await db
        .rawQuery('SELECT * FROM Places WHERE placeId="${place.placeId}"');
    var res = queryResult.toList();
    place.id = res.first.values.elementAt(0);
    var result = await db.update(placesTABLE, place.toDatabaseJson(),
        where: 'id = ${res.first.values.elementAt(0)}');
    print(result);
    return result;
  }

  Future<bool> checkIfExist(String placeId) async {
    final db = await dbProvider.database;

    var queryResult =
        await db.rawQuery('SELECT * FROM Places WHERE placeId="$placeId"');
    if (queryResult.isNotEmpty)
      return true;
    else
      return false;
  }

  Future<bool> checkIfExistInFavorite(String placeId) async {
    final db = await dbProvider.database;

    var queryResult = await db.rawQuery(
        'SELECT * FROM Places WHERE placeId="$placeId" AND isFavorite="true"');
    if (queryResult.isNotEmpty)
      return true;
    else
      return false;
  }

  Future<bool> checkIfExistInRecent(String placeId) async {
    final db = await dbProvider.database;

    var queryResult = await db.rawQuery(
        'SELECT * FROM Places WHERE placeId="$placeId" AND isRecentlyViewed="true"');
    if (queryResult.isNotEmpty)
      return true;
    else
      return false;
  }

  Future deleteAllPlaces() async {
    final db = await dbProvider.database;
    var result = await db.delete(
      placesTABLE,
    );

    return result;
  }

  Future<int> deletePlace(String placeId) async {
    final db = await dbProvider.database;
    var result = await db
        .delete(placesTABLE, where: 'placeId = ?', whereArgs: [placeId]);

    return result;
  }
}
