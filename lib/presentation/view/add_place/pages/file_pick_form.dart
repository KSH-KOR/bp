import 'package:bp/presentation/widgets/file_picker.dart';
import 'package:bp/provider/file_pick_provider.dart';
import 'package:flutter/material.dart';

class FilePickForm extends StatelessWidget {
  const FilePickForm({super.key});

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          FilePickerWidget(
              isViewMode: false,
              type: CustomFileType.image,
              displayMode: FileDisplayMode.pickedLocalFile),
        ],
      ),
    );
  }
}
