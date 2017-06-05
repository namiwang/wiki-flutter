// TODO
// - cover image
//   - use the first image in section ?
//   - or use the cover image from parent entity ?

// TODO
  // DRAWER

import 'package:flutter/material.dart';

import '../../shared/html_wrapper.dart';

class EntitiesSectionsShow extends StatelessWidget {
  final Map entity;
  final int sectionId;

  EntitiesSectionsShow({ Key key, this.entity, this.sectionId }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // section content
    Map section = entity['remaining']['sections'][sectionId - 1];

    // nested sections list
    List<Map> nestedSections = [];
    for (var cursorSectionId = sectionId + 1 ; cursorSectionId < (entity['lead']['sections'] as List).length ; cursorSectionId++ ) {
      final Map cursorSection = entity['remaining']['sections'][cursorSectionId - 1];
      if ( cursorSection['toclevel'] <= section['toclevel'] ) { break; }
      nestedSections.add(cursorSection);
    }

    // build content widgets
    List<Widget> contentWidgets = [];

    contentWidgets.add(
      new HtmlWrapper(htmlStr: section['text'])
    );

    contentWidgets.addAll(_nestedSectionTiles(context, nestedSections));

    return new Scaffold(
      body: new CustomScrollView(
        slivers: <Widget>[
          new SliverAppBar(
            expandedHeight: 256.0,
            floating: true,
            snap: true,
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

  List<Widget> _nestedSectionTiles (BuildContext context, List<Map> sections) {
    List<Widget> tiles = [];

    for (var section in sections) {
      final tile = new ListTile(
        title:
          new Row(
            children:
              new List<Widget>
                .filled( section['toclevel'], new Icon(Icons.chevron_right), growable: true )
                ..add(
                  new Expanded(
                    child: new HtmlWrapper(htmlStr: section['line'])
                  )
                )
          ),
        onTap: (){
          Navigator.of(context).push(
            new MaterialPageRoute<Null>(
              builder: (BuildContext context) {
                return new EntitiesSectionsShow(entity: entity, sectionId: section['id']);
              }
            )
          );
        },
      );

      tiles.add(tile);
      tiles.add(const Divider());
    }

    return tiles;
  }
}
