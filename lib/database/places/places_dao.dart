import 'dart:async';
import 'package:find_hotel/database/database.dart';
import 'package:find_hotel/database/authentication/model.dart';
import 'package:find_hotel/database/places/places_db_model.dart';
import 'package:find_hotel/home/model/places_detail_model.dart';

class UserDao {
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

    List<PlacesDbDetail> users = result.isNotEmpty
        ? result.map((item) => PlacesDbDetail.fromDatabaseJson(item)).toList()
        : [];
    return users;
  }

  Future deleteAllPlaces() async {
    final db = await dbProvider.database;
    var result = await db.delete(
      placesTABLE,
    );

    return result;
  }
}