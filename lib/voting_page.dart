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

class voting extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home:votingpage()
    );
  }
}
class votingpage extends StatefulWidget{
  @override
  State<votingpage> createState() => _votingpage();
}
class _votingpage extends State<votingpage> with TickerProviderStateMixin{
  bool isslidingopened=false;
  bool _ismultipleallowed=false;
  List values=[1,2,3,4];
  ScrollController trendingcontroller=ScrollController();
  ScrollController live =ScrollController();
  ScrollController ended = ScrollController();
  StreamController _streamController=StreamController();
  int livecount=4,endcount=4;
  late String college;

  @override
  void initState() async{
    // TODO: implement initState

    live.addListener(() {
    if(live.position.atEdge){
      if(live.position.pixels==0){}else{
        setState(() {
        livecount+=2;
      });}
    }});
    ended.addListener(() {
      if(ended.position.atEdge){
        if(ended.position.pixels==0){}
        else{
        setState(() {
          endcount+=2;
        });
      }}
    });

    dynamiclinkhandler(context);

    // var uid= FirebaseAuth.instance.currentUser?.uid;
    // var data=await FirebaseFirestore.instance.collection("users").doc(uid).get();
    // college=data["college"];

    super.initState();

  }

  @override
  void dispose() {
    // TODO: implement dispose
    live.removeListener(() { });
    ended.removeListener(() { });
    _streamController.close();
    super.dispose();
  }
  @override
  Widget build(BuildContext context){
    return  Builder(
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
            popupmenu(context, "sampleid")
          ],
          title:  const Text("Polls"),
          //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),),
    bottom: TabBar(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        isScrollable: true,
        //indicator: BoxDecoration(borderRadius:BorderRadius.circular(20),shape: BoxShape.rectangle,color: Colors.blue),
        indicatorColor: Colors.white,
        indicatorWeight: 3.5,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white,
        labelStyle: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold),
        tabs: [
          Tab(child:Row(mainAxisAlignment:MainAxisAlignment.center,children: [Icon(Icons.local_fire_department_sharp),SizedBox(width: 5,),Text("Trending")],)),
          Tab(child:Row(mainAxisAlignment:MainAxisAlignment.center,children: [Icon(Icons.poll_sharp),SizedBox(width: 5,),Text("LIVE")],)),
          Tab(child:Row(mainAxisAlignment:MainAxisAlignment.center,children: [Icon(Icons.timelapse),SizedBox(width: 5,),Text("Ended")],))
        ] ),),

        body: TabBarView(
          children:[
            SingleChildScrollView(
                child:showpost(fetchcondition: FirebaseFirestore.instance.collection("polls").where("endtime",isGreaterThanOrEqualTo: DateTime.now()).limit(3),trending: true,streamController: _streamController,)),

            SingleChildScrollView(
              controller: live,
                child:showpost(fetchcondition: FirebaseFirestore.instance.collection("polls").where("endtime",isGreaterThanOrEqualTo: DateTime.now()).limit(livecount),streamController: _streamController,)),
            SingleChildScrollView(
              controller: ended,
                child:showpost(fetchcondition: FirebaseFirestore.instance.collection("polls").where("endtime",isLessThan: DateTime.now()).limit(endcount),ended: true,streamController: _streamController,))
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(backgroundColor: Colors.blue,elevation: 3,child: Icon(Icons.add),onPressed: (){navigatenewpoll(context);},),
      )
      ),
      );

  }
}

