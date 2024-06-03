import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bp/model/firestore_models/storage_model.dart';
import 'package:bp/model/kakao_map/place_detail.dart';
import 'package:bp/model/place/my_place.dart';
import 'package:bp/model/place/place.dart';
import 'package:bp/model/place/place_zip.dart';
import 'package:bp/model/user.dart';
import 'package:bp/presentation/widgets/loading_indicator.dart';
import 'package:bp/provider/exceptions/cache_not_hit_exception.dart';
import 'package:bp/service/firestore/exceptions.dart';
import 'package:bp/service/kakao_service.dart';
import 'package:bp/service/location_service.dart';
import 'package:flutter/material.dart';

import '../service/firestore/firestore_service.dart';

class PlaceProvider with ChangeNotifier {
  List<MyPlace>? publicPlaces;
  Set<String>? publicCategories;

  List<MyPlace>? myPlaces;
  Set<String>? categories;
  List<Place>? places;
  Map<String, List<FirebaseStorageModel>> storageCache = {};
  Map<String, DateTime> cacheTimeout = {};

  List<MyPlace>? selectedPlacesToShare;
  List<PlaceZip>? mySharedPlaceZip;

  Set<String>? _selectedCategory; // 기본 카테고리를 최신순으로 설정
  String? _searchKeyword;

  Set<String>? get selectedCategory => _selectedCategory;

  bool get hasSearchKeyword =>
      _searchKeyword != null && _searchKeyword!.isNotEmpty;
  bool get hasCategoryFilter =>
      _selectedCategory != null && _selectedCategory!.isNotEmpty;
  bool get hasFilter => hasSearchKeyword || hasCategoryFilter;

  void reset() {
    mySharedPlaceZip = null;
    selectedPlacesToShare = null;
    myPlaces = null;
    places = null;
    storageCache.clear();
    cacheTimeout.clear();
    _selectedCategory = null;
    _searchKeyword = null;
  }

  void clearCatrgoryFilters({bool shouldNotify = true}) {
    _selectedCategory = null;
    if (shouldNotify) notifyListeners();
  }

  void clearKeywordFilters({bool shouldNotify = true}) {
    _searchKeyword = null;
    if (shouldNotify) notifyListeners();
  }

  bool containesMyPlacesToShare(MyPlace place) {
    return selectedPlacesToShare
            ?.where((e) => e.docRef! == place.docRef)
            .isNotEmpty ??
        false;
  }

  Future<void> fetchMyShareZip(String uid, {bool shouldNotify = true}) async {
    mySharedPlaceZip = await FirestoreService().fetchMySharedPlaceZip(uid: uid);
    if (shouldNotify) notifyListeners();
  }

  Future<PlaceZip?> postShareZip(
      {required AppUser user,
      required String title,
      required String? description,
      bool shouldNotify = true}) async {
    if (selectedPlacesToShare == null) return null;
    final zip = await FirestoreService().postShareZip(
      myPlaces: selectedPlacesToShare!,
      user: user,
      title: title,
      description: description,
    );
    selectedPlacesToShare = null;
    mySharedPlaceZip ??= [];
    mySharedPlaceZip!.add(zip);
    if (shouldNotify) notifyListeners();
    return zip;
  }

  void addMyPlaceToShare(MyPlace place, {bool shouldNotify = true}) {
    selectedPlacesToShare ??= [];
    if (place.docRef == null) return;
    if (!containesMyPlacesToShare(place)) {
      selectedPlacesToShare!.add(place);
    }
    if (shouldNotify) notifyListeners();
  }

  bool deleteMyPlaceToShare(MyPlace place, {bool shouldNotify = true}) {
    selectedPlacesToShare ??= [];
    final old = selectedPlacesToShare!.length;
    selectedPlacesToShare!.removeWhere((e) => e.docRef! == place.docRef);
    final recent = selectedPlacesToShare!.length;

    if (shouldNotify) notifyListeners();

    return old != recent;
  }

  void addOrDeleteMyPlaceToShare(MyPlace place, {bool shouldNotify = true}) {
    if (!deleteMyPlaceToShare(place)) {
      addMyPlaceToShare(place);
    }

    if (shouldNotify) notifyListeners();
  }

