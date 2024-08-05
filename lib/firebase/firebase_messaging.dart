import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    final fCMToken = await _firebaseMessaging.getToken();

    print('Token: $fCMToken');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    });

    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();


  }
}
