
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
        theme: ThemeData(
          backgroundColor: Colors.black,
        ),
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
            titleSpacing: 110,
            toolbarHeight: height * 0.4,
            toolbarOpacity: 0.1,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
              bottom: Radius.elliptical(width, 100),
            )),
          ),
          body: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                const Text(
                  "Your email was not verified yet ",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black),
                ),
                const SizedBox(
                  height: 30,
                ),
                const Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 100,
                ),
                Builder(
                  builder: (BuildContext context) {
                    return (SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const Text(
                            "if you done with your email verification, click on check status",
                            textAlign: TextAlign.left,
                            style: TextStyle(color: Colors.black),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                FirebaseAuth.instance.signOut();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Mylogin()));
                              },
                              child: const Text('signout')),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black54),
                            onPressed: () async {
                              final user =
                                  await FirebaseAuth.instance.currentUser;
                              await user?.sendEmailVerification();
                              Fluttertoast.showToast(msg: "successfully sent");
                            },
                            child: const Text("resend verification link"),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black54),
                              onPressed: () {
                                final user = FirebaseAuth.instance.currentUser;
                                final c = user?.emailVerified;
                                print(c);
                                if (c == true) {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const Voting()));
                                } else {
                                 Fluttertoast.showToast(msg: "not verified",backgroundColor: Colors.red);
                                }
                              },
                              child: const Text("check status")),
                        ],
                      ),
                    ));
                  },
                ),
              ],
            ),
          ),
        ));
  }
}
