import 'package:firebase_auth/firebase_auth.dart';
import 'package:auth_buttons/auth_buttons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:login/login_page.dart';
import 'firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUp extends StatelessWidget {
  const SignUp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SignUpPage(),
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => SignUpPage2();
}

class SignUpPage2 extends State<SignUpPage> {
  GlobalKey<FormFieldState> signUpFormKey = GlobalKey();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  bool passwordObscure = true, confirmPasswordObscure = true, isLoading = false;

  String? passwordvalidator(String? passwordtext) {
    if (passwordtext!.length < 8) {
      return "password length should be atleast 8";
    }
    return null;
  }

  String? confirmPasswordValidator(String? passwordtext) {
    if (password.text == passwordtext!) {
      return "password doesn't match";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Builder(
        builder: (context) => Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                title: const Text("SignUp"),
                titleTextStyle: const TextStyle(
                    fontStyle: (FontStyle.italic),
                    fontWeight: FontWeight.w500,
                    fontSize: 40),
                toolbarHeight: height * 0.25,
                toolbarOpacity: 0.1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                  bottom: Radius.elliptical(width, 100),
                )),
              ),
              body: SingleChildScrollView(
                child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Form(
                            key: signUpFormKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: email,
                                  decoration: const InputDecoration(
                                    suffixIcon: Icon(
                                      Icons.email,
                                      color: Colors.blue,
                                    ),
                                    labelText: "Email",
                                    hintText: "Enter your email",
                                  ),
                                ),
                                TextFormField(
                                  controller: password,
                                  obscureText: passwordObscure,
                                  obscuringCharacter: "*",
                                  validator: passwordvalidator,
                                  decoration: const InputDecoration(
                                      labelText: "Password",
                                      hintText: "Enter your password",
                                      suffixIcon: Icon(
                                        Icons.remove_red_eye,
                                        color: Colors.blue,
                                      )),
                                ),
                                TextFormField(
                                  controller: confirmPassword,
                                  obscureText: confirmPasswordObscure,
                                  obscuringCharacter: "*",
                                  validator: confirmPasswordValidator,
                                  decoration: const InputDecoration(
                                      labelText: "Confirm password",
                                      hintText: "Re-enter your Password"),
                                )
                              ],
                            )),
                        Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                      onPressed: () async {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        if (signUpFormKey.currentState
                                                ?.validate() ==
                                            null) {
                                          String res = await firebaseUserSignup(
                                              email.text, password.text);
                                          setState(() {
                                            isLoading = false;
                                          });
                                          Fluttertoast.showToast(msg: res);
                                        } else {
                                          Fluttertoast.showToast(
                                              msg: "Something went wrong");
                                        }
                                      },
                                      style: ButtonStyle(
                                          shape: MaterialStateProperty.all(
                                              const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              10))))),
                                      child: isLoading
                                          ? const CircularProgressIndicator()
                                          : const Text("Signup")),
                                  GestureDetector(
                                    child:
                                        const Text("Already have an account?"),
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: ((context) =>
                                                  const Mylogin())));
                                    },
                                  )
                                ])),
                        const SizedBox(
                          height: 5,
                        ),
                        GoogleAuthButton(
                          onPressed: () async {
                            final GoogleSignInAccount? googleUser =
                                await GoogleSignIn().signIn();
                            final GoogleSignInAuthentication? googleAuth =
                                await googleUser?.authentication;
                            final credential = GoogleAuthProvider.credential(
                              accessToken: googleAuth?.accessToken,
                              idToken: googleAuth?.idToken,
                            );
                            try{
                              await FirebaseAuth.instance.signInWithCredential(credential);
                              Fluttertoast.showToast(msg: "Successful");
                            } catch(e){Fluttertoast.showToast(msg: e.toString());}
                          },
                          style: const AuthButtonStyle(
                              iconType: AuthIconType.secondary),
                        )
                      ],
                    )),
              ),
            ));
  }
}
