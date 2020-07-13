import 'dart:io';

import 'package:flutter/material.dart';
import 'package:teste_persistencia/helpers/database_helper.dart';
import 'package:teste_persistencia/models/contato.dart';
import 'package:teste_persistencia/pages/contato_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DatabaseHelper db = DatabaseHelper();
  List<Contato> contatos = List<Contato>();
  @override
  void initState() {
    super.initState();
    _exibecontatos();
  }

  void _exibecontatos() {
    db.getContatos().then((lista) {
      setState(() {
        contatos = lista;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agenda'),
        backgroundColor: Colors.indigo,
        centerTitle: true,
        actions: <Widget>[],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _exibeContatoPage();
        },
        child: Icon(
          Icons.add,
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: contatos.length,
        itemBuilder: (context, index) {
          return _listaContatos(context, index);
        },
      ),
    );
  }

  Widget _listaContatos(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Column(
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: contatos[index].imagem != null
                                ? FileImage(File(contatos[index].imagem))
                                : AssetImage("assets/person.png"))),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      contatos[index].nome ?? "",
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      contatos[index].email ?? "",
                      style: TextStyle(fontSize: 20),
                    ), 
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _confirmaExclusao(context, contatos[index].id, index);
                      }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        _exibeContatoPage(contato: contatos[index]);
      },
    );
  }

  void _exibeContatoPage({Contato contato}) async {
    final contatoRecebido = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContatoPage(contato: contato),
        ));
    if (contatoRecebido != null) {
      if (contato != null) {
        await db.updateContato(contatoRecebido);
      } else {
        await db.insertContato(contatoRecebido);
      }
      _exibecontatos();
    }
  }

  void _confirmaExclusao(BuildContext context, int id, int index) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Excluir Contato"),
            content: Text("Confirma exclusão do contato"),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancelar"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                  onPressed: () {
                    setState(() {
                      contatos.removeAt(index);
                      db.deleteContato(id);
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text("Excluir"))
            ],
          );
        });
  }
}
