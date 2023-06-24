import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'login_page.dart';
import 'voting_page.dart';

class Emailverify extends StatelessWidget {
  const Emailverify({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return MaterialApp(
        theme: ThemeData(),
        home: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.lightBlue,
              foregroundColor: Colors.white,
              title: const Text("Secrets"),
              titleTextStyle: const TextStyle(
                  fontStyle: (FontStyle.italic),
                  fontWeight: FontWeight.w500,
                  fontSize: 40),
              toolbarHeight: height * 0.35,
              toolbarOpacity: 0.1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                bottom: Radius.elliptical(width, 100),
              )),
            ),
            body: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                child: Column(
                  children: [
                    const Text(
                        "To complete your registration, please check your email and click the verification link. After validating, use the 'Check Status' button to finish it."),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              await FirebaseAuth.instance.currentUser
                                  ?.sendEmailVerification();
                            },
                            child: const Text(
                              "resend",
                              style: TextStyle(color: Colors.white),
                            )),
                        ElevatedButton(
                            onPressed: () async {
                              await FirebaseAuth.instance.currentUser?.reload();
                              if (FirebaseAuth
                                      .instance.currentUser?.emailVerified ==
                                  true) {
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: ((context) =>
                                            const Voting())));
                              } else {
                                Fluttertoast.showToast(
                                    msg: "email not verified");
                              }
                            },
                            child: const Text(
                              "check status",
                              style: TextStyle(color: Colors.white),
                            )),
                        ElevatedButton(
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              Navigator.of(context).push(MaterialPageRoute(builder: ((context) => const Mylogin())));
                            },
                            child: const Text("signout",style: TextStyle(color: Colors.white),))
                      ],
                    )
                  ],
                ))));
  }
}
