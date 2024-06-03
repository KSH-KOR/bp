import 'dart:developer';
import 'dart:io';

import 'package:bp/model/firestore_models/saved_location.dart';
import 'package:bp/model/firestore_models/storage_model.dart';
import 'package:bp/model/place/my_place.dart';
import 'package:bp/model/place/place.dart';
import 'package:bp/model/place/place_zip.dart';
import 'package:bp/provider/file_pick_provider.dart';
import 'package:bp/service/firestore/exceptions.dart';
import 'package:bp/service/firestore/message_constant.dart';
import 'package:bp/service/kakao_service.dart';
import 'package:bp/utility/geo_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../../model/user.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _userCollection = 'users';
  static const String _saveLocationCollection = 'saved_locations';
  static const String _masterPlaceCollection = "master_places";
  static const String _myPlaceCollection = "my_places";
  static const String _sharedPlaceZip = "shared_place_zip";

  Future<void> batch1() async {
    // update place docs.
    final QuerySnapshot querySnapshot =
        await _firestore.collection(_masterPlaceCollection).get();
    for (final snap in querySnapshot.docs) {
      final data = snap.data() as Map<String, dynamic>?;
      if (data == null) continue;
      final place = Place.fromJson({...data, "docRef": snap.reference});
      await snap.reference.set(place.toJson());
      log("${snap.reference.id} updated");
    }
  }

  Future<void> batch2() async {
    // update my place docs.
    final QuerySnapshot querySnapshot =
        await _firestore.collection(_myPlaceCollection).get();
    for (final snap in querySnapshot.docs) {
      final data = snap.data() as Map<String, dynamic>?;
      if (data == null) continue;
      final place = MyPlace.fromJson({...data, "docRef": snap.reference});
      final master = await place.placeRef.get();
      final d2 = master.data();
      if (d2 == null) continue;
      final masterModel = Place.fromJson(d2);
      final geo = masterModel.geo?.data;

      await snap.reference.set({
        ...place.toJson(),
        "geo": geo,
        'createdAt': FieldValue.serverTimestamp()
      });
      log("${snap.reference.id} updated");
    }
  }

  // Add or Update a user document in Firestore from an AppUser instance
  Future<void> postUser(User firebaseUser) async {
    try {
      await _firestore.collection(_userCollection).doc(firebaseUser.uid).set({
        'uid': firebaseUser.uid,
        'name': firebaseUser.displayName,
        'email': firebaseUser.email,
        if (firebaseUser.phoneNumber != null)
          'phoneNumber': firebaseUser.phoneNumber,
      });
    } catch (e) {
      log(e.toString());
      throw FirestoreException(
          logMsg: e.toString(), errMsg: FirestoreMessage.failedToPostUser);
    }
  }

  // Fetch a user document by UID and convert to an AppUser instance
  Future<AppUser> getUser(User firebaseUser,
      {bool alreadyRetried = false}) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_userCollection)
          .doc(firebaseUser.uid)
          .get();

      if (!doc.exists) throw UserNotFound(errMsg: "user not found");

      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

      if (data == null) {
        throw FirestoreException(
          logMsg: "user document data is null",
          errMsg: FirestoreMessage.failedToGetUser,
        );
      }

      return AppUser.fromJson({
        "emailVerified": firebaseUser.emailVerified,
        "photoURL": firebaseUser.photoURL,
        ...data,
      });
    } on UserNotFound catch (e) {
      if (alreadyRetried) {
        throw FirestoreException(
          logMsg: "already retried log in. but still failed",
          errMsg: FirestoreMessage.failedToGetUser,
        );
      }
      log("$e, sign up process start..");
      await postUser(firebaseUser);
      return await getUser(firebaseUser, alreadyRetried: true);
    } catch (e) {
      log(e.toString());
      throw FirestoreException(
        logMsg: e.toString(),
        errMsg: FirestoreMessage.failedToGetUser,
      );
    }
  }

  Future<Place> postPlace(Place placeModel) async {
    final collection = _firestore.collection(_masterPlaceCollection);
    DocumentReference<Map<String, dynamic>>? newDocRef;
    try {
      await _firestore.runTransaction((transaction) async {
        // kakaoPlaceId로 문서 검색
        final querySnapshot = await collection
            .where('kakaoPlaceId', isEqualTo: placeModel.kakaoPlaceId)
            .limit(1)
            .get();

        // 존재하지 않는 경우, 새로운 Place 추가
        if (querySnapshot.docs.isEmpty) {
          newDocRef = collection.doc();
          transaction.set(newDocRef!, {
            ...placeModel.toJson(),
            'createdAt': FieldValue.serverTimestamp(), // 서버 타임스탬프 추가
          });
        } else {
          newDocRef = querySnapshot.docs.first.reference;
        }
      });

      if (newDocRef == null) {
        throw Exception('Document reference not found after transaction.');
      }

      final newPlaceData = placeModel.toJson();
      return Place.fromJson({...newPlaceData, "docRef": newDocRef!});
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<Place>> fetchPlaces() async {
    final collection = _firestore.collection(_masterPlaceCollection);
    List<Place> places = [];

    try {
      final querySnapshot = await collection.get();

      final places = querySnapshot.docs.map(
          (doc) => Place.fromJson({...doc.data(), "docRef": doc.reference}));

      return places.toList();
    } catch (e) {
      log('Error fetching places: $e');
    }

    return places;
  }

  Future<Place> updatePlace(Place newPlaceModel) async {
    DocumentReference<Map<String, dynamic>>? ref;
    if (newPlaceModel.docRef != null) {
      ref = newPlaceModel.docRef!;
    } else {
      final collection = _firestore.collection(_masterPlaceCollection);
      final querySnapshot = await collection
          .where('kakaoPlaceId', isEqualTo: newPlaceModel.kakaoPlaceId)
          .limit(1)
          .get();
      if (querySnapshot.docs.isEmpty) {
        throw FetchException(msg: "업데이트할 장소를 찾지 못했습니다.");
      }
      final docSnapshot = querySnapshot.docs.first;
      ref = docSnapshot.reference;
    }

    ref.set(newPlaceModel.toJson());
    final docSnapshot = await ref.get();
    if (docSnapshot.data() == null) {
      throw FetchException(msg: "업데이트 중 오류가 발생했습니다.");
    }
    return Place.fromJson({...docSnapshot.data()!, "docRef": ref});
  }

  Future<void> deleteAllMyPlace(String uid) async {
    final collection = _firestore.collection(_myPlaceCollection);
    final snaps = await collection.where("uid", isEqualTo: uid).get();
    final List<Future<void>> tasks = [];
    for (var snap in snaps.docs) {
      tasks.add(_deleteReference(snap.reference));
    }
    Future.wait(tasks);
  }

  Future<void> _deleteReference(DocumentReference ref) async {
    return await ref.delete();
  }

  Future<MyPlace> postMyPlace(
      BuildContext context, MyPlaceRepo myPlaceRepo) async {
    final collection = _firestore.collection(_myPlaceCollection);

    final docRef = await collection.add({
      ...myPlaceRepo.toJson(),
      'createdAt':
          FieldValue.serverTimestamp(), // Adds a timestamp from the server
    });
    final snapshot = await docRef.get();
    if (!snapshot.exists || snapshot.data() == null) {
      throw FetchException(msg: "저장한 장소를 불러오는데 실패하였습니다.");
    }
    if (myPlaceRepo.files != null) {
      final List<UploadTask> uploadTasks = [];
      for (final file in myPlaceRepo.files!) {
        final task = uploadFileToStorage(
            file: file,
            fileStorageType: FileStorageType.placePhotos,
            folderId: snapshot.reference.id,
            fileType: CustomFileType.image);
        uploadTasks.add(task);
      }
      // UploadTask를 Future로 변환하여 모든 업로드가 완료되길 기다림
      final List<Future<TaskSnapshot>> futures = uploadTasks
          .map((task) => task.whenComplete(() => task.snapshot))
          .toList();

      await Future.wait(futures);
    }

    final mp =
        MyPlace.fromJson({...snapshot.data()!, "docRef": snapshot.reference});
    if (context.mounted) await mp.getPlace(context);

    return mp;
  }

  Future<List<MyPlace>> fetchMyPlace(BuildContext context, String uid) async {
    final collection = _firestore.collection(_myPlaceCollection);

    final querySnapshot = await collection.where('uid', isEqualTo: uid).get();

    final mps = querySnapshot.docs
        .map(
            (doc) => MyPlace.fromJson({...doc.data(), "docRef": doc.reference}))
        .toList();

    if (!context.mounted) return mps;

    final List<Future> tasks = [];
    for (var element in mps) {
      tasks.add(element.getPlace(context));
    }
    await Future.wait(tasks);
    return mps;
  }

  Future<List<MyPlace>> getPublicPlaceList(BuildContext context,
      {double? lat, double? long, double? radiusInKm = 10}) async {
    radiusInKm ??= 10;
    // var bounds = GeoUtils.calculateBoundingBox(lat, long, radiusInKm);

    var query = _firestore.collection(_myPlaceCollection);
    // .where('geo.geopoint.latitude',
    //     isGreaterThanOrEqualTo: bounds['minLat'])
    // .where('geo.geopoint.latitude', isLessThanOrEqualTo: bounds['maxLat'])
    // .where('geo.geopoint.longitude',
    //     isGreaterThanOrEqualTo: bounds['minLon'])
    // .where('geo.geopoint.longitude', isLessThanOrEqualTo: bounds['maxLon']);

    var querySnapshot = await query.get();

    List<MyPlace> places = [];
    for (var doc in querySnapshot.docs) {
      var data = doc.data();
      var myPlace = MyPlace.fromJson({...data, 'docRef': doc.reference});

      if (!context.mounted) continue;
      await myPlace.getPlace(context);

      if (lat == null || long == null) {
        places.add(myPlace);
        continue;
      }

      if (myPlace.geo == null) continue;
      var xlat = myPlace.geo!.latitude;
      var xlon = myPlace.geo!.longitude;
      double distance = GeoUtils.calculateDistance(xlat, xlon, lat, long);

      if (distance <= radiusInKm) {
        places.add(myPlace);
      }
    }

    return places;
  }

  Future<Place> fetchPlaceByRef(
      DocumentReference<Map<String, dynamic>> ref) async {
    final snapshot = await ref.get();
    if (!snapshot.exists || snapshot.data() == null) {
      throw FetchException(msg: "저장한 장소를 불러오는데 실패하였습니다.");
    }
    return Place.fromJson({...snapshot.data()!, "docRef": ref});
  }

  Future<void> postSavedLocation(SavedLocationModel model) async {
    try {
      await _firestore.collection(_saveLocationCollection).doc(model.id).set({
        ...model.toJson(),
        'timestamp':
            FieldValue.serverTimestamp(), // Adds a timestamp from the server
      });
    } catch (e) {
      log(e.toString());
    }
  }

  Future<List<SavedLocationModel>> getSavedLocationsByUid(String uid) async {
    List<SavedLocationModel> locations = [];
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_saveLocationCollection)
          .where('uid', isEqualTo: uid)
          .get();

      for (var doc in querySnapshot.docs) {
        locations.add(
            SavedLocationModel.fromJson(doc.data() as Map<String, dynamic>));
      }
    } catch (e) {
      log("Error fetching locations: $e");
    }
    return locations;
  }

  UploadTask uploadFileToStorage(
      {required FileStorageType fileStorageType,
      required String folderId,
      required File file,
      required CustomFileType fileType}) {
    // Firebase Storage에 이미지 업로드
    String fileName =
        "${DateTime.now()}_${file.path.split("/").last}"; // 예: DateTime.now().toString()
    return FirebaseStorage.instance
        .ref('${fileStorageType.name}/$folderId/$fileName')
        .putFile(file,
            SettableMetadata(customMetadata: {"file_type": fileType.name}));
  }

  Future<List<FirebaseStorageModel>> getAllFilesUnderFolder(
      {required FileStorageType fileStorageType,
      required String folderId}) async {
    List<FirebaseStorageModel> models = [];

    try {
      final ListResult result = await FirebaseStorage.instance
          .ref('${fileStorageType.name}/$folderId/')
          .listAll();

      // 각 항목(파일)에 대한 참조를 얻은 후, URL을 가져옵니다.
      for (var ref in result.items) {
        String imageUrl = await ref.getDownloadURL();
        final meta = await ref.getMetadata();
        models.add(
            FirebaseStorageModel(downloadLink: imageUrl, ref: ref, meta: meta));
      }
    } catch (e) {
      log(e.toString());
    }

    return models;
  }

  Future<PlaceZip?> fetchSharedPlaceZip({required String id}) async {
    final collection = _firestore.collection(_sharedPlaceZip);
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await collection.where("id", isEqualTo: id).get();
    if (snapshot.docs.isEmpty) return null;
    final docSnap = snapshot.docs.first;
    return PlaceZip.fromJson(docSnap.data());
  }

  Future<List<PlaceZip>> fetchMySharedPlaceZip({required String uid}) async {
    final collection = _firestore.collection(_sharedPlaceZip);
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await collection.where("uid", isEqualTo: uid).get();
    final docSnap = snapshot.docs;
    return docSnap.map((e) => PlaceZip.fromJson(e.data())).toList();
  }

  Future<PlaceZip> postShareZip(
      {required List<MyPlace> myPlaces,
      required AppUser user,
      required String title,
      required String? description}) async {
    final collection = _firestore.collection(_sharedPlaceZip);

    final List<String> categories = [];
    final f = categories.addAll;
    fc(MyPlace place) {
      f(place.categories ?? []);
    }

    myPlaces.forEach(fc);

    final placeZip = PlaceZip(
      uid: user.uid,
      id: collection.doc().id,
      creatorName: user.name,
      creatorProfileUrl: user.profileImageUrl,
      title: title,
      description: description,
      categories: categories,
      createdAt: DateTime.now(),
      likeCnt: 0,
      sharedCnt: 0,
      places: myPlaces,
    );

    // Convert the PlaceZip object to JSON
    await collection
        .doc(placeZip.id)
        .set({...placeZip.toJson(), 'createdAt': FieldValue.serverTimestamp()});
    return placeZip;
  }
}

enum FileStorageType { placePhotos }
