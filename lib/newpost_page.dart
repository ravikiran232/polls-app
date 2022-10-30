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
import 'posts_page.dart';
import 'voting_page.dart';
import 'main.dart';


class newpostpage extends StatefulWidget{
  newpostpage({Key? key,this.college});
  final college;
  @override
  State<newpostpage> createState() => _newpostpage();
}
class _newpostpage extends State<newpostpage>{

  TextEditingController subjectcontroller = TextEditingController();
  TextEditingController posttcontroller = TextEditingController();
  final GlobalKey<FormFieldState> formField= GlobalKey();

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(title: Text("confession"),
              leading: IconButton(icon:Icon(Icons.navigate_before),onPressed: (){Navigator.pop(context);},)),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 15,vertical: 15),
            child: Column(
              key: formField,
              children: [
                TextFormField(

                  controller: subjectcontroller,
                  validator: (v){if (v==null || v?.isEmpty==true || v.length!<4 ) {return "Sholud contain atleast 4 letters";} return null;},
                  maxLength: 20,
                  decoration: InputDecoration(
                    hintText: "Sbject of your post",
                    labelText: "subject",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),gapPadding: 4),
                  ),
                ),
                SizedBox(height: 30,),
                TextFormField(

                  controller: posttcontroller,
                  validator: (v){if (v==null || v?.isEmpty==true){return "This field should be left blank";}return null;},
                  maxLines: 20,
                  minLines: null,
                  decoration: InputDecoration(
                    hintText: "Content of your post",
                    labelText: "Description",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),gapPadding: 4),
                  ),
                ),
                SizedBox(height: 20,),
                Builder(builder: (BuildContext context){
                  return
                    ElevatedButton(onPressed:()async{
                      if (formField.currentState?.isValid==false){print("erroe detected");}
                      else{
                        try {
                          final DocumentReference newpost= FirebaseFirestore.instance.collection("posts").doc();

                          await newpost.set({"subject":subjectcontroller.text,"post":posttcontroller.text,"time":DateTime.now().toString(),"comments":0,"likes":0,"postid":newpost.id,"college":widget.college,"report":0});
                          errormessage(Colors.green, "successfully Posted", context);
                          Future.delayed(Duration(seconds: 2));
                          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Myconfessionpage()));
                        } on Exception catch (e) {
                          errormessage(Colors.red, "something went wrong", context);
                        }

                      }
                    }, child: const Text("Post"),style: ElevatedButton.styleFrom(backgroundColor:Colors.blue,foregroundColor: Colors.white,minimumSize: Size(100,30)),);})
              ],
            ),
          )
      ),
    );
  }

}