
 import 'package:persian_datetime_picker/persian_datetime_picker.dart';

class Notes{
   final int? noteId;
   final String noteTitle;
   final String noteContent;
   final int? noteStatus;
   final DateTime? createAt;
   final String? updatedAt;
   Notes({this.noteId, required this.noteTitle, required this.noteContent,this.createAt,this.updatedAt, this.noteStatus = 1});

   factory Notes.fromMap(Map<String, dynamic> json) => Notes(
       noteId: json['noteId'],
       noteTitle: json ['noteTitle'],
       noteContent: json['noteContent'],
       noteStatus: json['noteStatus'],
       createAt: json['createdAt'],
       updatedAt: json['updatedAt'],
       );

      Map<String, dynamic> toMap(){
      return{
        'noteId':noteId,
        'noteTitle': noteTitle,
        'noteContent':noteContent,
        'noteStatus':noteStatus,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String()
      };
      }

 }