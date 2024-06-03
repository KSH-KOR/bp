// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:bp/constant/routes/routes.dart';
import 'package:bp/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:uni_links/uni_links.dart';

class DynamicLink extends ChangeNotifier {
  String? _id;

  String? get id => _id;

  set id(String? value) {
    _id = value;
    notifyListeners();
  }

  // 초기화
  Future<bool> setup(context) async {
    bool isExistDynamicLink = await _getInitialDynamicLink(context);
    _addListener(context);

    return isExistDynamicLink;
  }

  // 앱 종류 상태에서 딥링크를 받았을 때
  Future<bool> _getInitialDynamicLink(context) async {
    final PendingDynamicLinkData? initialLink =
        await FirebaseDynamicLinks.instance.getInitialLink();
    if (initialLink != null) {
      _setDynamicData(initialLink, context);
      return true;
    }

    final String? deepLink = await getInitialLink();
    if (deepLink != null && deepLink.isNotEmpty) {
      PendingDynamicLinkData? dynamicLinkData = await FirebaseDynamicLinks
          .instance
          .getDynamicLink(Uri.parse(deepLink));

      if (dynamicLinkData != null) {
        _setDynamicData(dynamicLinkData, context);

        return true;
      }
    }

    return false;
  }

  // 앱이 실행 중일 때 딥링크를 받았을 때
  void _addListener(context) {
    FirebaseDynamicLinks.instance.onLink.listen((
      PendingDynamicLinkData dynamicLinkData,
    ) {
      _setDynamicData(dynamicLinkData, context);
    }).onError((error) {
      log(error.toString());
    });
  }

  // 딥링크 데이터 설정
  void _setDynamicData(PendingDynamicLinkData dynamicLinkData, context) {
    log(dynamicLinkData.link.path);
    if (dynamicLinkData.link.queryParameters.containsKey('id')) {
      String? link = dynamicLinkData.link.path.split('/').last;
      _id = dynamicLinkData.link.queryParameters['id']!;

      notifyListeners();
      _redirectScreen(link, context);
    }
  }

  // 화면 이동
  Future<void> _redirectScreen(link, BuildContext context) async {
    debugPrint('setDynamicData: $_id');
    switch (link) {
      case 'shared-place-zip':
        final context = navigatorKey.currentState?.overlay?.context;
        if (context == null) return;
        Navigator.of(context).pushNamedAndRemoveUntil(
            sharedPlaceZip, (route) => route.settings.name == homeRoute,
            arguments: _id);
        break;
      default:
        Navigator.of(context)
            .pushNamedAndRemoveUntil(initRoute, (route) => false);
    }
  }

  // 동적 링크 생성
  Future<String> getShortLink(String screenName, String id) async {
    String dynamicLinkPrefix = 'https://balpum.page.link';

    final website = 'https://balpum-b18bd.web.app/$screenName/?id=$id';

    final dynamicLinkParams = DynamicLinkParameters(
      uriPrefix: dynamicLinkPrefix,
      link: Uri.parse('$dynamicLinkPrefix/$screenName?id=$id'),
      // 안드로이드 설정
      androidParameters: AndroidParameters(
        packageName: "com.balpum.bp",
        minimumVersion: 0,
        fallbackUrl: Uri.parse(website),
      ),
      // iOS 설정
      iosParameters: IOSParameters(
        bundleId: "com.balpum.bp",
        minimumVersion: '0',
        fallbackUrl: Uri.parse(website),
      ),

      /// 소셜 게시물에서의 동적 링크 미리보기 부분 설정
      socialMetaTagParameters: const SocialMetaTagParameters(
        title: '발품: 쉽게 저장하고 쉽게 공유하자',
        description: '발품에서 당신의 추억을 쉽게 저장하고 이웃과 공유해보세요.',
      ),
    );

    // build short link
    final dynamicLink =
        await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);

    return dynamicLink.shortUrl.toString();
  }
}
