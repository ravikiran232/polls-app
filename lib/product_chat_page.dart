import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:login/my_polls.dart';
import 'firebase_options.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sqflite/sqflite.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:show_more_text_popup/show_more_text_popup.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sql_conn/sql_conn.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:read_more_text/read_more_text.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:colours/colours.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_database/firebase_database.dart';
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

class Chatt extends StatelessWidget{
  Chatt({required this.documentid});
  String documentid;
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home:Chatpage(documentid: documentid,)
    );
  }
}




class Chatpage extends StatefulWidget{
  Chatpage({required this.documentid});
  String documentid;
  @override
  State<Chatpage> createState()=> _Chatpage(documentid: documentid);
}

class _Chatpage extends State<Chatpage> with WidgetsBindingObserver{
  _Chatpage({required this.documentid});
  String documentid;
  List<types.Message> _messages = [];
  bool _islaoding =false;
  String uid = FirebaseAuth.instance.currentUser!.uid;
  final _user = types.User(id: FirebaseAuth.instance.currentUser!.uid);
  DatabaseReference ref = FirebaseDatabase.instance.ref("buyandsellmessages/");
  String status="offline";
  late StreamSubscription rd;
  late StreamSubscription notification;
  late StreamSubscription typing;
  late StreamSubscription statusstream;

