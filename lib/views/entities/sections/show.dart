// TODO
// - cover image
//   - use the first image in section ?
//   - or use the cover image from parent entity ?

// TODO
  // DRAWER

import 'package:flutter/material.dart';

import '../../shared/html_wrapper.dart';

import '../../../models/entity.dart';

import '../shared/drawer.dart';
import '../shared/section_outline_tiles.dart';

class EntitiesSectionsShow extends StatelessWidget {
  final Entity entity;
  final Section section;

  EntitiesSectionsShow({ Key key, this.entity, this.section }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // build content widgets
    List<Widget> contentWidgets = [];

    contentWidgets.add(
      new HtmlWrapper(htmlStr: section.htmlText)
    );

    contentWidgets.add(const Divider());
    contentWidgets.addAll(sectionOutlineTiles(entity, rootSectionId: section.id));

    return new Scaffold(
      drawer: new EntitiesShowDrawer(entity: entity, currentSectionId: section.id),
      body: new CustomScrollView(
        slivers: <Widget>[
          new SliverAppBar(
            expandedHeight: 256.0,
            floating: true,
            // snap: true,
            flexibleSpace: new FlexibleSpaceBar(
              title: new Text(section.title),
              background: new Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  new Image.asset('assets/images/placeholder.jpg', fit: BoxFit.cover)
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
