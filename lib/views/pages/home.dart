import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class PagesHome extends StatefulWidget {
  const PagesHome({ Key key }) : super(key: key);

  @override
  _PagesHomeState createState() => new _PagesHomeState();
}

class _PagesHomeState extends State<PagesHome> {
  final _searchFetcher = new _Fetcher();
  List<_EntryWithSummary> _fetchedSearchingEntries = []; // NOTE null means loading

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new CustomScrollView(
        slivers: <Widget>[
          new SliverAppBar(
            expandedHeight: 256.0,
            floating: true,
            snap: true,
            flexibleSpace: new FlexibleSpaceBar(
              title: new Text('Wiki Flutter'),
              background: new Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  new Image.asset(
                    "assets/images/home_header.jpg",
                    fit: BoxFit.cover,
                    height: 256.0
                  ),
                ]
              )
            ),
          ),
          new SliverList(
            delegate: new SliverChildListDelegate([_searchBar()])
          ),
          _buildContent(context),
        ]
      )
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_fetchedSearchingEntries == null) { // NOTE which means loading
      return new SliverFillRemaining(
        child: new Center(
          child: new CircularProgressIndicator()
        )
      );
    }

    return new SliverList(
      delegate: new SliverChildListDelegate(_buildEntriesList(context))
    );
  }

  Widget _searchBar(){
    return new Container(
      padding: const EdgeInsets.all(8.0),
      child: new Card(
        child: new Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: new TextField(
            onChanged: _handleSearchTextChanged,
            decoration: const InputDecoration(
              icon: const Icon(Icons.search),
            ),
          )
        )
      )
    );
  }

  // TODO PERFORMANCE
  // TO FILE ISSUE
  // got triggered multiple times when using Google Chinese IME
  void _handleSearchTextChanged(String str) {
    print('TRIGGERED searchTextchangedTo $str');

    if (str == '') {
      setState((){
        _fetchedSearchingEntries = [];
      });
      return;
    }

    setState((){
      _fetchedSearchingEntries = null;
    });

    _searchFetcher.search(str).then((List<_EntryWithSummary> fetchedSearchingEntries){
      setState((){
        _fetchedSearchingEntries = fetchedSearchingEntries;
      });
    });
  }

  List<Widget> _buildEntriesList (BuildContext context) {
    List<Widget> list = [];

    for ( _EntryWithSummary e in _fetchedSearchingEntries ) {
      list
        ..add(
          new ListTile(
            title: new Text(e.title),
            subtitle: new RichText(
              text: new TextSpan(text: e.summary, style: Theme.of(context).textTheme.body1),
              overflow: TextOverflow.ellipsis,
            ),
            onTap: (){ Navigator.pushNamed(context, "/entities/${e.title}"); }
          ),
        )
        ..add( const Divider() );
    }

    return [ new Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
      child: new Card(
        child: new Column(
          children: list
        ),
      )
    ) ];
  }
}

class _Fetcher {
  http.Client client = new http.Client();

  Future<List<_EntryWithSummary>> search(String str) async {
    // TODO NOTE
    // there will be some unhandled `Connection closed before full header was received` exception
    // that's by design, yet still should be properly handled.
    // TODO wrap in WikiClient?

    client.close();

    client = new http.Client();

    final String url = "https://en.wikipedia.org/w/api.php?action=opensearch&format=json&errorformat=bc&search=$str&namespace=0&limit=10&suggest=1&utf8=1&formatversion=2";

    print('UUU fetching $str');

    final List fetched = JSON.decode( await client.read(url) ) as List;

    print('UUU fetched');

    client.close();

    List<_EntryWithSummary> entries = [];
    for (var i = 0; i < (fetched[1] as List).length; i ++ ) {
      entries.add(
        new _EntryWithSummary(
          title: fetched[1][i],
          summary: fetched[2][i]
        )
      );
    }

    return entries;
  }
}

class _EntryWithSummary {
  final String title;
  final String summary;
  _EntryWithSummary({this.title, this.summary});
}
