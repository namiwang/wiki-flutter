// TODO
// - entity
//   - issues
//   - hatnotes
//   - category

// sections, listtile.title
// - text contains html tags like <span> MUST DONE
// - BUT long text eclipse MUST DONE

// sections, listTile.selected

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import '../shared/html_wrapper.dart';
import './shared/section_outline_tiles.dart';
import './shared/drawer.dart';

class EntitiesShow extends StatefulWidget {
  final Map entity;
  final String title; // TODO TO-REFINE, actually this is the encoded_title

  EntitiesShow({Key key, this.entity, this.title}) : super(key: key);

  @override
  _EntitiesShowState createState() => new _EntitiesShowState();
}

class _EntitiesShowState extends State<EntitiesShow> {
  Map entity;

  @override
  void initState() {
    super.initState();

    // prefer passed-in existing entity than fetching via title
    if ( widget.entity != null ) {
      setState((){ this.entity = widget.entity; });
    } else {
      _fetchEntity().then( (fetchedEntity) {
        setState((){
          this.entity = fetchedEntity;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget content = ( entity == null ) ? (
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
      drawer: new EntitiesShowDrawer(entity: entity, currentSectionId: 0),
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
      ( entity != null ) ? (
        // TODO not that elegant, need more spec
        // TODO maybe more tags (like span) in title?
        // TODO maybe just use the htmlWrapper and set a theme
        new Text((entity['lead']['displaytitle'] as String).replaceAll('<i>', '').replaceAll('</i>', ''))
      ) : (
        new Text(widget.title)
      );
  }

  Future<Map> _fetchEntity() async {
    final url = "https://en.wikipedia.org/api/rest_v1/page/mobile-sections/${widget.title}";

    final Map entity = JSON.decode(await http.read(url));

    return entity;
  }

  Widget _buildCoverImg() {
    if (entity != null && entity['lead']['image'] != null ) {
      // TODO handle multiple image urls
      final imageUrl = 'https:' + entity['lead']['image']['urls'][entity['lead']['image']['urls'].keys.last];
      return new Image.network(
        imageUrl,
        height: 256.0,
        fit: BoxFit.cover,
      );
    } else {
      return new Image.asset('assets/images/placeholder.jpg', fit: BoxFit.cover);
    }

  }

  List<Widget> _contentsList(BuildContext context) {
    List<Widget> widgetsList = [];

    // title
    // TODO title is already in the appbar, though still need to handle super-long title
    // widgetsList.add(new Text(entity['lead']['displaytitle']));

    // description
    widgetsList.add(new Text(entity['lead']['description'], style: Theme.of(context).textTheme.subhead));
    widgetsList.add(const Divider());

    // main section
    widgetsList.add(new HtmlWrapper(htmlStr: entity['lead']['sections'][0]['text']));
    widgetsList.add(const Divider());

    // remaining sections list
    widgetsList.addAll(_remainingSectionsOutline());

    return widgetsList;
  }

  List<Widget> _remainingSectionsOutline () {
    if (entity['lead']['sections'].length < 1) { return []; }

    return sectionOutlineTiles(entity, rootSectionId: 0);
  }
}
