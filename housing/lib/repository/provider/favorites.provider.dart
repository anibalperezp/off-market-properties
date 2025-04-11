import 'package:flutter/widgets.dart';
import 'package:zipcular/models/listing/search/listing.dart';
import 'package:zipcular/repository/facade/saves.facade.dart';

class FavoriteProvider extends ChangeNotifier {
  final List<Listing> favorites = [];
  bool initialized = false;

  Future<void> fetchFavoriteFromDatabase() async {
    initialized = true;
    this.favorites.clear();
    final result = await SavesFacade().getFavorites();
    if (result.bSuccess!) {
      if (result.data.count > 0) {
        for (final element in result.data.list) {
          this.favorites.add(element);
        }
      }
    }
    notifyListeners();
  }

  Future<void> addFavorite(Listing listing) async {
    this.favorites.add(listing);
    notifyListeners();
    await SavesFacade().addFavoriteLising(listing);
  }

  Future<void> deleteFavorite(Listing listing) async {
    this.favorites.remove(listing);
    notifyListeners();
    final result = await SavesFacade().deleteFavoriteLising(listing);
  }
}
