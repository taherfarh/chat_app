import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final firebase = FirebaseAuth.instance;
  final GlobalKey<FormState> formkey1 = GlobalKey<FormState>();
  final GlobalKey<FormState> formkey2 = GlobalKey<FormState>();
  var islogin = true;
  var enteredemail ="";
  var enteredpassword ="";

  void submit() async {
    var validate1 = formkey1.currentState!.validate();
    var validate2 = formkey2.currentState!.validate();

    if (!validate1 || !validate2) {
      return;
    }
try {
    if (islogin) {
       var usercredintial = await firebase.signInWithEmailAndPassword(
            email: enteredemail, password: enteredpassword);
      
    }else{
      
        var usercredintial = await firebase.createUserWithEmailAndPassword(
            email: enteredemail, password: enteredpassword);
      }
      
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? "Authentication Failed")));
      }
    
    formkey1.currentState!.save();
    formkey2.currentState!.save();
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
                    key: formkey1,
                    child: TextFormField(
                      onSaved: (newValue) => enteredemail = newValue!,
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty ||
                            !value.contains("@")) {
                          return "Please entre a valid email";
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "Email Address",
                      ),
                    )),
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
                    key: formkey2,
                    child: TextFormField(
                      onSaved: (newValue) => enteredpassword = newValue!,
                      validator: (value) {
                        if (value == null || value.trim().length < 6) {
                          return "Password must be contain at least 6 characters";
                        }
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                      ),
                    )),
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
                child: Text(islogin ? "Login" : "SignUp")),
            SizedBox(
              height: 15,
            ),
            TextButton(
                onPressed: () {
                  setState(() {
                    islogin = !islogin;
                  });
                },
                child: Text(
                    islogin ? "Create an account" : "I have already account"))
          ],
        ),
      ),
    );
  }
}
