import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Title :  ${message.notification?.title}');
  print('Body :  ${message.notification?.body}');
}

class FirebaseApi{
  final _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings(
      onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {
        // Handle notification tapped logic here
      },
    );
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
          // Handle notification tapped logic here
        });

    final fCMToken = await _firebaseMessaging.getToken();
    print('Token :  $fCMToken');
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    // Trigger a local notification as an example
    _showLocalNotification();
  }

  Future<void> _showLocalNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id', 'Flash Event',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      0,
      'Flash Event',
      'Bienvenue sur Flash Event',
      platformChannelSpecifics,
      payload: 'item x',
    );
  }
}