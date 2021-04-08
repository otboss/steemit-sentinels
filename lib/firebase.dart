import 'package:firebase_database/firebase_database.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import './handler.dart';
import './main.dart';

final firebaseReference = FirebaseDatabase.instance.reference();


class FirebaseDBInterface{
  FirebaseDBInterface();

  Future<bool> addNewMember(User user) async{
    try{
      await firebaseReference.child("members")
        .child(user.username)
        //.push() //NOTE: PUSH ADDS A UNIQUE INDEX
        .set(user.toJson());
      return true;
    }
    catch(err){
      print(err);
      return false;
    }
  }

  Future<Map> getMembers() async{
    String network = await getCurrentNetwork();
    DataSnapshot data = await firebaseReference.child("members")
      .orderByChild("network")
      .equalTo(network)
      .limitToFirst(maxMembersOfNetwork)
      .once();
    return data.value;
  }

  Future<int> newPost(String url) async{
    //STATUS CODES
    // 1 - SHARED SUCCESSFULLY
    // 0 - AUTHOR IS NOT CURRENT USER
    // -1 - POST ALREADY SHARED
    // -2 - NO INTERNET CONNETION
    try{
      String author = getPostDetails(url)["author"];
      if(await getCurrentUser() == author){
        Post post = Post(url, await getCurrentNetwork(), author);
        var digest = md5.convert(utf8.encode(url));
        await firebaseReference.child("posts")
          .child(digest.toString())
          //.push() //NOTE: PUSH ADDS A UNIQUE INDEX
          .set(post.toJson());      
        return 1;
      }
      return 0;
    }
    catch(err){
      print(err);
      if(await isConnected() == false)
        return -2;
      return -1;
    }
  }

  Future<String> getLatestVersion() async{
    try{
      DataSnapshot data = await firebaseReference.child("latestVersion")
        .once();
      return data.value;
    }
    catch(err){
      return currentVersion;
    }
  }

  Future<List> getNewPosts() async{
    try{
      if(await getLatestVersion() != currentVersion)
        return [];
      updateLastActive();
      String network = await getCurrentNetwork();
      DataSnapshot  data = await firebaseReference.child("posts")
          .orderByChild("network")
          .equalTo(network)
          .limitToLast(maxNumberOfNewPosts)
          .once();    

      Map results = data.value;
      List newPosts = [];
      for(var key in results.keys){
        var digest = md5.convert(utf8.encode(results[key]["url"]));
        if(key.length != 32 || digest.toString() != key)
          continue;
        if(await databaseManager.isPostLiked(results[key]["url"]) == false && results[key]["url"].indexOf("https://steemit.com") == 0)
          newPosts.add(results[key]["url"]);
      }
      newPosts.sort();
      return newPosts;
    }
    catch(err){
      print(err);
      return [];
    }
  }



  Future<bool> updateLastActive() async{
    try{
      String currentUser = await getCurrentUser();
      await firebaseReference.child("members")
        .child(currentUser)
        .child("lastActive")
        //.push()
        .set(new DateTime.now().millisecondsSinceEpoch);
      return true;
    }
    catch(err){
      print(err);
      return false;
    }
  }


  Future<Map<String, dynamic>> getNetworks(String filter) async{
    if(filter == null)
      filter = "";
    DataSnapshot data = await firebaseReference.child("members")
      .orderByChild("network")
      .limitToLast(50)
      .startAt(filter)
      .endAt(filter+"\uf8ff")
      .once();
    Map results = data.value;      
    Map<String, int> networks = {};
    try{
      for(var key in results.keys){
        if(networks[results[key]["network"]] == null)
          networks[results[key]["network"]] = 1;
        else
          networks[results[key]["network"]]++;
      }
    }
    catch(err){
     return {}; 
    }
    return networks;
  }

  Future<List> getUserPosts() async{
    try{
      String currentUser = await getCurrentUser();
      DataSnapshot data = await firebaseReference.child("posts")
        .orderByChild("author")
        .equalTo(currentUser)
        .limitToLast(10)     
        .once();
      Map results = data.value;
      List resultKeys = results.keys.toList();
      List userPosts = [];
      for(var x = 0; x < resultKeys.length; x++){
        var url = results[resultKeys[x]]["url"];
        var digest = md5.convert(utf8.encode(url));
        if(resultKeys[x].length == 32 && digest.toString() == resultKeys[x] && results[resultKeys[x]]["url"].indexOf("https://steemit.com") == 0){
          userPosts.add(results[resultKeys[x]]);
        }
      }
      return userPosts;
    }
    catch(err){
      return [];
    }

  }  
}



class User{
  String username;
  String network;
  int lastActive;
  User(String username, String network){
    this.username = username;
    this.network = network;
    this.lastActive = new DateTime.now().millisecondsSinceEpoch;
  }
  Map<String, dynamic> toJson(){
    return{
        "network": this.network,
        "lastActive": this.lastActive
    };
  }
}

class Post{
  String url;
  String network;
  String author;
  Post(String url, String network, String author){
    this.url = url;
    this.network = network;
    this.author = author;
  }
  Map<String, dynamic> toJson(){
    Map<String, dynamic> data = {
      "network": this.network,
      "url": this.url,
      "author": this.author
    };
    return data;
  }
}