import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:find_hotel/home/model/places_detail_model.dart';
import 'package:find_hotel/profile/data_repository/profile_data.dart';
import 'package:meta/meta.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


part 'recently_viewed_event.dart';
part 'recently_viewed_state.dart';

class RecentlyViewedBloc extends Bloc<RecentlyViewedEvent, RecentlyViewedState> {
  final ProfileRepository profileRepo;
  RecentlyViewedBloc(this.profileRepo) : super(RecentlyViewedInitial());

  @override
  Stream<RecentlyViewedState> mapEventToState(
    RecentlyViewedEvent event,
  ) async* {
    if (event is GetRecentlyViewedPlaces) {           //Get nearby UserPlaces or UserPlaces from dataBase
      try {
        yield (RecentlyViewedLoading());
        final places = await profileRepo.fetchRecentlyViewedPlacesFromDataBase();
        yield (RecentlyViewedLoaded(places:places));
      }

      on PlacesNotFoundException{
        yield (RecentlyViewedError(AppLocalizations.of(profileRepo.context).recentError,
        ));
      }
      catch (error){
        if (!(error is PlacesNotFoundException)){
          yield (RecentlyViewedError(AppLocalizations.of(profileRepo.context).placesFromDatabaseCriticalErr));
        }
      }
    }
  }
}
