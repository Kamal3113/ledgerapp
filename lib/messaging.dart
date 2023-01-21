import 'dart:convert';

import 'package:http/http.dart';
import 'package:meta/meta.dart';

class Messaging {
  static final Client client = Client();

  // from 'https://console.firebase.google.com'
  // --> project settings --> cloud messaging --> "Server key"
  static const String serverKey =
  'AAAAGLim9Bs:APA91bF45cyVVGEmCYsfOUTLc9KX3cq9IO_L6Ci243i3QO1yeNyyAEQn68jVlxlnAsw8aqeaYzdoGqyWLbVSgrTbAllry0QzVG5uqpoSApfIO8rY8ZHYXdvvmvnwRznDbg6q-6M0JVF0';
     
//'AAAAagzhBvY:APA91bHDvXxfpWasB2PTFzxyUD9tJn4bHRgnBc0f5RBFY2peJ5StpZoxibIVA2W4RPjFsn3BTJ-r-_B1kHvLUapOKpiqK6l-_1SSZLJioYQh0j69OxVabANCowWziIPDubIaDwBq2L4P';
  static Future<Response> sendToUser({
    @required String description,
    @required String amount,
    @required String id,
  }) =>
      sendToTopic( amount:amount,description: description, token: id);

  static Future<Response> sendToTopic(
          {@required String description,
           @required String amount,
           @required String token}) =>
      sendTo(description: description, amount:amount,
       fcmToken:  '$token');
     

  static Future<Response> sendTo({
    @required String description,
    @required String amount,
    @required String fcmToken,
  }) =>
      client.post(
        'https://fcm.googleapis.com/fcm/send',
        body: json.encode({
     
          'notification': { 'title': '$amount','body':'$description',
          

         },
          'priority': 'high',
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            
          },
          'to': ' $fcmToken',
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
      );
}