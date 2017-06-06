// TODO
// - cover image
//   - use the first image in section ?
//   - or use the cover image from parent entity ?

// TODO
  // DRAWER

import 'package:flutter/material.dart';

import '../../shared/html_wrapper.dart';

import '../shared/drawer.dart';
import '../shared/section_outline_tiles.dart';

class EntitiesSectionsShow extends StatelessWidget {
  final Map entity;
  final int sectionId;

  EntitiesSectionsShow({ Key key, this.entity, this.sectionId }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // section content
    Map section = entity['remaining']['sections'][sectionId - 1];

    // build content widgets
    List<Widget> contentWidgets = [];

    contentWidgets.add(
      new HtmlWrapper(htmlStr: section['text'])
    );

    contentWidgets.add(const Divider());
    contentWidgets.addAll(sectionOutlineTiles(entity, rootSectionId: sectionId));

    return new Scaffold(
      drawer: new EntitiesShowDrawer(entity: entity, currentSectionId: sectionId),
      body: new CustomScrollView(
        slivers: <Widget>[
          new SliverAppBar(
            expandedHeight: 256.0,
            floating: true,
            // snap: true,
            flexibleSpace: new FlexibleSpaceBar(
              title: new Text(section['line']),
              background: new Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  new Image.network('http://via.placeholder.com/256x256?text=placeholder', fit: BoxFit.cover) // TODO
                ]
              )
            ),
          ),
          new SliverList(
            delegate: new SliverChildListDelegate( contentWidgets )
          )
        ]
      )
    );
  }
}
