import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:menu_app/models/LoginAuth.dart';
import 'package:menu_app/models/ResturauntItem.dart';
import 'package:menu_app/pages/item-editor.dart';
import 'package:menu_app/pages/item.dart';
import 'package:intl/intl.dart';
import '../main.dart';

Future<List<ResturauntItem>> fetchItems() async {
  final response = await http.get(Uri.parse('$endpoint/items'));
  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    List<ResturauntItem> allItems = <ResturauntItem>[];
    for (var item in data['results']) {
      allItems.add(ResturauntItem.fromJSON(item));
    }
    return allItems;
  }
  return [];
}

Future<bool> isLoggedIn() async {
  return await SessionManager().containsKey("loginAuth");
}

class ListPage extends StatefulWidget {
  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  late Future<List<ResturauntItem>> futureItems;
  late Future<bool> loggedIn;

  @override
  void initState() {
    super.initState();
    futureItems = fetchItems();
    loggedIn = isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([loggedIn, futureItems]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          return Scaffold(
              appBar: AppBar(
                title: const Text('Menu'),
              ),
              floatingActionButton: Builder(builder: (BuildContext context) {
                if (snapshot.hasData && snapshot.data![0]) {
                  return FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ItemEditorPage(null))).then((_) => {
                            setState(() {
                              futureItems = fetchItems();
                            })
                          });
                    },
                    backgroundColor: Colors.blue,
                    child: const Icon(Icons.add),
                  );
                }
                // "Null"
                return const SizedBox.shrink();
              }),
              body: Builder(builder: (BuildContext context) {
                if (snapshot.hasData && snapshot.data != null) {
                  final items = snapshot.data![1];
                  return ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: items?.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ItemPage(items![index].id)));
                            },
                            child: Container(
                                padding: const EdgeInsets.all(8),
                                child: Row(children: <Widget>[
                                  Expanded(
                                      child: Text('${items?[index].name}')),
                                  Text(NumberFormat.simpleCurrency(name: 'USD')
                                      .format(items?[index].price)),
                                ]))); // Text('${items?[index].name}'))
                      });
                } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return const Text('No Data');
                } else {
                  return const Text('Loading....');
                }
              }));
        });
  }
}
