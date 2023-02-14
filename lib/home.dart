import 'dart:convert';
import 'dart:math';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

class AddNote extends StatefulWidget {
  String title;
  AddNote({super.key, required this.title});
  @override
  AddNoteState createState() => AddNoteState();
}

class AddNoteState extends State<AddNote> {
  TextEditingController second = TextEditingController();
  var rng = Random();
  var k;
  var ref;
  var todos;
  TextEditingController third = TextEditingController();
  final fb = FirebaseDatabase.instance;

  openModal(type) {
    rng = Random();
    k = rng.nextInt(10000);
    ref = fb.ref().child(widget.title.toLowerCase() + '/$k');
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: Text(type),
                    ),
                    Container(
                      decoration: BoxDecoration(border: Border.all()),
                      child: TextField(
                        controller: third,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          hintText: 'Quantidade',
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    MaterialButton(
                      color: Colors.indigo[900],
                      onPressed: () {
                        ref.set({
                          "type": type.toLowerCase(),
                          "qtd": third.text,
                          "datetime": DateTime.now().toString()
                        }).asStream();
                        second.clear();
                        third.clear();
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "Salvar",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ]),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    rng = Random();
    k = rng.nextInt(10000);

    ref = fb.ref().child('${widget.title.toLowerCase()}/$k');
    todos = fb.ref().child(widget.title.toLowerCase());

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.cyan.shade300,
      ),
      floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_arrow,
          backgroundColor: Colors.cyan.shade300,
          children: [
            SpeedDialChild(
              backgroundColor: Colors.cyan.shade300,
              child: const Icon(Icons.medication_liquid),
              label: 'Leite',
              onTap: () => openModal("Leite"),
            ),
            SpeedDialChild(
              backgroundColor: Colors.cyan.shade300,
              child: const Icon(Icons.baby_changing_station),
              label: 'Fralda',
              onTap: () => openModal("Fralda"),
            ),
            SpeedDialChild(
              backgroundColor: Colors.cyan.shade300,
              child: const Icon(Icons.sick),
              label: 'Vômito',
              onTap: () => openModal("Vomito"),
            ),
            SpeedDialChild(
              backgroundColor: Colors.cyan.shade300,
              child: const Icon(Icons.thermostat),
              label: 'Febre',
              onTap: () => openModal("Febre"),
            )
          ]),
      body: Column(
        children: [
          Flexible(
            child: FirebaseAnimatedList(
              key: const ValueKey<bool>(false),
              query: todos,
              reverse: false,
              itemBuilder: (context, snapshot, animation, index) {
                Map<dynamic, dynamic> values =
                    snapshot.value as Map<dynamic, dynamic>;

                DateTime date = DateTime.parse(values["datetime"]);
                print(DateFormat('dd/MM/yyyy HH:mm').format(date));
                // DateTime data = DateTime.parse(
                //     _formatter.format(values['datetime']).toString());
                // DateTime dataInicial = DateTime.parse(
                //     DateTime.now().subtract(Duration(days: 1)).toString());
                // DateTime dataFinal = DateTime.parse(DateTime.now().toString());

                // print(data.toString());
                // print(dataInicial.toString());
                // print(dataFinal.toString());
                // print(dataFinal.isBefore(data));
                return SizeTransition(
                  sizeFactor: animation,
                  child: ListTile(
                    trailing: IconButton(
                      onPressed: () {
                        todos.child(snapshot.key!).remove();
                      },
                      icon: const Icon(Icons.delete),
                    ),
                    title: Text(
                        '${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(values['datetime']))} - ${values['type']}: ${values['qtd']}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
