// TODO
// - image placeholder/loader
// - cover image in appbar
// - entity
//   - issues
//   - hatnotes
//   - category

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import '../../shared/html_parser.dart';

class EntitiesShow extends StatefulWidget {
  EntitiesShow({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _EntitiesShowState createState() => new _EntitiesShowState();
}

class _EntitiesShowState extends State<EntitiesShow> {
  Map entity;

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
      )
    );
  }

  Future<Map> _fetchEntity() async {
    String encodeTitle(String title) {
      return title.replaceAll(' ', '_');
    }

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

    final htmlParser = new HtmlParser(theme: Theme.of(context).textTheme);

    // title
    widgetsList.add(new Text(entity['lead']['displaytitle']));

    // description
    widgetsList.add(new Text(entity['lead']['description']));
    widgetsList.add(const Divider());

    // main section
    widgetsList.add(htmlParser.parse(entity['lead']['sections'][0]['text']));
    widgetsList.add(const Divider());

    // remaining sections list
    if (entity['lead']['sections'].length > 1) {
      final sections = entity['remaining']['sections'];

      for (var section in sections) {
        final String titleText = (new List<String>.filled(section['toclevel'], '- ')).join() + section['line'];
        final tile = new ListTile(
          title: new Text(titleText)
        );

        widgetsList.add(tile);
        widgetsList.add(const Divider());
      }

    }

    return widgetsList;
  }
}