  @override
  void dispose(){
    rd.cancel();
    notification.cancel();
    statusstream.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState,){
    super.didChangeAppLifecycleState(lifecycleState);
    if(lifecycleState!=AppLifecycleState.resumed){
      if(!(rd.isPaused)){
        // userstatus("offline");
         rd.pause();
         print(rd.isPaused);
      }
    }
    if(lifecycleState==AppLifecycleState.resumed){
      if(rd.isPaused){
        rd.resume();
        print(rd.isPaused);
        // userstatus("online");
      }
    }

  }
  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);
   notification= FirebaseMessaging.onMessage.listen((RemoteMessage message) async{
      // await Firebase.initializeApp();
      // await FirebaseDatabase.instance.ref('buyandsellmessages/123456789/latsmessage/${message.data["id"]}/status').set("delivered");
      print("hi foreground");
    });
    rd=ref.child("$documentid/latsmessage").orderByChild("/createdAt").onValue.listen((event) async {
      if (event.snapshot.exists){
        final map =event.snapshot.value as Map;
        for (var value in map.entries){
          if ((value.value["author"] != uid) & (value.value["status"]!="read" )){
            setState(() {
              _messages.insert(0, types.TextMessage(id: value.key,author: types.User(id:value.value["author"]),createdAt: value.value["createdAt"],text: value.value["text"]));
            });
            await ref.child("$documentid/latsmessage/${value.key}/").update({"status":"read"});
            await ref.child("$documentid/messages/${value.key}/").update({"status":"read"});

          }
          if(value.value["author"] == uid){
            var index=null;
            var updatedMessage;
            if(value.value["status"]=="delivered"){
              try{
              index =
              _messages.indexWhere((element) => element.id == value.key);
              updatedMessage =
              (_messages[index] as types.TextMessage).copyWith(status: types.Status.delivered);} on Exception catch(err){}}
            if (value.value["status"]=="read"){
              try{
              index =
              _messages.indexWhere((element) => element.id == value.key);
              updatedMessage =
              (_messages[index] as types.TextMessage).copyWith(status: types.Status.seen);} on Exception catch(rr){};
              await ref.child("$documentid/latsmessage/${value.key}").remove();
            }
            if(index!=null){setState(() {
              _messages[index]= updatedMessage;
            });}
          }
        }
      }
      await updatingmessages(jsonEncode(_messages));
    });
    statusstream=FirebaseFirestore.instance.collection("Anonymouschat").doc("123456789").snapshots().listen((event) {
      if(event.exists){
        for (var value in event.data()!.entries){
          if(value.key!=uid){
            setState(() {
              status=value.value;
            });
          }
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_)async{
      List<types.Message> dummymessagevariable= await loadingmessages();
      if (dummymessagevariable.isEmpty){
        await ref.child("$documentid/messages").get().then((value) async{if (value.exists){
          setState(() {
            _messages.addAll(decodingdata(value.value));
            _islaoding=false;
            print("data accessed from server");
          });
          await updatingmessages(jsonEncode(_messages));
        }});
      }
      if (dummymessagevariable.isNotEmpty){
      setState(() {
        _messages.addAll(dummymessagevariable);
        _islaoding=false;
        print("data accessed from sql");
      });}
    });
        super.initState();
  }

  // @override
  // void dispose() async{
  //   await updatingmessages(jsonEncode(_messages));
  //   super.dispose();
  // }

  addmessages(message){
    setState(() {
      _messages.insert(0, message);
    });
  }

  onsendpressedfunction(types.PartialText message) async{
    int time = DateTime.now().millisecondsSinceEpoch;
    String id= const Uuid().v4();
    final textmessage=types.TextMessage(
        createdAt: time,
        author: _user,
        text: message.text,
      id: id,
      status: types.Status.sent
    );
    addmessages(textmessage);
    Map<String,dynamic> data ={
      "createdAt":time,
      "author":FirebaseAuth.instance.currentUser!.uid,
      "text":message.text,
      "id": id,
      "status":"sent"
    };
    await ref.child("$documentid/latsmessage/${id}").update(data);
    await ref.child("$documentid/messages/${id}").update(data);
    await updatingmessages(jsonEncode(_messages));
  }

  Widget bubble(Widget child,{required types.Message message, required bool nextMessageInGroup }){

    return ChatBubble(
      backGroundColor: message.author==_user?Colors.blue[150]:Colors.grey[100],
      alignment: message.author==_user?Alignment.topRight:Alignment.topLeft,
      padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 0),
      clipper: message.author==_user?(nextMessageInGroup?ChatBubbleClipper5(type: BubbleType.sendBubble):ChatBubbleClipper1(type: BubbleType.sendBubble)):
      (nextMessageInGroup?ChatBubbleClipper5(type: BubbleType.receiverBubble):ChatBubbleClipper1(type: BubbleType.receiverBubble)),
      child: child,
    );

  }

  // Widget custommessage(types.CustomMessage message,{required int messageWidth}){
  //   return Text(${message.)
  // }

  @override
  Widget build(BuildContext context){
    return Builder(builder: (context)=> Scaffold(
      appBar: AppBar(backgroundColor: Colors.indigo[300],
        leadingWidth: 200,
        leading: Row(children: [
        IconButton(onPressed: (){Navigator.of(context,rootNavigator: true).pop();}, icon: const Icon(Icons.arrow_back,color: Colors.white,),),
        const CircleAvatar(radius: 20,backgroundImage: AssetImage("assets/images/default_avatar.jpg"),),
        const SizedBox(width:10),
        Column(mainAxisAlignment: MainAxisAlignment.center,
            children:[const Text("Ravi",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 20),),Text(status,style: const TextStyle(fontSize: 12,fontStyle: FontStyle.italic),)])
      ],
        ),
      actions: [IconButton(onPressed: (){}, icon: const Icon(Icons.menu,color: Colors.white,))],),
      body: Stack(children:[
        Container(height: MediaQuery.of(context).size.height,width: double.infinity,decoration: const BoxDecoration(image: DecorationImage(fit: BoxFit.fill,image: AssetImage("assets/images/wp4410721-chat-wallpapers.jpg"))),),
        Chat(

        messages: _messages, onSendPressed:onsendpressedfunction, user: _user,
        bubbleBuilder: bubble ,
        theme: DefaultChatTheme(backgroundColor: Colors.transparent,inputMargin: EdgeInsets.only(bottom: 2,left: 5,right: 5),sentEmojiMessageTextStyle: TextStyle(fontSize:20),
        inputBorderRadius: BorderRadius.circular(20))
      ),
      _islaoding? Container(
        height: MediaQuery.of(context).size.height,
          width: double.infinity,
          alignment: Alignment.center,color: Colors.transparent,child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:const [CircularProgressIndicator(),
            Text("messages are syncing",style: TextStyle(color: Colors.white,fontSize: 7),)])):SizedBox.shrink()
      ]
      )
      )
    );
  }
}


loading(BuildContext context){
  return showDialog(context: context, builder: (_)=>
      Container(alignment: Alignment.center,color: Colors.transparent,child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
          children:const [CircularProgressIndicator(),
          Text("messages are syncing",style: TextStyle(color: Colors.white,fontSize: 7),)])));
}