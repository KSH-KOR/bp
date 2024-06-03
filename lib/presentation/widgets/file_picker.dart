import 'dart:developer';
import 'dart:io';

import 'package:bp/model/firestore_models/storage_model.dart';
import 'package:bp/presentation/widgets/space.dart';
import 'package:bp/presentation/styles/color_manager.dart';
import 'package:bp/presentation/styles/text_style_manager.dart';
import 'package:bp/provider/file_pick_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

enum FileDisplayMode { pickedLocalFile, cloudFile }

class FilePickerWidget extends StatefulWidget {
  const FilePickerWidget({
    super.key,
    required this.isViewMode,
    required this.type,
    required this.displayMode,
    this.cloudFileList,
  });

  final bool isViewMode;
  final FileDisplayMode displayMode;
  final CustomFileType type;
  final List<FirebaseStorageModel>? cloudFileList;

  @override
  State<FilePickerWidget> createState() => _FilePickerWidgetState();
}

class _FilePickerWidgetState extends State<FilePickerWidget> {
  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case CustomFileType.image:
        return GridLayoutForFilePicker(
          isViewMode: widget.isViewMode,
          displayMode: widget.displayMode,
          type: widget.type,
          cloudFileList: widget.cloudFileList,
        );
      case CustomFileType.video:
      case CustomFileType.audio:
        return ListLayoutForFilePicker(
          isViewMode: widget.isViewMode,
          displayMode: widget.displayMode,
          type: widget.type,
          cloudFileList: widget.cloudFileList,
        );
      case CustomFileType.undefined:
        return Container();
      case CustomFileType.document:
        return ListLayoutForFilePicker(
          isViewMode: widget.isViewMode,
          displayMode: widget.displayMode,
          type: widget.type,
          cloudFileList: widget.cloudFileList,
        );
    }
  }
}

class ListLayoutForFilePicker extends StatelessWidget {
  const ListLayoutForFilePicker(
      {super.key,
      required this.type,
      required this.isViewMode,
      required this.displayMode,
      this.cloudFileList});

  final CustomFileType type;
  final bool isViewMode;
  final FileDisplayMode displayMode;
  final List<FirebaseStorageModel>? cloudFileList;

  @override
  Widget build(BuildContext context) {
    late final Iterable<DisplayFile> files;

    switch (displayMode) {
      case FileDisplayMode.pickedLocalFile:
        final pickedFiles =
            Provider.of<FilePickProvider>(context).getPickedFilesByType(type);
        files = pickedFiles.map((e) => DisplayFile.fromPickedFile(e));
      case FileDisplayMode.cloudFile:
        if (cloudFileList == null) {
          files = [];
        } else {
          files = cloudFileList!.map((e) => DisplayFile.fromCloudMediaFile(e));
        }
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final double screenHeightRatio = screenHeight / 793;

    final int columnCount = isViewMode ? files.length : files.length + 1;
    final double height = 71 * columnCount * screenHeightRatio;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: isViewMode ? files.length : files.length + 1,
        itemBuilder: (context, index) {
          if (index == files.length) {
            return SelectedButtonCardForListTile(type: type);
          }
          return DisplayCardForListTile(
            isViewMode: isViewMode,
            onDelete: () =>
                Provider.of<FilePickProvider>(context, listen: false)
                    .removeById(files.elementAt(index).id),
            file: files.elementAt(index),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const AddVerticalSpace(8);
        },
      ),
    );
  }

  void handleDeleteFile() {}

  void handleAddFile() async {}
}

class DisplayFile {
  final String id;
  final CustomFileType type;
  final bool isCloudFile;
  final String? pathOrUrl;
  final int size;
  final String name;

  factory DisplayFile.fromPickedFile(PickedFile file) {
    return DisplayFile(
        type: file.type,
        isCloudFile: false,
        pathOrUrl: file.path,
        size: file.size,
        name: file.name,
        id: file.id);
  }
  factory DisplayFile.fromCloudMediaFile(FirebaseStorageModel file) {
    return DisplayFile(
        type: stringToCustomFileType(file.meta?.customMetadata?["file_type"]),
        isCloudFile: true,
        pathOrUrl: file.downloadLink,
        size: file.meta?.size ?? 0,
        name: file.meta?.name ?? "",
        id: file.ref.fullPath);
  }

  DisplayFile(
      {required this.type,
      required this.id,
      required this.isCloudFile,
      required this.pathOrUrl,
      required this.size,
      required this.name});
}

class GridLayoutForFilePicker extends StatelessWidget {
  const GridLayoutForFilePicker(
      {super.key,
      required this.type,
      required this.isViewMode,
      required this.displayMode,
      this.cloudFileList});

  final CustomFileType type;
  final bool isViewMode;
  final FileDisplayMode displayMode;
  final List<FirebaseStorageModel>? cloudFileList;

