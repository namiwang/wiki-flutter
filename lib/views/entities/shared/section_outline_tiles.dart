import 'package:flutter/material.dart';

import '../../shared/html_wrapper.dart';
import '../show.dart';
import '../sections/show.dart';

// TODO BUG selected is not applied since the contents are HtmlWrapper

List<Widget> sectionOutlineTiles(Map entity, { rootSectionId: 0, selectedSectionId: null, showMainSection: false }) {
  List<Map> sections = [];
  if ( rootSectionId == 0 ) {
    sections = entity['lead']['sections'];
  } else {
    final int rootSectionTocLevel = entity['lead']['sections'][rootSectionId]['toclevel'];
    for (var cursorSectionId = rootSectionId + 1 ; cursorSectionId < (entity['lead']['sections'] as List).length ; cursorSectionId++ ) {
      final Map cursorSection = entity['lead']['sections'][cursorSectionId];
      if ( cursorSection['toclevel'] <= rootSectionTocLevel ) { break; }
      sections.add(cursorSection);
    }
    // add current section as a header in the outline
    if (sections.length > 0) { sections.insert(0, entity['lead']['sections'][rootSectionId]); }
  }

  final iterableSections = showMainSection ? sections : sections.skipWhile( (Map section) => section['id'] == 0 );
  return iterableSections.map((Map section){
    return new _SectionListTile(entity, section['id'], selected: (section['id'] == selectedSectionId));
  }).toList();
}

class _SectionListTile extends StatelessWidget {
  final Map entity;
  final int sectionId;
  final bool selected;

  _SectionListTile(this.entity, this.sectionId, { Key key, this.selected = false }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map section = entity['lead']['sections'][sectionId];
    final int tocLevel = ( sectionId == 0 ) ? null : section['toclevel'];

    final List<Icon> prefixIcons =
      ( sectionId == 0 ) ?
      ( [ const Icon(Icons.subject) ] ) :
      ( new List<Icon>.filled(tocLevel, const Icon(Icons.remove)) );
    if (selected) { prefixIcons[0] = const Icon(Icons.label_outline);}

    final Widget titleContent =
      ( sectionId == 0 ) ?
      ( new Expanded( child: new Text('Main Section') ) ): // USE title
      ( new Expanded( child: new Text( parseInlineHtml(section['line']) ) ) );
    final List<Widget> titleRowChildren = []
      ..addAll(prefixIcons)
      ..add(titleContent);

    return new ListTile(
      title: new Row( children: titleRowChildren ),
      // leading: const Text(''),
      dense: true,
      selected: false,
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
