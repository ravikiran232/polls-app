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
import 'email_verify.dart';
import 'confession_posts.dart';
import 'newpost_page.dart';
import 'voting_page.dart';
import 'main.dart';

class postpage extends StatefulWidget{
  postpage({Key? key,this.collection}): super(key: key);
  final collection;
  @override
  State<postpage> createState() => _postpage();
}
class _postpage extends State<postpage>{
  bool isloading=false;
  var isliked;

  var  a;
  TextEditingController commentController = TextEditingController();
  @override
  Widget build(BuildContext context){
    return MaterialApp(
        home:Scaffold(
          appBar: AppBar(title: Text("confession"),
            leading: IconButton(icon:Icon(Icons.navigate_before),onPressed: (){Navigator.pop(context);},),
            actions: [
              popupmenu(context,widget.collection.id)
            ],),
          body:SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child:Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 25,),
                  Text(widget.collection.get("subject"),style: TextStyle(fontSize: 20),textAlign: TextAlign.left,),
                  SizedBox(height: 5,),
                  Text(widget.collection.get("time").substring(0,16),style: TextStyle(color: Colors.black26,fontStyle:FontStyle.italic ),),
                  Divider(thickness: 2,),
                  SizedBox(height: 20,),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height*0.3,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),border: Border.all(width: 2,color: Colors.black26)),
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: SingleChildScrollView(child: Text(widget.collection.get("post"))),
                  ),
                  SizedBox(height: 10,),
                  Divider(thickness: 3,),
                  SizedBox(height: 5,),
                  FutureBuilder(future:like_status(widget.collection.id),builder: (context , future){
                    isliked=future.data;
                    print(isliked);
                    return Row(
                      children:[Text("Comments"+"  "+widget.collection.get("comments").toString(),style: TextStyle(fontSize: 15,fontWeight: FontWeight.w200),), SizedBox(width: 30,),IconButton(onPressed: () async{
                        try{await onlikepress(isliked, widget.collection.id);
                        setState(() {
                          isliked=!isliked;
                        });}on Exception catch(e){errormessage(Colors.red, e.toString(),context);}}, icon: Icon(isliked!=true?Icons.favorite_border_outlined:Icons.favorite,color: isliked!=true?Colors.black:Colors.red))],);}),
                  Divider(thickness: 1,),
                  Container(width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height*0.25,child: StreamBuilder (stream: FirebaseFirestore.instance.collection(widget.collection.get("postid")).orderBy("time",descending: true).snapshots(),
                        builder: (context , future){
                          //print(future.data!.docs.length);
                          if (future.hasData){
                            return SingleChildScrollView(
                                child: Column(
                                    children: future.data!.docs.map( (items) =>
                                        Padding(padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                                            child:Container(
                                              width: MediaQuery.of(context).size.width,
                                              constraints: BoxConstraints(minHeight:70 ),
                                              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(16)),border: Border.all(width: 2,color: Colors.yellow),
                                              ),
                                              child:Padding(
                                                  padding:EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                                                  child: Column(
                                                    // tileColor: Colors.white,
                                                    //shape: Border.all(width: 2,color: Colors.white),
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children:[
                                                        Row(children:[Text(items.get("name"),style: TextStyle(color: Colors.black54),) ,SizedBox(width: 10,),Text(items.get("time").substring(0,16),style: TextStyle(color:Colors.black12),)]),
                                                        SizedBox(height:10),
                                                        Text(items.get("comment"),style: TextStyle(fontStyle: FontStyle.italic),)])),
                                            ))).toList()));}

                          if (!future.hasData){return Center(child:Text("No comments to show",style: TextStyle(fontSize: 20,color: Colors.black54),));}
                          else {
                            return  Center(child: CircularProgressIndicator(),);
                          }
                        },
                      )),

                  TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                        hintText: "post a comment",
                        suffixIcon: !isloading?IconButton(icon: Icon(Icons.send,color: Colors.blue,),onPressed: ()async{
                          setState(() {
                            isloading=true;
                          });
                          try{
                            await FirebaseFirestore.instance.collection("posts").doc(widget.collection.id).update({"comments":FieldValue.increment(1)});
                            final name= await FirebaseAuth.instance.currentUser;
                            await FirebaseFirestore.instance.collection(widget.collection.id).doc().set({"comment":commentController.text,"name":name?.displayName,"time":DateTime.now().toString()});
                          } on FirebaseException catch(e) {
                            errormessage(Colors.red, "something went wrong", context);
                          } on Exception catch(e){
                            errormessage(Colors.red, "something went wrong", context);
                          }
                          setState(() {
                            isloading=false;
                            commentController.text="";
                          });},): const CircularProgressIndicator(strokeWidth: 2,),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),gapPadding: 4)),),
                ]
            ),
          ),
        )
    );


  }
}
