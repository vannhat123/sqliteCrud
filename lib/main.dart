import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sqlite_crud/Users/login.dart';

import 'Methods/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
        return ChangeNotifierProvider(
          create: (BuildContext context) => MyProvider(),
          child: Consumer<MyProvider>(
            builder: (context, MyProvider notifier,child){
              final controller = Provider.of<MyProvider>(context, listen: false);
              return MaterialApp(
                themeMode: ThemeMode.system,
                color: Colors.teal,
                darkTheme: controller.darkLight? ThemeData.dark() : ThemeData.light(),
                debugShowCheckedModeBanner: false,
                title: 'Gadget Note',
                theme: ThemeData(

                  appBarTheme: const AppBarTheme(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.teal,
                    elevation: 0
                  ),
                  primarySwatch: Colors.teal,
                ),
                home: const LoginScreen(),
              );
            },
          ),
        );

  }
}

