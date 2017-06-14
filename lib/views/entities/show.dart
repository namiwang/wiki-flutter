// TODO
// - entity
//   - issues
//   - hatnotes
//   - category

import 'package:flutter/material.dart';

import '../../models/entity.dart';

import '../shared/html_wrapper.dart';
import './shared/section_outline_tiles.dart';
import './shared/drawer.dart';

class EntitiesShow extends StatefulWidget {
  final String title; // NOTE TODO TO-REFINE, actually this may be encoded title or not
  final Entity entity;

  EntitiesShow({Key key, this.entity, this.title}) : super(key: key);

  @override
  _EntitiesShowState createState() => new _EntitiesShowState();
}

class _EntitiesShowState extends State<EntitiesShow> {
  Entity entity;

  @override
  void initState() {
    super.initState();

    // prefer passed-in existing entity than fetching via title
    if ( widget.entity != null ) {
      setState((){ this.entity = widget.entity; });
    } else {
      Entity.fetch(title: widget.title).then( (Entity fetchedEntity) {
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
        new Text(entity.displayTitle)
      ) : (
        new Text(widget.title)
      );
  }

  Widget _buildCoverImg() {
    if (entity != null && entity.coverImgSrc != null) {
      return new Image.network(entity.coverImgSrc, fit: BoxFit.cover);
    } else {
      // TODO shared assets helper
      return new Image.asset('assets/images/placeholder.jpg', fit: BoxFit.cover);
    }
  }

  List<Widget> _contentsList(BuildContext context) {
    List<Widget> widgetsList = [];

    // title
    // TODO NOTE title is already in the appbar, though still need to handle super-long title
    // widgetsList.add(new Text(entity['lead']['displaytitle']));

    // description
    if (entity.description != null) {
      widgetsList.add(new Text(entity.description, style: Theme.of(context).textTheme.subhead));
      widgetsList.add(const Divider());
    }

    // main section
    widgetsList.add(new HtmlWrapper(htmlStr: entity.sections.first.htmlText));
    widgetsList.add(const Divider());

    // remaining sections list
    widgetsList.addAll(_remainingSectionsOutline());

    return widgetsList;
  }

  List<Widget> _remainingSectionsOutline () {
    if (entity.sections.length < 1) { return []; }

    return sectionOutlineTiles(entity, rootSectionId: 0);
  }
}
