


import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/services.dart';

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