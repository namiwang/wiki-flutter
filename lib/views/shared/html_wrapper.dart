import 'package:flutter/material.dart';

import 'package:html/parser.dart' as html show parse;
import 'package:html/dom.dart' as html;

class _HtmlParser {
  final String htmlStr;
  final TextTheme textTheme;

  _HtmlParser({this.htmlStr, this.textTheme});

  List<Widget> _widgets = [];
  List<TextSpan> _currentTextSpans = [];

  Widget parse () {
    // print('HtmlParser parsing: ' + htmlStr);

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
        // traverse down the tree
        for (var subNode in element.nodes) { _parseNode(subNode); }

        _tryCloseCurrentTextSpan();

        return;
      case 'figure': // TODO
        _tryCloseCurrentTextSpan();

        // traverse down the tree
        for (var subNode in element.nodes) { _parseNode(subNode); }

        return;
      // TODO fig caption
      case 'img':
        _tryCloseCurrentTextSpan();

        // TODO
        // - with placeholder
        // - click to show a fullscreen image
        // - support animated gif

        final String imgSrc = 'https:' + element.attributes['src'];
        final img = new Image.network(imgSrc, fit: BoxFit.contain);
        _widgets.add(
          new Container(
            padding: const EdgeInsets.all(16.0),
            alignment: FractionalOffset.center,
            child: img
          )
        );

        return;
      case 'table':
        _tryCloseCurrentTextSpan();

        // TODO PRIMARY OBJECT
        _widgets.add(
          new Container(
            padding: const EdgeInsets.all(16.0),
            alignment: FractionalOffset.center,
            child: const Text('<TABLE> placeholder')
          )
        );

        return;
      case 'span':
      case 'i':
      case 'strong':
        // TODO PRIMARY OBJECT
        // TODO style
        _currentTextSpans.add(new TextSpan(text: element.text));

        return;
      case 'a':
        // TODO PRIMARY OBJECT

        // 1. target is wiki entity
        // 2. target is wiki file
        _currentTextSpans.add(new TextSpan(text: element.text));

        // still traverse down the tree
        for (var subNode in element.nodes) { _parseNode(subNode); }

        return;
      default:
        print('=== MET UNSUPPORTED TAG: ${element.localName}');

        // still traverse down the tree
        for (var subNode in element.nodes) { _parseNode(subNode); }

        _currentTextSpans.add(new TextSpan(text: element.text));

        return;
    }
  }

  void _tryCloseCurrentTextSpan() {
    if ( _currentTextSpans.length > 0 ) {
      final richText = new RichText(
        text: new TextSpan(
          children: _currentTextSpans,
          style: textTheme.body1
        )
      );

      _widgets.add(richText);
      _currentTextSpans = [];
    }
  }
}

class HtmlWrapper extends StatelessWidget {
  final String htmlStr;

  HtmlWrapper({ Key key, this.htmlStr }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (new _HtmlParser(htmlStr: htmlStr, textTheme: Theme.of(context).textTheme)).parse();
  }
}
