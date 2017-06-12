import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:html/parser.dart' as html show parse;
import 'package:html/dom.dart' as html;
import 'package:url_launcher/url_launcher.dart';

import './image_with_loader.dart';

class _HtmlParser {
  final String htmlStr;
  final TextTheme textTheme;

  _HtmlParser({this.htmlStr, this.textTheme});

  List<Widget> _widgets = [];
  List<TextSpan> _currentTextSpans = [];

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

  void _parseNode(html.Node node) {
    // print('--- _parseNode');
    // print(node.toString());

    switch (node.nodeType) {
      case html.Node.ELEMENT_NODE:
        _parseElement(node as html.Element);
        return;
      case html.Node.TEXT_NODE:
        _appendToCurrentTextSpans(node.text);
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

          _appendToCurrentTextSpans(new _TextLink(text: text, href: href));
        } else {
          // still traverse down the tree
          for (var subNode in element.nodes) { _parseNode(subNode); }
        }

        return;
      default:
        print('=== MET UNSUPPORTED TAG: ${element.localName}');

        // still traverse down the tree
        for (var subNode in element.nodes) { _parseNode(subNode); }

        return;
    }
  }

  void _tryCloseCurrentTextSpan() {
    print('=== closingCurrentTextSpan ===' + _currentTextSpans.length.toString());

    if (_currentTextSpans.isEmpty) { return; }

    _widgets.add(new RichText(
      text: new TextSpan(
        style: textTheme.body1,
        children: new List.from(_currentTextSpans)
      )
    ));

    _currentTextSpans.clear();
  }

  void _appendToCurrentTextSpans(dynamic textOrLink){
    print('=== appending to _currentTextSpan: ' + textOrLink.toString());

    switch (textOrLink.runtimeType) {
      case String:
        // NOTE if the widget to be added, and the current last widget, are both Text, then we should append the text instead of widgets.
        if (_currentTextSpans.length > 0 && _currentTextSpans.last.runtimeType == Text) {
          final String originalText = _currentTextSpans.last.text;
          final String mergedText = originalText + textOrLink;
          _currentTextSpans[_currentTextSpans.length - 1] = new TextSpan(text: mergedText);
        } else {
          _currentTextSpans.add(new TextSpan(text: textOrLink));
        }
        break;
      case _TextLink:
        _currentTextSpans.add((textOrLink as _TextLink).textSpan);
        break;
      default:
        throw "dk how to append";
    }
  }

  // TODO
  // void _appendToCurrentWidgets(Widget w) {}

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

class _TextLink {
  // static const style = const TextStyle(color: Colors.blue, decoration: TextDecoration.underline);
  static const linkStyle = const TextStyle(color: Colors.blue);
  static final suffixIconString = new String.fromCharCode(Icons.open_in_browser.codePoint);
  static final suffixIconStyle = linkStyle.apply(fontFamily: 'MaterialIcons');

  final String text;
  final String href;
  TextSpan textSpan;

  // TODO REFINE
  _TextLink({this.text, this.href}){
    // TODO
    // if ( href.startsWith('#cite_note-') ) {
    //   print('=== TODO handle a cite_note');

    //   return new InkWell(
    //     child: new Text(text, style: linkStyle),
    //     onTap: (){ launch(href); },
    //   );
    // }

    String realHref = this.href;
    // TODO should be internal
    // <a href=\"/wiki/Political_union\" title=\"Political union\">political</a> and <a href=\"/wiki/Economic_union\" title=\"Economic union\">economic union</a>
    if ( href.startsWith('/wiki/') ) { String realHref = 'https://en.m.wikipedia.org' + this.href; }
    // 1. target is wiki entity
    // 2. target is wiki file

    final recognizer = new TapGestureRecognizer();
    recognizer.onTap = (){ launch(realHref); };

    // TODO BUG gesture not working
    this.textSpan = new TextSpan(children: [
      new TextSpan(text: text),
      new TextSpan(text: suffixIconString, style: suffixIconStyle),
    ], style: linkStyle, recognizer: recognizer);

    // TODO cleanup
    // return new InkWell(
    //   child: new RichText(
    //     text: new TextSpan(children: [
    //       new TextSpan(text: text),
    //       new TextSpan(text: suffixIconString, style: suffixIconStyle),
    //     ], style: linkStyle),
    //   ),
    //   onTap: (){ launch(realHref); },
    // );
  }
}

// for section name, entity title, etc
// this is a quick, yet not elegant way to parse inline html
// it just remove all expecting tags and return a string
parseInlineHtml(String htmlStr) {
  print('parsing inline html');

  return htmlStr.replaceAll(new RegExp("<\/*(i|b|span)>"), '');
}
