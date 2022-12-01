import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

class votingpage extends StatefulWidget{
  @override
  State<votingpage> createState() => _votingpage();
}
class _votingpage extends State<votingpage> with TickerProviderStateMixin{
  bool isslidingopened=false;
  bool _ismultipleallowed=false;
  List values=[1,2,3,4];

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: Builder(
        builder:(context)=>
      DefaultTabController(
      length:3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 90,
          elevation: 4,
          backgroundColor:Colors.indigo[400],
          foregroundColor: Colors.white,
          leading: IconButton(icon: Icon(Icons.arrow_back),onPressed:(){Navigator.of(context).pop();} ,),
          actions: [
            IconButton(onPressed: (){
            }, icon: Icon(Icons.menu),padding: EdgeInsets.symmetric(horizontal: 30),)
          ],
          title:  const Text("Polls"),
          //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),),
    bottom: TabBar(
        padding: EdgeInsets.symmetric(horizontal: 20),
        isScrollable: true,
        //indicator: BoxDecoration(borderRadius:BorderRadius.circular(20),shape: BoxShape.rectangle,color: Colors.blue),
        indicatorColor: Colors.white,
        indicatorWeight: 3.5,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white,
        labelStyle: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),
        tabs: [
          Tab(child:Row(mainAxisAlignment:MainAxisAlignment.center,children: [Icon(Icons.local_fire_department_sharp),SizedBox(width: 5,),Text("Trending")],)),
          Tab(child:Row(mainAxisAlignment:MainAxisAlignment.center,children: [Icon(Icons.poll_sharp),SizedBox(width: 5,),Text("LIVE")],)),
          Tab(child:Row(mainAxisAlignment:MainAxisAlignment.center,children: [Icon(Icons.timelapse),SizedBox(width: 5,),Text("Ended")],))
        ] ),),

        body: TabBarView(
          children:[
            SingleChildScrollView(child:showpost()),
            Icon(Icons.timelapse,size:40),
            Icon(Icons.timelapse,size:40)
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(backgroundColor: Colors.blue,elevation: 3,child: Icon(Icons.add),onPressed: (){navigatenewpoll(context);},),
      )
      ),
      ));

  }
}

class optionforquestion extends StatefulWidget{
  optionforquestion(this.documentid,this.option,this.multiple,this.index,this.uservoted,this.singletime,this.optionslength,this.votecountlist);
  var option,documentid;
  bool multiple;
  int index,optionslength;
   var uservoted;bool singletime; var votecountlist;
  @override
  State<optionforquestion> createState()=> _optionforquestion();
}
class _optionforquestion extends State<optionforquestion>{
  @override
  Widget build(BuildContext context) {
    bool _value=widget.uservoted[widget.index];
    return InkWell(onTap: ()async{
      var result=await onsamevotepress(widget.uservoted,widget.documentid, widget.multiple, widget.singletime, widget.index, widget.optionslength,widget.votecountlist);
      print(result);
      setState(() {
        if (result==true){
        widget.uservoted[widget.index]=!widget.uservoted[widget.index];}
    });},
        child:Stack(
          children:[
            AnimatedContainer(duration: Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
              decoration: BoxDecoration(shape: BoxShape.rectangle,borderRadius: BorderRadius.circular(10),color: _value?Colors.blue.withOpacity(0.5):Colors.white,),
              width: _value?100:0,
              height: 50,
            ),
            Container(
              height: 50,
              margin: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(shape: BoxShape.rectangle,borderRadius: BorderRadius.circular(12),border: Border.all(color: _value?Colors.blue:Colors.black54),),
              child:
              Row(children:[ _value?Icon(Icons.verified):SizedBox(width: 5,),Text(widget.option.toString()),_value?Row(children:[SizedBox(width:15),Text("34%",style: TextStyle(fontWeight: FontWeight.bold),)]):SizedBox(height: 5,)]),
            ),
         ],
        ));
  }
}


// for adding the new questions to the polls by + option.


