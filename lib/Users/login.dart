import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqlite_crud/Methods/textfield.dart';
import 'package:sqlite_crud/SQLite/database_helper.dart';
import 'package:sqlite_crud/Screens/home_screen.dart';
import 'package:sqlite_crud/Users/signup.dart';
import 'package:sqlite_crud/Users/usr_model.dart';

import '../Methods/provider.dart';
import '../Screens/bottom_nav_bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final usrName = TextEditingController();
  final usrPass = TextEditingController();
  final formKey = GlobalKey<FormState>();

  //Login method for login button
  login()async{
    final db = DatabaseHelper();
     var result = await db.authentication(Users(usrName: usrName.text, usrPassword: usrPass.text));
    if(result){
      String uName = usrName.text;
      if(!mounted)return;
      Navigator.push(context, MaterialPageRoute(builder: (context)=> BottomNavBar()));
    }else{
      if(!mounted)return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Username and password is incorrect")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MyProvider>(context, listen: false);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              UnderlineInputField(
                controller: usrName,
                hint: "Username",
                validator: (value){
                  if(value.isEmpty){
                    return "Username is empty";
                  }else{
                    usrName.text = value;
                  }
                  return null;
                },
              ),
              UnderlineInputField(
                controller: usrPass,
                hint: "Password",
                validator: (value){
                  if(value.isEmpty){
                    return "Password is empty";
                  }else{
                    usrPass.text = value;
                  }
                  return null;
                },
              ),

              MaterialButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)
                  ),
                  minWidth: size.width *.95,
                  height: 60,
                  color: Colors.teal,
                  child: const Text("Login",style: TextStyle(color: Colors.white),),
                  onPressed: (){
                    if(formKey.currentState!.validate()){
                     //Login function
                     login();
                    }
                  }
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an Account?"),
                  TextButton(
                      onPressed: (){
                        Navigator.push(context,MaterialPageRoute(builder: (context)=>const SignUpScreen()));
                      },
                      child: const Text("Sign up"))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
