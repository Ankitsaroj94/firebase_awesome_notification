import 'dart:io';
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_intigration/firebase_options.dart';
import 'package:firebase_intigration/notification_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print(await FirebaseMessaging.instance.getToken());



  await AwesomeNotifications().initialize(
    null,
      [
        NotificationChannel(
          channelKey: "basic_channel",
          channelName: "Basic notifications",
          channelDescription: "Notification channel for basic tests", 
          defaultColor: Color(0xFF9D50DD),
          ledColor: Colors.white,
          channelShowBadge: true,
          importance: NotificationImportance.High,
        )
      ],
      debug: true



      
  );
  AwesomeNotifications().setListeners(
      onActionReceivedMethod: (ReceivedAction receivedAction) {
        return NotificationController.onActionReceivedMethod(receivedAction);
      },
      onNotificationCreatedMethod: (ReceivedNotification receivedNotification) {
        return NotificationController.onNotificationCreatedMethod(
          receivedNotification,
        );
      },
      onNotificationDisplayedMethod:
          (ReceivedNotification receivedNotification) {
        return NotificationController.onNotificationDisplayedMethod(
          receivedNotification,
        );
      },
      onDismissActionReceivedMethod: (ReceivedAction receivedAction) {
        return NotificationController.onDismissActionReceivedMethod(
          receivedAction,
        );
      },
    );

     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (Platform.isIOS) return;
      final data = <String, String>{};
      message.data.forEach((key, value) {
        data[key] = value.toString();
      });

      final messageId = message.messageId ?? '';
      final secondPart =
          messageId.split(':').length > 1 ? messageId.split(':')[1] : '';

      final intId =
          int.tryParse(secondPart.split('%').first) ?? Random().nextInt(100);

      final max32BitInt = 2147483647;
      final finalId = (intId % (max32BitInt * 2)) - max32BitInt;

      final groupKey = message.data['flag'] ?? 'notifications';

      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: finalId,
          channelKey: 'basic_channel',
          title: message.notification?.title ?? '',
          body: message.notification?.body ?? '',
          groupKey: groupKey,
          payload: data,
        ),
      );
    });
    FirebaseMessaging.onBackgroundMessage(
      NotificationController.firebaseMessagingBackgroundHandler,
    );
  



  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
