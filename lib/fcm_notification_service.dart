import 'dart:async';
import 'dart:convert' show json;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

abstract class IFCMNotificationService {
  Future<void> sendNotificationToUser({
    required String fcmToken,
    required String title,
    required String body,
  });
  Future<void> sendNotificationToGroup({
    required String group,
    required String title,
    required String body,
  });
  Future<void> unsubscribeFromTopic({
    required String topic,
  });
  Future<void> subscribeToTopic({
    required String topic,
  });
}

class FCMNotificationService extends IFCMNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final String _endpoint = 'https://fcm.googleapis.com/fcm/send';
  final String _contentType = 'application/json';
  final String _authorization =
      'key=AAAAK-9tvqM:APA91bFSuuKsJVoTuNC19D_Tg1QkmW2Cfbfop879_daYGyvQYOa3zWBP2qcQwRfUPf5UVsJ01-xc6ZTfnz5cBjrkRQRRUPRshiflERqjCdU5byGIoHma8XrVuO2HPEE4FHCWUyTW5D9X';

  Future<http.Response> _sendNotification(
    String to,
    String title,
    String body,
  ) async {
    try {
      final dynamic data = json.encode(
        {
          'to': to,
          'priority': 'high',
          'notification': {
            'title': title,
            'body': body,
          },
          'content_available': true
        },
      );
      http.Response response = await http.post(
        Uri.parse(_endpoint),
        body: data,
        headers: {'Content-Type': _contentType, 'Authorization': _authorization},
      );

      return response;
    } catch (error) {
      throw Exception(error);
    }
  }

  @override
  Future<void> unsubscribeFromTopic({required String topic}) {
    return _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  @override
  Future<void> subscribeToTopic({required String topic}) {
    return _firebaseMessaging.subscribeToTopic(topic);
  }

  @override
  Future<void> sendNotificationToUser({
    required String fcmToken,
    required String title,
    required String body,
  }) {
    return _sendNotification(
      fcmToken,
      title,
      body,
    );
  }

  @override
  Future<void> sendNotificationToGroup(
      {required String group, required String title, required String body}) {
    return _sendNotification('/topics/' + group, title, body);
  }
}
