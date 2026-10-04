import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'dart:async';

import 'theme/app_colors.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/home/travel_welcome_screen.dart';
import 'screens/auth/login_modal_sheet.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tour & Travel App',
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      home: const AppRoot(),
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _showSplash = true;
  bool _hasShownGuestModal = false;
  StreamSubscription<User?>? _authSub;
  Map<String, String> _userProfileData = {};
  Map<String, String> _personalInfoData = {};
  List<String> _userInterests = [];

  @override
  void initState() {
    super.initState();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _loadUserData(user.uid);
      } else {
        if (mounted) {
          setState(() {
            _userProfileData = {};
            _personalInfoData = {};
            _userInterests = [];
            _hasShownGuestModal = false;
          });
          _maybeShowGuestModal();
        }
      }
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showSplash = false);
        _maybeShowGuestModal();
      }
    });
  }

  void _maybeShowGuestModal() {
    if (_showSplash) return;
    if (_hasShownGuestModal) return;
    if (FirebaseAuth.instance.currentUser != null) return;
    if (!mounted) return;
    _hasShownGuestModal = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => LoginModalSheet(onAuthSuccess: _handleAuthSuccess),
      );
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          _userProfileData = {
            'born': data['born'] ?? '',
            'destination': data['destination'] ?? '',
            'work': data['work'] ?? '',
            'pets': data['pets'] ?? '',
            'skill': data['skill'] ?? '',
            'funFact': data['funFact'] ?? '',
            'song': data['song'] ?? '',
            'languages': data['languages'] ?? '',
            'love': data['love'] ?? '',
            'live': data['live'] ?? '',
            'about': data['about'] ?? '',
          };
          _personalInfoData = {
            'legalName': '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim(),
            'email': data['email'] ?? '',
            'phone': data['phone'] ?? '',
          };
          _userInterests = List<String>.from(data['interests'] ?? []);
        });
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
    }
  }

  void _onUpdateProfile(Map<String, String> data, List<String> interests) {
    setState(() {
      _userProfileData = data;
      _userInterests = interests;
    });
  }

  void _onPersonalDataUpdated(Map<String, String> data) {
    setState(() {
      _personalInfoData = data;
    });
  }

  void _handleAuthSuccess(String? name, String? email, String? phone) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _loadUserData(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final isLoggedIn = snapshot.hasData;

        if (_showSplash) {
          return const TravelWelcomeScreen();
        }

        return MainNavigationScreen(
          isLoggedIn: isLoggedIn,
          userProfileData: _userProfileData,
          personalInfoData: _personalInfoData,
          userInterests: _userInterests,
          onUpdateProfile: _onUpdateProfile,
          onPersonalDataUpdated: _onPersonalDataUpdated,
          onAuthSuccess: _handleAuthSuccess,
        );
      },
    );
  }
}