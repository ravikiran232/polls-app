import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
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
import 'posts_page.dart';
import 'newpost_page.dart';
import 'voting_page.dart';
import 'main.dart';

class Myconfession extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: Myconfessionpage(),
    );
  }
}

class Myconfessionpage extends StatefulWidget{
  @override
  State<Myconfessionpage> createState() => _Myconfessionpage();
}
class _Myconfessionpage extends State<Myconfessionpage>{
  final user=  FirebaseAuth.instance.currentUser;
  var _college;
  Future<String> college() async{

    await FirebaseFirestore.instance.collection("users").doc(user?.uid).get().then((item)=> _college=item['college']);
    return "ok";
  }
  @override
  initState() {
    // TODO: implement initState
    super.initState();
    print("init");
    WidgetsBinding.instance.addPostFrameCallback((_) async{
     dynamiclinkhandler(context);
    });
  }
  @override
  Widget build(BuildContext context){
    if (_college==null){
      college();
      print(_college);}
    //print (_college);
    return  Builder(
        builder:(context)=>Scaffold(
          //backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            title: Text("confessions"),
          ),
          body:Container(
            decoration:BoxDecoration(gradient:LinearGradient(begin:Alignment.topLeft,colors: [Colors.amberAccent,Colors.white],end:Alignment.bottomRight)),
            child:
          StreamBuilder<QuerySnapshot<Map<String , dynamic>>> (
            stream: FirebaseFirestore.instance.collection("posts").where("college",isEqualTo:_college).snapshots(),
            builder:(context  , future){
              //print(future.data!.docs.length);
              if (future.hasData){
                return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                    itemCount: future.data!.docs.length,
                    //separatorBuilder: (context, index) {
                    //return Divider(thickness: 1,);
                    //},
                    itemBuilder: (context,i) {
                      //sql_query_connect();
                      //if (i.isOdd){return const Divider();}
                      return
                        Card(
                          margin: EdgeInsets.fromLTRB(10, 3, 10, 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),side: BorderSide(color: Colors.amberAccent)),
                            elevation: 4,
                            shadowColor: Colors.white,
                            child: ListTile(
                              onTap: (){
                                Navigator.of(context).push(PageTransition(type:PageTransitionType.rightToLeft,duration:const Duration(milliseconds: 300),child:postpage(collection:future.data!.docs[i])));
                              },
                              tileColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),side: BorderSide(color: Colors.black)),
                              title: Text(future.data!.docs[i].get("subject"),style: TextStyle(fontStyle: FontStyle.italic),),
                              subtitle: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                                child: Row(
                                  children: [
                                    const SizedBox(height: 15,),
                                    const Icon(Icons.comment,color: Colors.blue,size: 20,),
                                    const SizedBox(width: 2,),
                                    Text(  future.data!.docs[i].get('comments').toString()),
                                    const SizedBox(width: 20,),
                                    const Icon(Icons.favorite_border_outlined,color: Colors.red,size: 20,),
                                    const SizedBox(width: 2,),
                                    Text( future.data!.docs[i].get('likes').toString()),
                                  ],
                                ),
                              ),

                            ));
                    }

                );}if (!future.hasData){return Container(child:Center(child:Text("something went wrong")));}
              else {
                return Container(child: Center(child: CircularProgressIndicator(),),);
              }
            },
          ),

        ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: FloatingActionButton(backgroundColor: Colors.blue,elevation: 3,child: Icon(Icons.add),onPressed: (){Navigator.of(context).push(MaterialPageRoute(builder: (context)=> newpostpage(college:_college)));},),
        ));
  }
}