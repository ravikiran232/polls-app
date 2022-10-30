import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:show_more_text_popup/show_more_text_popup.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sql_conn/sql_conn.dart';
import 'sql_queries.dart';
import 'firestore.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_polls/flutter_polls.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'confession_posts.dart';
import 'posts_page.dart';
import 'newpost_page.dart';
import 'voting_page.dart';
import 'main.dart';

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
            foregroundColor:Colors.white ,
            title:Text("Secrets"),
            titleTextStyle: TextStyle(fontStyle: (FontStyle.italic ),fontWeight: FontWeight.w500,fontSize:40 ),
            titleSpacing: 110,
            toolbarHeight: height*0.4,
            toolbarOpacity: 0.1,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.elliptical(width, 100),
                )
            ),
          ),
          body:Center(
            child: Column(
              children: [
                SizedBox(height: 40,),
                Text("Your email was not verified yet ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,color: Colors.black),),
                SizedBox(height: 30,),
                Icon(Icons.error,color:Colors.red,size: 100,),
                Builder(builder: (BuildContext context){
                  return( SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column (
                      children:[
                        Text("if you done with your email verification, click on check status",textAlign: TextAlign.left,style: TextStyle(color: Colors.black),),
                        SizedBox(height: 20,),
                        ElevatedButton(onPressed: () {
                          FirebaseAuth.instance.signOut();
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => const Mylogin()));
                        }, child: Text('signout')),
                        SizedBox(height: 20),
                        ElevatedButton(style:ElevatedButton.styleFrom(backgroundColor: Colors.white,foregroundColor: Colors.black54 ),onPressed: () async {
                          final user = await FirebaseAuth.instance.currentUser;
                          await user?.sendEmailVerification();
                          errormessage(Colors.green,"successfully sent", context);
                        }, child: const Text("resend verification link"),),
                        SizedBox(height: 20),
                        ElevatedButton(style:ElevatedButton.styleFrom(backgroundColor: Colors.white,foregroundColor: Colors.black54 ),onPressed: () {
                          final user = FirebaseAuth.instance.currentUser;
                          final c = user?.emailVerified;
                          print(c);
                          if (c == true) {
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) =>  Myconfessionpage()));
                          } else {
                            errormessage(Colors.red, "email not verified", context);
                          }
                        }, child: const Text("check status")),
                      ],), ));},
                ),
              ],
            ),
          ),));
  }}