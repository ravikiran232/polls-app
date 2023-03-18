


import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:login/main.dart';

// signin function
Future<String> firebase_usersignin(useremail,userpassword) async {
  var  result;
  try{
    final user=await FirebaseAuth.instance.signInWithEmailAndPassword(email:useremail , password: userpassword);
    result="successful";
  } on FirebaseException catch(e){
    if(e.code=="email-already-in-use"){
      result="Email was already registered use forgot password";
    }
    if (e.code=="user-not-found"){result="either your email or password is wrong";}
    else{
      result="something went wrong";
    }
  } on PlatformException catch (e) {
    result =e.toString();
  }
  return result;
}

// user signup function.
Future<String> firebase_usersignup(useremail,userpassword) async {
  var  result;
  try{
    final user=await FirebaseAuth.instance.createUserWithEmailAndPassword(email:useremail , password: userpassword);
    final user1= await FirebaseAuth.instance.currentUser;
    await user1?.sendEmailVerification();
    result="successful";
  } on FirebaseException catch(e){
    if(e.code=="email-already-in-use"){
      result="Email was already registered use forgot password";
    }
    if (e.code=="user-not-found"){result="either your email or password is wrong";}
    else{
      result="something went wrong";
    }
  } on PlatformException catch (e) {
    result =e.toString();
  }
  return result;
}

//user post like status
Future<bool> like_status(id) async{
  final user= await FirebaseAuth.instance.currentUser;
  var uid=user?.uid;
  final data=await FirebaseFirestore.instance.collection(id+"like").doc(uid).get();
  if (data.exists){
    return true;
  }
  return false;
}

// user liking or disliking the post.
// it is depreciated due to wrong database management update it with newonlikepress function for faster and better management
onlikepress(liked ,id) async {
  final user =await FirebaseAuth.instance.currentUser;
  var uid=user?.uid;
  if (liked==true){
    await FirebaseFirestore.instance.collection("posts").doc(id).update({"likes":FieldValue.increment(-1)});
    await FirebaseFirestore.instance.collection(id+"like").doc(uid).delete();
  }else{
    await FirebaseFirestore.instance.collection("posts").doc(id).update({"likes":FieldValue.increment(1)});
    await FirebaseFirestore.instance.collection(id+"like").doc(uid).set({"status":true});
  }
}

newonlikepress(documentid,likestatus,userid,postfeature, bool isfieldavailable) async{
  if(likestatus==true){
    try{
    await FirebaseFirestore.instance.collection(postfeature).doc(documentid).update({"like":FieldValue.increment(-1)});
    await FirebaseFirestore.instance.collection(postfeature).doc(documentid).update({"userlikes":FieldValue.arrayRemove([userid])});} on Exception catch(e){Fluttertoast.showToast(msg: "something went wrong",timeInSecForIosWeb: 3,backgroundColor: Colors.red);}
  }
  else{
    try{
    await FirebaseFirestore.instance.collection(postfeature).doc(documentid).update({"like":FieldValue.increment(1)});
    await FirebaseFirestore.instance.collection(postfeature).doc(documentid).update({"userlikes":FieldValue.arrayUnion([userid])});
    }on Exception catch(e){ errormessage(Colors.red, "something went wrong", "hi");}
  }
}

get_post_ids () async {
  try{
    List a=[];
     QuerySnapshot posts =  await FirebaseFirestore.instance.collection("posts").get();
   // var data = snapshot.docs ;
    posts.docs.forEach((element) {a.add(element.data());});
    print(a);
    return a.toList();
  } on Exception catch(e) {
    print(e);
    return "something went wrong";
  }
}

read_post(String ids , key) async{
 try{
   final a = await FirebaseFirestore.instance.collection('users').doc(ids).get();
   final data = a.data() as Map<String,dynamic> ;
   return data[key];
 } on Exception catch(e) {
   print(e);
   return "something went wrong";
 }
}

//dynamic link generator
firebasedynamiclink(path,documentid) async{
  final dynamiclinkparams = DynamicLinkParameters(link: Uri.parse("https://openupra.page.link/"+path+"/"+documentid), uriPrefix: "https://openupra.page.link",
    androidParameters: const AndroidParameters(packageName: "com.example.login.login"),);
  try{final dynamiclink= await FirebaseDynamicLinks.instance.buildLink(dynamiclinkparams).timeout(Duration(seconds: 5));
  return dynamiclink.normalizePath().toString();}
      on TimeoutException catch(e){return "out";} on Exception catch(e){return false;}
}

