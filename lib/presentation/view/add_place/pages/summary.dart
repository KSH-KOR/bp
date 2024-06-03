import 'dart:io';

import 'package:bp/model/kakao_map/place_detail.dart';
import 'package:bp/presentation/widgets/bottom_sheet/place_detail_bottom_sheet.dart';
import 'package:bp/presentation/widgets/file_picker.dart';
import 'package:bp/presentation/styles/text_style_manager.dart';
import 'package:bp/provider/auth_provider.dart';
import 'package:bp/provider/file_pick_provider.dart';
import 'package:bp/provider/form_provider.dart';
import 'package:bp/provider/place_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddPlaceFormSummaryView extends StatelessWidget {
  const AddPlaceFormSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    final list = Provider.of<FormProvider>(context)
        .repo
        .where(
            (element) => element.value is PlaceDetail || element.value is List)
        .toList();
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "이렇게 저장할까요?",
                style: TextStyleManager.h4,
              ),
              const SizedBox(
                height: 24,
              ),
              ListView.separated(
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        list[index].displayTitle,
                        style: TextStyleManager.body9,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      _summaryListTile(context, list[index]),
                    ],
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider();
                },
                itemCount: list.length,
              ),
              const Divider(),
              const Text(
                "장소 사진",
                style: TextStyleManager.body9,
              ),
              const SizedBox(
                height: 8,
              ),
              const FilePickerWidget(
                  isViewMode: true,
                  type: CustomFileType.image,
                  displayMode: FileDisplayMode.pickedLocalFile),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: double.infinity,
          child: FloatingActionButton.extended(
            onPressed: () async {
              try {
                final placeDetails = list
                    .where((element) => element.value is PlaceDetail)
                    .toList();
                if (placeDetails.isEmpty) throw Exception();
                final PlaceDetail detail = placeDetails.first.value;
                final uid = Provider.of<AppAuthProvider>(context, listen: false)
                    .user
                    ?.uid;
                if (uid == null) return;
                final files =
                    Provider.of<FilePickProvider>(context, listen: false)
                        .imageFiles
                        .map((e) => File(e.path))
                        .toList();

                await Provider.of<PlaceProvider>(context, listen: false)
                    .postMyPlace(
                        detail: detail,
                        uid: uid,
                        description: null,
                        files: files,
                        context: context);
                if (!context.mounted) return;
                Provider.of<FilePickProvider>(context, listen: false).reset();
                Provider.of<FormProvider>(context, listen: false).reset();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              } catch (_) {
              } finally {}
            },
            label: const Text("저장하기"),
          ),
        ),
      ),
    );
  }

  Widget _summaryListTile(BuildContext context, FormDataModel model) {
    if (model.value is List) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: model.value.length,
        itemBuilder: (BuildContext context, int index) {
          String? message;
          if (model.value[index] is String) {
            message = model.value[index];
          }
          return Align(
              alignment: Alignment.centerLeft,
              child: Chip(label: Text(message ?? "")));
        },
      );
    }
    if (model.value is PlaceDetail) {
      final PlaceDetail detail = model.value;
      return ListTile(
        title: Text(detail.placeName),
        subtitle: Text(detail.addressName),
        trailing: IconButton.filledTonal(
          onPressed: () {
            showBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return PlaceDetailBottomSheet(
                  placeDetail: detail,
                );
              },
            );
          },
          icon: const Icon(Icons.open_in_full),
        ),
      );
    }
    return Container();
  }
}
