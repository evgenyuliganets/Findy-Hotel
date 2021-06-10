import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
final userTABLE = 'User';
final placesTABLE = 'Places';
final photosTABLE = 'Photos';
class DatabaseProvider {
  static final DatabaseProvider dbProvider = DatabaseProvider();
  Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await createUserDatabase();
    return _database;
  }
  createUserDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "User.db");
    var database = await openDatabase(path,
        version: 1, onCreate: initUserDB, onUpgrade: onUpgrade);
    return database;
  }
  void onUpgrade(Database database, int oldVersion, int newVersion) {
    if (newVersion > oldVersion) {}
  }
  void initUserDB(Database database, int version) async {
    print('DATABASE Creating table');
     await database.execute("CREATE TABLE $userTABLE ("
        "id INTEGER PRIMARY KEY, "
        "username TEXT"
        ")");
    print('Created User');
     await database.execute("CREATE TABLE $placesTABLE ("
         "id INTEGER PRIMARY KEY, "
         "icon TEXT, "
         "name TEXT, "
         "openNow TEXT,"
         "latitude REAL, "
         "longitude REAL, "
         "placeId TEXT, "
         "priceLevel TEXT, "
         "rating REAL, "
         "vicinity TEXT, "
         "formattedAddress TEXT, "
         "openingHours TEXT, "
         "website TEXT, "
         "utcOffset REAL, "
         "formattedPhoneNumber TEXT, "
         "internationalPhoneNumber TEXT "
         ")");
    print('Created Place');
    await database.execute("CREATE TABLE $photosTABLE ("
        "id INTEGER PRIMARY KEY, "
        "placeId TEXT, "
        "photo BLOB, "
        "photosReference TEXT "
        ")");
    print('Created photo');
  }

}