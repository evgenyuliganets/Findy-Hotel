class UserModel {
  int id;
  String username;
  UserModel({this.id, this.username,});
  factory UserModel.fromDatabaseJson(Map<String, dynamic> data) => UserModel(
    id: data['id'],
    username: data['username'],
  );
  Map<String, dynamic> toDatabaseJson() => {
    "id": this.id,
    "username": this.username,
  };
}