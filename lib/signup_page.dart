
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:login/firestore.dart';
import 'login_page.dart';
import 'email_verify.dart';
import 'voting_page.dart';

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
          title:const Text("Secrets"),
          titleTextStyle: const TextStyle(fontStyle: (FontStyle.italic ),fontWeight: FontWeight.w500,fontSize:40 ),
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
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child:Column(

            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30,),
              const Text('Signup',style: TextStyle(fontSize:25,fontWeight: FontWeight.bold ),textAlign: TextAlign.left,),
              const SizedBox(height: 40,),
              TextFormField(
                controller: nameController,
                //onChanged: ((v) {emailController.text=v;}),
                validator: (v){ if(v==null || v?.isEmpty==true){return "field is required";}
                return null;},
                decoration: InputDecoration(
                  suffixIcon: const Icon(Icons.person,color: Colors.blue,),
                  labelText: "username",
                  errorText: error??error,
                  hintText: 'please enter your username',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),gapPadding: 4),
                ),
              ),
              const SizedBox(height: 20,),
              DropdownButtonFormField(items: items.map((values){return DropdownMenuItem(value:values,child:Text(values));}).toList() , onChanged:(String? new_value){
                setState(() {
                  _value=new_value!;
                });
              },value:_value,hint:const Text("university Email domain"),borderRadius:(BorderRadius.circular(20.0)) ,decoration:InputDecoration(labelText:"University Domain",border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),suffixIcon: Icon(Icons.school_outlined,color: Colors.blue,) ,)),
              const SizedBox(height: 20,),
              DropdownButtonFormField(items: gitems.map((values){return DropdownMenuItem(value:values,child:Text(values));}).toList() , onChanged:(String? new_value){
                setState(() {
                  g_value=new_value!;
                });
              },value:g_value,hint:const Text("Gender"),borderRadius:(BorderRadius.circular(20.0)) ,decoration:InputDecoration(labelText:"Gender",border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),suffixIcon: Icon(Icons.boy,color: Colors.blue,) ,)),
              const SizedBox(height:20),
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
              const SizedBox(height: 20,),
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
              const SizedBox(height: 25,),
              Builder(builder: (BuildContext context){
                return(
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0) ,
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
                              a = await firebaseUserSignup(emailController.text,passwordcontroller.text);
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
                              Fluttertoast.showToast(msg: "signup successful");
                              if (user2==true){
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  Voting()));}
                              else{Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Emailverify()));}
                            }
                            //Navigator.push(context,  MaterialPageRoute(builder: (context) => const MyApp1()));
                            else{
                              Fluttertoast.showToast(msg: a);
                            }
                          },style: ButtonStyle(shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)))),child: const Text("Signup",style:TextStyle(fontSize:20,fontWeight: FontWeight.w500,fontStyle: FontStyle.italic),),
                          ): const Center(child: CircularProgressIndicator(),),
                          GestureDetector(child:const Text("Already have a account login?"),onTap: ()  { Navigator.push(context , MaterialPageRoute(builder: (context)=> const Mylogin()));
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