class newpollpage extends StatefulWidget{
  @override
  State<newpollpage> createState() => _newpollpage();
}
class _newpollpage extends State<newpollpage>{

  GlobalKey<FormState> _key = new GlobalKey();
  ScrollController _totalscrollcontroller= ScrollController();
  TextEditingController questioncontroller = TextEditingController();
  int optionscount=2;
  List textcontrollers= [TextEditingController(),TextEditingController()];
  var datetime ;
  bool isprivate=false;
  bool ismultiple=false;
  bool issingletime=true;

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("New Poll"),
          leading: IconButton(icon:Icon(Icons.navigate_before),onPressed: (){Navigator.pop(context);},),
          elevation: 4,
          backgroundColor:Colors.indigo[400],
          foregroundColor: Colors.white,
        ),
        body:
            Card(
              margin: const EdgeInsets.fromLTRB(10, 20, 10, 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 4,

                 child: Form(
                    key: _key,

                  child: SingleChildScrollView(
                    controller:_totalscrollcontroller ,
                 padding: EdgeInsets.symmetric(vertical:8,horizontal: 10),
                      child: Column(

                    children:[
                      TextFormField(
                        //expands: true,
                  maxLines: 3,
                  validator: _validatequestion,
                  controller: questioncontroller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)
                    ),
                    hintText: "Enter your question",
                    labelText: "Question",
                    suffixIcon: Icon(Icons.question_mark,color: Colors.blue,),
                  ),
                ),
                      //SizedBox(height: 15,),
                      ListView.builder(
                        controller:_totalscrollcontroller ,
                        shrinkWrap: true,
                        itemCount: optionscount ,
                        padding: EdgeInsets.symmetric(vertical:15),
                        itemBuilder: (context ,i){
                          return
                          Padding(padding: EdgeInsets.symmetric(vertical: 3),
                              child:
                              TextFormField(
                                maxLength: 30,
                                validator:_validateoption,
                                controller: textcontrollers[i],
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15)
                                  ),
                                  hintText: "Enter your option",
                                      labelText: "Option ${i+1}",
                                ),
                              ));
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:[InkWell(
                        onTap: (){
                          if (optionscount<=4){
                          setState(() {
                            optionscount+=1;
                            textcontrollers.add(new TextEditingController());
                          });}
                          else{
                            Fluttertoast.showToast(
                                msg: "Maximum 5 options are allowed",
                            timeInSecForIosWeb: 3,
                            backgroundColor: Colors.redAccent,
                            fontSize: 12,
                            gravity: ToastGravity.BOTTOM);
                          }
                        },
                        child:Row(children: const [Icon(Icons.add,color: Colors.blue,), SizedBox(width: 5,),Text("Add Option",style: TextStyle(color: Colors.blue),)],)
                      ),
                        InkWell(
                            onTap: (){
                              if (optionscount>2){
                                setState(() {
                                  optionscount-=1;
                                  textcontrollers.removeAt(optionscount);
                                });}
                              else{
                                Fluttertoast.showToast(
                                    msg: "Minimum 2 options required",
                                    timeInSecForIosWeb: 3,
                                    backgroundColor: Colors.redAccent,
                                    fontSize: 12,
                                    gravity: ToastGravity.BOTTOM);
                              }
                            },
                            child:Row(children: const [Icon(Icons.remove,color: Colors.red,), SizedBox(width: 5,),Text("remove Option",style: TextStyle(color: Colors.red),)],)
                        ),]),
                      SizedBox(height:8),
                      DateTimePicker(type:DateTimePickerType.dateTime,
                          validator: _timevalidator,
                          onChanged: (dt) => datetime=dt,
                          decoration: InputDecoration(
                            labelText: "deadline",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))
                          ),
                          initialDate: DateTime.now().add(Duration(days:1)),
                      firstDate: DateTime.now() ,
                      lastDate: DateTime.now().add(Duration(days:30)),),


                      Row(
                        children:[
                         Checkbox(
                        value:isprivate,
                        onChanged:(value){
                          setState((){
                            isprivate=!isprivate;
                          });
                        }
                      ),Text("only person with link can see the post")]),
                SizedBox(height:5),
                Row(
                children:[
                Checkbox(
                  value:ismultiple,
                  onChanged:(value){
                    setState((){
                      ismultiple=!ismultiple;
                    });

                  }
                ),Text("allow multiple option selection")]),
                      SizedBox(height: 5,),
                      Row(
                          children:[
                            Checkbox(
                                value:issingletime,
                                onChanged:(value){
                                  setState((){
                                    issingletime=!issingletime;
                                  });

                                }
                            ),Text("only one vote per user")]),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),minimumSize: Size(100, 40),backgroundColor:Colors.indigo[400] ),
                        onPressed: () async{
                        if(_key.currentState?.validate()==true){await showloadingdilog(context,questioncontroller.text,textcontrollers,DateTime.parse(datetime),ismultiple,isprivate,issingletime);
                        //if (submitvalue){Fluttertoast.showToast(msg: "submitted successfully",backgroundColor: Colors.green,timeInSecForIosWeb: 4);}
                        //else{Fluttertoast.showToast(msg: "something went wrong",backgroundColor: Colors.red,timeInSecForIosWeb: 4);}}
                      }}, child: Text("Post"),)
                    ])
            )))

      ),
    );
  }

}

