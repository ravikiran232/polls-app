


import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  print(data.exists.toString()+"fuck");
  if (data.exists){
    return true;
  }
  return false;
}

// user liking or disliking the post.
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
   isuservoted(documentid,length) async{
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
onsamevotepress(List uservoted,documentid,_ismultiple,_issingletime,indexofpress,optionslength,votecountlist) async{
  var user= await FirebaseAuth.instance.currentUser;
  var _uid= user?.uid;
  
  if ( _ismultiple==true&&_issingletime==false){
    List response=uservoted;
    var _forincrement =response[indexofpress];
    response[indexofpress]=!response.elementAt(indexofpress);
    await FirebaseFirestore.instance.collection("users").doc(_uid).collection("polls").doc(documentid).update({"response":response});
    if(_forincrement==false){votecountlist[indexofpress]=votecountlist[indexofpress]+1;}
    if(_forincrement==true){votecountlist[indexofpress]=votecountlist[indexofpress]-1;}
    await FirebaseFirestore.instance.collection("polls").doc(documentid).update({"votes":votecountlist});
    return true;
  }
  if( _ismultiple==false && _issingletime==false){
    List response=List.generate(optionslength, (index) => false);

    var _forincrement =uservoted[indexofpress];
    response[indexofpress]=!uservoted[indexofpress];
    await FirebaseFirestore.instance.collection("users").doc(_uid).collection("polls").doc(documentid).update({"response":response});
    
    uservoted.asMap().entries.map((items){
      print("run");
      if(items.value==true && items.key!=indexofpress){
      print("running0");
      votecountlist[items.key]=votecountlist[items.key]-1;
    }});
    if(_forincrement==false){print("running1");votecountlist[indexofpress]=votecountlist[indexofpress]+1;}
    if(_forincrement==true){print("running");votecountlist[indexofpress]=votecountlist[indexofpress]-1;}
    await FirebaseFirestore.instance.collection("polls").doc(documentid).update({"votes":votecountlist});
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