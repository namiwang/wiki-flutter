import 'package:flutter/material.dart';

import 'package:html/dom.dart' as html;

import './html_parser.dart';

// parse a fragment of html string into a widget
class HtmlWrap extends StatelessWidget {
  final String htmlStr;
  final html.Element htmlElement;

  HtmlWrap({ Key key, this.htmlStr, this.htmlElement }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    assert(htmlElement != null || htmlStr != null);

    if ( htmlElement != null ) {
      return (new HtmlParser(context)).parseFromElement(htmlElement);
    } else {
      return (new HtmlParser(context)).parseFromStr(htmlStr);
    }
  }
}

// for section name, entry title, etc
// this is a quick, yet not elegant way to parse inline html
// it just remove all expecting tags and return a string
String inlineHtmlWrap(String htmlStr) {
  print('*** parsing inline html...');

  return htmlStr.replaceAll(new RegExp("<\/*(i|b|span)>"), '');
}
