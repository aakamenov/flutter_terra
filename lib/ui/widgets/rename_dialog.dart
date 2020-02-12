import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_terra/models/terrarium.dart';

class RenameDialog extends StatefulWidget {
  RenameDialog({Key key}) : super(key: key);

  @override
  _RenameDialogState createState() => _RenameDialogState();

  static Future<String> show(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return RenameDialog();
      }
    );
  }
}

class _RenameDialogState extends State<RenameDialog> {
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final terrarium = Provider.of<Terrarium>(context);
    final error = validateInput(terrarium);

    return AlertDialog(
      title: Text("Creature name"),
      content: Container(
        child: TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: "Enter the creature's name:",
            errorText: error,
          ),
          onChanged: (value) {        
            setState(() {});
          },
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop(null);
          },
        ),
        FlatButton(
          child: Text("OK"),
          onPressed: error == null && _controller.text.isNotEmpty ?
            () {
              Navigator.of(context, rootNavigator: true).pop(_controller.text);
            }
            : null,
        )
      ],
    );
  }

  String validateInput(Terrarium terrarium) {
    final text = _controller.text;

    if(text.isEmpty) {
      return null;
    }

    if(terrarium.containsCreature(text)) {
      return 'This name already exists!';
    }

    return null;
  }
}
