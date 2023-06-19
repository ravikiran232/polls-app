import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:show_more_text_popup/show_more_text_popup.dart';
import 'firestore.dart';
import 'signup_page.dart';
import 'email_verify.dart';
import 'voting_page.dart';

class Mylogin extends StatelessWidget {
  const Mylogin({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      theme: ThemeData(
        // Add the 5 lines from here...
        appBarTheme: const AppBarTheme(
          elevation: 10,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      home: const MyloginPage(),
    );
  }
}

class MyloginPage extends StatefulWidget {
  const MyloginPage({super.key});

  @override
  State<MyloginPage> createState() => _Myloginpage();
}

class _Myloginpage extends State<MyloginPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  bool isloading = false, _obscure = true;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user != null) {
          if (user.emailVerified) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Voting()));
          } else {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const Emailverify()));
          }
        } else {
          print("please login to countinue");
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          title: Text("Secrets"),
          titleTextStyle: TextStyle(
              fontStyle: (FontStyle.italic),
              fontWeight: FontWeight.w500,
              fontSize: 40),
          titleSpacing: 110,
          toolbarHeight: height * 0.35,
          toolbarOpacity: 0.1,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
            bottom: Radius.elliptical(width, 100),
          )),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 30,
              ),
              Text(
                'Login',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
              SizedBox(
                height: 40,
              ),
              TextField(
                controller: emailController,
                //onChanged: ((v) {emailController.text=v;}),
                decoration: InputDecoration(
                  suffixIcon: const Icon(
                    Icons.email_outlined,
                    color: Colors.blue,
                  ),
                  labelText: "Email",
                  hintText: 'Enter your university Provided Email',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0), gapPadding: 4),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                obscureText: _obscure,
                controller: passwordcontroller,
                // onChanged: ((v)  { if ( (v.length>=8) & ( v.contains("1") | v.contains("2") | v.contains("3") | v.contains("4") )){passwordcontroller.text=v;}else{
                // print('please include numbers and make sure your password is atleast 8 letters');}}) ,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter Your Password',
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          if (_obscure) {
                            _obscure = false;
                          } else {
                            _obscure = true;
                          }
                        });
                      },
                      icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0), gapPadding: 4),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Builder(builder: (BuildContext context) {
                return (Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      !isloading
                          ? ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  isloading = true;
                                });
                                final a = await firebaseUserSignin(
                                    emailController.text,
                                    passwordcontroller.text);
                                final user1 = FirebaseAuth.instance.currentUser;
                                var user2 = user1?.emailVerified;
                                print(a);

                                setState(() {
                                  isloading = false;
                                  //isloading=!isloading;
                                });
                                if (a == "successful") {
                                  Fluttertoast.showToast(
                                      msg: "successfully logged in");
                                  if (user2 == true) {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Voting()));
                                  } else {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const Emailverify()));
                                  }
                                }
                                //Navigator.push(context,  MaterialPageRoute(builder: (context) => const MyApp1()));
                                else {
                                  Fluttertoast.showToast(
                                      msg: a, backgroundColor: Colors.red);
                                }
                              },
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0)))),
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FontStyle.italic),
                              ),
                            )
                          : const Center(
                              child: CircularProgressIndicator(),
                            ),
                      GestureDetector(
                        child: const Text("Forgot Password?"),
                        onTap: () async {
                          var _result;
                          ShowMoreTextPopup(context,
                              text:
                                  "enter your email in email box and click forgot password",
                              backgroundColor: Colors.lightBlueAccent,
                              height: 100);
                          try {
                            await FirebaseAuth.instance.sendPasswordResetEmail(
                                email: emailController.text);
                            _result = "successfully sent password reset email";
                          } on FirebaseException catch (e) {
                            _result = e.code;
                          } on Exception catch (e) {
                            _result = e.toString();
                          }
                          if (_result !=
                              "successfully sent password reset email") {
                            Fluttertoast.showToast(
                              msg: _result,
                              backgroundColor: Colors.red,
                            );
                          } else {
                            Fluttertoast.showToast(msg: _result);
                          }
                        },
                      )
                    ],
                  ),
                ));
              }),
              const SizedBox(
                height: 30,
              ),
              Builder(builder: (BuildContext context) {
                return (Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                        child: const Text("Don\'t have a account? signup"),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Signup()));
                        })));
              }),
            ],
          ),
        ),
      ),
    );
  }
}
