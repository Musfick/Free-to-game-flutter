import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.white));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "🔥 Trending Games",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: GamesScreen(),
      ),
    );
  }
}

class GamesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  List<Game> lists = [];

  var url = Uri.https('freetogame.com', '/api/games');

  void getData() async {
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var parsed = json.decode(response.body).cast<Map<String, dynamic>>();

      setState(() {
        lists = parsed.map<Game>((json) => Game.fromJson(json)).toList();
      });
    } else {
      print("${response.statusCode} Error");
    }
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: lists.isEmpty
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.blueAccent,
                  strokeWidth: 4,
                ),
              )
            : GridView.builder(
                padding: EdgeInsets.only(left: 8, right: 8, top: 8),
                itemCount: lists.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 0.60,
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemBuilder: (context, position) {
                  return Card(
                      elevation: 16,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    GameDetailsScreen(lists[position].id)),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: Image.network(
                              lists[position].thumbnail ?? "",
                              fit: BoxFit.cover,
                            )),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 8, right: 8, top: 8, bottom: 8),
                              child: Text(lists[position].title ?? "",
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(left: 8, right: 8, bottom: 8),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 8),
                                color: Colors.green,
                                child: Text(
                                  lists[position].genre ?? "",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10.0),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(bottom: 8, left: 8, right: 8),
                              child: Text(
                                lists[position].platform ?? "",
                                style: TextStyle(fontSize: 12),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 8, right: 8, bottom: 16),
                              child: Text(
                                "Release : ${lists[position].release}",
                                style: TextStyle(fontSize: 12.0),
                              ),
                            ),
                          ],
                        ),
                      ));
                }));
  }
}

class Game {
  final int id;
  final String? title;
  final String? thumbnail;
  final String? genre;
  final String? platform;
  final String? release;
  final String? description;

  Game(this.id, this.title, this.thumbnail, this.genre, this.platform,
      this.release, this.description);

  factory Game.fromJson(Map<String, dynamic> data) {
    return Game(data['id'], data['title'], data['thumbnail'], data['genre'],
        data['platform'], data['release_date'], data['description']);
  }

  factory Game.fromJsonToPOJO(dynamic data) {
    return Game(data['id'], data['title'], data['thumbnail'], data['genre'],
        data['platform'], data['release_date'], data['description']);
  }
}

class GameDetailsScreen extends StatelessWidget {
  final int id;

  const GameDetailsScreen(this.id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          backgroundColor: Colors.white,
          title: Text(
            "Game Details",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: GameDetails(id));
  }
}

class GameDetails extends StatefulWidget {
  final int id;

  const GameDetails(this.id);

  @override
  State<StatefulWidget> createState() => _GameDetailsState(id);
}

class _GameDetailsState extends State<GameDetails> {
  final int id;

  _GameDetailsState(this.id);

  Game? game;
  var isLoading = true;

  void getData() async {
    var url = Uri.parse("https://www.freetogame.com/api/game?id=$id");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        game = Game.fromJsonToPOJO(jsonDecode(response.body.toString()));
        isLoading = false;
      });
    } else {
      print("${response.statusCode} Error");
    }
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.blueAccent,
                  strokeWidth: 4,
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(left: 16, right: 16, top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Card(
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          game!.thumbnail?? "",
                          fit: BoxFit.cover,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 4),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 8),
                              color: Colors.green,
                              child: Text(
                                game!.genre?? "",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12.0),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 4),
                            child: Text(
                              "Platform : ${game!.platform?? ""}",
                              style: TextStyle(fontSize: 14.0),
                            ),
                          )
                        ],
                      ),
                      Padding(
                          padding:
                              EdgeInsets.only(bottom: 8, left: 4, right: 4),
                          child: Text(
                            game!.title?? "",
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                          )),
                      Padding(
                        padding: EdgeInsets.only(bottom: 8, left: 4, right: 4),
                        child: Text(
                          "Release : ${game!.title?? ""}",
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                      Padding(
                          padding:
                              EdgeInsets.only(bottom: 16, left: 4, right: 4),
                          child: Text(
                            game!.description?? "",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.justify,
                          )),
                    ],
                  ),
                ),
              ));
  }
}
