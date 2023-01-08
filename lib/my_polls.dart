import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:show_more_text_popup/show_more_text_popup.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sql_conn/sql_conn.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:readmore/readmore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:lottie/lottie.dart';
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
import 'voting_page.dart';

class mypolls extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: mypollspage(),
    );
  }
}

class mypollspage extends StatefulWidget{

  @override
  State<mypollspage> createState() => _mypollpage();
}

class _mypollpage extends State<mypollspage>{

  late StreamSubscription<QuerySnapshot> myfeed;
  late List<QueryDocumentSnapshot> _myfeed;
  bool error=false; bool loading=true;

  @override
  void initState() {
    // TODO: implement initState
    var uid= FirebaseAuth.instance.currentUser?.uid;
    myfeed = FirebaseFirestore.instance.collection("polls").where("uid",isEqualTo:uid ).snapshots().listen((event) {
      setState((){
        _myfeed=event.docs;
        loading=false;
      });

    },onError: (e){
      setState(() {
        error=true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return Builder(builder: (context)=>
    Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo[400],
        foregroundColor: Colors.white,
        title: const Text("My Polls"),
        leading: IconButton(icon: Icon(Icons.arrow_back),onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>voting()));
        },),
      ),
      body: SingleChildScrollView(
        child: showpost(trending: true,fetchcondition:!loading? _myfeed:null,error: error,mypolls:true),
      ),
    ));
  }
}

mypollspopupmenu(BuildContext context,var documentid){
  return PopupMenuButton(itemBuilder: (context){
  return[
    const PopupMenuItem(child: Text("End Poll"),value: 0,),
    const PopupMenuItem(child: Text("Delete",style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),),value: 1,),
    const PopupMenuItem(child: Text("Contact Us"),value:2)
  ];},
  onSelected: (value) async{
    if(value==1){
      showDialog(context: context, builder: (context)=>AlertDialog(
        title: const Text("..."),
        content: const Text("This post will be deleted permanently",style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),),
        actions: [
          TextButton(onPressed: (){
            Navigator.of(context,rootNavigator: true).pop();
          }, child: Text("Cancel")),
          TextButton(onPressed: ()async{
            try{
            await FirebaseFirestore.instance.collection("polls").doc(documentid).delete();
            Fluttertoast.showToast(msg: "Poll Deleted Successfully");
            } on Exception catch(e){
              Fluttertoast.showToast(msg: e.toString(),backgroundColor: Colors.red);
            }
            Navigator.of(context,rootNavigator: true).pop();
          }, child: const Text("Delete",style:TextStyle(color: Colors.red,fontWeight: FontWeight.bold) ,))
        ],
      ));

    }
    if (value==0){
      showDialog(context: context, builder: (_)=>
      const Dialog(child: CircularProgressIndicator(),));
      await FirebaseFirestore.instance.collection("polls").doc(documentid).update({"endtime":DateTime.now()});
      Navigator.of(context,rootNavigator: true).pop();
      Fluttertoast.showToast(msg: "Your poll has been ended successfully");
    }
    if (value==2){
      var url = Uri.parse("mailto:secretsapp@gmail.com?subject=postid:"+documentid+"&body=");
      try{
        await launchUrl(url);
      }on Exception catch(e){
        throw "something went wrong";
      }
    }
  },
  );
}