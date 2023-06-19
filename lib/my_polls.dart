import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'voting_page.dart';

class Mypolls extends StatelessWidget{
  const Mypolls({super.key});

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
    print(uid);
    myfeed = FirebaseFirestore.instance.collection("polls").where("userid",isEqualTo:uid ).snapshots().listen((event) {
      setState((){
        print("hi");
        _myfeed=event.docs;
        print(event.docs.length);
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
  void dispose(){
    myfeed.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Builder(builder: (context)=>
    Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo[400],
        foregroundColor: Colors.white,
        title: const Text("My Polls"),
        leading: IconButton(icon: const Icon(Icons.arrow_back),onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const Voting()));

        },),
      ),
      body: SingleChildScrollView(
        child: showpost(fetchcondition:!loading? _myfeed:null,error: error,mypolls:true),
      ),
    ));
  }
}

mypollspopupmenu(BuildContext context,var documentid){
  return PopupMenuButton(itemBuilder: (context){
  return[
    const PopupMenuItem(value: 0,child: Text("End Poll"),),
    const PopupMenuItem(value: 1,child: Text("Delete",style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),),),
    const PopupMenuItem(value:2, child: Text("Contact Us"))
  ];},
  onSelected: (value) async{
    if(value==1){
      showDialog(context: context, builder: (context)=>AlertDialog(
        title: const Text("..."),
        content: const Text("This post will be deleted permanently",style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),),
        actions: [
          TextButton(onPressed: (){
            Navigator.of(context,rootNavigator: true).pop();
          }, child: const Text("Cancel")),
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
      const  SizedBox(height:50,width:30,child:CircularProgressIndicator(strokeWidth: 3,)));
      await FirebaseFirestore.instance.collection("polls").doc(documentid).update({"endtime":DateTime.now()});
      Navigator.of(context,rootNavigator: true).pop();
      Fluttertoast.showToast(msg: "Your poll has been ended successfully");
    }
    if (value==2){
      var url = Uri.parse("mailto:secretsapp@gmail.com?subject=postid:$documentid&body=");
      try{
        await launchUrl(url);
      }on Exception catch(e){
        throw "something went wrong";
      }
    }
  },
  );
}