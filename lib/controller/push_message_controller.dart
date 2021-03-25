import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class PushMessageController{
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  void settingPush(String title, String body){
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async { // 앱을 사용중
        print("onMessage: $message");
        // Get.snackbar(title, body);
      },
      onLaunch: (Map<String, dynamic> message) async { // 앱이 꺼져있을 때
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async { // 앱이 백그라운드
        print("onResume: $message");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      print("token: $token");
    });
  }

  void pushMessage(String title, String body, String token) async{
    var serverToken = 'AAAAZ81_9pE:APA91bG7Ny_dRvOgHBWQfewAUl1t1CbL7QL6cu-oxjoCvzZTyrjo-tJ7MiKPCSqat7SZSwtjMe5iLX6eJ2v-71BBH0vshqfg4BB2G4vcWL7uEtYJWbO0Heej7n1i76uCR_Hiqg-U38g8';

    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': body,
            'title': title,
            'tag': '1',
            'color': '#FF97B3',
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          'to': token,
          // 'to': await firebaseMessaging.getToken(),
        },
      ),
    );
    settingPush(title, body);

    // _firebaseMessaging.configure(
    //   onMessage: (Map<String, dynamic> message) async { // 앱을 사용중
    //     print("onMessage: $message");
    //   },
    //   onLaunch: (Map<String, dynamic> message) async { // 앱이 꺼져있을 때
    //     print("onLaunch: $message");
    //   },
    //   onResume: (Map<String, dynamic> message) async { // 앱이 백그라운드
    //     print("onResume: $message");
    //   },
    // );

    // final Completer<Map<String, dynamic>> completer =
    // Completer<Map<String, dynamic>>();
    //
    // _firebaseMessaging.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     completer.complete(message);
    //   },
    // );

  }


}