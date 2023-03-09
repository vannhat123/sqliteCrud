
import 'package:flutter/material.dart';
import 'package:sqlite_crud/Notes/complete.dart';
import 'package:sqlite_crud/Notes/notes.dart';

import '../Notes/pending.dart';
import 'dashboard.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int currentIndex = 0;
  List<IconData> icons =[
    Icons.home_rounded,
    Icons.query_stats_rounded,
    Icons.newspaper_rounded,
    Icons.help
  ];
  List titles = [
    "Home",
    "Notes",
    "Completed",
    "Pending"
  ];
  List<Widget> screens = <Widget>[
    const Dashboard(),
    const NotesPage(),
    const ComNotes(),
    const PendingNotes(),
  ];
  List title = [
    "Dashboard",
    "Notes",
    "Completed",
    "Pending"
  ];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      drawer: Drawer(),
     appBar: AppBar(
       title: Text(title[currentIndex]),
     ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.teal.withOpacity(.10),
            borderRadius: BorderRadius.circular(10)
        ),
        height: 65,
        child: ListView.builder(
            itemCount: 4,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: size.width *.035),
            itemBuilder: (context,index)=>InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: (){
                setState(() {
                  currentIndex = index;
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 5),
                  Icon(icons[index],size: index == currentIndex? 26:24,color: index == currentIndex? Colors.teal:Colors.black54),
                  Text(titles[index],style: TextStyle(color: index == currentIndex? Colors.teal:Colors.black54,fontSize: 12),),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.fastLinearToSlowEaseIn,
                    width: size.width *.140,
                    height: index == currentIndex? 5:0,
                    margin: EdgeInsets.only(
                        right: size.width* .0422,
                        left: size.width* .0422,
                        top: index == currentIndex? size.width * .014:0),
                    decoration: const BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20)
                        )
                    ),
                  )
                ],
              ),
            )),
      ),
      body: screens[currentIndex],
    );
  }
}
