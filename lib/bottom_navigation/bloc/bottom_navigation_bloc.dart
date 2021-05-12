import 'dart:async';
import 'package:find_hotel/home/data_repository/home_repository.dart';
import 'package:find_hotel/map/repository/map_repository.dart';
import 'package:find_hotel/profile/repository/profile_repository.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'bottom_navigation_event.dart';
part 'bottom_navigation_state.dart';

class BottomNavigationBloc
    extends Bloc<BottomNavigationEvent, BottomNavigationState> {
  BottomNavigationBloc({this.homeRepository, this.mapRepository, this.profileRepository, })
      : assert(homeRepository != null),
        assert(mapRepository != null),
        assert(profileRepository != null),
        super(PageLoading());

  final HomeRepository homeRepository;
  final MapRepository mapRepository;
  final ProfileRepository profileRepository;
  int currentIndex = 0;

  @override
  Stream<BottomNavigationState> mapEventToState(BottomNavigationEvent event) async* {
    if (event is AppStarted) {
      this.add(PageTapped(index: this.currentIndex));
    }
    if (event is PageTapped) {
      this.currentIndex = event.index;
      yield CurrentIndexChanged(currentIndex: this.currentIndex);
      yield PageLoading();

      if (this.currentIndex == 0) {
        String data = await _getHomePageData();
        yield HomePageLoaded(text: data);
      }
      if (this.currentIndex == 1) {
        int data = await _getMapPageData();
        yield MapPageLoaded(number: data);
      }
      if (this.currentIndex == 2) {
        int data = await _getProfilePageData();
        yield ProfilePageLoaded(number: data);
      }
      else if(this.currentIndex==null){
        yield PageError('Unknown error');
      }
    }

  }

  Future<String> _getHomePageData() async {
    String data = homeRepository.data;
    if (data == null) {
      await homeRepository.fetchData();
      data = homeRepository.data;
    }
    return data;
  }

  Future<int> _getMapPageData() async {
    int data = mapRepository.data;
    if (data == null) {
      await mapRepository.fetchData();
      data = mapRepository.data;
    }
    return data;
  }

  Future<int> _getProfilePageData() async {
    int data = mapRepository.data;
    if (data == null) {
      await mapRepository.fetchData();
      data = mapRepository.data;
    }
    return data;
  }
}