class optionforquestion extends StatefulWidget{
  optionforquestion(this.documentid,this.option,this.multiple,this.index,this.uservoteresponse,this.singletime,this.optionslength,this.votecountlist,this.totalvotecount,this.uservoted,this.ended,this.isfieldavailable);
  var option,documentid;
  bool multiple , ended;
  int index,optionslength;
   List uservoteresponse;bool singletime; var votecountlist; int totalvotecount; bool uservoted; bool isfieldavailable;
  @override
  State<optionforquestion> createState()=> _optionforquestion();
}
class _optionforquestion extends State<optionforquestion>{
  @override
  Widget build(BuildContext context) {
    var size=MediaQuery.of(context).size.width*0.85;
    bool _value=widget.uservoteresponse[widget.index];
    bool uservoted=widget.uservoted;
    if(widget.ended){uservoted=widget.ended;}
    if(widget.totalvotecount==0){uservoted=false;}
    return InkWell(onTap: ()async{
      if (!widget.ended){
     await onsamevotepress(widget.uservoteresponse,widget.documentid, widget.multiple, widget.singletime, widget.index, widget.optionslength,widget.votecountlist,widget.uservoted,widget.isfieldavailable);}
      else{Fluttertoast.showToast(msg: "This poll has been ended",backgroundColor: Colors.red,timeInSecForIosWeb: 3);}

   },
        child:Stack(
          children:[
            AnimatedContainer(duration: Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
              decoration: BoxDecoration(shape: BoxShape.rectangle,borderRadius: BorderRadius.circular(10),color: uservoted?Colors.blue.withOpacity((widget.votecountlist[widget.index]/widget.totalvotecount)):Colors.white,),
              width: uservoted?size*(widget.votecountlist[widget.index]/widget.totalvotecount):0,
              height: 50,

            ),
            Container(
              height: 50,
              width: size ,
              margin: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(shape: BoxShape.rectangle,borderRadius: BorderRadius.circular(12),border: Border.all(color: _value?Colors.blue:Colors.black54),),
              child:
              Row(children:[ _value?Icon(Icons.verified):SizedBox(width: 5,),Text(widget.option.toString()),uservoted?Row(children:[SizedBox(width:15),Text(double.parse(((widget.votecountlist[widget.index]/widget.totalvotecount)*100).toStringAsFixed(1)).toString()+"%",style: TextStyle(fontWeight: FontWeight.bold),)]):SizedBox(height: 5,)]),
            ),
         ],
        ));
  }
}


// for adding the new questions to the polls by + option.

class newpoll extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: newpollpage(),
    );
  }
}


class newpollpage extends StatefulWidget{
  @override
  State<newpollpage> createState() => _newpollpage();
}
class _newpollpage extends State<newpollpage>{

  final GlobalKey<FormState> _key = new GlobalKey();
  final ScrollController _totalscrollcontroller= ScrollController();
  TextEditingController questioncontroller = TextEditingController();
  int optionscount=2;
  List textcontrollers= [TextEditingController(),TextEditingController()];
  var datetime ;
  bool isprivate=false;
  bool ismultiple=false;
  bool issingletime=true;

  @override
  initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      dynamiclinkhandler(context);
    });
  }

  @override
  Widget build(BuildContext context){
    return Builder(
      builder: (context)=>Scaffold(
        appBar: AppBar(
          title: const Text("New Poll"),
          leading: IconButton(icon:const Icon(Icons.navigate_before),onPressed: (){Navigator.pop(context);},),
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
                 padding: const EdgeInsets.symmetric(vertical:8,horizontal: 10),
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
                    suffixIcon: const Icon(Icons.question_mark,color: Colors.blue,),
                  ),
                ),
                      //SizedBox(height: 15,),
                      ListView.builder(
                        controller:_totalscrollcontroller ,
                        shrinkWrap: true,
                        itemCount: optionscount ,
                        padding: const EdgeInsets.symmetric(vertical:15),
                        itemBuilder: (context ,i){
                          return
                          Padding(padding: const EdgeInsets.symmetric(vertical: 3),
                              child:
                              TextFormField(
                                maxLength: 30,
                                validator:(v)=>_validateoption(v,textcontrollers),
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
                      ),const Text("only person with link can see the post")]),
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
                ),const Text("allow multiple option selection")]),
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
                            ),const Text("only one vote per user")]),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),minimumSize: Size(100, 40),backgroundColor:Colors.indigo[400] ),
                        onPressed: () async{
                        if(_key.currentState?.validate()==true){await showloadingdilog(context,questioncontroller.text,textcontrollers,DateTime.parse(datetime),ismultiple,isprivate,issingletime);
                        //if (submitvalue){Fluttertoast.showToast(msg: "submitted successfully",backgroundColor: Colors.green,timeInSecForIosWeb: 4);}
                        //else{Fluttertoast.showToast(msg: "something went wrong",backgroundColor: Colors.red,timeInSecForIosWeb: 4);}}
                      }}, child: const Text("Post"),)
                    ])
            )))

      ),
    );
  }

}

