// TODO should move out of 'views'

import 'package:flutter/material.dart';

import './html_parser.dart';

// parse a fragment of html string into a widget
class HtmlWrapper extends StatelessWidget {
  final String htmlStr;

  HtmlWrapper({ Key key, this.htmlStr}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (new HtmlParser(context)).parse(htmlStr);
  }
}
