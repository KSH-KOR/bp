import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> sharePlaceZip({
    required String shareName,
    required String link,
  }) async {
    String sharedText = """
$shareName 님께서 발품을 통해 당신에게 공간 리스트를 공유합니다.

발품이란 무엇일까요? 
발품은 여러분이 다녀온 다양한 장소를 쉽게 저장하고, 친구나 가족과 공유할 수 있는 혁신적인 공간 공유 플랫폼입니다.

[$shareName 님께서 공유한 공간 리스트 확인하러 바로가기]
$link""";

    await Share.share(
      sharedText,
      sharePositionOrigin: null,
    );
  }

  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }
}
