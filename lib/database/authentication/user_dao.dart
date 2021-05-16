import 'dart:async';
import 'package:find_hotel/database/database.dart';
import 'package:find_hotel/database/authentication/model.dart';

class UserDao {
  final dbProvider = DatabaseProvider.dbProvider;

  Future<int> createUser(UserModel user) async {
    final db = await dbProvider.database;
    var result = db.insert(userTABLE, user.toDatabaseJson());
    return result;
  }

  Future<List<UserModel>> getUsers({List<String> columns, String query}) async {
    final db = await dbProvider.database;

    List<Map<String, dynamic>> result;
    if (query != null) {
      if (query.isNotEmpty)
        result = await db.query(userTABLE);
    } else {
      result = await db.query(userTABLE, columns: columns);
    }

    List<UserModel> users = result.isNotEmpty
        ? result.map((item) => UserModel.fromDatabaseJson(item)).toList()
        : [];
    return users;
  }

  Future deleteAllUsers() async {
    final db = await dbProvider.database;
    var result = await db.delete(
      userTABLE,
    );

    return result;
  }
}