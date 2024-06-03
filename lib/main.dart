import 'package:bp/constant/routes/routes.dart';
import 'package:bp/presentation/view/add_place/add_place.dart';
import 'package:bp/presentation/view/add_place/pages/summary.dart';
import 'package:bp/presentation/view/home/home.dart';
import 'package:bp/presentation/view/add_place_with_image/image_gps.dart';
import 'package:bp/presentation/view/profile/profile_view.dart';
import 'package:bp/presentation/view/share/share_my_places.dart';
import 'package:bp/presentation/view/share/share_view.dart';
import 'package:bp/provider/dynamic_link.dart';
import 'package:bp/provider/file_pick_provider.dart';
import 'package:bp/provider/form_provider.dart';
import 'package:bp/provider/place_provider.dart';
import 'package:bp/provider/screen_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'firebase_options.dart';

import 'package:provider/provider.dart';
import 'presentation/view/login.dart';
import 'provider/auth_provider.dart';
import 'provider/location_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
  AuthRepository.initialize(appKey: '06afd0d3764fc23f849eafef982da3da');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppAuthProvider>(
            create: (context) => AppAuthProvider()),
        ChangeNotifierProvider<ScreenProvider>(
            create: (context) => ScreenProvider()),
        ChangeNotifierProvider<LocationProvider>(
            create: (context) => LocationProvider()),
        ChangeNotifierProvider<PlaceProvider>(
            create: (context) => PlaceProvider()),
        ChangeNotifierProvider<FormProvider>(
            create: (context) => FormProvider()),
        ChangeNotifierProvider<FilePickProvider>(
            create: (context) => FilePickProvider()),
        ChangeNotifierProvider<DynamicLink>(create: (context) => DynamicLink()),
        ChangeNotifierProvider<ScreenProvider>(
            create: (context) => ScreenProvider()),
        StreamProvider(
          create: (context) => FirebaseAuth.instance.authStateChanges(),
          initialData: null,
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        initialRoute: initRoute,
        routes: {
          initRoute: (context) => const AuthenticationWrapper(),
          homeRoute: (context) => const HomeView(),
          loginRoute: (context) => const LoginView(),
          imageGPSRoute: (context) => const ImageGPSView(),
          profileRoute: (context) => const ProfileView(),
          formRoute: (context) => const FormPageView(),
          formSummaryRoute: (context) => const AddPlaceFormSummaryView(),
          sharedPlaceZip: (context) => const PlaceListInZipView(),
          shareMyPlacesRoute: (context) => const ShareMyPlaces(),
        },
      ),
    );
  }
}

class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({super.key});

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      Provider.of<AppAuthProvider>(context, listen: false)
          .syncAuthStateChanges();
    });
  }

  @override
  Widget build(BuildContext context) {
    context.read<DynamicLink>().setup(context);

    if (Provider.of<AppAuthProvider>(context).user != null) {
      return const HomeView(); // 로그인이 되어 있을 때의 화면
    }
    return const LoginView(); // 로그인이 되어 있지 않을 때의 화면
  }
}
