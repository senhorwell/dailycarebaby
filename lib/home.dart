import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AddNote extends StatefulWidget {
  String title;
  AddNote({super.key, required this.title});
  @override
  AddNoteState createState() => AddNoteState();
}

class AddNoteState extends State<AddNote> {
  var k;
  var ref;
  final fb = FirebaseDatabase.instance;

  late DatabaseReference todos = fb.ref().child(widget.title.toLowerCase());
  int totalDia = 0;
  int totalHoje = 0;
  int totalPlantao = 0;
  String lastDay = "";
  int lastDayVerifier = 0;
  TextEditingController qtdController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  DateTime? pickedDate;

  IconData getIcon(type) {
    switch (type) {
      case 'leite':
        return Icons.medication_liquid;
      case 'fralda':
        return Icons.baby_changing_station;
      case 'vomito':
        return Icons.sick;
      case 'febre':
        return Icons.thermostat;
    }
    return Icons.add;
  }

  openModal(type) {
    k = getDateTimeId();
    ref = fb.ref().child('${widget.title.toLowerCase()}/$k');
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
                        controller: qtdController,
                        textAlign: TextAlign.center,
                        keyboardType: type.toLowerCase() == "leite" || type.toLowerCase() == "febre" ? TextInputType.number : TextInputType.text,
                        decoration: const InputDecoration(
                          hintText: 'Quantidade',
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    MaterialButton(
                      color: Colors.cyan,
                      onPressed: () {
                        if(type.toLowerCase() == "leite") {
                          sumCounter(int.parse(qtdController.text));
                        }
                        ref.set({
                          "type": type.toLowerCase(),
                          "qtd": qtdController.text,
                          "datetime": DateTime.now().toString()
                        }).asStream();
                        qtdController.clear();
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

  openFilterModal() {
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 10, 0),
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          alignment: FractionalOffset.topRight,
                          child: GestureDetector(
                            child: const Icon(
                              Icons.clear,
                              color: Colors.black,
                            ),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: const Text("Fitro"),
                    ),
                    Container(
                      decoration: BoxDecoration(border: Border.all()),
                      child: TextField(
                          controller: dateController,
                          decoration: InputDecoration(
                              icon: const Icon(Icons.calendar_today),
                              labelText: "Data",
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  dateController.clear();
                                },
                              )),
                          readOnly: true,
                          onTap: () async {
                            pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101));

                            String formattedDate =
                                DateFormat('dd/MM').format(pickedDate!);

                            setState(() {
                              dateController.text = formattedDate;
                            });
                          }),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    MaterialButton(
                      color: Colors.cyan,
                      onPressed: () async {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "Filtrar",
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
  int verificaPlantao(DateTime data) {
    if (data.hour >= 07 && data.hour < 19) {
      return 1;
    }
    
    return 2;
  }
  getCounter() async {
    todos.once().then((snapshot){
    Map<dynamic, dynamic> values = snapshot.snapshot.value as Map<dynamic, dynamic>;    
    values.forEach((key, value) {
      DateTime data = DateTime.parse(value['datetime'].toString());
      DateTime dataInicial = DateTime.parse(DateTime.now().subtract(const Duration(days: 1)).toString());
      DateTime dataFinal = DateTime.parse(DateTime.now().toString());
      if (value['type'] == "leite") {
        if (dataInicial.isBefore(data) && dataFinal.isAfter(data)) {
          setState(() {
            totalDia += int.parse(value['qtd']);
          });
        }
        if (data.day == dataFinal.day && dataFinal.month == data.month) {
          setState(() {
            totalHoje += int.parse(value["qtd"]);
          });
        }
      }
    });
  });
  }

  sumCounter(int value) {
    setState(() {
      totalDia += value;
    });
  }

  String getMetric(type) {
    if(type == 'leite') {
      return "ml";
    }
    return "";
  }

  int getDateTimeId() {
    DateTime date = DateTime.now();
    String dateWorkers = date.year.toString() + date.month.toString().padLeft(2, '0') + date.day.toString().padLeft(2, '0')  + date.hour.toString().padLeft(2, '0') + date.minute.toString() + date.second.toString().padLeft(2, '0');
    return int.parse(dateWorkers);
  }
  @override
  void initState() {
    getCounter();
    todos = fb.ref().child(widget.title.toLowerCase());
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Colors.cyan.shade300,
      ),
      floatingActionButton: SpeedDial(
          icon: Icons.add,
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
            ),
            SpeedDialChild(
              backgroundColor: Colors.cyan.shade300,
              child: const Icon(Icons.filter_alt),
              label: 'Filtro',
              onTap: () => openFilterModal(),
            )
          ]),
      body: Column(
        children: [
          Flexible(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(
                      child: Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(150)),
                          border: Border.all(
                            width: 3,
                            color: Colors.black,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(totalDia.toString(),style: const TextStyle(fontSize: 50)),
                              const Text("Leite/24h"),
                            ],
                          ),
                        ),
                      ),
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(
                      child: Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(150)),
                          border: Border.all(
                            width: 3,
                            color: Colors.black,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(totalHoje.toString(),style: const TextStyle(fontSize: 50)),
                              const Text("Leite hoje"),
                            ],
                          ),
                        ),
                      ),
                    )
                  )
              ],
            )
          ),
          Flexible(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.only(bottom:50.0),
              child: FirebaseAnimatedList(
                key: const ValueKey<bool>(false),
                query: todos,
                reverse: false,
                itemBuilder: (context, snapshot, animation, index) {
                  Map<dynamic, dynamic> values =
                      snapshot.value as Map<dynamic, dynamic>;

                  DateTime data = DateTime.parse(values['datetime'].toString());
                  
                  lastDayVerifier = 0;
                  if ('${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}' != lastDay.toString().padLeft(2, '0') || lastDay == '') {
                    lastDay = '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}';
                    lastDayVerifier = 1;
                  }
                  if (dateController.text.length > 4) {
                    if (pickedDate!.day != data.day ||
                        pickedDate!.month != data.month ||
                        pickedDate!.year != data.year) {
                      return const SizedBox();
                    }
                  }
                  return SizeTransition(
                    sizeFactor: animation,
                    child: Column(
                      children: [
                        lastDayVerifier == 1 ? 
                        Column(
                          children: [
                            Divider(),
                            Text(lastDay,style: TextStyle(fontSize: 25),)
                          ]
                        ) : const SizedBox(),
                        
                        
                        ListTile(
                          trailing: IconButton(
                            onPressed: () {
                              todos.child(snapshot.key!).remove();
                              if(values['type'] == 'leite') sumCounter(int.parse(values['qtd']) * (-1));
                            },
                            icon: const Icon(Icons.delete),
                          ),
                          leading: Icon(
                            getIcon(values['type']),
                            color: Colors.red,
                            size: 30,
                          ),
                          title: Text(
                              '${DateFormat('HH:mm').format(DateTime.parse(values['datetime']))}: ${values['qtd']}${getMetric(values['type'])}',style: TextStyle(fontSize: 20),),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