class showpost extends StatefulWidget{
  @override
  State<showpost> createState() => _showpost();
}
class _showpost extends State<showpost>{
  @override
  Widget build(BuildContext context){

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("polls").where("endtime",isGreaterThanOrEqualTo: DateTime.now()).snapshots(),
        builder: (context,streamer) {

        if (streamer.hasData){
      return Column(
        children: (streamer.data?.docs.map((items)=>pollpostdesign(context,items.id, items["question"], items["options"], 30, items["votes"], items['username'],items["multipleopt"],items['singletime'])))!.toList(),

    );}
        if(!streamer.hasData){return Align(alignment: Alignment.center,child:SizedBox(height:40,width:40,child:CircularProgressIndicator(strokeWidth: 5,)));}
        if(streamer.hasError){
          return Text("An Error Occured",style:TextStyle(fontWeight: FontWeight.bold,color: Colors.red,fontSize: 20),textAlign:TextAlign.center,);
        }
        else{return Text("something went wrong",style:TextStyle(fontWeight: FontWeight.bold,color: Colors.red,fontSize: 20),textAlign:TextAlign.center,);}
      });
  }
}
Widget pollpostdesign(BuildContext context,documentid,String question,List options,likes,List votes,username,bool ismultiple,bool singletime) {
  var _isuservoted;
    return InkWell(splashColor:Colors.lightGreenAccent,onTap:(){
    },
    child:Container(constraints: BoxConstraints(maxHeight:450 ),
    child:Card(
    margin: EdgeInsets.fromLTRB(15, 10, 15, 10),
    elevation: 5,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: SingleChildScrollView(
      child:
      FutureBuilder(
  future:isuservoted(documentid,options.length).timeout(Duration(seconds: 5)),
              builder:(context,future){
    if(future.hasData){
      int votecount= votes.reduce((value, element) => value+element);
      print(votecount);
      
      _isuservoted=future.data;
      return
              Column(
              children: [
                Padding(padding:EdgeInsets.fromLTRB(20, 20, 10, 10),
                    child:Row(  children: [CircleAvatar(radius: 20,foregroundImage: NetworkImage("https://thumbs.dreamstime.com/b/girl-vector-icon-elements-mobile-concept-web-apps-thin-line-icons-website-design-development-app-premium-pack-glyph-flat-148592081.jpg"),),SizedBox(width: 5,),Text(username,style: TextStyle(color: Colors.black54),)],)),
                Padding(padding:EdgeInsets.fromLTRB(10, 1, 10, 15),child:ReadMoreText(question,trimLines: 3,
                  colorClickableText: Colors.blue,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: '..Read More',
                  style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
                  trimExpandedText: ' Less',),),
                Column(
                    children: options.asMap().entries.map((items)=>optionforquestion(documentid,items.value,ismultiple,items.key,_isuservoted!,singletime,options.length,votes)).toList()
                ),
                SizedBox(height: 3,),
                Row(children:[OutlinedButton(style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.white)),onPressed: (){}, child: Icon(Icons.favorite,color: Colors.red,)), IconButton(onPressed: (){}, icon:Icon(Icons.share)),SizedBox(width: 120,),Text("votes : "+votecount.toString(),style: TextStyle(color: Colors.black54),)
                ])
              ],
                  );}
    else if (future.hasData==false){
      return  Container(constraints: BoxConstraints(minHeight:200 ),child:Center(child: CircularProgressIndicator(),)
      );
    }

    else{return Text("An error Occured",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red),);}
  })))));}


