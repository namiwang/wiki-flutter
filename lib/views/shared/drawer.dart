import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:url_launcher/url_launcher.dart' as urlLauncher;

import '../../models/entity.dart';

import '../entities/shared/section_outline_tiles.dart';

class WikiFlutterDrawer extends StatelessWidget {
  final Entity currentEntry;
  final int currentSectionId;

  WikiFlutterDrawer({ Key key, this.currentEntry, this.currentSectionId }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];

    widgets
      // header
      // TODO style, maybe use a transparent-background wiki-flutter logo img
      ..add(new DrawerHeader(child: new Center(child: new Image.asset('assets/images/drawer_header.jpg'))))
      // home
      // TODO ontap
      ..add(
        const ListTile(
          leading: const Icon(Icons.home),
          title: const Text('Home'),
        )
      )
      ..add( const Divider() );

    // sections outline
    // TODO collapsible
    if (currentEntry != null && currentEntry.sections.length > 1){
      widgets
        ..add(
          const ListTile(
            leading: const Icon(Icons.list),
            title: const Text('sections outline'),
          )
        )
        ..addAll(sectionOutlineTiles(currentEntry, rootSectionId: 0, selectedSectionId: currentSectionId, showMainSection: true))
        ..add(const Divider());
    }

    // about dialog
    widgets.add(_buildAboutListTile(context));

    return new Drawer(
      child: new ListView(
        children: widgets
      )
    );
  }

  _buildAboutListTile(BuildContext context){
    final TextStyle bodyStyle = Theme.of(context).textTheme.body1;
    final TextStyle linkStyle = Theme.of(context).textTheme.body2.copyWith(color: Colors.blue);

    return new AboutListTile(
      icon: const FlutterLogo(),
      applicationVersion: 'pre-alpha', // TODO
      applicationIcon: const FlutterLogo(), // TODO
      applicationLegalese: '© NanoWANG',
      aboutBoxChildren: <Widget>[
        new Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: new RichText(
            text: new TextSpan(
              children: <TextSpan>[
                new TextSpan(
                  style: bodyStyle,
                  text: "WikiFlutter intend to be more than an elegant wikipedia client.\n\n"
                ),
                new TextSpan(
                  style: bodyStyle,
                  text: "This is also an experimental product derived from our trial with the Flutter framework.\n\n"
                ),
                new TextSpan(
                  style: bodyStyle,
                  text: "You may checkout the source code at: \n"
                ),
                new _LinkTextSpan(
                  style: linkStyle,
                  text: 'github:nanowang/wiki-flutter',
                  url: 'https://github.com/nanowang/wiki-flutter'
                ),
              ]
            )
          )
        )
      ]
    );
  }
}

// TODO separate and replace the original one in html-parser/entities-helper
class _LinkTextSpan extends TextSpan {
  _LinkTextSpan({ TextStyle style, String url, String text }) : super(
    style: style,
    text: text ?? url,
    recognizer: new TapGestureRecognizer()..onTap = () {
      urlLauncher.launch(url);
    }
  );
}
