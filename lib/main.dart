
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

void main() async {

  runApp(Mysplash());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

errormessage (_color,text,c){
  return ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(text),
    duration: Duration(seconds: 2),
    backgroundColor: _color,)
  );
}

popupmenu (c,id){
  return PopupMenuButton(
    // add icon, by default "3 dot" icon
    // icon: Icon(Icons.book)
      itemBuilder: (context){
        return [
          PopupMenuItem<int>(
            value: 0,
            child: Text("Report"),
          ),

          PopupMenuItem<int>(
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

class MyApp1 extends StatelessWidget {
  const MyApp1({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'Welcome to Flutter',
      theme: ThemeData(          // Add the 5 lines from here...
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      home: const MyApp(),
    );
  }
}

class Myapp2 extends StatelessWidget {
  const Myapp2({super.key});




  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'Welcome to Flutter',
      theme: ThemeData(          // Add the 5 lines from here...
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      home: Scaffold(appBar: AppBar(title:Text('welcome')),body:ElevatedButton(onPressed: (){
        FirebaseAuth.instance.signOut();
        Navigator.push(context, MaterialPageRoute(builder: (context) => const Myhome()));
      }, child: Text('signout')),),
    );
  }
}


class Myhome extends StatelessWidget {
  const Myhome({super.key});




  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'Welcome to Flutter',
      theme: ThemeData(// Add the 5 lines from here...
        appBarTheme: const AppBarTheme(
          elevation: 10,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MySignup extends StatelessWidget {
  const MySignup({super.key});




  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'Welcome to Flutter',
      theme: ThemeData(          // Add the 5 lines from here...
        appBarTheme: const AppBarTheme(
          elevation: 10,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      home: Signup(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar (
      title: const Text("home page"),
      ),
      body:Padding(
          padding: const EdgeInsets.all(100),
        child: Column(
          children:[
            Text("awaiting for confirmation of email address"),
      ElevatedButton(onPressed: (){
        FirebaseAuth.instance.signOut();
        Navigator.push(context, MaterialPageRoute(builder: (context) => const Myhome()));
      }, child: Text('signout')),
            ElevatedButton(onPressed: () async{final user= await FirebaseAuth.instance.currentUser; await user?.sendEmailVerification();}, child: Text("resend verification link")),
            ElevatedButton(onPressed: (){final user=FirebaseAuth.instance.currentUser;final c= user?.emailVerified; print(c);if (c==true){Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> const Myapp2()));}else{ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("email not verified"),duration: Duration(seconds:10 ),backgroundColor: Colors.red,)
            );}}, child: Text("chech status")),
      ],
      ),
    ),);
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordcontroller= TextEditingController();
  bool isloading=false , _obscure=true;

  @override
  initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      FirebaseAuth.instance
          .authStateChanges()
          .listen((User? user) {
        if (user != null) { if (user.emailVerified){
          Navigator.pushReplacement(context,MaterialPageRoute(builder:(context)=> Mypage()));} else{
          Navigator.pushReplacement(context,MaterialPageRoute(builder:(context)=>const Emailverify()));
        }
        }
        else {
          print("please login to countinue");
        }
      });

    });}

  Future<String> firebase_usersignin() async {
    var  result;
    try{
      final user=await FirebaseAuth.instance.signInWithEmailAndPassword(email:emailController.text , password: passwordcontroller.text);
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


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          foregroundColor:Colors.white ,
          title:Text("Secrets"),
          titleTextStyle: TextStyle(fontStyle: (FontStyle.italic ),fontWeight: FontWeight.w500,fontSize:40 ),
          titleSpacing: 110,
          toolbarHeight: height*0.35,
          toolbarOpacity: 0.1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.elliptical(width, 100),
            )
          ),
        ),
      body:SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            SizedBox(height: 30,),
            Text('Login',style: TextStyle(fontSize:25,fontWeight: FontWeight.bold ),textAlign: TextAlign.left,),
            SizedBox(height: 40,),
            TextField(
                  controller: emailController,
                  //onChanged: ((v) {emailController.text=v;}),
                  decoration: InputDecoration(
                    suffixIcon: const Icon(Icons.email_outlined,color: Colors.blue,),
                    labelText: "Email",
                    hintText: 'Enter your university Provided Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),gapPadding: 4),
                  ),
                ),
            SizedBox(height: 20,),
            TextField(
              obscureText: _obscure ,
                  controller: passwordcontroller,
                 // onChanged: ((v)  { if ( (v.length>=8) & ( v.contains("1") | v.contains("2") | v.contains("3") | v.contains("4") )){passwordcontroller.text=v;}else{
   // print('please include numbers and make sure your password is atleast 8 letters');}}) ,
                  decoration:  InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter Your Password',
                    suffixIcon: IconButton(onPressed: () {setState(() {
                      if (_obscure) {
                        _obscure=false;
                      }else{_obscure=true;}
                    });}, icon:Icon(_obscure?Icons.visibility:Icons.visibility_off)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),gapPadding: 4),
                  ),
                ),
            SizedBox(height: 25,),
            Builder(builder: (BuildContext context){
              return(
                  Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0) ,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  !isloading?ElevatedButton(onPressed:() async{
              setState(() {
                isloading = true;
              });
              final a = await firebase_usersignin();
              final user1=FirebaseAuth.instance.currentUser;
              var user2= user1?.emailVerified;
              print(a);

              setState(() {
                isloading=false;
                //isloading=!isloading;
              });
              if (a=="successful") {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(a),duration: Duration(seconds:10 ),backgroundColor: Colors.green,)
              );
                if (user2==true){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Mypage()));}
                else{Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Emailverify()));}
                }
              //Navigator.push(context,  MaterialPageRoute(builder: (context) => const MyApp1()));
              else{
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(a),duration: Duration(seconds:10 ),backgroundColor: Colors.red,)
                );
              }
            },child: const Text("Login",style:TextStyle(fontSize:20,fontWeight: FontWeight.w500,fontStyle: FontStyle.italic),),style: ButtonStyle(shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)))),
            ): Center(child: CircularProgressIndicator(),),
                  GestureDetector(child:Text("Forgot Password?"),onTap: () async {var _result;ShowMoreTextPopup(context,text:"enter your email in email box and click forgot password",backgroundColor: Colors.lightBlueAccent,height: 100);try{await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text);_result="successfully sent password reset email";}on FirebaseException catch(e){_result=e.code;}on Exception catch(e){_result=e.toString();} if(_result!="successfully sent password reset email") {ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_result),duration: Duration(seconds:10 ),backgroundColor: Colors.red,)
                  );}else{ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_result),duration: Duration(seconds:10 ),backgroundColor: Colors.green,)
                  );}},)
                ],
            ),
              )
              );
            }
            ),
            SizedBox(height: 30,),
            Builder(builder: (BuildContext context){
              return(Padding(padding:EdgeInsets.symmetric(horizontal: 20),
              child:GestureDetector(child:Text("Don\'t have a account? signup"),onTap: (){Navigator.push(context,MaterialPageRoute(builder: (context)=>  MySignup()));})));
            }),
          ],
        ),
      ),

    ),);
  }

}

