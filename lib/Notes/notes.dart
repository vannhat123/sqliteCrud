import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqlite_crud/Notes/note_model.dart';
import '../SQLite/database_helper.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final noteTitle = TextEditingController();
  final noteContent= TextEditingController();

  //SQLite instance of DatabaseHelper class
  late DatabaseHelper handler;
  late Future<List<Notes>> notes;
  final db = DatabaseHelper();

  int? selectedId;
  int? totalNotes;



  @override
  void initState() {
    super.initState();
    handler = DatabaseHelper();
    notes = handler.getNotes();
    handler.initDB().whenComplete(() async {
      setState(() {
        notes = getList();
      });
    });
    total();
  }

  //Total Users count
  Future<int?> total()async{
    int? count = await handler.totalNotes();
    setState(() => totalNotes = count!);
    return totalNotes;
  }

  //Method to get data from database
  Future<List<Notes>> getList() async {
    return await handler.getNotes();
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
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      maxLength: 30,
                      maxLines: 1,
                      controller: noteTitle,
                      decoration: const InputDecoration(
                        hintText: "Title",
                      ),
                    ),
                    TextField(
                      maxLength: 100,
                      maxLines: 3,
                      controller: noteContent,
                      decoration: const InputDecoration(
                        hintText: "Content",
                      ),
                    ),


                  ],
                ),
              ),
              actions: [
                MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)
                    ),
                    minWidth: double.infinity,
                    color: Colors.teal,
                    child: Text("Create",style: TextStyle(color: Colors.white),),
                    onPressed: (){
                      db.createNote( Notes(noteTitle: noteTitle.text, noteContent: noteContent.text)).whenComplete(() => Navigator.pop(context));
                      _onRefresh();
                    })
              ],
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
          } else if (snapshot.hasError) {
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
                                content: Text("${items[index].noteTitle} has been deleted",style: const TextStyle(color: Colors.white),))));
                        setState(() {
                          items.remove(items[index]);
                          total();
                          _onRefresh();
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 10,vertical: 4),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: items[index].noteStatus == 1? Colors.amber:Colors.green,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 1,
                              color: Colors.grey
                            )
                          ]
                        ),
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
                                enableDrag: true,
                                  isDismissible: true,
                                  isScrollControlled: true,
                                  shape:const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(15),
                                          topLeft: Radius.circular(15)
                                      )
                                  ),
                                  context: context, builder: (context){
                                return SingleChildScrollView(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        right: 15,
                                        left: 15,
                                        bottom: MediaQuery.of(context).viewInsets.bottom
                                    ),
                                    child: SizedBox(
                                      height: 320,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(top: 10),
                                            width: 50,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: Colors.grey,
                                              borderRadius: BorderRadius.circular(50)
                                            ),
                                          ),
                                          const SizedBox(height: 25),

                                          TextFormField(
                                              maxLines: 1,
                                              maxLength: 30,
                                              controller: noteTitle,
                                              decoration: const InputDecoration(
                                                hintText: "Title",
                                              )
                                          ),

                                          TextFormField(
                                              maxLines: 3,
                                              maxLength: 100,
                                              controller: noteContent,
                                              decoration: const InputDecoration(
                                                hintText: "Content",
                                              )
                                          ),
                                          const SizedBox(height: 15),
                                          //Update button
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              MaterialButton(
                                                  minWidth: MediaQuery.of(context).size.width * .55,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                                  height: 50,
                                                  color: Colors.teal,
                                                  child: const Text("Update",style: TextStyle(color: Colors.white),),
                                                  onPressed: (){
                                                    setState(() {
                                                      _onRefresh();
                                                    });
                                                  }
                                              ),
                                              const SizedBox(width: 10),
                                              MaterialButton(
                                                  minWidth: MediaQuery.of(context).size.width * .3,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                                  height: 50,
                                                  color: Colors.teal,
                                                  child: const Text("Done",style: TextStyle(color: Colors.white)),
                                                  onPressed: (){
                                                    setState(() {
                                                      _onRefresh();
                                                    });
                                                  }
                                              ),
                                            ],
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
                            subtitle: Text(items[index].noteStatus == 1 ? "Pending":"Completed"),
                             //subtitle: Text(DateFormat.yMd().format(items[index].createAt!)),
                            trailing: IconButton(
                              onPressed: (){},
                              icon: Icon(Icons.arrow_forward_ios,size: 14),
                            )
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
