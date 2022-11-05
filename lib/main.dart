
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:page_transition/page_transition.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'email_verify.dart';
import 'confession_posts.dart';
import 'posts_page.dart';
import 'newpost_page.dart';
import 'voting_page.dart';

void main() async {

  runApp(votingpage());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

errormessage (_color,text,c,{duration =2}){
  return ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(text),
    duration: Duration(seconds: duration),
    backgroundColor: _color,)
  );
}

popupmenu (c,id){
  return PopupMenuButton(
    // add icon, by default "3 dot" icon
    // icon: Icon(Icons.book)
      itemBuilder: (context){
        return [
         const PopupMenuItem<int>(
            value: 0,
            child: Text("Report"),
          ),

          const PopupMenuItem<int>(
            value: 1,
            child: Text("contact us"),
          ),

        ];
      },
      onSelected:(value) async{
        if(value == 0){
          showDialog<String>(
            context: c,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Report This Post'),
              content: const Text('Click ok to report this post'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(c,rootNavigator: true).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async{
                    try{await FirebaseFirestore.instance.collection("posts").doc(id).update({"report":FieldValue.increment(1)});
                    errormessage(Colors.green, "submitted successfully", c);
                    Future.delayed(Duration(seconds:1 ));
                    Navigator.of(c,rootNavigator: true).pop();} on Exception catch(e){errormessage(Colors.red, "something went wrong", c);}
                  },
                  child: const Text('OK'),
                ),
              ],
            )
          );
        }else if(value == 1){
          var url = Uri.parse("mailto:secretsapp@gmail.com?subject=postid:"+id+"&body=");
          try{
            await launchUrl(url);
          }on Exception catch(e){
            throw "something went wrong";
          }
        }
      }
  );
}

class Mysplash extends StatelessWidget{
  const Mysplash({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Splash Screen',
      home: spalshscreen()
    );
  }
}


class  spalshscreen  extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return AnimatedSplashScreen(splash: Text("Secrets",style: TextStyle(fontSize: 55,fontStyle: FontStyle.italic,color: Colors.white,fontWeight: FontWeight.w800),), backgroundColor: Colors.blueAccent,
      nextScreen: Mylogin() ,duration: 4000,);
  }
}




















