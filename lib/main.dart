import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final int _counter = 0;
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();

  String domain = 'y8wsckyqiv.sharedwithexpose.com';

  Future<List<dynamic>> _incrementCounter() async {
    var url = Uri.https(domain, 'api/pets');
    var response = await http.get(url);
    // print('Response status: ${response.statusCode}');
    // print('Response body: ${response.body}');

    String body = response.body;

    var pets = jsonDecode(body);

    return pets;
  }

  Future<void> removePet(int id) async {
    var url = Uri.https(domain, 'api/pets/$id');
    await http.delete(url);
    setState(() {});
  }

  Future<void> addPet(String name, String age) async {
    var url = Uri.https(domain, 'api/pets');
    var response = await http.post(url, body: {'name': name, 'age': age});
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    setState(() {});
  }

  Future<Map<String, dynamic>> showPet(int id) async {
    var url = Uri.https(domain, 'api/pets/$id');
    var response = await http.get(url);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> updatePet(int id, String name, String age) async {
    var url = Uri.https(domain, 'api/pets/$id');
    var response = await http.put(url, body: {'name': name, 'age': age});
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: FutureBuilder(
          future: _incrementCounter(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(snapshot.data[index]['name']),
                    onTap: () async {
                      //muestra un dialogo utilizando el showPet
                      Map<String, dynamic> pet =
                          await showPet(snapshot.data[index]['id']);
                      TextEditingController nameControllerUpdate =
                          TextEditingController(
                        text: pet['name'].toString(),
                      );
                      TextEditingController ageControllerUpdate =
                          TextEditingController(
                        text: pet['age'].toString(),
                      );
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Pet info'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('id: ${pet['id']}'),
                                TextField(
                                  controller: nameControllerUpdate,
                                  decoration: InputDecoration(
                                    hintText: 'Name',
                                  ),
                                ),
                                TextField(
                                  controller: ageControllerUpdate,
                                  decoration: InputDecoration(
                                    hintText: 'Age',
                                  ),
                                ),
                                Text('Create: ${pet['created_at']}'),
                                Text('Update: ${pet['updated_at']}'),
                              ],
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await updatePet(
                                    pet['id'],
                                    nameControllerUpdate.text,
                                    ageControllerUpdate.text,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Pet updated'),
                                    ),
                                  );
                                  Navigator.of(context).pop();
                                },
                                child: Text('Guardar'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    trailing: IconButton(
                      onPressed: () async {
                        await removePet(snapshot.data[index]['id']);

                        //muestra un dialogo de confimracion que se elimino la mascota
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Pet removed'),
                              content: Text(
                                  'The pet ${snapshot.data[index]['name']} was removed'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: Icon(
                        Icons.delete,
                      ),
                    ),
                  );
                },
              );
            } else {
              return const CircularProgressIndicator();
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //crea un input dialog para agregar una mascota
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Add a pet'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                      ),
                    ),
                    TextField(
                      controller: ageController,
                      decoration: InputDecoration(
                        labelText: 'Age',
                      ),
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      await addPet(
                        nameController.text,
                        ageController.text,
                      );
                      nameController.clear();
                      ageController.clear();
                      //pon un snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Pet added'),
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                    child: Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
