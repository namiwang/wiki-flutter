import 'package:flutter/material.dart';

import 'package:html/parser.dart' as html show parse;
import 'package:html/dom.dart' as html;

class HtmlParser {
  final TextTheme theme;

  List<Widget> _widgets = [];
  List<TextSpan> _currentTextSpans = [];

  HtmlParser({this.theme});

  Widget parse(String htmlStr) {
    print('HtmlParser parsing: ' + htmlStr);

    // init
    _widgets = [];
    _currentTextSpans = [];

    // html to dom
    final html.Node body = html.parse(htmlStr).body;

    // 
    _parseNode(body);
    _tryCloseCurrentTextSpan();

    // print('--- parsed');
    // print('widgets: ' + _widgets.length.toString());
    // print((_widgets.first as RichText).text);
    // print((_widgets.first as RichText).text.toPlainText());

    return new Wrap(children: _widgets);
  }

  // mechanism
  // there're several kinds/levels of nodes,

  // for p, div, etc.
  // parse children nodes

  // for img, table, etc
  // 0. if currentTextSpans is not empty, close it, wrap it with a RichText, and append it into outerWrap
  // 1. append self into outerWrap

  // i, b, a, span
  // append self as TextSpan into currentTextSpan, or outerWrap, if currentWrap is null

  // textnode
  // append into currentWrap, or outerWrap, if currentWrap is null

  // TODO lists like <li>

  void _parseNode(html.Node node) {
    // print('--- _parseNode');
    // print(node.toString());

    switch (node.nodeType) {
      case html.Node.ELEMENT_NODE:
        _parseElement(node as html.Element);
        return;
      case html.Node.TEXT_NODE:
        _currentTextSpans.add(new TextSpan(text: node.text));
        return;
      default:
        break;
    }
  }

  void _parseElement(html.Element element) {
    // print('--- _parseElement');
    // print(element.toString());

    switch (element.localName) {
      case 'p':
      case 'div':
      case 'body':
        for (var subNode in element.nodes) {
          _parseNode(subNode);
        }

        _tryCloseCurrentTextSpan();

        return;
      case 'img':
        _tryCloseCurrentTextSpan();

        // TODO PRIMARY OBJECT
        _currentTextSpans.add(new TextSpan(text: '<IMG> PLACEHOLDER'));

        return;
      case 'table':
        _tryCloseCurrentTextSpan();

        // TODO PRIMARY OBJECT
        _currentTextSpans.add(new TextSpan(text: '<TABLE> PLACEHOLDER'));

        return;
      default:
        // TODO PRIMARY OBJECT
        // as i, b, span, a, etc
        _currentTextSpans.add(new TextSpan(text: element.text));
    }
  }

  void _tryCloseCurrentTextSpan() {
    if ( _currentTextSpans.length > 0 ) {
      final richText = new RichText(
        text: new TextSpan(
          children: _currentTextSpans,
          style: theme.body1
        )
      );

      _widgets.add(richText);
      _currentTextSpans = [];
    }
  }
}
