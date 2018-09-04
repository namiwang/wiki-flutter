import 'package:flutter/material.dart';

import './html_parser.dart';

// parse a fragment of html string into a widget
class HtmlWrap extends StatelessWidget {
  final String htmlStr;

  HtmlWrap({ Key key, this.htmlStr }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (new HtmlParser(context)).parseFromStr(htmlStr);
  }
}

// for section name, entry title, etc
// this is a quick, yet not elegant way to parse inline html
// it just remove all expecting tags and return a string
String inlineHtmlWrap(String htmlStr) {
  // print('*** parsing inline html...');

  return htmlStr.replaceAll(new RegExp("<\/*(i|b|span)>"), '');
}
