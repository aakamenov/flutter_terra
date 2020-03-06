import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_terra/models/terrarium.dart';

class RenameDialog extends StatefulWidget {
  final String title;

  RenameDialog({this.title});

  @override
  _RenameDialogState createState() => _RenameDialogState();

  static Future<String> show(BuildContext context, {String title}) async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return RenameDialog(title: title);
      }
    );
  }
}

class _RenameDialogState extends State<RenameDialog> {
  TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final terrarium = Provider.of<Terrarium>(context);
    final error = validateInput(terrarium);

    return AlertDialog(
      title: Text(widget.title),
      content: Container(
        child: TextField(
          controller: controller,
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
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop(null);
          },
        ),
        FlatButton(
          child: const Text("OK"),
          onPressed: error == null && controller.text.isNotEmpty ?
            () {
              Navigator.of(context, rootNavigator: true).pop(controller.text);
            }
            : null,
        )
      ],
    );
  }

  String validateInput(Terrarium terrarium) {
    final text = controller.text;

    if(text.isEmpty) {
      return null;
    }

    if(terrarium.containsCreature(text)) {
      return 'This name already exists!';
    }

    return null;
  }
}
