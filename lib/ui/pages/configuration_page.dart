import 'package:flutter/material.dart';
import 'package:flutter_terra/ui/widgets/creature_config.dart';
import 'package:flutter_terra/ui/widgets/rename_dialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter_terra/models/terrarium.dart';

class ConfigurationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final terrarium = Provider.of<Terrarium>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Configuration"),
      ),
      body: PageView(
        children: <Widget>[
          for(var creature in terrarium.registeredCreatures) 
            CreatureConfig(creature)
        ]
      ),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[       
            RaisedButton(
              child: Text("Add creature"),
              onPressed: () async {
                final result = await RenameDialog.show(context);
              },
            )
          ],
        ),
      ),
    );
  }
}
