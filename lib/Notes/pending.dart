import 'package:flutter/material.dart';
import 'package:sqlite_crud/Notes/note_model.dart';
import '../SQLite/database_helper.dart';

class PendingNotes extends StatefulWidget {
  const PendingNotes({Key? key}) : super(key: key);

  @override
  State<PendingNotes> createState() => _PendingNotesState();
}

class _PendingNotesState extends State<PendingNotes> {
  final noteTitle = TextEditingController();
  final noteContent= TextEditingController();
  //SQLite instance of DatabaseHelper class
  late DatabaseHelper handler;
  late Future<List<Notes>> notes;
  final db = DatabaseHelper();

  int? selectedId;
  int number = -1;

  @override
  void initState() {
    super.initState();
    handler = DatabaseHelper();
    notes = handler.getPendingNotes();
    handler.initDB().whenComplete(() async {
      setState(() {
        notes = getList();
      });
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
  Future<List<Notes>> getList() async {
    return await handler.getPendingNotes();
  }


  //Method to refresh data on pulling the list
  Future<void> _onRefresh() async {
    setState(() {
      notes = getList();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: (){
          showDialog(context: context, builder: (context){
            return AlertDialog(
              title: const Text("Note"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: noteTitle,
                    decoration: const InputDecoration(
                      hintText: "Note Title",
                    ),
                  ),
                  TextField(
                    controller: noteContent,
                    decoration: const InputDecoration(
                      hintText: "Note Content",
                    ),
                  ),

                  MaterialButton(
                      color: Colors.teal,
                      child: const Text("Create"),
                      onPressed: (){
                        db.createNote( Notes(noteTitle: noteTitle.text, noteContent: noteContent.text)).whenComplete(() => Navigator.pop(context));
                        _onRefresh();
                      })
                ],
              ),
            );
          });
        },
      ),

      body: FutureBuilder<List<Notes>>(
        future: notes,
        builder: (BuildContext context, AsyncSnapshot<List<Notes>> snapshot) {
          //in case whether data is pending
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              //To show a circular progress indicator
              child: CircularProgressIndicator(),
            );
            //If snapshot has error
          }else if(!snapshot.hasData){
            return Text("No data");
          } else if(snapshot.hasData && snapshot.data!.isEmpty) {
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
          }else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            //a final variable (item) to hold the snapshot data
            final items = snapshot.data ?? <Notes>[];
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
                      key: ValueKey<int>(items[index].noteId!),
                      onDismissed: (DismissDirection direction) async {
                        await handler.deleteNote(items[index].noteId.toString()).whenComplete(() => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)
                                ),
                                backgroundColor: Colors.teal,
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(milliseconds: 900),
                                content: Text("${items[index].noteTitle} deleted",style: const TextStyle(color: Colors.white),))));
                        setState(() {
                          items.remove(items[index]);
                          total();
                          _onRefresh();
                        });
                      },
                      child: Card(
                          child: ListTile(
                            onTap: (){
                              //To hold the data in text fields for update method
                              setState(() {
                                //selectedId = items [index].noteId;
                                //noteTitle.text = items[index].noteTitle;
                                db.setNoteStatus(items [index].noteId);
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
                                                controller: noteTitle,
                                                decoration: const InputDecoration(
                                                  hintText: "username",
                                                )
                                            ),
                                          ),

                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextFormField(
                                                controller: noteContent,
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
                            title: Text(items[index].noteTitle),
                            trailing: Text(items[index].noteStatus == 1?"Pending":"Completed"),
                            subtitle: Text(items[index].createAt.toString()),
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
