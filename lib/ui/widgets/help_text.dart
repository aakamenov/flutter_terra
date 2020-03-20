import 'package:flutter/material.dart';

class HelpText extends StatelessWidget {
  final String text;
  final String helpText;
  final TextStyle textStyle;
  final double iconSize;

  const HelpText({ 
    Key key,
    @required this.text,
    @required this.helpText,
    this.textStyle,
    this.iconSize = 24.0
  })
    : assert(text != null),
      assert(helpText != null),
      assert(iconSize != null && iconSize > 0.0),
      super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: <InlineSpan> [
          TextSpan(
            text: text, 
            style: textStyle,
            children: <InlineSpan>[
              WidgetSpan(
                style: TextStyle(height: 1.0),
                alignment: PlaceholderAlignment.middle,
                child: GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2.0),
                    child: Icon(Icons.help, size: iconSize),
                  ),
                  onTap: () async {
                    await showDescription(context);
                  }
                )
              )
            ]
          ),
        ]
      ),
    );
  }

  Future<void> showDescription(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(helpText),
          actions: <Widget>[
            FlatButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            )
          ],
        );
      }
    );
  }
}
