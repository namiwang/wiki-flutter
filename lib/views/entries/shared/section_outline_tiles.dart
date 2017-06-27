import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../models/entry.dart';

// import '../../shared/html_wrapper.dart';
import '../show.dart';
import '../sections/show.dart';

// TODO may be refined after models created. maybe move code to models.
List<Widget> sectionOutlineTiles(Entry entry, { rootSectionId: 0, selectedSectionId: null, @required bool inDrawer }) {
  final showMainSection = inDrawer;

  List<Section> sections = [];
  if ( rootSectionId == 0 ) {
    sections = entry.sections;
  } else {
    final int rootSectionTocLevel = entry.sections[rootSectionId].tocLevel;
    for (var cursorSectionId = rootSectionId + 1 ; cursorSectionId < entry.sections.length ; cursorSectionId++ ) {
      final Section cursorSection = entry.sections[cursorSectionId];
      if ( cursorSection.tocLevel <= rootSectionTocLevel ) { break; }
      sections.add(cursorSection);
    }
    // add current section as a header in the outline
    if (sections.length > 0) { sections.insert(0, entry.sections[rootSectionId]); }
  }

  final iterableSections = showMainSection ? sections : sections.skipWhile( (Section section) => section.id == 0 );
  return iterableSections.map((Section section){
    return new _SectionListTile(
      entry: entry,
      section: section,
      inDrawer: inDrawer,
      selected: inDrawer ? ( section.id == selectedSectionId ) : false,
    );
  }).toList();
}

class _SectionListTile extends StatelessWidget {
  final Entry entry;
  final Section section;
  final bool inDrawer;
  final bool selected;

  _SectionListTile({
    Key key,
    @required this.entry,
    @required this.section,
    @required this.inDrawer,
    @required this.selected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final leadPadding = inDrawer;

    // prefix icons
    List<Icon> prefixIcons = new List<Icon>.filled(section.tocLevel, const Icon(null));

    // content
    final String title = section.id == 0 ? 'Main section' : section.title;
    final Widget titleWidget = new Expanded( child: new Text(title) );
    final List<Widget> titleRowChildren = []
      ..addAll(prefixIcons)
      ..add(titleWidget);

    final ListTile sectionTile = new ListTile(
      dense: true,
      leading: leadPadding ? ( selected ? const Icon(Icons.label_outline) : const Icon(null) ) : null,
      title: new Row( children: titleRowChildren ),
      selected: selected,
      onTap:
        inDrawer ?
        (){
          // close the drawer
          Navigator.of(context).pop();

          // NOTE if the target section is the same as the current section, just close the drawer
          if ( selected ) { return; }

          Navigator.of(context).push(
            new MaterialPageRoute<Null>(
              builder: (BuildContext context) {
                return ( section.id == 0 ) ? ( new EntriesShow( entry: entry ) ) : ( new EntriesSectionsShow(entry: entry, section: section) );
              }
            )
          );
        } : (){
          Navigator.of(context).push(
            new MaterialPageRoute<Null>(
              builder: (BuildContext context) {
                return ( section.id == 0 ) ? ( new EntriesShow( entry: entry ) ) : ( new EntriesSectionsShow(entry: entry, section: section) );
              }
            )
          );
        },
    );

    return new _AnimatedSectionTile(sectionTile: sectionTile);
  }
}

class _AnimatedSectionTile extends StatefulWidget {
  final ListTile sectionTile;

  const _AnimatedSectionTile({ Key key, this.sectionTile }) : super(key: key);

  @override
  _AnimatedSectionTileState createState() => new _AnimatedSectionTileState();
}

class _AnimatedSectionTileState extends State<_AnimatedSectionTile> {
  double opacity = 0.0;

  @override
  void initState() {
    super.initState();

    Timer.run((){
      setState((){
        opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new AnimatedOpacity(child: widget.sectionTile, opacity: opacity, duration: const Duration(milliseconds: 300),);
  }
}
