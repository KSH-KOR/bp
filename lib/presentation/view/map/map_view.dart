import 'package:bp/model/place/my_place.dart';
import 'package:bp/presentation/widgets/bottom_sheet/my_place_bottom_sheet.dart';
import 'package:bp/provider/place_provider.dart';
import 'package:bp/service/kakao_service.dart';
import 'package:bp/service/location_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:provider/provider.dart';

class PlacesOnMapView extends StatefulWidget {
  const PlacesOnMapView({super.key});

  @override
  State<PlacesOnMapView> createState() => _PlacesOnMapViewState();
}

class _PlacesOnMapViewState extends State<PlacesOnMapView> {
  KakaoMapController? mapController;
  late final TextEditingController _latitudeController, _longitudeController;

  // firestore init
  GeoFlutterFire geo = GeoFlutterFire();
  Stream<Iterable<MyPlace>>? stream;

  Set<Marker> markers = {};

  bool didFetch = false;
  Position? currLocation;

  @override
  void initState() {
    super.initState();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      try {
        await Provider.of<PlaceProvider>(context, listen: false)
            .fetchPublicPlacesList(context: context);
        if (!mounted) return;
        Provider.of<PlaceProvider>(context, listen: false)
            .publicPlaces
            ?.forEach(_updateMarkers);
        currLocation = await LocationService().getCurrentLocation();
        if (currLocation == null) throw FetchException(msg: "위치정보가 필요합니다.");
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
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!didFetch) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: KakaoMap(
            onMapCreated: _onMapCreated,
            center: LatLng(currLocation!.latitude, currLocation!.longitude),
            markers: markers.toList(),
            onMarkerTap: (markerId, latLng, zoomLevel) {
              final myPlace = Provider.of<PlaceProvider>(context, listen: false)
                  .publicPlaces
                  ?.where(
                    (element) => element.docRef?.id == markerId,
                  );
              if (myPlace?.isNotEmpty != true) return;

              showBottomSheet(
                context: context,
                enableDrag: false,
                builder: (BuildContext context) {
                  return MyPlaceBottomSheet(
                    myPlace: myPlace!.first,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _onMapCreated(KakaoMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  void _updateMarkers(MyPlace myPlace) {
    final GeoPoint? point = myPlace.geo?.geoPoint;
    if (point == null || myPlace.docRef == null) return;
    final info = myPlace.place?.placeName;
    final marker = Marker(
      markerId: myPlace.docRef!.id,
      latLng: LatLng(point.latitude, point.longitude),
      infoWindowContent: info ?? '',
      infoWindowFirstShow: info != null,
    );
    markers.add(marker);
  }
}
