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
  List<dynamic> _todoList = [];
  Map<String, dynamic> _ultimoRemovido;
  int _ultimoRemovidoPosicao;

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
    if (_tarefaController.text == "") {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                "Sua tarefa está vazia!",
              ),
              content: Text("Coloque alguma coisa nas suas tarefas :)"),
              actions: <Widget>[
                IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    })
              ],
            );
          });
    } else {
      setState(() {
        Map<String, dynamic> novaTarefa = Map();
        novaTarefa["tittle"] = _tarefaController.text;
        novaTarefa["estado"] = false;
        _tarefaController.text = "";
        _todoList.add(novaTarefa);
        _saveTarefas();
      });
    }
  }

  Future<Null> _recarregar() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _todoList.sort((a, b) {
        if (a["estado"] && !b["estado"])
          return 1;
        else if (!a["estado"] && b["estado"])
          return -1;
        else
          return 0;
      });

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
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 3, horizontal: 15),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _tarefaController,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
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
          Expanded(
            child: RefreshIndicator(
              child: ListView.builder(
                padding: EdgeInsets.only(top: 20.0),
                itemCount: _todoList.length,
                itemBuilder: itemBuilder,
              ),
              onRefresh: _recarregar,
            ),
          ),
        ],
      ),
    );
  }

  Widget itemBuilder(context, index) {
    return Dismissible(
      key: UniqueKey(),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_todoList[index]["tittle"]),
        value: _todoList[index]["estado"],
        secondary: CircleAvatar(
          child: Icon(_todoList[index]["estado"] ? Icons.check : Icons.error),
        ),
        onChanged: (ok) {
          setState(() {
            _todoList[index]["estado"] = ok;
            _saveTarefas();
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          _ultimoRemovido = Map.from(_todoList[index]);
          _ultimoRemovidoPosicao = index;
          _todoList.removeAt(index);
          _saveTarefas();
          final snack = SnackBar(
            content: Text("Tarefa \"${_ultimoRemovido["tittle"]}\" removida"),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    _todoList.insert(_ultimoRemovidoPosicao, _ultimoRemovido);
                    _saveTarefas();
                  });
                }),
            duration: Duration(seconds: 3),
          );
          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }

  Future<File> _getArquivo() async {
    final diretorio = await getApplicationDocumentsDirectory();
    final archive = File("${diretorio.path}/tarefas.json");
    if (archive.existsSync()) {
      return archive;
    } else {
      return File("${diretorio.path}/tarefas.json");
    }
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
