import 'dart:async';
import 'package:find_hotel/map/repository/map_repository.dart';
import 'package:find_hotel/profile/data_repository/profile_data.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';

part 'bottom_navigation_event.dart';
part 'bottom_navigation_state.dart';

class BottomNavigationBloc
    extends Bloc<BottomNavigationEvent, BottomNavigationState> {
  BottomNavigationBloc():super(PageLoading());
  int currentIndex = 0;

  @override
  Stream<BottomNavigationState> mapEventToState(BottomNavigationEvent event) async* {
    if (event is AppStarted) {
      this.add(PageTapped(index: this.currentIndex));
    }
    if (event is PageTapped) {
      this.currentIndex = event.index;
      yield CurrentIndexChanged(currentIndex: this.currentIndex);
      if (this.currentIndex == 0) {
        yield HomePageStarted();
      }
      if (this.currentIndex == 1) {
        yield MapPageStarted();
      }
      if (this.currentIndex == 2) {
        yield ProfilePageStarted();
      }
      else if(this.currentIndex==null){
        yield PageError('Unknown error');
      }
    }

  }


}