// is User already voted the question or not? function.
   Future<List> isuservoted(documentid,length) async{
  var user= await FirebaseAuth.instance.currentUser;
  var _uid= user?.uid;
  final value= await FirebaseFirestore.instance.collection("users").doc(_uid).collection("polls").doc(documentid).get();
  if(value.exists){
    return value["response"];
  }
  else{
    return List.generate(length, (index) => false)  ;
  }
}

// handling the user option press.
onsamevotepress(List uservoted,documentid,_ismultiple,_issingletime,indexofpress,optionslength,votecountlist,_isvoted,) async{
  var user= await FirebaseAuth.instance.currentUser;
  var uid= user?.uid;
  
  if ( _ismultiple==true&&_issingletime==false){
    List response=uservoted;
    var _forincrement =response[indexofpress];
    response[indexofpress]=!response.elementAt(indexofpress);

    if(_forincrement==true){votecountlist[indexofpress]=votecountlist[indexofpress]-1;}
    if(_forincrement==false){votecountlist[indexofpress]=votecountlist[indexofpress]+1;}
    try{
    await FirebaseFirestore.instance.collection("polls").doc(documentid).update({"votes":votecountlist});
    await FirebaseFirestore.instance.collection("polls").doc(documentid).update(({"userresponses.$uid":response}));
    } on Exception catch (e){errormessage(Colors.red, "something went wrong", "context");}
    return true;
  }
  if( _ismultiple==false && _issingletime==false){
    List response=List.generate(optionslength, (index) => false);

    var _forincrement =uservoted[indexofpress];
    response[indexofpress]=!uservoted[indexofpress];

    if(uservoted.contains(true) && uservoted.indexOf(true)!=indexofpress){
      votecountlist[uservoted.indexOf(true)]=votecountlist[uservoted.indexOf(true)]-1;
    }
    if(_forincrement==true){votecountlist[indexofpress]=votecountlist[indexofpress]-1;}
    if(_forincrement==false){votecountlist[indexofpress]=votecountlist[indexofpress]+1;}
    try{
    await FirebaseFirestore.instance.collection("polls").doc(documentid).update({"votes":votecountlist});
    await FirebaseFirestore.instance.collection("polls").doc(documentid).update(({"userresponses.$uid":response}));
    }on Exception catch(e){errormessage(Colors.red, "something went wrong", "context");}
    return true;
  }

  // if(_isvoted==false){
  //   List response=List.generate(optionslength,(i)=>false);
  //   response[indexofpress]=true;
  //   await FirebaseFirestore.instance.collection("users").doc(_uid).collection("polls").doc(documentid).set({"response":response});
  //   var polldata=await FirebaseFirestore.instance.collection("polls").doc(documentid).get();
  //   var _polldata=polldata["votes"];
  //   _polldata[indexofpress]=_polldata[indexofpress]+1;
  //   await FirebaseFirestore.instance.collection("polls").doc(documentid).update({"votes":_polldata});
  //   return true;
  // }
  if (uservoted.contains(true)==true && _issingletime==true){
    Fluttertoast.showToast(msg: "owner has allowed only single vote for a user",backgroundColor: Colors.red,timeInSecForIosWeb:4 );
  }

}


// realtime database functions be ready.........

decodingdata(final data){
  final map = data as Map;
  List<types.Message> messages=[];
  for (var value in map.values){
    if (value["status"]=="read"){
    messages.add(
      types.TextMessage(author: types.User(id:value["author"]),
          id:value["id"] ,
          text: value["text"],
      createdAt: value["createdAt"],
      status: types.Status.seen)
    );}
    if (value["status"]=="delivered"){
      messages.add(
          types.TextMessage(author: types.User(id:value["author"]),
              id:value["id"] ,
              text: value["text"],
              createdAt: value["createdAt"],
              status: types.Status.delivered)
      );
    }
    if (value["status"]=="sent"){
      messages.add(
          types.TextMessage(author: types.User(id:value["author"]),
              id:value["id"] ,
              text: value["text"],
              createdAt: value["createdAt"],
              status: types.Status.sent)
      );
    }
  }
  print("data from the server decoded successfully ");
  return messages;
}

userstatus(String status) async{
  String uid = FirebaseAuth.instance.currentUser!.uid;
  await FirebaseFirestore.instance.collection("Anonymouschat").doc("123456789").update({uid:status});
}
