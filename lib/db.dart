import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import './handler.dart';
import './main.dart';


class DatabaseManager {

  static final DatabaseManager _databaseManager  = new DatabaseManager.internal();

  factory DatabaseManager() {
    return _databaseManager;
  }  

  static Database db;

  final String postsTable = "likedPosts";
  final String membersTable = "members";
  final String userTable = "currentUser";
  final String remaindingDaysTable = "remainingDays";

  DatabaseManager.internal();


  Future<String> getDatabasePath() async {
    Directory privateStorage = await getApplicationDocumentsDirectory();
    return join(privateStorage.path, 'steemitsentinels.db');
  }  

  
  Future<Database> initDb() async{
    try{
      String path = await getDatabasePath();
      db = await openDatabase(path, version: 1);
      await db.execute("CREATE TABLE IF NOT EXISTS $membersTable(mid INTEGER PRIMARY KEY, username TEXT, status TEXT, network TEXT, ts DATETIME DEFAULT CURRENT_TIMESTAMP)");
      await db.execute("CREATE TABLE IF NOT EXISTS $userTable(usrid INTEGER PRIMARY KEY, username TEXT, network TEXT, ts DATETIME DEFAULT CURRENT_TIMESTAMP)");
      await db.execute("CREATE TABLE IF NOT EXISTS $postsTable(lpid INTEGER PRIMARY KEY, url TEXT, network TEXT, status TEXT, ts DATETIME DEFAULT CURRENT_TIMESTAMP)");  
      return db;
    }
    catch(err){
      print(err);
      return db;
    }
  }

  Future<Database> getDatabase() async{
    if(db != null)
      return db;
    await initDb();
    return db;
  }



  Future<Map> getCurrentUser() async{
    try{
      var client = await getDatabase();
      List results = await client.rawQuery("SELECT * FROM $userTable");
      if(results[0] != null)
        return results[0];
    }
    catch(err){
      return null;
    }
    return null;
  }

  Future<bool> removeCurrentUser() async{
    try{
      var client = await getDatabase();
      await client.delete(userTable);
      return true;
    }
    catch(err){
      print(err);
    }
    return true;
  }

  Future<bool> setCurrentUser(String username, String network) async{
    try{
      var client = await getDatabase();
      await removeCurrentUser();
      await client.rawInsert("INSERT INTO $userTable (username, network) VALUES ('$username', '$network')");
      return true;
    }
    catch(err){
      print(err);
      return false;
    }
  }

  Future<int> getTotalLikedPosts() async{
    try{
      var client = await getDatabase();
      String currentNetwork = await getCurrentNetwork();
      List allLikedPosts = await client.rawQuery("SELECT COUNT(*) totalLikedPosts FROM (SELECT * FROM $postsTable WHERE network = '$currentNetwork' AND status = '"+ContentStatus.complete.toString()+"' GROUP BY url)");
      if(allLikedPosts[0]["totalLikedPosts"] == null)
        return 0;
      return allLikedPosts[0]["totalLikedPosts"];
    }
    catch(err){
      return 0;
    }
  }

  Future<int> getTotalActiveMembers() async{
    try{
      var client = await getDatabase();
      String currentNetwork = await getCurrentNetwork();
      String activeStatus = MembershipStatus.active.toString();
      List allActiveClients = await client.rawQuery("SELECT COUNT(*) totalActiveMembers FROM (SELECT * FROM $membersTable WHERE status = '$activeStatus' AND network = '$currentNetwork' GROUP BY username)");
      if(allActiveClients[0]["totalActiveMembers"] == null)
        return 0;
      return allActiveClients[0]["totalActiveMembers"];
    }
    catch(err){
      return 0;
    }    
  }

  Future<int> getTotalInactiveMembers() async{
    try{
      var client = await getDatabase();
      String currentNetwork = await getCurrentNetwork();
      String inactiveStatus = MembershipStatus.inactive.toString();
      List allInactiveClients = await client.rawQuery("SELECT COUNT(*) totalInactiveMembers FROM (SELECT * FROM $membersTable WHERE status = '$inactiveStatus' AND network = '$currentNetwork' GROUP BY username)");
      if(allInactiveClients[0]["totalInactiveMembers"] == null)
        return 0;
      return allInactiveClients[0]["totalInactiveMembers"];
    }
    catch(err){
      return 0;
    }    
  }
  
