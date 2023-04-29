import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:menu_app/models/LoginAuth.dart';
import 'package:menu_app/models/ResturauntItem.dart';
import '../main.dart';

class ItemEditorPage extends StatefulWidget {
  final String? id;

  const ItemEditorPage(this.id, {super.key});

  @override
  State<ItemEditorPage> createState() => _ItemEditorPageState();
}

class _ItemEditorPageState extends State<ItemEditorPage> {
  var loading = false;
  var isEdit = false;
  final _formKey = GlobalKey<FormState>();
  late Future<ResturauntItem?> futureItem;
  late Future<String?> authenticationToken;
  late TextEditingController nameController = TextEditingController();
  late TextEditingController descriptionController = TextEditingController();
  late TextEditingController caloriesController = TextEditingController();
  late TextEditingController priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureItem = fetchItem(widget.id);
    authenticationToken = fetchToken();
    //
  }

  Future<String?> fetchToken() async {
    var login = await SessionManager().containsKey("loginAuth");
    if (!login) {
      return null;
    }
    dynamic loginAuth = await SessionManager().get("loginAuth");
    LoginAuth parsedLoginAuth = LoginAuth.fromSession(loginAuth);
    return parsedLoginAuth.getAccessToken();
  }

  Future<ResturauntItem?> fetchItem(String? id) async {
    var item;
    if (id == null) {
      return item;
    }
    final response = await http.get(Uri.parse('$endpoint/items/$id'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      debugPrint(response.body);
      item = ResturauntItem.fromJSON(data);
    }
    if (item != null) {
      isEdit = true;
      nameController =
          TextEditingController.fromValue(TextEditingValue(text: item.name));
      descriptionController = TextEditingController.fromValue(
          TextEditingValue(text: item.description));
      priceController = TextEditingController.fromValue(
          TextEditingValue(text: '${item.price}'));
      caloriesController = TextEditingController.fromValue(
          TextEditingValue(text: '${item.calories}'));
    }
    return item;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Item Management'),
        ),
        body: Center(
            child: FutureBuilder(
                future: Future.wait([futureItem, authenticationToken]),
                builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                  if (!snapshot.hasData) {
                    return const Text("Loading");
                  }
                  final item = snapshot.data![0];
                  // Draw Item Thing Here
                  return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            constraints: const BoxConstraints(maxWidth: 200),
                            margin: const EdgeInsets.all(8.0),
                            child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    Container(
                                        margin: const EdgeInsets.only(
                                            top: 12, bottom: 12),
                                        child: TextFormField(
                                          controller: nameController,
                                          decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              label: Text('Name')),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please Enter Item Name';
                                            }
                                            return null;
                                          },
                                        )),
                                    Container(
                                        margin: const EdgeInsets.only(
                                            top: 12, bottom: 12),
                                        child: TextFormField(
                                          controller: descriptionController,
                                          decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              label: Text('Description')),
                                        )),
                                    Container(
                                        margin: const EdgeInsets.only(
                                            top: 12, bottom: 12),
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          controller: priceController,
                                          decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              label: Text('Price')),
                                          validator: (value) {
                                            try {
                                              if (value == null ||
                                                  double.parse(value) < 0) {
                                                return 'Please Enter Valid Price';
                                              }
                                            } catch (e) {
                                              return 'Please Enter Valid Number!';
                                            }
                                            return null;
                                          },
                                        )),
                                    Container(
                                        margin: const EdgeInsets.only(
                                            top: 12, bottom: 12),
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          controller: caloriesController,
                                          decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              label: Text('Calories')),
                                          validator: (value) {
                                            try {
                                              if (value == null ||
                                                  double.parse(value) < 0) {
                                                return 'Please Enter Valid Calorie Count';
                                              }
                                            } catch (e) {
                                              return 'Please Enter Valid Number!';
                                            }
                                            return null;
                                          },
                                        )),
                                    Container(
                                        margin: const EdgeInsets.only(
                                            top: 12, bottom: 12),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              minimumSize: Size(100, 45)),
                                          onPressed: loading
                                              ? null
                                              : () async {
                                                  // Validate returns true if the form is valid, or false otherwise.
                                                  if (_formKey.currentState!
                                                      .validate()) {
                                                    setState(() {
                                                      loading = true;
                                                    });
                                                    try {
                                                      var resp;
                                                      if (isEdit) {
                                                        resp = await http.patch(
                                                            Uri.parse(
                                                                '$endpoint/items/${item!.id}'),
                                                            body: jsonEncode({
                                                              "name":
                                                                  nameController
                                                                      .text,
                                                              "description":
                                                                  descriptionController
                                                                      .text,
                                                              "price": double.parse(
                                                                  priceController
                                                                      .text),
                                                              "calories": int.parse(
                                                                  caloriesController
                                                                      .text)
                                                            }),
                                                            headers: {
                                                              "Authorization":
                                                                  "Bearer ${snapshot.data![1]}",
                                                              "Content-Type":
                                                                  "application/json"
                                                            });
                                                      } else {
                                                        resp = await http.post(
                                                            Uri.parse(
                                                                '$endpoint/items/'),
                                                            body: jsonEncode({
                                                              "name":
                                                                  nameController
                                                                      .text,
                                                              "description":
                                                                  descriptionController
                                                                      .text,
                                                              "price": double.parse(
                                                                  priceController
                                                                      .text),
                                                              "calories": int.parse(
                                                                  caloriesController
                                                                      .text)
                                                            }),
                                                            headers: {
                                                              "Authorization":
                                                                  "Bearer ${snapshot.data![1]}",
                                                              "Content-Type":
                                                                  "application/json"
                                                            });
                                                      }
                                                      if (resp.statusCode >=
                                                              200 &&
                                                          resp.statusCode <
                                                              300) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                                "Success!"),
                                                          ),
                                                        );
                                                        Navigator.pop(context);
                                                      } else {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                                "Failed to Update/Create"),
                                                          ),
                                                        );
                                                        setState(() {
                                                          loading = false;
                                                        });
                                                      }
                                                      // stuff
                                                    } catch (e) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              "Failed to Update/Create"),
                                                        ),
                                                      );
                                                    }
                                                    setState(() {
                                                      loading = false;
                                                    });
                                                  }
                                                },
                                          child:
                                              Text(isEdit ? 'Edit' : 'Create'),
                                        )),
                                    Builder(builder: (context) {
                                      if (!isEdit) {
                                        return const SizedBox.shrink();
                                      }
                                      return Container(
                                          margin: const EdgeInsets.only(
                                              top: 12, bottom: 12),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                minimumSize: Size(100, 45)),
                                            onPressed: loading
                                                ? null
                                                : () => showDialog<String>(
                                                      context: context,
                                                      builder: (BuildContext
                                                              context) =>
                                                          AlertDialog(
                                                        title: const Text(
                                                            'AlertDialog Title'),
                                                        content: const Text(
                                                            'AlertDialog description'),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context,
                                                                    'Cancel'),
                                                            child: const Text(
                                                                'Cancel'),
                                                          ),
                                                          TextButton(
                                                            onPressed:
                                                                () async {
                                                              setState(() {
                                                                loading = true;
                                                              });
                                                              try {
                                                                if (isEdit) {
                                                                  var resp = await http.delete(
                                                                      Uri.parse(
                                                                          '$endpoint/items/${item!.id}'),
                                                                      headers: {
                                                                        "Authorization":
                                                                            "Bearer ${snapshot.data![1]}",
                                                                        "Content-Type":
                                                                            "application/json"
                                                                      });
                                                                  if (resp.statusCode >=
                                                                          200 &&
                                                                      resp.statusCode <
                                                                          300) {
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                      const SnackBar(
                                                                        content:
                                                                            Text("Updated!"),
                                                                      ),
                                                                    );
                                                                    Navigator.popUntil(
                                                                        context,
                                                                        (route) =>
                                                                            route.settings.name ==
                                                                            '/list');
                                                                  } else {
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                      const SnackBar(
                                                                        content:
                                                                            Text("Failed to Delete"),
                                                                      ),
                                                                    );
                                                                    setState(
                                                                        () {
                                                                      loading =
                                                                          false;
                                                                    });
                                                                  }
                                                                }
                                                                // stuff
                                                              } catch (e) {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  const SnackBar(
                                                                    content: Text(
                                                                        "Failed to Delete"),
                                                                  ),
                                                                );
                                                              }
                                                              setState(() {
                                                                loading = false;
                                                              });
                                                            },
                                                            child: const Text(
                                                                'OK'),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                            child: const Text("Delete"),
                                          ));
                                    })
                                  ],
                                )))
                      ]);
                })));
  }
}
