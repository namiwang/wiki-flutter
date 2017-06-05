import 'package:flutter/material.dart';

import '../shared/section_list_tile.dart';

class EntitiesShowDrawer extends StatelessWidget {
  final Map entity;
  final int currentSectionId;

  EntitiesShowDrawer({ Key key, this.entity, this.currentSectionId }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    assert(entity != null);
    assert(currentSectionId != null); // TODO maybe default to 0?

    List<Widget> widgets = [];

    // header
    widgets.add(const DrawerHeader(child: const Center(child: const Text('Wiki Flutter')))); // TODO image

    // home
    // TODO ontap
    widgets.add(
      const ListTile(
        leading: const Icon(Icons.home),
        title: const Text('Home'),
      )
    );
    widgets.add( const Divider() );

    // sections outline
    widgets.add( const Text('sections outline') ); // TODO style
    widgets.addAll(_sectionsOutline(context));

    return new Drawer(
      child: new ListView(
        children: widgets
      )
    );
  }

  List<Widget> _sectionsOutline(BuildContext context) {
    List<Widget> tiles = [];

    for (Map section in ( entity['lead']['sections'] as List ) ) {
      tiles.add(new SectionListTile(entity, section['id']));
      // TODO selected
    }

    return tiles;
  }

}
