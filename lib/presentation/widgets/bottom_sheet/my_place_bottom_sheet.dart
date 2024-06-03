import 'package:bp/model/place/my_place.dart';
import 'package:bp/presentation/widgets/file_picker.dart';
import 'package:bp/presentation/styles/text_style_manager.dart';
import 'package:bp/provider/file_pick_provider.dart';
import 'package:bp/provider/place_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MyPlaceBottomSheet extends StatefulWidget {
  const MyPlaceBottomSheet({
    super.key,
    required this.myPlace,
  });

  final MyPlace myPlace;

  @override
  State<MyPlaceBottomSheet> createState() => _MyPlaceBottomSheetState();
}

class _MyPlaceBottomSheetState extends State<MyPlaceBottomSheet> {
  bool didFetch = false;
  PlaceProvider? provider;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      try {
        provider = Provider.of<PlaceProvider>(context, listen: false);
        await widget.myPlace.getPlace(context);
        if (!mounted) return;
        await widget.myPlace.fetchPhotos(context);
      } finally {
        if (mounted) {
          setState(() {
            didFetch = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.lightBlue.shade100.withAlpha(0),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close),
                ),
              ),
              Text(
                widget.myPlace.place?.placeName ?? "로딩중",
                style: TextStyleManager.h3,
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                widget.myPlace.place?.placeAddress ?? "로딩중",
                style: TextStyleManager.body5,
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  const Icon(Icons.phone),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(widget.myPlace.place?.phoneNumber ?? "로딩중"),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Text(widget.myPlace.place?.categories.join(" > ") ?? "로딩중"),
              const SizedBox(
                height: 8,
              ),
              Text(widget.myPlace.place?.placeCategory ?? "로딩중"),
              const SizedBox(
                height: 8,
              ),
              const SizedBox(
                height: 8,
              ),
              if (widget.myPlace.place?.mapUrl != null)
                TextButton.icon(
                  icon: const Icon(Icons.map),
                  label: const Text("지도에서 확인하기"),
                  onPressed: () {
                    launchUrl(Uri.parse(widget.myPlace.place!.mapUrl));
                  },
                ),
              const SizedBox(
                height: 8,
              ),
              if (!didFetch)
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: LinearProgressIndicator(),
                ),
              FilePickerWidget(
                  isViewMode: true,
                  type: CustomFileType.image,
                  displayMode: FileDisplayMode.cloudFile,
                  cloudFileList: widget.myPlace.photos)
            ],
          ),
        ),
      ),
    );
  }
}
