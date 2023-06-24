import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_page.dart';
import 'voting_page.dart';
import "my_polls.dart";
import 'package:flutter_native_splash/flutter_native_splash.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  await FirebaseDatabase.instance
      .ref('buyandsellmessages/123456789/latsmessage/${message.data["id"]}/')
      .update({"status": "delivered"});
  print("hi");
}

void main() async {
  WidgetsBinding widgetsbinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsbinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );
  FirebaseMessaging.instance.getToken().then((event) => print(event));
  FirebaseMessaging.instance.onTokenRefresh.listen((event) async {
    print("pushing token to Firestore");
    String userid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userid)
        .update({"token": event});
  });
  final PendingDynamicLinkData? initialLink =
      await FirebaseDynamicLinks.instance.getInitialLink();
  print(initialLink);
  if (initialLink != null) {
    final Uri deepLink = initialLink.link;
    print(deepLink);
    List pathfragments = deepLink.path.split("/");
    runApp(votingpage());
  }
  await Future.delayed(const Duration(seconds: 3));
  if (FirebaseAuth.instance.currentUser != null) {
    runApp(const Voting());
  } else {
    runApp(const Mylogin());
  }
}

popupmenu(c, id) {
  return PopupMenuButton(
      // add icon, by default "3 dot" icon
      // icon: Icon(Icons.book)
      itemBuilder: (context) {
    return [
      const PopupMenuItem<int>(
        value: 0,
        child: Text("Report"),
      ),
      const PopupMenuItem<int>(
        value: 1,
        child: Text("contact us"),
      ),
      const PopupMenuItem(
        value: 2,
        child: Text("my polls"),
      )
    ];
  }, onSelected: (value) async {
    if (value == 0) {
      showDialog<String>(
          context: c,
          builder: (BuildContext context) => AlertDialog(
                title: const Text('Report This Post'),
                content: const Text('Click ok to report this post'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(c, rootNavigator: true).pop(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      try {
                        await FirebaseFirestore.instance
                            .collection("posts")
                            .doc(id)
                            .update({"report": FieldValue.increment(1)});
                        Fluttertoast.showToast(msg: "post reported");
                        Future.delayed(const Duration(seconds: 1));
                        Navigator.of(c, rootNavigator: true).pop();
                      } on Exception catch (e) {
                        Fluttertoast.showToast(
                            msg: "something went wrong",
                            backgroundColor: Colors.red);
                      }
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ));
    } else if (value == 1) {
      var url =
          Uri.parse("mailto:secretsapp@gmail.com?subject=postid:$id&body=");
      try {
        await launchUrl(url);
      } on Exception catch (e) {
        throw "something went wrong";
      }
    } else if (value == 2) {
      Navigator.of(c).push(MaterialPageRoute(builder: (c) => const Mypolls()));
    }
  });
}

dynamiclinkhandler(c) async {
  FirebaseDynamicLinks.instance.onLink.listen((event) {
    if (event != null) {
      List pathfragments = event.link.path.split("/");
      if (pathfragments[1] == "polls") {
        Navigator.of(c).push(MaterialPageRoute(
            builder: (c) => individualpollpage(pathfragments[2], true)));
      }
      if (pathfragments[1] == "confession") {
        Navigator.of(c).push(MaterialPageRoute(builder: (c) => const Voting()));
      }
    }
  });
}