navigatenewpoll (c){
  Navigator.of(c).push( MaterialPageRoute(builder: (context)=> newpollpage()));
}

String? _validatequestion(String? value){
  if (value!.length==0){
    return "* Required Field";
  }
  else if (value!.length<=5){
    return "Question is too short";
  }
  return null;
}

String? _validateoption(String? value){
  if (value!.length==0){
    return "* Required Field";
  }
  return null;
}

String? _timevalidator(String? value){
  if(value!.length==0){
    return "*Required Field";
  }
  return null;
}

pushingtofirestore(question,List optionslist,time,multipleoption,publicview,singletime) async{
  List options= [];
  List votes=[];
  List response=[];
  for (var items in optionslist) {
    options.add(items.text);
    votes.add(0);
    response.add(false);
  }

  var user=await FirebaseAuth.instance.currentUser;
  var userid= user?.uid;
  var username = user?.displayName;
  var photo=user?.photoURL;
  final DocumentReference newpoll= FirebaseFirestore.instance.collection("polls").doc();
  try {
    await newpoll.set({
      "question": question,
      "options": options,
      "endtime":time,
      "multipleopt":multipleoption,
      "public":publicview,
      "userid": userid,
      "username": username,
      "photo": photo,
      "like":0,
      "votes":votes,
      "singletime":singletime
    }).timeout(Duration(seconds: 6));
    await FirebaseFirestore.instance.collection("polls").doc(newpoll.id).collection("users").doc(userid).set({"response":response});
    return newpoll.id;
  }on TimeoutException catch(e){return "out";} on Exception catch(e){
    return false;
  }
}

showloadingdilog(BuildContext context,question, optionslist, time, multipleoption, bool publicview,singletime){
  var document_id;
  showDialog(context: context,
      barrierDismissible: false,
      //have to use dialog for customisation after finding better loading animations.
      builder: (_)=>AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Hang On..."),
        content: FutureBuilder (
          future:pushingtofirestore(question, optionslist, time, multipleoption, publicview,singletime),
          builder: (context,future){
            if (future.hasData){
              if (future.data!=false && future.data!="out"){document_id=future.data;return Text(!publicview?"Successfully Posted":"Successfully Posted.Share your link by using share button",style:TextStyle(fontWeight: FontWeight.bold,color: Colors.green));}
              if (future.data==false){return Text("Something went wrong",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red),);}
              else{return Text("An error Occured",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red),);}
            }
            else if (future.hasData==false){
              return const SizedBox(width:10,height:30,child:
              CircularProgressIndicator(strokeWidth: 2));
            }

            else{return Text("An error Occured",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red),);}
          },

        ),
        actions: [
          TextButton(onPressed: ()async{
            //final MethodChannel _method = new MethodChannel("share");
            var linkresult=await firebasedynamiclink("polls",document_id );
            if (linkresult!=false || linkresult!="out"){
              Share.share("express your opnion to the poll "+linkresult.toString());
            }
            else{Fluttertoast.showToast(msg: "unable to generate link",backgroundColor: Colors.red,timeInSecForIosWeb: 3);}

          }, child:Text("share")),
          TextButton(onPressed: (){Navigator.of(context,rootNavigator: true).pop();}, child: Text("ok"))
        ],
      ));
}