class  spalshscreen  extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return AnimatedSplashScreen(splash: Text("Secrets",style: TextStyle(fontSize: 55,fontStyle: FontStyle.italic,color: Colors.white,fontWeight: FontWeight.w800),), backgroundColor: Colors.blueAccent,
      nextScreen: Myhome() ,duration: 4000,);
  }
}


class Signup extends StatefulWidget{
  @override
  State<Signup> createState() => _Mysignup();
}

class _Mysignup extends State<Signup>{
  TextEditingController nameController = TextEditingController();
  TextEditingController emaildomainController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordcontroller= TextEditingController();
  TextEditingController passwordrecheckcontroller= TextEditingController();
  bool isloading=false , _obscure=true;
  String _value="iitk.ac.in";
  String g_value="Female";
  List<String> gitems =["Female","Male"];
  List<String> items =["iitk.ac.in","iitkgp.ac.in"];
  final GlobalKey<FormFieldState> formField= GlobalKey();
  final GlobalKey<FormFieldState> formField1= GlobalKey();
  final GlobalKey<FormFieldState> formField2= GlobalKey();

  Future<String> firebase_usersignup() async {
    var  result;
    try{
      final user=await FirebaseAuth.instance.createUserWithEmailAndPassword(email:emailController.text , password: passwordcontroller.text);
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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var error;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          foregroundColor:Colors.white ,
          title:Text("Secrets"),
          titleTextStyle: TextStyle(fontStyle: (FontStyle.italic ),fontWeight: FontWeight.w500,fontSize:40 ),
          titleSpacing: 110,
          toolbarHeight: height*0.2,
          toolbarOpacity: 0.1,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.elliptical(width, 100),
              )
          ),
        ),
        body:SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child:Column(

            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 30,),
              Text('Signup',style: TextStyle(fontSize:25,fontWeight: FontWeight.bold ),textAlign: TextAlign.left,),
              SizedBox(height: 40,),
              TextFormField(
                controller: nameController,
                //onChanged: ((v) {emailController.text=v;}),
                validator: (v){ if(v==null || v?.isEmpty==true){return "field is required";}
 return null;},
                decoration: InputDecoration(
                  suffixIcon: const Icon(Icons.person,color: Colors.blue,),
                  labelText: "username",
                  errorText: error!=null?error:null,
                  hintText: 'please enter your username',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),gapPadding: 4),
                ),
              ),
              SizedBox(height: 20,),
              DropdownButtonFormField(items: items.map((values){return DropdownMenuItem(value:values,child:Text(values));}).toList() , onChanged:(String? new_value){
                setState(() {
                  _value=new_value!;
                });
              },value:_value,hint:Text("university Email domain"),borderRadius:(BorderRadius.circular(20.0)) ,decoration:InputDecoration(labelText:"University Domain",border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),suffixIcon: Icon(Icons.school_outlined,color: Colors.blue,) ,)),
              SizedBox(height: 20,),
              DropdownButtonFormField(items: gitems.map((values){return DropdownMenuItem(value:values,child:Text(values));}).toList() , onChanged:(String? new_value){
                setState(() {
                  g_value=new_value!;
                });
              },value:g_value,hint:Text("Gender"),borderRadius:(BorderRadius.circular(20.0)) ,decoration:InputDecoration(labelText:"Gender",border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),suffixIcon: Icon(Icons.boy,color: Colors.blue,) ,)),
              SizedBox(height:20),
              TextFormField(
                controller: emailController,
                //onChanged: ((v) {emailController.text=v;}),
                validator: (v){if(v==null || v?.isEmpty==true){return "This field is required";}if(v!=null && v?.contains(_value)==false ){return "your email should be in the format abcd@"+_value;}
return null;},
                decoration: InputDecoration(
                  suffixIcon: const Icon(Icons.email_outlined,color: Colors.blue,),
                  labelText: "Email",
                  hintText: 'Enter your university Provided Email',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),gapPadding: 4),
                ),
              ),
              SizedBox(height: 20,),
              TextField(
                obscureText: _obscure ,
                controller: passwordcontroller,
                // onChanged: ((v)  { if ( (v.length>=8) & ( v.contains("1") | v.contains("2") | v.contains("3") | v.contains("4") )){passwordcontroller.text=v;}else{
                // print('please include numbers and make sure your password is atleast 8 letters');}}) ,
                decoration:  InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter Your Password',
                  suffixIcon: IconButton(onPressed: () {setState(() {
                    if (_obscure) {
                      _obscure=false;
                    }else{_obscure=true;}
                  });}, icon:Icon(_obscure?Icons.visibility:Icons.visibility_off)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),gapPadding: 4),
                ),
              ),
              SizedBox(height: 25,),
              Builder(builder: (BuildContext context){
                return(
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0) ,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          !isloading?ElevatedButton(onPressed:() async{
                            var a;
                            var user2;
                            print(formField.currentState?.validate());
                            if( formField.currentState?.validate()!=null && formField.currentState?.validate()==false ){a="please check the errors";print(a);}
                            //if( formField1.currentState?.validate()!=null && formField1.currentState?.validate()==false ){a="some errors in your inputs";print(a);}
                            else{
                            setState(() {
                              isloading = true;
                            });
                            a = await firebase_usersignup();
                            final user1=FirebaseAuth.instance.currentUser;
                            user2= user1?.emailVerified;
                            user1?.updateDisplayName(nameController.text);
                            await FirebaseFirestore.instance.collection("users").doc(user1?.uid).set({"college":_value,"gender":g_value});
                            print(a);

                            setState(() {
                              isloading=false;
                              //isloading=!isloading;
                            });}
                            if (a=="successful") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(a),duration: Duration(seconds:10 ),backgroundColor: Colors.green,)
                              );
                              if (user2==true){
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  Mypage()));}
                              else{Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Emailverify()));}
                            }
                            //Navigator.push(context,  MaterialPageRoute(builder: (context) => const MyApp1()));
                            else{
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(a),duration: Duration(seconds:10 ),backgroundColor: Colors.red,)
                              );
                            }
                          },child: const Text("Signup",style:TextStyle(fontSize:20,fontWeight: FontWeight.w500,fontStyle: FontStyle.italic),),style: ButtonStyle(shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)))),
                          ): Center(child: CircularProgressIndicator(),),
                          GestureDetector(child:Text("Already have a account login?"),onTap: ()  { Navigator.push(context , MaterialPageRoute(builder: (context)=> const Myhome()));
                          },)
                        ],
                      ),
                    )
                );
              }
              ),
            ],
          ),
          ),

      ),);
  }
}

