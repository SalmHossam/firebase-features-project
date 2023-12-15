import 'package:faculty_lab1/MyHomePage.dart';
import 'package:faculty_lab1/Screen1.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

FirebaseDatabase database = FirebaseDatabase.instance;
final firebaseApp = Firebase.app();
final rtdb = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://cloudlab1-7f832-default-rtdb.firebaseio.com/');
final storage = FirebaseStorage.instance;
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call initializeApp before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.setAutoInitEnabled(true);

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  }else {
    print('User declined or has not accepted permission');
  }

  String? token = await messaging.getToken();


  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    String title = message.notification?.title ?? "";
    String body = message.notification?.body ?? "";
    print("Message opened app: $title");
    print("Body: $body");
    storeNotification(title, body);
  });
  runApp(MyApp());
}
void storeNotification(String title, String body) {
  try {
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
    DatabaseReference notificationsReference = databaseReference.child('notifications');

    notificationsReference.push().set({
      'title': title,
      'body': body,
      'timestamp': ServerValue.timestamp,
    });
    print("Notification stored successfully");
  } catch (error) {
    print("Error storing notification: $error");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: MyHomePage.routeName,
      routes: {
        MyHomePage.routeName:(context)=>MyHomePage(),
        Screen1.routeName:(context)=>Screen1(userName: '',),
      },
    );
  }
}
