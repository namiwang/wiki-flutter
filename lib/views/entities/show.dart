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

    _fetchEntity(widget.title).then( (fetchedEntity) {
      setState((){
        this.entity = fetchedEntity;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: _buildContent(context),
    );
  }

  Future<Map> _fetchEntity(String title) async {
    final url = "https://en.wikipedia.org/api/rest_v1/page/mobile-sections/$title";

    final Map entity = JSON.decode(await http.read(url));

    return entity;
  }

  Widget _buildContent(BuildContext context) {
    if (entity == null) {
      return new Center(
        child: new CircularProgressIndicator()
      );
    }

    List<Widget> widgetsList = [];

    // cover image
    // TODO multiple image urls
    if ( entity['lead']['image'] != Null ) {
      final imageUrl = 'https:' + entity['lead']['image']['urls'][entity['lead']['image']['urls'].keys.last];
      widgetsList.add(new Image.network(imageUrl, fit: BoxFit.cover));
    }

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

    return new ListView(
      children: widgetsList
    );
  }
}
