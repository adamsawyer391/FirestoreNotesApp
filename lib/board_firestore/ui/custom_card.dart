
import 'dart:collection';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomCard extends StatelessWidget {


  late final QuerySnapshot snapshot;
  late final int index;
  var _snapshotData;
  var _documentID;
  var firestoreDB = FirebaseFirestore.instance;
  late TextEditingController nameInputController = TextEditingController();
  late TextEditingController titleInputController = TextEditingController();
  late TextEditingController descriptionInputController = TextEditingController();

  CustomCard(this.snapshot, this.index);

  @override
  Widget build(BuildContext context) {
    int adjust = index + 1;
    String number = adjust.toString();


    _snapshotData = snapshot.docs[index];
    _documentID = snapshot.docs[index].id;

    var timestamp = new DateTime.fromMillisecondsSinceEpoch(_snapshotData['timestamp'] * 1000);
    var time = new DateFormat("EEEE, MMM dd").format(timestamp);

    return Column(
      children: <Widget>[
        Container(
          height: 190,
          child: Card(
            shadowColor: Colors.blue.shade900,
            elevation: 10,
            margin: EdgeInsets.only(left: 10.0, top: 5.0, right: 10.0, bottom: 5.0),
            child: Column(
              children: [
                _deliverListTile(number),
                _displayRow("name", time, context),
                _displayRow("time", time, context),
                _displayRow("edit", time, context)
              ],
            ),
          ),
        ),
      ],
    );
  }

  _deliverListTile(String number){
    return ListTile(
      title: Text(_snapshotData['title'].toString(), style: _setStyle(19.0, FontWeight.bold, Colors.black, FontStyle.normal)),
      subtitle: Text(_snapshotData['description'], style: _setStyle(16.0, FontWeight.normal, Colors.black, FontStyle.italic)),
      leading: CircleAvatar(
        backgroundColor: Colors.pink.shade100,
        radius: 34,
        child: Text(number, style: TextStyle(color: Colors.black),),
      ),
    );
  }

  _setStyle(double fontSize, FontWeight weight, Color color, FontStyle fontStyle){
    return TextStyle(
        fontSize: fontSize,
        fontWeight: weight,
        color: color,
        fontStyle: fontStyle
    );
  }

  _deliverIconButton(BuildContext context, String purpose){
    if(purpose == "edit"){
      nameInputController.text = _snapshotData['name'].toString();
      titleInputController.text = _snapshotData['title'].toString();
      descriptionInputController.text = _snapshotData['description'].toString();
      return IconButton(
          onPressed: () async {
            await showDialog(
                context: context,
                builder: (context){
                  return AlertDialog(
                    contentPadding: EdgeInsets.all(10),
                    content: Column(
                      children: <Widget>[
                        Text("Please fill out the form"),
                        dialogExpanded(context, "Your Name", nameInputController),
                        dialogExpanded(context, "Title", titleInputController),
                        dialogExpanded(context, "Description", descriptionInputController)
                      ],
                    ),
                    actions: <Widget>[
                      dialogButtons("Cancel", "clear", context),
                      dialogButtons("Submit", "submit", context)
                    ],
                  );
                });
          },
          icon: Icon(FontAwesomeIcons.edit, color: Colors.blue, size: 20,));
    }else if(purpose == "trash"){
      return IconButton(
          onPressed: () async {
           // _printMessage(_documentID);
            var _collection_reference = FirebaseFirestore.instance.collection("board");
            await _collection_reference.doc(_documentID).delete();
          },
          icon: Icon(FontAwesomeIcons.trashAlt, color: Colors.red, size: 20,));
    }

  }

  _displayRow(String row, var time, BuildContext context){
    switch(row){
      case "name":
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text("Submitted by: ${_snapshotData["name"]}")
          ],
        );
        break;
      case "time":
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text(time.toString())
          ],
        );
        break;
      case "edit":
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _deliverIconButton(context, "edit"),
            SizedBox(height: 19,),
            _deliverIconButton(context, "trash")
          ],
        );
        break;

    }


  }

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

  Widget dialogButtons(String _buttonText, String _methodCall, BuildContext context){
    return TextButton(
        onPressed: () {
          if(_methodCall == "clear"){
            _clearInputs(context);
          }else{
            Map<String, Object> map = new HashMap();
            map['title'] = titleInputController.text;
            map['description'] = descriptionInputController.text;
            map['name'] = nameInputController.text;
            FirebaseFirestore.instance.collection("board").doc(_documentID).update(map);
            _clearInputs(context);
          }
        },
        child: Text(_buttonText));
  }

  _clearInputs(BuildContext context){
    nameInputController.clear();
    titleInputController.clear();
    descriptionInputController.clear();
    Navigator.pop(context);
  }

  _printMessage(String message){
    print("........................................................................................................"
        + "\n"
        + "\n"
        + "\n"
        + message);
  }

}


