import 'dart:developer';
import 'dart:io';

import 'package:bp/model/firestore_models/saved_location.dart';
import 'package:bp/service/firestore/firestore_service.dart';
import 'package:bp/service/google_map_api_service.dart';
import 'package:bp/utility/get_coordinate_from_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../model/image_info.dart';
import '../../../service/local_database_service.dart';

class PickedImageModel {
  final String path;
  final PickedImageInfo? info;

  PickedImageModel({required this.path, required this.info});
}

class ImageGPSView extends StatefulWidget {
  const ImageGPSView({super.key});

  @override
  State<ImageGPSView> createState() => _ImageGPSViewState();
}

class _ImageGPSViewState extends State<ImageGPSView> {
  bool isPicking = false;
  final ImagePicker _picker = ImagePicker();
  final List<PickedImageModel> list = [];
  final List<int> doneList = [];
  final List<int> failedList = [];
  bool isUploading = false;
  bool shouldShowResult = false;

  Future<void> _pickImage() async {
    if (isPicking) return;
    isPicking = true;
    try {
      final pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        for (final pickedFile in pickedFiles) {
          final imageInfo = await getCoordinateFromImage(pickedFile.path);
          list.add(PickedImageModel(info: imageInfo, path: pickedFile.path));
        }
      }
    } catch (e) {
      log(e.toString());
      // Handle exceptions or show an error message
    } finally {
      setState(() {
        isPicking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (list.isNotEmpty && !shouldShowResult)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () async => await _pickImage(),
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Pick More'),
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  itemBuilder: ((context, index) {
                    final im = list[index];
                    return ListTile(
                      leading: Image.file(File(im.path)),
                      title: Text(
                        im.info?.name ?? "No name",
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "lat: ${im.info?.lat?.toString() ?? ""}",
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "long: ${im.info?.long?.toString() ?? ""}",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      trailing: getTrailingWidget(index),
                    );
                  }),
                  separatorBuilder: (context, index) {
                    return const Divider();
                  },
                  itemCount: list.length,
                ),
              ),
              const SizedBox(
                height: 70,
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: 24, vertical: list.isEmpty ? 100 : 0),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            label: Text(
              getButtonMsg(),
              textAlign: TextAlign.center,
            ),
            onPressed: shouldShowResult
                ? null
                : () async =>
                    list.isEmpty ? await _pickImage() : uploadLocations(),
            icon: Icon(list.isEmpty ? Icons.add_a_photo : Icons.cloud_upload),
          ),
        ),
      ),
    );
  }

  Future<void> uploadLocations() async {
    if (isUploading) return;
    final fs = FirestoreService();
    setState(() {
      isUploading = true;
    });

    for (int i = 0; i < list.length; i++) {
      try {
        final model = list[i];
        if (model.info == null) throw Exception();
        if (!model.info!.hasCoordinate()) throw Exception();
        final res = await GoogleMapAPIService.getAddressFromCoordinate(
            model.info!.lat!, model.info!.long!);
        if (res == null) throw Exception();
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) throw Exception("No user");
        final savedLocationModel = SavedLocationModel(
          id: const Uuid().v4(),
          uid: uid,
          latitude: model.info!.lat!,
          longitude: model.info!.long!,
          method: "image",
          placeId: res["placeId"]!,
          address: res["address"]!,
          visitedAt: model.info!.datetime!,
        );
        await LocalDatabaseService.instance
            .insertSavedLocation(savedLocationModel);
        await fs.postSavedLocation(savedLocationModel);
        if (!mounted) {
          return;
        }
        setState(() {
          doneList.add(i);
        });
      } catch (_) {
        setState(() {
          failedList.add(i);
        });
      }
    }
    setState(() {
      isUploading = false;
      shouldShowResult = true;
    });
  }

  String getButtonMsg() {
    if (list.isEmpty) return "Pick Image";
    if (isUploading) return "Submitting...";
    return "Submit";
  }

  Widget getTrailingWidget(int index) {
    if (isUploading || shouldShowResult) {
      if (doneList.contains(index)) {
        return const Icon(Icons.done);
      }
      if (failedList.contains(index)) {
        return const Icon(Icons.error_outline);
      }
      return const CircularProgressIndicator();
    }

    return IconButton(
      icon: const Icon(Icons.remove),
      onPressed: () {
        setState(() {
          list.removeAt(index);
        });
      },
    );
  }
}
