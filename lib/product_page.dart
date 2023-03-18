import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:login/my_polls.dart';
import 'package:login/product_chat_page.dart';
import 'firebase_options.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:show_more_text_popup/show_more_text_popup.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sql_conn/sql_conn.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:read_more_text/read_more_text.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:colours/colours.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'sql_queries.dart';
import 'firestore.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_polls/flutter_polls.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'email_verify.dart';
import 'confession_posts.dart';
import 'posts_page.dart';
import 'newpost_page.dart';
import 'main.dart';

class Product extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: Productpage()
    );
  }
}

class Productpage extends StatefulWidget{
  @override
  State<Productpage> createState()=> _Productpage();
}

class _Productpage extends State<Productpage>{
  @override
  Widget build(BuildContext context){
    return Builder(
      builder: (context)=>Scaffold(
        body:SingleChildScrollView(padding:const EdgeInsets.symmetric(horizontal: 10,vertical: 70),child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Stack(children:[Container(
            decoration: BoxDecoration(color: Colors.amber[100]),
            width: double.infinity,
            height: 300,
          ),
          Positioned(top:10,right:5,
            child: IconButton(onPressed: (){
              print("hi");
            Navigator.of(context,rootNavigator: true).pop();
          }, icon: const Icon(Icons.close,color: Colors.black,size: 30,)),)]),
          const SizedBox(height: 10,),
          const Text("Mouse",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w400,color: Colors.black),),
            const SizedBox(height: 10,),
            const Text("\$\400",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w400,color: Colors.black),),
            const SizedBox(height: 10,),
            const ReadMoreText("This mouse is been using from my first year. This was originall dell mouse so you can trust the performance , Ibought it for 1200 ruppess and I am selling it for only 300 due its usage of four years. Interested can contact me by using start chat option provided there thankyou.",
              numLines:4, readMoreText: 'Read more', readLessText: 'read less',

            ),
            const SizedBox(height: 10,),
            Row(children:[const Text("User reviews:", style:  TextStyle(fontWeight: FontWeight.w200,color: Colors.black),
            ),const SizedBox(width: 4,),
              Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),color: Colors.green),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3,vertical: 3),
                      child:Row(children: const [
                        Text("4.4",style: TextStyle(color: Colors.white),),
                        SizedBox(width: 3,),
                        Icon(Icons.star,color: Colors.white,size: 10,)
                      ],)
                  )
              ),])

        ],)
      ),
        bottomNavigationBar: Container(
          alignment: Alignment.center,
          color: Colors.green[300],
          height: 80,
          child: TextButton(child:const Text("Start Chat",style: TextStyle(color: Colors.white,fontSize: 30),),onPressed: (){
            Navigator.of(context,rootNavigator: true).push(MaterialPageRoute(builder: (context)=>Chatt(documentid: "123456789",)));
          },)
        ),
      ),
    );
  }
}