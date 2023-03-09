import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqlite_crud/Methods/provider.dart';
import 'package:sqlite_crud/Notes/complete.dart';
import 'package:sqlite_crud/Notes/notes.dart';
import 'package:sqlite_crud/SQLite/database_helper.dart';
import 'package:sqlite_crud/Users/usr_model.dart';

import '../Users/login.dart';

class HomeScreen extends StatefulWidget {
  final String name;
  const HomeScreen({Key? key,required this.name }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final usrName = TextEditingController();
  final usrPass = TextEditingController();

  //SQLite instance of DatabaseHelper class
  late DatabaseHelper handler;
  late Future<List<Users>> users;
  final db = DatabaseHelper();

  int? selectedId;
  int number = -1;

  // stateful initState function, for refreshing the entire screen on each entry
  @override
  void initState() {
    super.initState();
    handler = DatabaseHelper();
    users = handler.getUsers();
    handler.initDB().whenComplete(() async {
        users = getList();
    });
    total();
  }



  //Total Users count
   Future<int?> total()async{
    int? count = await handler.totalUsers();
    setState(() => number = count!);
    return number;
  }

  //Method to get data from database
  Future<List<Users>> getList() async {
    return await handler.getUsers();
  }


  //Method to refresh data on pulling the list
  Future<void> _onRefresh() async {
    setState(() {
      users = getList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MyProvider>(context, listen: false);
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              ListTile(
                trailing: const Icon(Icons.notes),
                title: Text(widget.name,style: const TextStyle(fontSize: 18),),
              ),
              ListTile(
                title:  const Text("Notes"),
                leading: const Icon(Icons.note_alt_outlined),
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> const NotesPage()));
                },
              ),
              ListTile(
                title: const Text("Complete"),
                leading: const Icon(Icons.done_all),
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> const ComNotes()));
                },
              ),

              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.power_settings_new),
                      title: const Text("Logout"),
                      trailing: const Icon(Icons.arrow_forward_ios,size: 14,),
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>const LoginScreen()));
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      appBar: AppBar(
        actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(child: Text(number.toString(),style: const TextStyle(fontSize: 14),)),
        ),

         Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: IconButton(
              onPressed: (){
              setState(() {
                controller.changeTheme();
              });
              },
              icon: Icon(controller.darkLight? Icons.light_mode:Icons.dark_mode),
            )),
         ),

        ],
        title: Text(widget.name),
      ),

      //Future Builder to load data live as stream
      body: FutureBuilder<List<Users>>(
        future: users,
        builder: (BuildContext context, AsyncSnapshot<List<Users>> snapshot) {
          //in case whether data is pending
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
               //To show a circular progress indicator
              child: CircularProgressIndicator(),
            );
            //If snapshot has error
          }else if(snapshot.hasData && snapshot.data!.isEmpty) {
            return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("No Data"),
                    MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)
                      ),
                      minWidth: 100,
                      color: Colors.teal,
                      onPressed: ()=>_onRefresh(),
                      child: Text("Refresh"),
                    )
                  ],
                ));
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            //a final variable (item) to hold the snapshot data
            final items = snapshot.data ?? <Users>[];
            return Scrollbar(
              //The refresh indicator
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) {
                    //Dismissible widget is to delete a data on pushing a record from left to right
                    return Dismissible(
                      direction: DismissDirection.startToEnd,
                      background: Container(
                        decoration: BoxDecoration(
                            color: Colors.red.shade900,
                        ),

                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                             Icon(Icons.delete,color: Colors.white,size: 30,),
                            Text("Delete",style: TextStyle(color: Colors.white),)
                          ],
                        ),
                      ),
                      key: ValueKey<int>(items[index].usrId!),
                      onDismissed: (DismissDirection direction) async {
                        await handler.deleteUser(items[index].usrId.toString()).whenComplete(() => ScaffoldMessenger.of(context).showSnackBar(

                            SnackBar(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)
                              ),
                                 backgroundColor: Colors.teal,
                                 behavior: SnackBarBehavior.floating,
                                duration: const Duration(milliseconds: 900),
                                content: Text("${items[index].usrName} deleted",style: const TextStyle(color: Colors.white),))));
                        setState(() {
                          items.remove(items[index]);
                          total();
                        });
                      },
                      child: Card(
                          child: ListTile(
                            onTap: (){
                              //To hold the data in text fields for update method
                             setState(() {
                               selectedId = items [index].usrId;
                               usrName.text = items[index].usrName;
                               usrPass.text = items[index].usrPassword;
                             });
                              //bottom modal sheet for update
                              showModalBottomSheet(
                                  isScrollControlled: true,
                                  shape:const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(20),
                                          topLeft: Radius.circular(20)
                                      )
                                  ),
                                  context: context, builder: (context){
                                return SingleChildScrollView(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context).viewInsets.bottom
                                    ),
                                    child: SizedBox(
                                      height: 270,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(height: 25),

                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextFormField(
                                               controller: usrName,
                                              decoration: const InputDecoration(
                                                hintText: "username",
                                              )
                                            ),
                                          ),

                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextFormField(
                                                controller: usrPass,
                                                decoration: const InputDecoration(
                                                  hintText: "Password",
                                                )
                                            ),
                                          ),
                                         const SizedBox(height: 15),
                                         //Update button
                                          MaterialButton(
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              minWidth: MediaQuery.of(context).size.width *.94,
                                              height: 50,
                                              color: Colors.teal,
                                              child: const Text("Update"),
                                              onPressed: (){
                                               setState(() {
                                                   db.updateUser(Users(usrId: selectedId,usrName: usrName.text, usrPassword: usrPass.text)).whenComplete(() => Navigator.pop(context));
                                                   _onRefresh();
                                               });
                                              }
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              });
                            },
                            contentPadding: const EdgeInsets.all(8.0),
                            //To show data in the page
                            title: Text(items[index].usrName),
                            subtitle: Text(items[index].usrPassword),
                          )),
                    );
                  },
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
