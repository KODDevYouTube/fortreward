import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class AppNotifications {

  final streamCtrl = StreamController<Map<String, dynamic>>.broadcast();

  setNotifications() {
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);

    forgroundNotifications();

    backgroundNotification();

    terminateNotification();
  }

  forgroundNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      //streamCtrl.sink.add(message.data);
    });
  }

  backgroundNotification() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      streamCtrl.sink.add(message.data);
    });
  }

  terminateNotification() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if(initialMessage != null){
      streamCtrl.sink.add(initialMessage.data);
    }
  }

}

Future<void> onBackgroundMessage(RemoteMessage message)async {
  await Firebase.initializeApp();

  if(message.data.containsKey('data')){
    final data = message.data['data'];
  }

  if(message.data.containsKey('notification')){
    final notification = message.data['notification'];
  }
}