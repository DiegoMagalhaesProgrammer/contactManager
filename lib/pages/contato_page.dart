import 'dart:io';

import 'package:flutter/material.dart';

import 'package:teste_persistencia/models/contato.dart';
import 'package:image_picker/image_picker.dart';

class ContatoPage extends StatefulWidget {
  final Contato contato;
  ContatoPage({this.contato});

  @override
  _ContatoPageState createState() => _ContatoPageState();
}

class _ContatoPageState extends State<ContatoPage> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _nomeFocus = FocusNode();
  bool editado = false;
  Contato _editaContato;
  @override
  void initState() {
    super.initState();
    if (widget.contato == null) {
      _editaContato = Contato(null, '', '', null);
    } else {
      _editaContato = Contato.convertendoinverso(widget.contato.toMap());
      _nomeController.text = _editaContato.nome;
      _emailController.text = _editaContato.email;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text(
          _editaContato.nome == '' ? "Novo Contato" : _editaContato.nome,
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_editaContato.nome != null && _editaContato.nome.isNotEmpty) {
            Navigator.pop(context, _editaContato);
          } else {
            _alert("Erro", "Preecha o campo nome");
            FocusScope.of(context).requestFocus(_nomeFocus);
          }
        },
        child: Icon(
          Icons.save,
        ),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            GestureDetector(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    image: _editaContato.imagem != null
                        ? FileImage(
                            File(_editaContato.imagem),
                          )
                        : AssetImage("assets/person.png"),
                  ),
                ),
              ),
              onTap: () {
                ImagePicker.pickImage(source: ImageSource.camera).then((file) {
                  if (file == null) return;
                  setState(() {
                    _editaContato.imagem = file.path;
                  });
                });
              },
            ),
            TextField(
                focusNode: _nomeFocus,
                controller: _nomeController,
                decoration: InputDecoration(labelText: "Nome"),
                onChanged: (text) {
                  editado = true;
                  setState(() {
                    _editaContato.nome = text;
                  });
                }),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
              onChanged: (text) {
                editado = true;
                _editaContato.email = text;
              },
              keyboardType: TextInputType.emailAddress,
            )
          ],
        ),
      ),
    );
  }

  _alert(String text, String bodyAlert) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(text),
          content: new Text(bodyAlert),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Fechar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
