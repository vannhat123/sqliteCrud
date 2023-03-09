import 'package:flutter/material.dart';
import 'package:sqlite_crud/Methods/textfield.dart';
import 'package:sqlite_crud/SQLite/database_helper.dart';
import 'package:sqlite_crud/Users/login.dart';
import 'package:sqlite_crud/Users/usr_model.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final usrName = TextEditingController();
  final usrPassword = TextEditingController();
  final formKey = GlobalKey<FormState>();

  createUsers(){
    final db = DatabaseHelper();
    var result = db.createUsers(Users(usrName: usrName.text, usrPassword: usrPassword.text)).whenComplete(() => Navigator.push(context,MaterialPageRoute(builder: (context) => LoginScreen(),)));

    if(result != -1){
      print("Hello $result");
     usrName.clear();
     usrPassword.clear();
    }else{
      print("Failed sign up");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              UnderlineInputField(
                  hint: "username",
                 controller: usrName,
                validator: (value){
                    if(value.isEmpty){
                      return "username is empty";
                    }else{
                      usrName.text = value;
                    }
                    return null;
                },
              ),
              UnderlineInputField(
                hint: "password",
                controller: usrPassword,
                validator: (value){
                  if(value.isEmpty){
                    return "password is empty";
                  }else{
                    usrPassword.text = value;
                  }
                  return null;
                },
              ),

              MaterialButton(
                color: Colors.teal,
                  minWidth: MediaQuery.of(context).size.width*.95,
                  child: const Text("Create account"),
                  onPressed: (){
                  setState(() {
                    
                  });
                ///Signup method
                    createUsers();
              })
            ],
          ),
        ),
      ),
    );
  }
}
