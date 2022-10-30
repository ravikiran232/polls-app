 import 'dart:convert';

import 'package:sql_conn/sql_conn.dart';


sql_query_connect () async{
  try{await SqlConn.connect(ip:"localhost",port:"3306",databaseName: "whatsapp",username: "root",password: "Sreedhar@123");return true;}
      on Exception catch(e){print(e);return false;}
}

sql_read(String query) async{
  var res = await SqlConn.readData(query);
  return jsonDecode(res.toString());
}
sql_write(String query) async{
  var res =await SqlConn.writeData(query);
  return res;
}
