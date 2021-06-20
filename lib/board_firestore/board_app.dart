import 'dart:collection';

import 'package:firebase/board_firestore/ui/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BoardApp extends StatefulWidget {
  @override
  _BoardAppState createState() => _BoardAppState();
}

class _BoardAppState extends State<BoardApp> {

  var firestoreDB = FirebaseFirestore.instance;
  late TextEditingController nameInputController;
  late TextEditingController titleInputController;
  late TextEditingController descriptionInputController;

  var key;

  @override
  void initState() {
    super.initState();
    nameInputController = TextEditingController();
    titleInputController = TextEditingController();
    descriptionInputController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Firestore"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _inflateMyDialog(context);
        },
        child: Icon(FontAwesomeIcons.pen),
      ),
      body: StreamBuilder(
        stream: firestoreDB.collection("board").snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
          if(!snapshot.hasData) return CircularProgressIndicator();
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, int index){
                //return Text(snapshot.data!.docs[index]['title'].toString());
                return CustomCard(snapshot.data!, index);
              }
          );
        },
      ),
    );
  }

  //@override
  Widget dialogExpanded(BuildContext context, String _labelText, TextEditingController _controller){
    return Expanded(
      child: TextField(
        autofocus: true,
        decoration: InputDecoration(
          labelText: _labelText,
        ),
        controller: _controller,
      ),
    );
  }

  Widget dialogButtons(String _buttonText, String _methodCall){
    return TextButton(
        onPressed: () {
          if(_methodCall == "clear"){
            _clearInputs();
          }else{
            _submitDataToFirestore(context);
          }
        },
        child: Text(_buttonText));
  }
  
  Future<void> _inflateMyDialog(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context){
          return AlertDialog(
            contentPadding: EdgeInsets.all(10.0),
            content: Column(
              children: <Widget>[
                Text("Please fill out the form"),
                dialogExpanded(context, "Your Name", nameInputController),
                dialogExpanded(context, "Title", titleInputController),
                dialogExpanded(context, "Description", descriptionInputController)
              ],
            ),
            actions: <Widget>[
              dialogButtons("Cancel", "clear"),
              dialogButtons("Submit", "submit")
            ],
          );
        });
  }

  _submitDataToFirestore(BuildContext context){
    Map<String, Object> map = new HashMap();
    map['title'] = titleInputController.text;
    map['description'] = descriptionInputController.text;
    map['name'] = nameInputController.text;
    if(nameInputController.text.isNotEmpty && titleInputController.text.isNotEmpty && descriptionInputController.text.isNotEmpty){
      FirebaseFirestore.instance.collection("board").add({
        "name": nameInputController.text,
        "title": titleInputController.text,
        "description": descriptionInputController.text,
        "timestamp": new DateTime.now().millisecondsSinceEpoch
      }).then((value) =>{
        print(value.id),
        _insertKey(value.id, context)
      }).catchError((error) => print(error));
    }
  }

  _clearInputs(){
    nameInputController.clear();
    titleInputController.clear();
    descriptionInputController.clear();
    Navigator.pop(context);
  }

  _insertKey(String id, BuildContext context){
    FirebaseFirestore.instance.collection("board").doc(id).update({
      "id": id
    }).then((value) => {
      _displaySnackbar(context),
      _clearInputs()
    }).catchError((error) => print(error));
  }

  _displaySnackbar(BuildContext context){
    final snackbar = SnackBar(
        content: Text("New Record Added!", style: TextStyle(color: Colors.black),),
      backgroundColor: Colors.blue,
      duration: Duration(
        milliseconds: 1000
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }


  
}



