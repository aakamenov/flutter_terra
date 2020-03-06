import 'package:flutter/material.dart';
import 'package:flutter_terra/ui/widgets/creature_config.dart';
import 'package:flutter_terra/ui/widgets/rename_dialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter_terra/models/terrarium.dart';
import 'dart:collection';

class ConfigurationPage extends StatefulWidget {
  @override
  _ConfigurationPageState createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> {
  PageController controller;

  @override
  void initState() {
    super.initState();
    controller = PageController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final terrarium = Provider.of<Terrarium>(context);
    final creatures = terrarium.registeredCreatures;

    return WillPopScope(
      onWillPop: () {
        final distribution = HashMap<String, int>();
        distribution['brute'] = 20;
        distribution['bully'] = 20;

        terrarium.buildGrid(distribution);

        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Configuration"),
          actions: <Widget>[
            if(creatures.length > 0)
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () async {
                  final result = await RenameDialog.show(context, title: "Rename creature");

                  if(result == null)
                    return;

                  setState(() {
                    final creature = creatures.elementAt(controller.page.toInt());
                    terrarium.unregisterCreature(creature);
                    terrarium.registerCreature(Creature.clone(creature, newType: result));
                  });

                  controller.jumpToPage(creatures.length - 1);
                },
              ),
            if(creatures.length > 0)
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  if(!await confirmDeleteDialog(context))
                    return;

                  final creature = creatures.elementAt(controller.page.toInt());
                  terrarium.unregisterCreature(creature);
                  setState(() {});
                },
              )
          ],
        ),
        body: PageView(
          controller: controller,
          children: <Widget>[
            for(var creature in creatures) 
              CreatureConfig(creature)
          ]
        ),
        bottomNavigationBar: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[       
              if(creatures.length < 11)
                RaisedButton(
                  child: Text("Add creature"),
                  onPressed: () async {
                    final result = await RenameDialog.show(context, title: "New creature");

                    if(result == null)
                      return;

                    setState(() {
                      terrarium.registerCreature(Creature(type: result));
                    });

                    controller.jumpToPage(creatures.length - 1);
                  },
                )
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> confirmDeleteDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete the current creature?'),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop(false);
              },
            ),
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop(true);
              },
            )
          ]
        );
      }
    );
  }
}
