import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:login/login_page.dart';
import 'firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUp extends StatelessWidget {
  const SignUp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
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
  final GlobalKey<FormState> signUpFormKey = new GlobalKey();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  bool passwordObscure = true, confirmPasswordObscure = true, isLoading = false;

  String? emailvalidator(String? email) {
    if (email!.isEmpty) {
      return "* Required field";
    }
    return null;
  }

  String? passwordvalidator(String? passwordtext) {
    if (passwordtext!.length < 8) {
      return "password length should be atleast 8";
    }
    return null;
  }

  String? confirmPasswordValidator(String? passwordtext) {
    if (password.text != passwordtext!) {
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
                title: const Center(child: Text("SignUp")),
                titleTextStyle: const TextStyle(
                    fontStyle: (FontStyle.italic),
                    fontWeight: FontWeight.w500,
                    fontSize: 40),
                toolbarHeight: height * 0.35,
                toolbarOpacity: 0.1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                  bottom: Radius.elliptical(width, 100),
                )),
              ),
              body: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 30,
                        ),
                        Form(
                            key: signUpFormKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: email,
                                  validator: emailvalidator,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                    suffixIcon: Icon(
                                      Icons.email,
                                      color: Colors.blue,
                                    ),
                                    labelText: "Email",
                                    hintText: "Enter your email",
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: password,
                                  obscureText: passwordObscure,
                                  obscuringCharacter: "*",
                                  validator: passwordvalidator,
                                  decoration: InputDecoration(
                                      border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
                                      labelText: "Password",
                                      hintText: "Enter your password",
                                      suffixIcon: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              passwordObscure =
                                                  !passwordObscure;
                                            });
                                          },
                                          icon: Icon(
                                            !passwordObscure
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: Colors.blue,
                                          ))),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: confirmPassword,
                                  obscureText: confirmPasswordObscure,
                                  obscuringCharacter: "*",
                                  validator: confirmPasswordValidator,
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
                                      labelText: "Confirm password",
                                      hintText: "Re-enter your Password"),
                                )
                              ],
                            )),
                        Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                      onPressed: () async {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        print("auth");
                                        print(signUpFormKey.currentState
                                            ?.validate());
                                        if (signUpFormKey.currentState
                                                ?.validate() ==
                                            true) {
                                          String res = await firebaseUserSignup(
                                              email.text, password.text);
                                          setState(() {
                                            isLoading = false;
                                          });
                                          Fluttertoast.showToast(msg: res);
                                        } else {
                                          setState(() {
                                            isLoading = false;
                                          });
                                          Fluttertoast.showToast(
                                              msg: "Something went wrong");
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          minimumSize: const Size(90, 40)),
                                      child: isLoading
                                          ? const CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 3,
                                            )
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
                        SignInButton(
                          Buttons.google,
                          onPressed: () async {
                            try{
                            final GoogleSignInAccount? googleUser =
                                await GoogleSignIn().signIn();
                            final GoogleSignInAuthentication? googleAuth =
                                await googleUser?.authentication;
                            final credential = GoogleAuthProvider.credential(
                              accessToken: googleAuth?.accessToken,
                              idToken: googleAuth?.idToken,
                            );
                              await FirebaseAuth.instance
                                  .signInWithCredential(credential);
                              Fluttertoast.showToast(msg: "Successful");
                            } catch (e) {
                              Fluttertoast.showToast(msg: e.toString());
                            }
                          },
                        )
                      ],
                    )),
              ),
            ));
  }
}