  Future<int> savePost(String url, String network, ContentStatus status) async{
    var client = await getDatabase();
    try{
      List testIfExists = await client.rawQuery("SELECT * FROM $postsTable WHERE url = '$url'");
      if(testIfExists.length == 0){
        int result = await client.rawInsert("INSERT INTO $postsTable (url, network, status) VALUES ('$url', '$network', '"+status.toString()+"')");
        return result;
      }
      return 0;
    }
    catch(err){
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> getLikedPosts(String filter, List<String> negatePostsArray) async{
    var client = await getDatabase();
    filter = filter.toLowerCase();
    String exclude = listToSqlArray(negatePostsArray);
    String currentNetwork = await getCurrentNetwork();
    List results = await client.rawQuery("SELECT * FROM $postsTable WHERE network = '$currentNetwork' AND status = '"+ContentStatus.complete.toString()+"' AND url NOT IN $exclude ORDER BY lpid DESC LIMIT 20");
    for(var x = results.length - 1; x > -1; x--){
      var url = results[x]["url"];
      var title = getPostDetails(url)["title"].toLowerCase();
      if(title.indexOf(filter) == -1)
        results.removeRange(x, x+1);
    }
    return results;
  }

  Future<bool> isPostLiked(String url) async{
    var client = await getDatabase();
    List results = await client.rawQuery("SELECT * FROM $postsTable WHERE url = '$url';");
    if(results.length == 0)
      return false;
    return true;
  }

  Future<bool> deleteAll() async{
    try{
      var client = await getDatabase();
      await client.rawQuery("DELETE FROM $postsTable");
      return true;
    }
    catch(err){
      return false;
    }
  }

  Future<int> saveMember(String username, MembershipStatus status) async{
    var client = await getDatabase();
    List testIfExist = await client.rawQuery("SELECT * FROM $membersTable WHERE username = '$username'");
    if(testIfExist.length == 0){
      List isNetworkFull = await client.rawQuery("SELECT * FROM $membersTable");
      if(isNetworkFull.length < maxMembersOfNetwork){
        try{
          String currentNetwork = await getCurrentNetwork();
          int result = await client.rawInsert("INSERT INTO $membersTable (username, status, network) VALUES ('$username', '"+status.toString()+"', '$currentNetwork')");
          return result;
        }
        catch(err){
          print("ERROR WHILE INSERTING");
          print(err);
        }
      }
      return 0;
    }
    else{
      await updateMember(username, status);
      return 0;
    }
  }

  Future<Map<String, dynamic>> getMembersAsMap(String filter, List negateUsernameArray) async{
    var client = await getDatabase();
    String exclude = listToSqlArray(negateUsernameArray);
    List members = await client.rawQuery("SELECT * FROM $membersTable WHERE username LIKE '%$filter%' AND username NOT IN $exclude GROUP BY username LIMIT 20");
    Map<String, dynamic> results;
    for(var x = 0; x < members.length; x++){
      results[members[x]["username"]] = {
        "status": members[x]["status"],
      };
    }
    return results;
  }

  Future<int> updateMember(String username, MembershipStatus status) async{
    var client = await getDatabase();
    int result = 0;
    try{
      result = await client.rawUpdate("UPDATE $membersTable SET status = '"+status.toString()+"' WHERE username = '$username'");  
    }
    catch(err){
      print(err);
      print(err);
      print(err);
      print(err);
      print(err);
      return 0;
    }
    return result;
  }

  Future<int> deleteMembers() async{
    var client = await getDatabase();
    int result = await client.delete(membersTable);
    result = await client.delete(postsTable);
    return result;
  }


  Future<List<Map<String, dynamic>>> getMembers(String filter, List negateUsernameArray) async{
    var client = await getDatabase();
    //ADD LIMITER TO THE QUERY BELOW
  
    String exclude = listToSqlArray(negateUsernameArray);
    return await client.rawQuery("SELECT * FROM $membersTable WHERE username LIKE '%$filter%' AND username NOT IN $exclude GROUP BY username ORDER BY mid DESC LIMIT 20");
  } 


  Future<int> getMembersCount() async{
    var client = await getDatabase();
    List allMembers = await client.rawQuery("SELECT COUNT(*) totalMembers FROM $membersTable GROUP BY username");
    return allMembers[0]["totalMembers"];
  }

  String listToSqlArray(List lst){
    String sqlArr = "(";
    if(lst.length == 0){
      lst = [];
      sqlArr = "('')";
    }
    else{
      for(var x = 0; x < lst.length; x++){
        if(x != lst.length - 1)
          sqlArr += "'"+lst[x]+"',";
        else
          sqlArr += "'"+lst[x]+"'";
      }
      sqlArr += ")";
    }
    return sqlArr;
  }
}