  @override
  Widget build(BuildContext context) {
    late final Iterable<DisplayFile> files;
    switch (displayMode) {
      case FileDisplayMode.pickedLocalFile:
        final pickedFiles =
            Provider.of<FilePickProvider>(context).getPickedFilesByType(type);
        files = pickedFiles.map((e) => DisplayFile.fromPickedFile(e));
      case FileDisplayMode.cloudFile:
        if (cloudFileList == null) {
          files = [];
        } else {
          files = cloudFileList!.map((e) => DisplayFile.fromCloudMediaFile(e));
        }
    }
    final int columnCount = ((files.length + 1) / 3).ceil();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double screenWidthRatio = screenWidth / 390;
    final double screenHeightRatio = screenHeight / 793;

    final double height = 110.0 * columnCount * screenHeightRatio;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8 * screenHeightRatio,
          mainAxisSpacing: 8 * screenWidthRatio,
        ),
        itemCount: isViewMode ? files.length : files.length + 1,
        itemBuilder: (context, index) {
          if (index == files.length) {
            return SelectedButtonCardForGridTile(
              type: type,
            );
          } else {
            // 이미지 표시
            return DisplayCardForGridTile(
              isViewMode: isViewMode,
              onDelete: () =>
                  Provider.of<FilePickProvider>(context, listen: false)
                      .removeById(files.elementAt(index).id),
              file: files.elementAt(index),
            );
          }
        },
      ),
    );
  }
}

class SelectedButtonCardForGridTile extends StatelessWidget {
  const SelectedButtonCardForGridTile({super.key, required this.type});

  final CustomFileType type;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Provider.of<FilePickProvider>(context, listen: false)
          .pickFile(type: type),
      child: Container(
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorManager.primary, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.add,
              color: ColorManager.primary,
              size: 32,
            ),
            Text(
              "파일 추가",
              style:
                  TextStyleManager.body5.copyWith(color: ColorManager.primary),
            )
          ],
        ),
      ),
    );
  }
}

class SelectedButtonCardForListTile extends StatelessWidget {
  const SelectedButtonCardForListTile({super.key, required this.type});

  final CustomFileType type;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final double screenHeightRatio = screenHeight / 793;
    return InkWell(
      onTap: () => Provider.of<FilePickProvider>(context, listen: false)
          .pickFile(type: type),
      child: Container(
        height: 44 * screenHeightRatio,
        width: double.infinity,
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: ColorManager.primary,
            width: 1.0,
          ),
        ),
        child: Center(
          child: Text(
            "파일 추가",
            style: TextStyleManager.body6.copyWith(color: ColorManager.primary),
          ),
        ),
      ),
    );
  }
}

class DisplayCardForListTile extends StatelessWidget {
  const DisplayCardForListTile({
    super.key,
    required this.file,
    required this.isViewMode,
    required this.onDelete,
  });

  final DisplayFile file;
  final bool isViewMode;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final double screenHeightRatio = screenHeight / 793;
    return Container(
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorManager.grey04),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: FileTypeToIcon(file: file),
            ),
            const AddHorizontalSpace(12),
            Expanded(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    style: TextStyleManager.body6,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AddVerticalSpace(4 * screenHeightRatio),
                  Text(
                    _formatFileSize(file.size),
                    style: TextStyleManager.body3.copyWith(
                      color: ColorManager.grey09,
                    ),
                  ),
                ],
              ),
            ),
            if (!isViewMode)
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 20 * screenHeightRatio,
                  height: 20 * screenHeightRatio,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatFileSize(int? bytes) {
    if (bytes == null) return '';
    double fileSizeMB = bytes / (1024 * 1024);
    return '${fileSizeMB.toStringAsFixed(2)} MB';
  }
}

class DisplayCardForGridTile extends StatelessWidget {
  final DisplayFile file;
  final VoidCallback onDelete;
  final bool isViewMode;

  const DisplayCardForGridTile({
    super.key,
    required this.file,
    required this.isViewMode,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double screenWidthRatio = screenWidth / 390;
    final double screenHeightRatio = screenHeight / 793;
    return Stack(
      children: [
        Container(
          width: 111 * screenWidthRatio,
          height: 111 * screenHeightRatio,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.transparent),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 80,
              height: 80,
              child: FileTypeToIcon(
                file: file,
              ),
            ),
          ),
        ),
        if (!isViewMode)
          Positioned(
            top: 8 * screenHeightRatio,
            right: 8 * screenWidthRatio,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 20 * screenWidthRatio,
                height: 20 * screenHeightRatio,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class FileTypeToIcon extends StatelessWidget {
  const FileTypeToIcon({super.key, required this.file});

  final DisplayFile file;

  @override
  Widget build(BuildContext context) {
    Widget child;
    switch (file.type) {
      case CustomFileType.image:
        child = _buildImageChild();
      case CustomFileType.audio:
        child = const Icon(Icons.audio_file);
      case CustomFileType.video:
        child = const Icon(Icons.video_file);
      case CustomFileType.document:
        child = const Icon(Icons.description);
      case CustomFileType.undefined:
        child = const Icon(Icons.question_mark);
    }
    return child;
  }

  Widget _buildImageChild() {
    Widget? child;
    try {
      if (file.pathOrUrl == null) throw Exception("path or url is null");
      if (file.isCloudFile) {
        child = Image.network(
          file.pathOrUrl!,
          fit: BoxFit.cover,
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) return child; // 이미지 로딩 완료시 이미지 표시
            // 로딩 중 Shimmer 효과 적용
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!, // Shimmer 효과의 기본 색상
              highlightColor: Colors.grey[100]!, // Shimmer 효과의 하이라이트 색상
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
              ),
            );
          },
        );
      } else {
        child = Image.file(File(file.pathOrUrl!), fit: BoxFit.cover);
      }
    } catch (e) {
      log(e.toString());
    }
    return child ?? const Icon(Icons.error);
  }
}
