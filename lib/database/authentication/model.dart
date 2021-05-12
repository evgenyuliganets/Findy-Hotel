class UserModel {
  int id;
  String username;
  UserModel({this.id, this.username,});
  factory UserModel.fromDatabaseJson(Map<String, dynamic> data) => UserModel(
    id: data['id'],
    username: data['username'],
  );
  Map<String, dynamic> toDatabaseJson() => {
    //This will be used to convert Todo objects that
    //are to be stored into the database in a form of JSON
    "id": this.id,
    "username": this.username,
  };
}