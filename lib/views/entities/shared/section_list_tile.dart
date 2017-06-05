import 'package:flutter/material.dart';

import '../../shared/html_wrapper.dart';
import '../show.dart';
import '../sections/show.dart';

class SectionListTile extends StatelessWidget {
  final Map entity;
  final int sectionId;
  final bool selected;

  SectionListTile(this.entity, this.sectionId, { Key key, this.selected = false }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map section = entity['lead']['sections'][sectionId];
    final int tocLevel = ( sectionId == 0 ) ? null : section['toclevel'];
    final List<Icon> prefixIcons =
      ( sectionId == 0 ) ?
      ( [ const Icon(Icons.home) ] ) :
      ( new List<Icon>.filled(tocLevel, const Icon(Icons.chevron_right)) );
    final Widget titleContent =
      ( sectionId == 0 ) ?
      ( new Expanded( child: new Text('Main Section') ) ):
      ( new Expanded( child: new HtmlWrapper( htmlStr: section['line'] ) ) );
    final List<Widget> titleRowChildren = []
      ..addAll(prefixIcons)
      ..add(titleContent);

    return new ListTile(
      title: new Row( children: titleRowChildren ),
      onTap: (){
        // TODO HIGH PRIORITY, KINDA COMPLEX
        // if inside the drawer, should replace current route to close the drawer, I guess
        // if the target section is the same as the current section, should just close the drawer, I guess
        Navigator.of(context).push(
          new MaterialPageRoute<Null>(
            builder: (BuildContext context) {
              return ( sectionId == 0 ) ? ( new EntitiesShow( entity: entity ) ) : ( new EntitiesSectionsShow(entity: entity, sectionId: sectionId) );
            }
          )
        );
      },
    );
  }
}
