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

import '../../shared/html_parser.dart';

import './sections/show.dart';

class EntitiesShow extends StatefulWidget {
  EntitiesShow({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _EntitiesShowState createState() => new _EntitiesShowState();
}

class _EntitiesShowState extends State<EntitiesShow> {
  Map entity;

  // TODO PERFORMANCE
  // not that elegant,
  // should share one parser in the whold app
  // maybe should also share theme data
  HtmlParser _htmlParser;

  @override
  void initState() {
    super.initState();

    _fetchEntity().then( (fetchedEntity) {
      setState((){
        this.entity = fetchedEntity;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _htmlParser = new HtmlParser(theme: Theme.of(context).textTheme);

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
      body: new CustomScrollView(
        slivers: <Widget>[
          new SliverAppBar(
            expandedHeight: 256.0,
            floating: true,
            snap: true,
            flexibleSpace: new FlexibleSpaceBar(
              title: new Text(widget.title),
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
      // floatingActionButton: new FloatingActionButton(
      //   child: new Text('a')
      // ),
    );
  }

  Future<Map> _fetchEntity() async {
    String encodeTitle(String title) {
      return title.replaceAll(' ', '_');
    }

    // TODO use encodedTitle
    final String encodedTitle = encodeTitle(widget.title);

    final url = "https://en.wikipedia.org/api/rest_v1/page/mobile-sections/$encodedTitle";

    final Map entity = JSON.decode(await http.read(url));

    return entity;
  }

  Widget _buildCoverImg() {
    if (entity != null && entity['lead']['image'] != Null ) {
      // TODO multiple image urls
      final imageUrl = 'https:' + entity['lead']['image']['urls'][entity['lead']['image']['urls'].keys.last];
      return new Image.network(
        imageUrl,
        height: 256.0,
        fit: BoxFit.cover,
      );
    } else {
      return new Image.network('http://via.placeholder.com/256x256?text=placeholder', fit: BoxFit.cover);
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
    widgetsList.add(_htmlParser.parse(entity['lead']['sections'][0]['text']));
    widgetsList.add(const Divider());

    // remaining sections list
    widgetsList.addAll(_remainingSectionTiles());

    return widgetsList;
  }

  List<Widget> _remainingSectionTiles () {
    if (entity['lead']['sections'].length < 1) { return []; }

    List tiles = [];

    for (var section in entity['remaining']['sections']) {
      final tile = new ListTile(
        title:
          new Row(
            children:
              new List<Widget>
                .filled( section['toclevel'], new Icon(Icons.chevron_right), growable: true )
                ..add(
                  new Expanded(
                    child: _htmlParser.parse(section['line'])
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
