import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortreward/app_notifications.dart';
import 'package:fortreward/web.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebHomeScreen extends StatefulWidget {

  String? url;

  WebHomeScreen({Key? key, required this.url}) : super(key: key);

  @override
  _WebHomeScreenState createState() => _WebHomeScreenState();
}

class _WebHomeScreenState extends State<WebHomeScreen> {

  late WebViewController _controller;

  final Completer<WebViewController> _controllerCompleter =
  Completer<WebViewController>();

  bool loading = true;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
    final firebaseMessaging = AppNotifications();
    firebaseMessaging.setNotifications();
    firebaseMessaging.streamCtrl.stream.listen((event) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WebHomeScreen(url: event['url']))
      );
    });
  }

  Future<bool> _goBack(BuildContext context) async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return Future.value(false);
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Do you want to exit'),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('No'),
              ),
              FlatButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                child: const Text('Yes'),
              ),
            ],
          ));
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFFD10015),
    ));

    return SafeArea(
      child: WillPopScope(
        onWillPop: () => _goBack(context),
        child: Scaffold(
          body: Stack(
            children: [
              WebView(
                initialUrl: widget.url,
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controllerCompleter.future.then((value) => _controller = value);
                  _controllerCompleter.complete(webViewController);
                },
                navigationDelegate: (NavigationRequest request) async {
                  if (!request.url.startsWith(Web.URL)) {
                    await launch(request.url);
                    return NavigationDecision.prevent;
                  }
                  return NavigationDecision.navigate;
                },
                zoomEnabled: false,
                onPageFinished: (value) {
                  if(loading) {
                    setState(() {
                      loading = false;
                    });
                  }
                },
              ),
              if(loading)
                Container(
                  color: const Color(0xFFD10015),
                  child: const Center(
                    child: Text(
                      "FortR Recipes",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                )
            ],
          ),
        )
      ),
    );
  }
}
