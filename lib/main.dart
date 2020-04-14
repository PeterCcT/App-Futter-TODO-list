import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';

void main() {
  runApp(
    MaterialApp(
      title: "ToDo List",
      home: Home(),
    ),
  );
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map> _todoList = [];

  final _tarefaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getDados().then((dados) {
      setState(() {
        _todoList = json.decode(dados);
      });
    });
  }

  void _addTarefa() {
    setState(() {
      Map<String, dynamic> novaTarefa = Map();
      novaTarefa["tittle"] = _tarefaController.text;
      novaTarefa["estado"] = false;
      _tarefaController.text = "";
      _todoList.add(novaTarefa);
      _saveTarefas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.indigo,
        title: Text(
          "Lista de tarefas",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 15),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _tarefaController,
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.indigo,
                            width: 1.4,
                          ),
                        ),
                        hintText: "Digite sua tarefa",
                        hintStyle: TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: _addTarefa,
                    iconSize: 40,
                    splashColor: Colors.lightGreenAccent,
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: ScrollPhysics(),
              padding: EdgeInsets.only(top: 20.0),
              itemCount: _todoList.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(_todoList[index]["tittle"]),
                  value: _todoList[index]["estado"],
                  secondary: CircleAvatar(
                    child: Icon(
                        _todoList[index]["estado"] ? Icons.check : Icons.error),
                  ),
                  onChanged: (ok) {
                    setState(() {
                      _todoList[index]["estado"] = ok;
                      _saveTarefas();
                    });
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<File> _getArquivo() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/tarefas.json");
  }

  Future<File> _saveTarefas() async {
    String dado = json.encode(_todoList);
    final arquivo = await _getArquivo();
    return arquivo.writeAsString(dado);
  }

  Future<String> _getDados() async {
    try {
      final arquivo = await _getArquivo();
      return arquivo.readAsString();
    } catch (error) {
      return null;
    }
  }
}
