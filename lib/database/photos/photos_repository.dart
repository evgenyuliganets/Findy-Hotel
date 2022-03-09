import 'package:find_hotel/database/photos/photos_dao.dart';
import 'package:find_hotel/database/photos/photos_db_model.dart';



class PhotosRepository {
  final photosDao = PhotosDao();

  Future<List<PhotosDbDetail>> getAllPhotos({String  query}) => photosDao.getPhotos(query: query);

  Future <List<PhotosDbDetail>> getSelectedPhotos(String placeId) => photosDao.getSelectedPhotos(placeId);

  Future insertPhoto(PhotosDbDetail photo) => photosDao.createPhoto(photo);

  Future deleteSelectedPhotos(String placeId) => photosDao.deleteSelected(placeId);

  Future deleteAllPhotos() => photosDao.deleteAllPhotos();

  Future getPhoto(String placeId) => photosDao.getPhoto(placeId);

}