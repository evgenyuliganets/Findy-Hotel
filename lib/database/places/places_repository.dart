import 'package:find_hotel/database/authentication/model.dart';
import 'package:find_hotel/database/authentication/user_dao.dart';

class UsersRepository {
  final userDao = UserDao();

  Future<List<UserModel>> getAllUser({String  query}) => userDao.getUsers(query: query);

  Future insertUser(UserModel user) => userDao.createUser(user);

  Future deleteAllUsers() => userDao.deleteAllUsers();
}