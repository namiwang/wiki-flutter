import 'package:flutter/material.dart';

class PagesHome extends StatelessWidget {
  PagesHome({Key key}) : super(key: key);

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
            delegate: new SliverChildListDelegate(_entitiesList(context))
          )
        ]
      )
    );
  }

  List<Widget> _entitiesList(BuildContext context) {
    final titles = ['Doraemon', 'European Union', 'Serious game'];

    return titles.map((t){
      return new ListTile(
        title: new Text(t),
        onTap: (){ Navigator.pushNamed(context, "/entities/$t"); }
      );
    }).toList();
  }
}
