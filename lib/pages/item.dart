import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:menu_app/models/LoginAuth.dart';
import 'package:menu_app/models/ResturauntItem.dart';
import 'package:menu_app/pages/item-editor.dart';
import '../main.dart';

Future<ResturauntItem?> fetchItem(String id) async {
  final response = await http.get(Uri.parse('$endpoint/items/$id'));
  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    return ResturauntItem.fromJSON(data);
  }
  return null;
}

Future<bool> isLoggedIn() async {
  return await SessionManager().containsKey("loginAuth");
}

class ItemPage extends StatefulWidget {
  final String id;

  const ItemPage(this.id, {super.key});

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  late Future<ResturauntItem?> futureItem;
  late Future<bool> loggedIn;
  @override
  void initState() {
    super.initState();
    futureItem = fetchItem(widget.id);
    loggedIn = isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([loggedIn, futureItem]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          return Scaffold(
              appBar: AppBar(
                title: const Text('About'),
              ),
              floatingActionButton: Builder(builder: (BuildContext context) {
                if (snapshot.hasData && snapshot.data![0]) {
                  debugPrint(snapshot.data![0] ? "yea" : "no");
                  final item = snapshot.data![1];
                  return FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ItemEditorPage(item.id))).then((_) {
                        // This block runs when you have returned back to the 1st Page from 2nd.
                        setState(() {
                          futureItem = fetchItem(widget.id);
                        });
                      });
                      ;
                    },
                    backgroundColor: Colors.blue,
                    child: const Icon(Icons.edit),
                  );
                }
                // "Null"
                return const SizedBox.shrink();
              }),
              body: Builder(builder: (BuildContext context) {
                if (snapshot.hasData && snapshot.data!.length == 2) {
                  if (snapshot.data![1] == null) {
                    return const Text("Item does not exist");
                  }
                  final item = snapshot.data![1];
                  // Draw Item Thing Here
                  return ListView(
                    padding: const EdgeInsets.all(8),
                    children: [
                      Text(item!.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(item.description),
                      Text(NumberFormat.simpleCurrency(name: 'USD')
                          .format(item.price)),
                      Text('${item.calories} calories'),
                    ],
                  );
                } else if (snapshot.data == null) {
                  return const Text('No Data');
                } else {
                  return const Text('Loading....');
                }
              }));
        });
  }
}
