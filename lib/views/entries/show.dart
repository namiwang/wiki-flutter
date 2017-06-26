// TODO
// - entry
//   - issues
//   - hatnotes
//   - category

import 'package:flutter/material.dart';

import '../../models/entry.dart';

import '../shared/entries_helper.dart' as entriesHelper;
import '../shared/drawer.dart';
import './shared/section_outline_tiles.dart';

class EntriesShow extends StatefulWidget {
  final String title; // NOTE TODO TO-REFINE, actually this may be encoded title or not
  final Entry entry;

  EntriesShow({Key key, this.entry, this.title}) : super(key: key);

  @override
  _EntriesShowState createState() => new _EntriesShowState();
}

class _EntriesShowState extends State<EntriesShow> {
  Entry entry;

  @override
  void initState() {
    super.initState();

    // prefer passed-in existing entry than fetching via title
    if ( widget.entry != null ) {
      setState((){ this.entry = widget.entry; });
    } else {
      Entry.fetch(title: widget.title).then( (Entry fetchedEntry) {
        setState((){
          this.entry = fetchedEntry;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget content = ( entry == null ) ? (
                             new SliverFillRemaining(
                               child: new Center(
                                 child: new CircularProgressIndicator()
                               )
                             )
                           ) : (
                             new SliverList(
                               delegate: new SliverChildListDelegate(_contentsList(context))
                             )
                           );

    return new Scaffold(
      drawer: new WikiFlutterDrawer(currentEntry: entry, currentSectionId: 0),
      body: new CustomScrollView(
        slivers: <Widget>[
          new SliverAppBar(
            expandedHeight: 256.0,
            floating: true,
            // snap: true,
            flexibleSpace: new FlexibleSpaceBar(
              title: _buildTitle(),
              background: new Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  _buildCoverImg()
                ]
              )
            ),
          ),
          content
        ]
      ),
    );
  }

  Widget _buildTitle() {
    return
      ( entry != null ) ? (
        new Text(entry.displayTitle)
      ) : (
        new Text(widget.title)
      );
  }

  Widget _buildCoverImg() {
    if (entry != null && entry.coverImgSrc != null) {
      return new Image.network(entry.coverImgSrc, fit: BoxFit.cover);
    } else {
      // TODO shared assets helper
      return new Image.asset('assets/images/placeholder.jpg', fit: BoxFit.cover);
    }
  }

  List<Widget> _contentsList(BuildContext context) {
    List<Widget> widgetsList = [];

    // title
    // TODO NOTE title is already in the appbar, though still need to handle super-long title
    // widgetsList.add(new Text(entry['lead']['displaytitle']));

    // description
    if (entry.description != null) {
      widgetsList.add(
        new entriesHelper.HintTile(
          text: entry.description,
          icon: const Icon(Icons.format_quote)
        )
      );
    }

    // hatnotes
    for (String hatnote in entry.hatnotes) {
      widgetsList.add(
        new entriesHelper.HintTile.withHtmlStr(
          htmlStr: hatnote,
        )
      );
    }

    // main section
    widgetsList
      ..add(
        new Container(
          padding: const EdgeInsets.all(16.0),
          child: new entriesHelper.SectionHtmlWrapper(entry: entry, sectionId: 0))
        )
      ..add(const Divider());

    // remaining sections list
    widgetsList.addAll(_remainingSectionsOutline());

    return widgetsList;
  }

  List<Widget> _remainingSectionsOutline () {
    if (entry.sections.length < 1) { return []; }

    return sectionOutlineTiles(entry, rootSectionId: 0);
  }
}