class showpost extends StatefulWidget{
  showpost({this.documentid:null,required this.fetchcondition,this.trending:false,this.ended:false,this.optionslengthlarge:false,required this.streamController});
  var documentid; bool trending; bool ended;
  Query fetchcondition; bool optionslengthlarge;
  StreamController streamController;

  @override
  State<showpost> createState() => _showpost();
}
class _showpost extends State<showpost>{
  @override
  Widget build(BuildContext context){
    if(widget.documentid==null){
    return StreamBuilder(
      stream: widget.fetchcondition.snapshots(),
        builder: (context,streamer) {
        if (streamer.hasData){
         streamer.data!.metadata.isFromCache?print("from cache"):print("from internet");
      return Column(
        children: ((streamer.data?.docs.map((items)=>pollpostdesign(context,items.id, items["question"], items["options"],items["like"], items["votes"], items['username'],items["multipleopt"],items['singletime'],items["userid"],widget.trending,widget.ended,items["endtime"],false))))!.toList(),

    );}
        if(!streamer.hasData){return Align(alignment: Alignment.center,child:SizedBox(height:40,width:40,child:CircularProgressIndicator(strokeWidth: 5,)));}
        if(streamer.hasError){
          return const Text("An Error Occured",style:TextStyle(fontWeight: FontWeight.bold,color: Colors.red,fontSize: 20),textAlign:TextAlign.center,);
        }
        else{return const Text("something went wrong",style:TextStyle(fontWeight: FontWeight.bold,color: Colors.red,fontSize: 20),textAlign:TextAlign.center,);}
      });
  }
    else{
      return StreamBuilder(
          stream: FirebaseFirestore.instance.collection("polls").doc(widget.documentid).snapshots(),
          builder: (context,streamer) {

            if (streamer.hasData){
              streamer.data!.metadata.isFromCache?print("from cache"):print("from internet");
              var items=streamer.data!;
              return Column(
                children: [pollpostdesign(context,widget.documentid, items["question"], items["options"], items["like"], items["votes"], items['username'],items["multipleopt"],items['singletime'],items["userid"],false,widget.ended,items["endtime"],widget.optionslengthlarge)]);

              }
            if(!streamer.hasData){return Align(alignment: Alignment.center,child:SizedBox(height:40,width:40,child:CircularProgressIndicator(strokeWidth: 5,)));}
            if(streamer.hasError){
              return const Text("An Error Occured",style:TextStyle(fontWeight: FontWeight.bold,color: Colors.red,fontSize: 20),textAlign:TextAlign.center,);
            }
            else{return const Text("something went wrong",style:TextStyle(fontWeight: FontWeight.bold,color: Colors.red,fontSize: 20),textAlign:TextAlign.center,);}
          });

    }
  }
}
Widget pollpostdesign(BuildContext context,documentid,String question,List options,likes,List votes,username,bool ismultiple,bool singletime,userid,bool trending,bool ended,Timestamp endtime,bool optionslengthlarge) {
  var _isuservoteresponse; String lefttime=endtime.toDate().difference(DateTime.now()).inDays.toString()+" Days";
  bool isoptionslenthlarge= (options.length>4);
  if(endtime.toDate().difference(DateTime.now()).inDays<0){ended=true;}
  if (endtime.toDate().difference(DateTime.now()).inDays==0){
    if(endtime.toDate().difference(DateTime.now()).inHours>0){
      lefttime="${endtime.toDate().difference(DateTime.now()).inHours} Hours";
    }else{lefttime=endtime.toDate().difference(DateTime.now()).inMinutes.toString()+" min";}
  }
  if(optionslengthlarge){
    isoptionslenthlarge=false;
  }
    return InkWell(splashColor:Colors.lightGreenAccent,onTap:(){
    },
    child:Container(
    child:Card(
    margin: EdgeInsets.fromLTRB(15, 10, 15, 10),
    elevation: 5,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child:
      StreamBuilder(
  stream:FirebaseFirestore.instance.collection("users").doc(userid).collection("polls").doc(documentid).snapshots(),
              builder:(context,future){
    if(future.hasData){
      future.data!.metadata.isFromCache?print("from cache"):print("from internet");
      int votecount= votes.reduce((value, element) => value+element);
      _isuservoteresponse=List.generate(options.length, (index) => false);
      bool isliked=false;
      bool isfieldavailable=false;
      if(future.data?.data()  !=null){
        if(future.data?.data()?.containsKey("response")==true){
          isfieldavailable=true;
      _isuservoteresponse=future.data!["response"];}
      if(future.data?.data()?.containsKey("like")==true){
        isfieldavailable=true;
        isliked=future.data!["like"];
      }}
      bool _isuservoted=_isuservoteresponse.contains(true);
      return Stack(
        clipBehavior: Clip.none,
        children:[
      trending?Positioned(
          top:-20,child: Card(elevation: 6,
        //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(height: 35,width: 80,alignment: Alignment.topRight,
          decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.redAccent,Colors.amber],begin: Alignment.topLeft,end: Alignment.bottomRight))
          ,child: Center(child:Text("Trending",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),),),)):const Text(""),
              Column(
              children: [


                Padding(padding:EdgeInsets.fromLTRB(20, 10, 10, 10),
                    child:Row(  children: [CircleAvatar(radius: 20,foregroundImage: NetworkImage("https://thumbs.dreamstime.com/b/girl-vector-icon-elements-mobile-concept-web-apps-thin-line-icons-website-design-development-app-premium-pack-glyph-flat-148592081.jpg"),),SizedBox(width: 5,),Text(username,style: TextStyle(color: Colors.black54),),Spacer(),popupmenu(context, documentid)],)),

                Padding(padding:EdgeInsets.fromLTRB(10, 1, 10, 15),child:forlargequestions(context,question)),
                Column(
                    children: !isoptionslenthlarge?options.asMap().entries.map((items)=>optionforquestion(documentid,items.value,ismultiple,items.key,_isuservoteresponse!,singletime,options.length,votes,votecount,_isuservoted,ended,isfieldavailable)).toList():[largeoptioncontainer(context,documentid)]
                ),
                SizedBox(height: 3,),
                Row(children:[OutlinedButton(style:OutlinedButton.styleFrom(side:BorderSide(color: Colors.white),shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),onPressed: (){newonlikepress(documentid, isliked, userid, "polls",_isuservoted);}, child: Column(children:[Icon(isliked?Icons.favorite:Icons.favorite_border_outlined,color: isliked?Colors.red:Colors.black,),Text(likes.toString()+" likes",style: TextStyle(color: Colors.black),)])), IconButton(onPressed: ()async{
                  var linkresult=await firebasedynamiclink("polls",documentid );
                  if (linkresult!=false || linkresult!="out"){
                    Share.share("express your opnion to the poll "+linkresult.toString());
                  }
                  else{Fluttertoast.showToast(msg: "unable to generate link",backgroundColor: Colors.red,timeInSecForIosWeb: 3);}
                }, icon:Icon(Icons.share)),SizedBox(width: 10,),ended?Text("Final Results",style: TextStyle(color: Colors.black54),):Text("Ends in:"+lefttime,style: TextStyle(color: Colors.black54),),SizedBox(width: 15,),Text("votes : "+votecount.toString(),style: TextStyle(color: Colors.black54),)
                ])
              ],
                  )]);}
    else if (future.hasData==false){
      return  Container(constraints: BoxConstraints(minHeight:200 ),child:Center(child: CircularProgressIndicator(),)
      );
    }

    else{return Text("An error Occured",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red),);}
  }))));}

