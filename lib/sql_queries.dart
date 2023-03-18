 import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


loadingmessages() async{
   List<Message> messages=[];
   var databasepath = await getDatabasesPath();
   String path = join(databasepath,'buymessages.db');
   // deleteDatabase(path);
   String path2= join(databasepath,"unreadmessages.db");
  Database database = await openDatabase(path,onCreate:(Database db,int number) async{
    await db.execute("Create Table chatmessages (id STRING, messageslist JSON)");
  },version: 1 );
   Database database1 = await openDatabase(path2,onCreate:(Database db,int number) async{
     await db.execute("Create Table unread (messageid STRING, createdAt BIGINT, text STRING)");
   },version: 1 );
  List chatmessages=await database.rawQuery("SELECT messageslist from chatmessages WHERE id= ?",["developer"]);
  print(chatmessages);

  if (chatmessages.isNotEmpty) {
    for (int i=0; i<jsonDecode(chatmessages[0]["messageslist"]).length;i++){
      if (jsonDecode(chatmessages[0]["messageslist"])[i]["status"]=="sent"){
      messages.add(
          TextMessage(
              createdAt: jsonDecode(chatmessages[0]["messageslist"])[i]["createdAt"],
              author: User(id:jsonDecode(chatmessages[0]["messageslist"])[i]["author"]["id"]),
              text: jsonDecode(chatmessages[0]["messageslist"])[i]["text"],
              id:jsonDecode(chatmessages[0]["messageslist"])[i]["id"],
              status:Status.sent
          )
      );}
      if (jsonDecode(chatmessages[0]["messageslist"])[i]["status"]=="delivered"){
        messages.add(
            TextMessage(
                createdAt: jsonDecode(chatmessages[0]["messageslist"])[i]["createdAt"],
                author: User(id:jsonDecode(chatmessages[0]["messageslist"])[i]["author"]["id"]),
                text: jsonDecode(chatmessages[0]["messageslist"])[i]["text"],
                id:jsonDecode(chatmessages[0]["messageslist"])[i]["id"],
                status:Status.delivered
            )
        );}
      if (jsonDecode(chatmessages[0]["messageslist"])[i]["status"]=="seen"){
        messages.add(
            TextMessage(
                createdAt: jsonDecode(chatmessages[0]["messageslist"])[i]["createdAt"],
                author: User(id:jsonDecode(chatmessages[0]["messageslist"])[i]["author"]["id"]),
                text: jsonDecode(chatmessages[0]["messageslist"])[i]["text"],
                id:jsonDecode(chatmessages[0]["messageslist"])[i]["id"],
                status:Status.seen
            )
        );}

    }
  // List unreadmessages =await database1.rawQuery("SELECT * FROM unread ORDER BY createdAt") ;
  // if (unreadmessages.isNotEmpty){
  //   for (int i=0 ; i<unreadmessages.length;i++){
  //     messages.insert(0,TextMessage(author: User(id:"developer"), id: unreadmessages[i]["messageid"], text: unreadmessages[i]["text"],createdAt: unreadmessages[i]["createdAt"]));
  //   }
  // }

  }


  return messages;
}

updatingmessages(messages) async{
  var databasepath = await getDatabasesPath();
  String path = join(databasepath,'buymessages.db');
  Database database = await openDatabase(path);
  List count_list =  await database.rawQuery("Select * from chatmessages where id=?",["developer"]);
  print(count_list.length);
  if (count_list.isNotEmpty){
    database.rawUpdate("Update chatmessages SET messageslist=? where id=?",[messages,"developer"]);
    print("hi");
  }
  else{
    database.rawInsert("Insert into chatmessages(id,messageslist) values(?,?)",["developer",messages]);
  print("hello");
  }

}

// updatingsentmessages(String id,int time,String text) async{
//   var databasepath= await getDatabasesPath();
//   String path =join(databasepath,"unreadmessages.db");
//   Database database = await openDatabase(path);
//   database.rawInsert("Insert into unread(messageid,createdAt,text) values(?,?,?)",[id,time,text]);
// }