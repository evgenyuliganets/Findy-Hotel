import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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

  var options = OpenDatabaseOptions(
    version: 1,
    onOpen: (db) {},
    onUpgrade: (Database database, int oldVersion, int newVersion) {
      if (newVersion > oldVersion) {}
    },
    onCreate: (Database database, int version) async {
      print('DATABASE Creating tables');
      await database.execute("CREATE TABLE $userTABLE ("
          "id INTEGER PRIMARY KEY, "
          "username TEXT"
          ")");
      print('Created User');
      await database.execute("CREATE TABLE $placesTABLE ("
          "id INTEGER PRIMARY KEY, "
          "isNearest TEXT,"
          "isRecentlyViewed TEXT,"
          "isFavorite TEXT,"
          "icon TEXT, "
          "name TEXT, "
          "openNow TEXT,"
          "latitude REAL, "
          "longitude REAL, "
          "placeId TEXT, "
          "priceLevel TEXT, "
          "rating REAL, "
          "types TEXT, "
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
          "photo BLOB "
          ")");
      print('Created photo');
    },
  );

  createUserDatabase() async {
    final databaseFactory = databaseFactoryFfi;
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "User.db");
    var database;
    if (Platform.isWindows) {
      return databaseFactory.openDatabase(path, options: options);
    }
    else{
       database = await openDatabase(path,
          version: options.version,
          onCreate: options.onCreate,
          onUpgrade: options.onUpgrade,
          onOpen: options.onOpen);
    }
    return database;
  }
}
