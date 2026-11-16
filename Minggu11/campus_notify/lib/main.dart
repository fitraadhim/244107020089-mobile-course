import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'app/router.dart';
import 'features/notifications/presentation/providers/notification_providers.dart';
import 'messaging/push_service.dart';
import 'routes.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage _) async {
  // Background handlers run in a separate isolate; do not use BuildContext or Riverpod here.
  await Firebase.initializeApp();
}

void registerBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

void listenForeground(void Function(String route) onRoute) {
  FirebaseMessaging.onMessage.listen((message) async {
    await showForegroundNotification(message);
  });

  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    onRoute(routeFromMessage(message.data));
  });
}

Future<void> handleTerminated(void Function(String route) onRoute) async {
  final message = await FirebaseMessaging.instance.getInitialMessage();
  final route = message == null
      ? pendingDeepLink
      : routeFromMessage(message.data);
  pendingDeepLink = null;
  if (route != null && route.isNotEmpty) onRoute(route);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initializer wajib tidak boleh memblokir startup. Kegagalan Firebase/GMS
  // (mis. token tidak bisa diambil saat Play Services belum siap) sebelumnya
  // membuat aplikasi menggantung di splash screen.
  try {
    await Firebase.initializeApp();
    registerBackgroundHandler();
  } on Exception catch (error) {
    debugPrint('Firebase init failed: $error');
  }

  // 2. Minta izin & inisialisasi local notification
  try {
    await requestNotificationPermission();
    await initLocalNotifications();
  } on Exception catch (error) {
    debugPrint('Local notification init failed: $error');
  }

  // 3. Buat ProviderContainer agar state Riverpod bisa diisi sebelum UI muncul
  final container = ProviderContainer();
  final fcmTokenService = container.read(fcmTokenServiceProvider);

  // 4. Inisialisasi FCM token & lifecycle
  try {
    await initFcmToken(
      onToken: (token) async {
        await fcmTokenService.register(token);
      },
    );
  } on Exception catch (error) {
    debugPrint('FCM token init failed: $error');
  }

  // 5. Jalankan aplikasi menggunakan UncontrolledProviderScope
  runApp(
    UncontrolledProviderScope(container: container, child: const MainApp()),
  );
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  @override
  void initState() {
    super.initState();
    // [BARU - Praktikum 3] Jalankan listener penanganan klik notifikasi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final router = ref.read(routerProvider);

      setNotificationRouteHandler(router.go);
      listenForeground((route) => router.go(route));
      unawaited(handleTerminated((route) => router.go(route)));
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Campus Notify',
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
