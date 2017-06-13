import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:html/parser.dart' as html show parse;
import 'package:html/dom.dart' as html;
import 'package:url_launcher/url_launcher.dart';

import './image_with_loader.dart';

class _HtmlParser {
  final BuildContext context;
  final TextTheme textTheme;

  _HtmlParser(this.context)
    : textTheme = Theme.of(context).textTheme {}

  List<Widget> _widgets = [];
  List<TextSpan> _currentTextSpans = [];

  Widget parse (String htmlStr) {
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

          _appendToCurrentTextSpans(new _TextLink(context, text: text, href: href));
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
    return (new _HtmlParser(context)).parse(htmlStr);
  }
}

// NOTE removed suffixIcon due to vendor issue: https://github.com/flutter/flutter/issues/10623
class _TextLink {
  // static const style = const TextStyle(color: Colors.blue, decoration: TextDecoration.underline);
  static const linkStyle = const TextStyle(color: Colors.blue);
  // static final suffixIconString = new String.fromCharCode(Icons.open_in_browser.codePoint);
  // static final suffixIconStyle = linkStyle.apply(fontFamily: 'MaterialIcons');

  final BuildContext context;
  final String text;
  final String href;
  TextSpan textSpan;

  // TODO REFINE
  _TextLink(this.context, {this.text, this.href}){
    // cite note
    if ( href.startsWith('#cite_note-') ) {
      this.textSpan = _textSpanForInternalCiteNote();
      return;
    }

    // internal link to another entity
    // <a href=\"/wiki/Political_union\" title=\"Political union\">political</a> and <a href=\"/wiki/Economic_union\" title=\"Economic union\">economic union</a>
    if ( href.startsWith('/wiki/') ) {
      final String targetEntityTiele = href.replaceAll('/wiki/', '');
      this.textSpan = _textSpanForInternalEntityLink(targetEntityTiele);
      return;
    }

    // default as an external link
    this.textSpan = _textSpanForExternalLink();
  }

  TextSpan _textSpanForInternalEntityLink(String targetEntityTitle) {
    final recognizer = new TapGestureRecognizer();
    recognizer.onTap = (){
      Navigator.pushNamed(context, "/entities/$targetEntityTitle");
    };

    return new TextSpan(
      text: text,
      style: linkStyle,
      recognizer: recognizer
    );
  }

  TextSpan _textSpanForInternalCiteNote() {
    print('=== TODO handle a cite_note');
    return new TextSpan(text: '<CITE NOTE PLACEHOLDER>', style: linkStyle);
  }

  TextSpan _textSpanForExternalLink() {
    final recognizer = new TapGestureRecognizer();
    recognizer.onTap = (){ launch(href); };

    return new TextSpan(
      text: text,
      style: linkStyle,
      recognizer: recognizer
    );
  }
}

// for section name, entity title, etc
// this is a quick, yet not elegant way to parse inline html
// it just remove all expecting tags and return a string
parseInlineHtml(String htmlStr) {
  print('parsing inline html');

  return htmlStr.replaceAll(new RegExp("<\/*(i|b|span)>"), '');
}