class Emailverify extends StatelessWidget {
  const Emailverify({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return MaterialApp(
      theme: ThemeData(
        backgroundColor: Colors.black,
      ),
      home: Scaffold(
        backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.lightBlue,
        foregroundColor:Colors.white ,
        title:Text("Secrets"),
        titleTextStyle: TextStyle(fontStyle: (FontStyle.italic ),fontWeight: FontWeight.w500,fontSize:40 ),
        titleSpacing: 110,
        toolbarHeight: height*0.4,
        toolbarOpacity: 0.1,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.elliptical(width, 100),
            )
        ),
      ),
      body:Center(
        child: Column(
          children: [
                  SizedBox(height: 40,),
                  Text("Your email was not verified yet ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,color: Colors.black),),
                  SizedBox(height: 30,),
    Icon(Icons.error,color:Colors.red,size: 100,),
    Builder(builder: (BuildContext context){
    return( SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column (
            children:[
              Text("if you done with your email verification, click on check status",textAlign: TextAlign.left,style: TextStyle(color: Colors.black),),
              SizedBox(height: 20,),
              ElevatedButton(onPressed: () {
                   FirebaseAuth.instance.signOut();
                   Navigator.push(context,
                       MaterialPageRoute(builder: (context) => const Myhome()));
                  }, child: Text('signout')),
                  SizedBox(height: 20),
                  ElevatedButton(style:ElevatedButton.styleFrom(backgroundColor: Colors.white,foregroundColor: Colors.black54 ),onPressed: () async {
                    final user = await FirebaseAuth.instance.currentUser;
                    await user?.sendEmailVerification();
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("successfully sent"),
                          duration: Duration(seconds: 10),
                          backgroundColor: Colors.green,)
                    );
                  }, child: Text("resend verification link"),),
                  SizedBox(height: 20),
                  ElevatedButton(style:ElevatedButton.styleFrom(backgroundColor: Colors.white,foregroundColor: Colors.black54 ),onPressed: () {
                    final user = FirebaseAuth.instance.currentUser;
                    final c = user?.emailVerified;
                    print(c);
                    if (c == true) {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) =>  Mypage()));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("email not verified"),
                            duration: Duration(seconds: 10),
                            backgroundColor: Colors.red,)
                      );
                    }
                  }, child: Text("chech status")),
          ],), ));},
        ),
      ],
        ),
      ),));
  }}


