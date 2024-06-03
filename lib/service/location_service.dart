import 'package:geolocator/geolocator.dart';

class LocationServiceException implements Exception {
  final String message;
  LocationServiceException(this.message);
}

class LocationService {
  // requires to handle LocationServiceException

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스 활성화 여부 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 위치 서비스가 비활성화되어 있다면, 사용자에게 활성화 요청
      throw LocationServiceException('위치 서비스가 비활성화되어 있습니다. 활성화해주세요.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // 권한이 거부되었다면, 권한 요청
        throw LocationServiceException('위치 권한이 거부되었습니다. 권한을 허용해주세요.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // 권한이 영구적으로 거부되었다면, 설정으로 유도
      throw LocationServiceException('위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.');
    }

    return await Geolocator.getCurrentPosition();
  }
}