  List<MyPlace>? getFilteredMyPlaces() {
    if (myPlaces == null) return null;

    bool containsKeyword(MyPlace place) {
      if (_searchKeyword == null) return true;
      return place.description?.contains(_searchKeyword!) == true ||
          place.place?.placeName.contains(_searchKeyword!) == true;
    }

    bool containsAllTags(List<String>? categories) {
      if (_selectedCategory == null) return true;
      if (categories == null) return false;

      for (String c in _selectedCategory!) {
        if (!categories.contains(c)) return false;
      }
      return true;
    }

    List<MyPlace> result = myPlaces!;
    if (_searchKeyword != null) {
      result = result
          .where(
            (element) => containsKeyword(element),
          )
          .toList();
    }
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      result = result
          .where((element) => containsAllTags(element.categories))
          .toList();
    }
    result.sort((a, b) =>
        b.createdAt.millisecondsSinceEpoch -
        a.createdAt.millisecondsSinceEpoch);
    return result;
  }

  void setSearchKeyword(String? keyword, {bool shouldNotify = true}) {
    _searchKeyword = keyword;
    if (shouldNotify) notifyListeners();
  }

  void setCategory(String category, {bool shouldNotify = true}) {
    _selectedCategory ??= {};
    if (!_selectedCategory!.remove(category)) {
      _selectedCategory!.add(category);
    }
    if (shouldNotify) notifyListeners();
  }

  Future<List<FirebaseStorageModel>> fetchPlacePhotos({
    required FileStorageType fileStorageType,
    required String folderId,
    bool fromCache = true,
  }) async {
    if (fromCache && storageCache.containsKey(folderId)) {
      return storageCache[folderId]!;
    }
    final list = await FirestoreService().getAllFilesUnderFolder(
        fileStorageType: fileStorageType, folderId: folderId);
    storageCache[folderId] = list;
    return list;
  }

  Future<void> postMyPlace({
    required PlaceDetail detail,
    required String uid,
    required String? description,
    required List<File>? files,
    required BuildContext context,
    bool public = true,
    bool shouldNotify = true,
  }) async {
    LoadingIndicatorDialog().show(context);
    try {
      final Place placeModel = Place.fromPlaceDetail(detail);
      Place masterPlace = await FirestoreService().postPlace(placeModel);
      final myPlaceRepo = MyPlaceRepo(
          placeRef: masterPlace.docRef!,
          uid: uid,
          files: files,
          description: description,
          categories: masterPlace.categories,
          public: public,
          geo: placeModel.geo);
      final newMasterPlace = await FirestoreService()
          .updatePlace(placeModel.copyWith(savedCnt: placeModel.savedCnt + 1));
      if (places != null) {
        places!.removeWhere(
            (element) => element.kakaoPlaceId == newMasterPlace.kakaoPlaceId);
      }
      places ??= [];
      places!.add(newMasterPlace);
      if (!context.mounted) return;
      final myPlaceModel =
          await FirestoreService().postMyPlace(context, myPlaceRepo);
      myPlaces ??= [];
      myPlaces!.add(myPlaceModel);
    } catch (e) {
      shouldNotify = false;
      if (context.mounted) {
        log(e.toString());
        _showDialogForException(context,
            e is FirestoreException ? e.toString() : "내 장소를 저장하는데 실패하였습니다.");
      }
    } finally {
      LoadingIndicatorDialog().dismiss();
    }
    if (shouldNotify) notifyListeners();
  }

  Future<void> fetchMyPlaces(
    String uid, {
    required BuildContext context,
    bool shouldNotify = true,
  }) async {
    try {
      myPlaces = await FirestoreService().fetchMyPlace(context, uid);
      if (!context.mounted) return;
      myPlaces!.forEach(_addCategory);
      final List<Future> tasks = [];
      for (var element in myPlaces!) {
        tasks.add(_fetchData(element, context));
      }
      await Future.wait(tasks);
    } catch (e) {
      shouldNotify = false;
      if (context.mounted) {
        log(e.toString());
        _showDialogForException(context,
            e is FirestoreException ? e.toString() : "내 장소를 불러오는데 실패하였습니다.");
      }
    }
    if (shouldNotify) notifyListeners();
  }

  Future<void> fetchPublicPlacesList({
    required BuildContext context,
    bool shouldNotify = true,
    bool fromCache = true,
    int timeoutInSec = 300,
    double? radiusInKm,
  }) async {
    if (fromCache && publicPlaces != null) {
      if (cacheTimeout.containsKey("fetchPublicPlacesStream")) {
        final cachedAt = cacheTimeout["fetchPublicPlacesStream"];
        if (DateTime.now()
                .compareTo(cachedAt!.add(Duration(seconds: timeoutInSec))) !=
            1) {
          if (shouldNotify) notifyListeners();
          return;
        }
      }
    }
    try {
      final location = await LocationService().getCurrentLocation();
      if (!context.mounted) return;
      publicPlaces = await FirestoreService().getPublicPlaceList(context,
          lat: location.latitude,
          long: location.longitude,
          radiusInKm: radiusInKm);
      cacheTimeout["fetchPublicPlacesStream"] = DateTime.now();
    } on LocationServiceException catch (_) {
      if (!context.mounted) return;
      publicPlaces = await FirestoreService().getPublicPlaceList(context);
      cacheTimeout["fetchPublicPlacesStream"] = DateTime.now();
    } catch (e) {
      shouldNotify = false;
      if (context.mounted) {
        log(e.toString());
        _showDialogForException(context,
            e is FirestoreException ? e.toString() : "장소를 불러오는데 실패하였습니다.");
      }
    }
    if (shouldNotify) notifyListeners();
  }

  Future<void> _fetchData(MyPlace element, BuildContext context) async {
    await element.getPlace(context);
    if (!context.mounted) return;
    await element.fetchPhotos(context);
  }

  void _addCategory(MyPlace element) {
    categories ??= {};
    final target = element.categories;
    if (target == null) return;
    categories!.addAll(target);
  }

  FutureOr<Place> getPlaceByRef(MyPlace myPlace) async {
    if (myPlace.docRef == null) {
      throw FetchException(msg: "내 장소를 불러오는데 실패하였습니다.");
    }
    try {
      if (places == null) throw CacheNotHitException();

      final candidate =
          places!.where((place) => place.docRef?.path == myPlace.placeRef.path);
      if (candidate.isEmpty) throw CacheNotHitException();
      return candidate.first;
    } on CacheNotHitException catch (_) {
      final fetchedPlace =
          await FirestoreService().fetchPlaceByRef(myPlace.placeRef);
      places ??= [];
      places!.add(fetchedPlace);
      return fetchedPlace;
    } catch (e) {
      log("getPlaceByRef error: $e");
      throw FetchException(msg: "내 장소를 불러오는데 실패하였습니다.");
    }
  }

  void _showDialogForException(BuildContext context, String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(msg),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("확인"),
            )
          ],
        );
      },
    );
  }
}
