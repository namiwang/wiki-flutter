import 'package:flutter/material.dart';

import 'package:html/parser.dart' as html show parse;
import 'package:html/dom.dart' as html;
import 'package:url_launcher/url_launcher.dart';

import './image_with_loader.dart';

class _HtmlParser {
  final String htmlStr;
  final TextTheme textTheme;

  _HtmlParser({this.htmlStr, this.textTheme});

  List<Widget> _widgets = [];
  // List<TextSpan> _currentTextSpans = [];
  List<Widget> _currentWrapChildren = [];

  Widget parse () {
    // print('HtmlParser parsing: ' + htmlStr);

    // html to dom
    final html.Node body = html.parse(htmlStr).body;

    // 
    _parseNode(body);
    _tryCloseCurrentTextSpan();

    // _debugPrintWidgets();

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
        // _currentTextSpans.add(new TextSpan(text: node.text));

        _appendToCurrentWrap(new Text(node.text));

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

        final imgSrc = 'https:' + element.attributes['src'];
        final img = new ImageWithLoader(imgSrc);
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
        // TODO NEED IMPROVEMENT maybe a _currentTextStylesStack for nesting stacks

        // still traverse down the tree
        for (var subNode in element.nodes) { _parseNode(subNode); }

        return;
      case 'a':
        // TODO PRIMARY OBJECT
        // TODO NEED IMPROVEMENT

        // print(element.attributes['href']);

        if ( element.hasContent() && ( element.nodes.length == 1 ) && ( element.firstChild.nodeType == html.Node.TEXT_NODE ) ) {
          // if contains only one text node

          final text = element.text;
          final href = element.attributes['href'];

          _appendToCurrentWrap(new _TextLink(text: text, href: href));
        } else {
          // still traverse down the tree
          for (var subNode in element.nodes) { _parseNode(subNode); }
        }

        // 1. target is wiki entity
        // 2. target is wiki file
  
        // <a href=\"/wiki/Political_union\" title=\"Political union\">political</a> and <a href=\"/wiki/Economic_union\" title=\"Economic union\">economic union</a>

        return;
      default:
        print('=== MET UNSUPPORTED TAG: ${element.localName}');

        // still traverse down the tree
        for (var subNode in element.nodes) { _parseNode(subNode); }

        return;
    }
  }

  void _tryCloseCurrentTextSpan() {
    // print('=== closingCurrentWrap ===' + _currentWrapChildren.isEmpty.toString());
    if (_currentWrapChildren.isEmpty) { return; }

    _widgets.add(new Wrap(children: new List.from(_currentWrapChildren)));

    _currentWrapChildren.clear();
  }

  void _appendToCurrentWrap(Widget widget){
    // print('=== appending to _currentWrap: ' + widget.toString());

    // TODO BUG if the widget to be added, and the current last widget, are both Text, then we should append the text instead of widgets.

    _currentWrapChildren.add(widget);
  }

  // void _debugPrintWidgets() {
  //   List<String> lines = [' === *** current widgets *** ==='];

  //   for (var w in _widgets) {
  //     lines.add(w.toString());
  //     if (w.runtimeType == Wrap){
  //       lines.add((w as Wrap).children.toString());
  //     }
  //   }

  //   lines.add(' === *** current widges end *** ===');

  //   print(lines.join('\n'));
  // }

}

class HtmlWrapper extends StatelessWidget {
  final String htmlStr;

  HtmlWrapper({ Key key, this.htmlStr }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (new _HtmlParser(htmlStr: htmlStr, textTheme: Theme.of(context).textTheme)).parse();
  }
}

class _TextLink extends StatelessWidget {
  // static const style = const TextStyle(color: Colors.blue, decoration: TextDecoration.underline);
  static const style = const TextStyle(color: Colors.blue);

  final String text;
  final String href;

  _TextLink({this.text, this.href});

  @override
  Widget build(BuildContext context) {
    // NOTE added following https://docs.flutter.io/flutter/material/InkWell-class.html
    assert(debugCheckHasMaterial(context));

    // TODO
    if ( href.startsWith('#cite_note-') ) {
      print('=== TODO handle a cite_note');

      return new InkWell(
        child: new Text(text, style: style),
        onTap: (){ launch(href); },
      );
    }

    // TODO
    if ( href.startsWith('/wiki/') ) {
      String realHref = this.href.replaceFirst('/wiki/', 'https://en.m.wikipedia.org/wiki/');
      return new InkWell(
        child: new Text(text, style: style),
        onTap: (){ launch(realHref); },
      );
    }

    // default external link
    return new InkWell(
      child: new Text(text, style: style),
      onTap: (){ launch(this.href); },
    );

  }
}
