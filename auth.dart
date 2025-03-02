import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/screens/chats_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final firebase = FirebaseAuth.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  var isLogin = true;
  var enteredEmail = "";
  var enteredPassword = "";

void submit() async {
  if (!formKey.currentState!.validate()) {
    return;
  }
  formKey.currentState!.save();

  try {
    UserCredential userCredential;
    if (isLogin) {
      userCredential = await firebase.signInWithEmailAndPassword(
        email: enteredEmail,
        password: enteredPassword,
      );
      print("✅ Logged in successfully: ${userCredential.user?.email}");
    } else {
      userCredential = await firebase.createUserWithEmailAndPassword(
        email: enteredEmail,
        password: enteredPassword,
      );
      print("✅ Account created successfully: ${userCredential.user?.email}");

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userCredential.user!.uid)
          .set({
        "username": "...",
        "email": enteredEmail,
      });
    }

    // ✅ التأكد إن الويدجت لا يزال موجودًا قبل التنقل إلى صفحة الشات
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ChatsScreen()),
    );
  } on FirebaseAuthException catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message ?? "Authentication Failed")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(top: 50, left: 15, right: 15, bottom: 15),
              child: Image.asset(
                "assets/images/undraw_real_time_collaboration_c62i 1.png",
                width: 200,
              ),
            ),
            Center(
              child: Container(
                margin: EdgeInsets.only(left: 25, right: 15),
                child: Text(
                  "Stay connected with your friends and family!",
                  style: TextStyle(
                      fontSize: 35,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Card(
              shadowColor: Colors.grey,
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              margin: EdgeInsets.all(20),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        onSaved: (newValue) => enteredEmail = newValue!,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              !value.contains("@")) {
                            return "Please enter a valid email";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Email Address",
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        onSaved: (newValue) => enteredPassword = newValue!,
                        validator: (value) {
                          if (value == null || value.trim().length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    const Color.fromARGB(255, 255, 206, 61)),
                minimumSize: MaterialStateProperty.all<Size>(
                    Size(MediaQuery.of(context).size.width - 20, 50)),
              ),
              onPressed: submit,
              child: Text(isLogin ? "Login" : "Sign Up"),
            ),
            SizedBox(height: 15),
            TextButton(
              onPressed: () {
                setState(() {
                  isLogin = !isLogin;
                });
              },
              child: Text(
                  isLogin ? "Create an account" : "I already have an account"),
            )
          ],
        ),
      ),
    );
  }
}
