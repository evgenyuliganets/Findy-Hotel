
import 'package:find_hotel/database/types/photos_dao.dart';
import 'package:find_hotel/database/types/photos_db_model.dart';





class PhotosRepository {
  final photosDao = PhotosDao();

  Future<List<PhotosDbDetail>> getAllPhotos({String  query}) => photosDao.getPhotos(query: query);

  Future <List<PhotosDbDetail>> getSelectedPhotos(String placeId) => photosDao.getSelectedPhotos(placeId);

  Future insertPhoto(PhotosDbDetail photo) => photosDao.createPhoto(photo);

  Future updatePhoto(PhotosDbDetail photo) => photosDao.updatePhoto(photo);

  Future deletePhotos(String photo) => photosDao.deletePhoto(photo);

  Future deleteAllPhotos() => photosDao.deleteAllPhotos();

  Future getPhoto(String placeId) => photosDao.getPhoto(placeId);

  Future checkIfExist(String placeId, String photosReference) => photosDao.checkIfExist(placeId,photosReference);
}