class Mypage extends StatefulWidget{
  @override
  State<Mypage> createState() => _Mypage();
}
class _Mypage extends State<Mypage>{
  final user=  FirebaseAuth.instance.currentUser;
  var _college;
  Future<String> college() async{

    await FirebaseFirestore.instance.collection("users").doc(user?.uid).get().then((item)=> _college=item['college']);
    return "ok";
  }

  @override
  Widget build(BuildContext context){
    if (_college==null){
     college();
    print(_college);}
  //print (_college);
    return MaterialApp(

      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          title: Text("confessions"),
        ),
        body:
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),side: BorderSide(color: Colors.amberAccent)),
                elevation: 15,
                shadowColor: Colors.grey.withOpacity(0.6),
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
                      SizedBox(height: 15,),
                      Icon(Icons.comment,color: Colors.blue,size: 20,),
                      SizedBox(width: 2,),
                      Text(  future.data!.docs[i].get('comments').toString()),
                      SizedBox(width: 20,),
                      Icon(Icons.favorite_border_outlined,color: Colors.red,size: 20,),
                      SizedBox(width: 2,),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: FloatingActionButton(backgroundColor: Colors.blue,elevation: 3,child: Icon(Icons.add),onPressed: (){Navigator.of(context).push(MaterialPageRoute(builder: (context)=> newpostpage(college:_college)));},),
      ));
  }
}

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
            //          return
            // ListView.separated(
            //   shrinkWrap: true,
            // padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
            // itemCount: future.data!.docs.length,
            // separatorBuilder: (context, index) {
            // return Divider(thickness: 1,);
            // },
            // itemBuilder: (context,i) {
            // //sql_query_connect();
            // //if (i.isOdd){return const Divider();}
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
                        } on FirebaseException catch(e) {ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("something went wrong"),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.red,)
                        ); } on Exception catch(e){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("something went wrong"),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.red,)
                        );}
                        setState(() {
                          isloading=false;
                          commentController.text="";
                        });},):CircularProgressIndicator(strokeWidth: 2,),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),gapPadding: 4)),),
                  ]
              ),
              ),
      )
        );


  }
}

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
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("successfully Posted"),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.green,)
                  );
                  Future.delayed(Duration(seconds: 2));
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Mypage()));
                  } on Exception catch (e) {ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("something went wrong"),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.red,)
                  );}

                }
              }, child: Text("Post"),style: ElevatedButton.styleFrom(backgroundColor:Colors.blue,foregroundColor: Colors.white,minimumSize: Size(100,30)),);})
            ],
          ),
        )
      ),
    );
  }

}

