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
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:readmore/readmore.dart';
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
  bool _value=false;
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home:DefaultTabController(
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
              setState(() {
                isslidingopened=true;
              });
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
          children: [
            Column(
                children:[InkWell(splashColor:Colors.lightGreenAccent,onTap:(){
                  },
                    child:Container(height:400,
                child:Card(
              margin: EdgeInsets.fromLTRB(15, 10, 15, 10),
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child:
              Column(
                  children:[
                    Padding(padding:EdgeInsets.fromLTRB(20, 20, 10, 20),
                        child:Row(  children: [CircleAvatar(radius: 20,foregroundImage: NetworkImage("https://thumbs.dreamstime.com/b/girl-vector-icon-elements-mobile-concept-web-apps-thin-line-icons-website-design-development-app-premium-pack-glyph-flat-148592081.jpg"),),SizedBox(width: 5,),Text("user3467",style: TextStyle(color: Colors.black54),)],)),
                    Padding(padding:EdgeInsets.fromLTRB(10, 15, 10, 15),child:const ReadMoreText("""Hi, this is the sample question of polling post in which users can cast the vote anonymously. Thank you,hi, this is the sample question of polling post in which users can cast the vote anonymously. Thank you""",trimLines: 3,
                      colorClickableText: Colors.blue,
                      trimMode: TrimMode.Line,
                      trimCollapsedText: '..Read More',
                      style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
                      trimExpandedText: ' Less',),),
                    Container(
                      height: 50,
                      margin: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(shape: BoxShape.rectangle,borderRadius: BorderRadius.circular(20),border: Border.all(color: Colors.black54),color: _value?Colors.lightBlue:Colors.white),
                      child: Row(children: [Center(child:Row(children:[Checkbox(value: _value, onChanged:(newvalue){
                        setState(() {
                          _value=!_value;
                        });
                      }),Text("hi,this for yes option")]))],),
                    )
                  ]
            ))))]),
            Icon(Icons.timelapse,size:40),
            Icon(Icons.timelapse,size:40)
          ],
        ),
      )
      ),
      );

  }
}


sliding_panel(controller){
  PanelState panel_value=PanelState.OPEN;
  

  return SlidingUpPanel(
      backdropEnabled: true,
      minHeight: 0,
      borderRadius: BorderRadius.circular(30),
      margin: EdgeInsets.only(left: 10,right: 10),
      maxHeight: 550,
      defaultPanelState: panel_value,
    onPanelClosed: (){
        panel_value=PanelState.CLOSED;
    },
    panel: TabBar(
      controller: controller,
        padding: EdgeInsets.symmetric(horizontal: 20),
        isScrollable: false,
        indicator: BoxDecoration(borderRadius:BorderRadius.circular(20),shape: BoxShape.rectangle,color: Colors.blue),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.blue,
        tabs:const [
          Tab(text: "question",icon: Icon(Icons.question_answer,color:Colors.white ,),),
          Tab(text:"analysis",icon: Icon(Icons.analytics,color: Colors.white,),)
        ] ),
    body: TabBarView(
      controller: controller,
      children: [
        Icon(Icons.poll_sharp,size: 50,),
        Icon(Icons.pie_chart_rounded,size: 20,)
      ],
    ),


  );
}