class individualpoll extends StatelessWidget{
  individualpoll(this.documentid,this.optionslengthlarge);
  var documentid; bool optionslengthlarge;
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: individualpollpage(documentid,optionslengthlarge),
    );
  }
}

class individualpollpage extends StatefulWidget{
  individualpollpage(this.documentid,this.optionslengthlarge);
  var documentid; bool optionslengthlarge;
  @override
  State<individualpollpage> createState() => _individualpollpage();
}
class _individualpollpage extends State<individualpollpage>{
  StreamController _streamController =StreamController();

  @override
  void initState() {
    // TODO: implement initState
    dynamiclinkhandler(context);
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
  return Builder(
      builder:(context)=>Scaffold(
        appBar: AppBar(title: Text("Poll"),
          backgroundColor:Colors.indigo[400],
          foregroundColor: Colors.white,
        leading: IconButton(onPressed: (){Navigator.of(context).push(MaterialPageRoute(builder: (context)=> votingpage()));}, icon: Icon(Icons.arrow_back)),),
        body: SingleChildScrollView(child: showpost(documentid: widget.documentid,fetchcondition: FirebaseFirestore.instance.collection("polls"),optionslengthlarge: true,streamController: _streamController,),),
      )
      );}
}

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

String? _validateoption(String? value,List controllers){

  List optionstext=[];
  List _optionstext=[];
  controllers.forEach((element) {if(optionstext.contains(element.text)){_optionstext.add(true);}
  else{optionstext.add(element.text);}});
  if (value?.length==0){
    return "* Required Field";
  }
  if(value?.length!=0 && _optionstext.contains(true)){
    return "One or more options contains same value";
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
              return
              Lottie.asset("assets/lottiefiles/92864-loading-animation.json",
              animate: true,
              height: 90,
              addRepaintBoundary: false,
              reverse: true,
              repeat: true,);
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

Widget largeoptioncontainer(BuildContext context ,documentid){
  return Padding(padding:const EdgeInsets.symmetric(vertical: 5,horizontal: 10) ,
      child:Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15),color: Colors.grey),

        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
          child:Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:[
             Container(child:const Text("This question contains too many options if you want to see click on view"),width: 180,),
            TextButton(onPressed: (){Navigator.of(context).push(MaterialPageRoute(builder: (context)=>individualpoll(documentid,true)));}, child: const Text("View",style: TextStyle(color: Colors.blue,),))
          ]
        ),
      ))
  );
}

Widget forlargequestions(BuildContext context,String question) {
  if (question.length>80){
    return RichText(text: TextSpan(
      style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
      text: question.substring(0,80)+"...",
      children: [
        TextSpan(text: "Readmore",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),
        recognizer:TapGestureRecognizer()..onTap=()=>
        showDialog(context: context, builder: (_)=>Dialog(
          elevation: 5,
          child:Container(
            width: 150,
            constraints: BoxConstraints(maxHeight: 450),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: SingleChildScrollView(padding: EdgeInsets.symmetric(horizontal: 10),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text("Question",style: TextStyle(fontWeight: FontWeight.bold),),IconButton(onPressed: (){Navigator.of(context,rootNavigator: true).pop();}, icon: Icon(Icons.close,color: Colors.black,))],),
              SizedBox(height: 5,),
              Text(question)
            ],)),
          ) ,
        )))
      ]
    ));
  }
  else{return Text(question,softWrap: true,style: TextStyle(fontWeight: FontWeight.bold),);}
}

// ReadMoreText(question,trimLines: 3,
// colorClickableText: Colors.blue,
// trimMode: TrimMode.Line,
// trimCollapsedText: '..Read More',
// style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
// trimExpandedText: ' Less',)
