import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

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
  List<dynamic> listValue = [];
  List<List<dynamic>> listList = [];
  final fb = FirebaseDatabase.instance;

  late DatabaseReference todos = fb.ref().child(widget.title.toLowerCase());
  int totalDia = 0;
  int totalHoje = 0;
  double totalDiaPercent = 1.0;
  double totalHojePercent = 1.0;
  int totalPlantao = 0;
  String lastDay = "";
  int lastDayVerifier = 0;
  TextEditingController qtdController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  DateTime? pickedDate;
  String shitCounter = "";
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
    qtdController.text = type.toLowerCase() == "fralda" ? "Apenas xixi" : "";
    List<DropdownMenuItem<String>> cnhCategories = const [
      DropdownMenuItem(
          value: "Apenas xixi", child: Center(child: Text("Apenas xixi"))),
      DropdownMenuItem(
          value: "Pouco cocô", child: Center(child: Text("Pouco cocô"))),
      DropdownMenuItem(
          value: "Médio cocô", child: Center(child: Text("Médio cocô"))),
      DropdownMenuItem(
          value: "Muito cocô", child: Center(child: Text("Muito cocô"))),
      DropdownMenuItem(
          value: "Diarréia", child: Center(child: Text("Diarréia")))
    ];

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
                      child: Text(
                        type,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 40),
                      ),
                    ),
                    Container(
                        decoration: BoxDecoration(border: Border.all()),
                        child: type.toLowerCase() == "leite"
                            ? TextField(
                                controller: qtdController,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  hintText: 'Quantidade',
                                ),
                              )
                            : DropdownButtonFormField(
                                icon: Icon(Icons.expand_more_rounded,
                                    color: Theme.of(context).primaryColor),
                                value: qtdController.text,
                                isExpanded: true,
                                alignment: Alignment.center,
                                onChanged: (String? value) async {
                                  qtdController.text = value!;
                                },
                                items: cnhCategories)),
                    const SizedBox(
                      height: 10,
                    ),
                    MaterialButton(
                      minWidth: MediaQuery.of(context).size.width,
                      color: Colors.cyan,
                      onPressed: () {
                        if (type.toLowerCase() == "leite") {
                          sumCounter(int.parse(qtdController.text));
                        }
                        ref.set({
                          "type": type.toLowerCase(),
                          "qtd": qtdController.text,
                          "datetime": DateTime.now().toString(),
                          "ativo": "1"
                        }).asStream();
                        qtdController.clear();
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (_) => AddNote(title: widget.title)));
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          "Salvar",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
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

  getCounter() {
    DateTime? dataTest;
    int id = 0;
    todos.once().then((snapshot) {
      Map<dynamic, dynamic> values =
          snapshot.snapshot.value as Map<dynamic, dynamic>;
      values.forEach((key, value) {
        DateTime data = DateTime.parse(value['datetime'].toString());
        DateTime dataInicial = DateTime.parse(
            DateTime.now().subtract(const Duration(days: 1)).toString());
        DateTime dataFinal = DateTime.parse(DateTime.now().toString());
        if (value['type'] == "leite") {
          if (dataInicial.isBefore(data) && dataFinal.isAfter(data)) {
            setState(() {
              totalDia += int.parse(value['qtd']);
            });

            totalDiaPercent = double.parse(totalDia.toString()) * 100.0;
            totalDiaPercent = totalDiaPercent / 96000.0;
            totalDiaPercent > 1 ? totalDiaPercent = 1 : totalDiaPercent;
          }
          if (data.day == dataFinal.day && dataFinal.month == data.month) {
            setState(() {
              totalHoje += int.parse(value["qtd"]);
            });
            totalHojePercent = double.parse(totalHoje.toString()) * 100.0;
            totalHojePercent = totalHojePercent / 96000.0;
            totalHojePercent > 1 ? totalHojePercent = 1 : totalHojePercent;
          }
        }

        if (value["qtd"].toString().contains("coco") ||
            value["qtd"].toString().contains("cocô")) {
          shitCounter = DateFormat('dd/MM HH:mm', 'pt_Br')
              .format(DateTime.parse(value["datetime"]));
        }
        dataTest ??= data;

        if (dataTest!.day != data.day) {
          listList.insert(id, listValue);
          id++;
          listValue.clear();
          dataTest = data;
        }

        if (dataTest!.day == data.day) {
          listValue.add(value);
        }
      });
    });
  }

  sumCounter(int value) {
    setState(() {
      totalDia += value;
      totalHoje += value;
    });
  }

  String getMetric(type) {
    if (type == 'leite') {
      return "ml";
    }
    return "";
  }

  int getDateTimeId() {
    DateTime date = DateTime.now();
    String dateWorkers = date.year.toString() +
        date.month.toString().padLeft(2, '0') +
        date.day.toString().padLeft(2, '0') +
        date.hour.toString().padLeft(2, '0') +
        date.minute.toString() +
        date.second.toString().padLeft(2, '0');
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
                child: const Icon(Icons.medication_liquid, color: Colors.white),
                label: 'Leite',
                onTap: () => openModal("Leite"),
              ),
              SpeedDialChild(
                backgroundColor: Colors.cyan.shade300,
                child: const Icon(Icons.baby_changing_station,
                    color: Colors.white),
                label: 'Fralda',
                onTap: () => openModal("Fralda"),
              )
            ]),
        body: Column(
          children: [
            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.width / 3,
                        width: MediaQuery.of(context).size.width / 3,
                        child: Center(
                          child: CircularPercentIndicator(
                            radius: 80.0,
                            lineWidth: 13.0,
                            animation: true,
                            percent: totalDiaPercent,
                            center: Text(
                              "${totalDia.toString()}ml/960ml",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20.0),
                            ),
                            footer: const Text(
                              "Leite/24h",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17.0),
                            ),
                            circularStrokeCap: CircularStrokeCap.round,
                            progressColor: Colors.blue,
                          ),
                        ),
                      ),
                    )),
                shitCounter != ""
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Último cocô",
                              style: TextStyle(fontSize: 25)),
                          Text(shitCounter,
                              style: const TextStyle(fontSize: 15)),
                        ],
                      )
                    : const SizedBox(),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.width / 3,
                        width: MediaQuery.of(context).size.width / 3,
                        child: Center(
                          child: CircularPercentIndicator(
                            radius: 80.0,
                            lineWidth: 13.0,
                            animation: true,
                            percent: totalHojePercent,
                            center: Text(
                              "${totalHoje.toString()}ml/960ml",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20.0),
                            ),
                            footer: const Text(
                              "Leite hoje",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17.0),
                            ),
                            circularStrokeCap: CircularStrokeCap.round,
                            progressColor: Colors.blue,
                          ),
                        ),
                      ),
                    )),
              ],
            )),
            Expanded(
              child: SingleChildScrollView(
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 1,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        child: ExpansionTile(
                            title: Text(DateFormat('dd MMMM', 'pt_Br').format(
                                DateTime.parse(
                                    listList[0][index]["datetime"]))),
                            children: <Widget>[
                              Column(
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: listList[index].length,
                                    itemBuilder: (context, i) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ListTile(
                                          leading: listList[index][i]["type"] ==
                                                  'fralda'
                                              ? Image.asset(AppImages.fralda)
                                              : Image.asset(AppImages.leite),
                                          title: Text(
                                            DateFormat('HH:mm', 'pt_Br').format(
                                                DateTime.parse(listList[index]
                                                    [i]["datetime"])),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 30),
                                          ),
                                          subtitle: Row(children: [
                                            Text(
                                              listList[index][i]["type"] ==
                                                      "leite"
                                                  ? listList[index][i]["qtd"] +
                                                      "ml"
                                                  : listList[index][i]["qtd"],
                                              style:
                                                  const TextStyle(fontSize: 20),
                                            )
                                          ]),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ]),
                      );
                    }),
              ),
            ),
          ],
        ));
  }
}

class AppImages {
  static String get fralda => "assets/images/fralda.png";
  static String get leite => "assets/images/leite.png";
}