class votingpage extends StatefulWidget{
  @override
  State<votingpage> createState() => _votingpage();
}
class _votingpage extends State<votingpage>{

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Polls"),
        ),
        // body: SingleChildScrollView(
        //   child: FutureBuilder (
        //     future: FirebaseFirestore.instance.collection("posts").get(),
        //     builder: (context , future){
        //       return Column(
        //         children: future.data!.docs.map((items)=>
        //             Padding(padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
        //             // child:FlutterPolls(
        //             //   pollId: items.id,
        //             //   onVoted: (PollOption pollOption, int newTotalVotes) {
        //             //     print('Voted: ${pollOption.id}');
        //             //   },
        //             //   pollOptionsSplashColor: Colors.white,
        //             //   votedProgressColor: Colors.grey[100]?.withOpacity(0.3),
        //             //   votedBackgroundColor: Colors.grey.withOpacity(0.2),
        //             //   votesTextStyle: ThemeData..subtitle1,
        //             //   votedPercentageTextStyle:
        //             //   themeData.textTheme.headline4?.copyWith(
        //             //     color: Colors.black(),
        //             //   ),
        //             //   votedCheckmark: Icon(
        //             //     Icons.circle_check,
        //             //     color: AppColors.black(),
        //             //     height: 18,
        //             //     width: 18,
        //             //   ),
        //             // ))
        //         ).toList());}),
        //       )
        //     ,
          ),
        );

  }
}

class newpoll extends StatefulWidget{
  @override
  State<newpoll> createState() => _newpoll();
}
class _newpoll extends State<newpoll>{

  @override
  Widget builder(BuildContext context){
    return MaterialApp(
      home:Scaffold(
      )
    );
  }

}





