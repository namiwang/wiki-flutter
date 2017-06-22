import 'package:flutter/material.dart';

import 'package:html/parser.dart' as html show parse;
import 'package:html/dom.dart' as html;

import './entities_helper.dart' as entitiesHelper;

import './image_with_loader.dart';

class HtmlParser {
  final BuildContext context;
  final Map appContext; // possible keys: [entity], TODO REFINE not that elegant, should pass-in, say, a refTextBuilder
  final TextTheme textTheme;

  HtmlParser(this.context, {this.appContext: const {}})
    : textTheme = Theme.of(context).textTheme {}

  List<Widget> _widgets = [];
  List<TextSpan> _currentTextSpans = [];

  Widget parse (String htmlStr) {
    print('*** parsing html...');
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

        final imgSrc = 'https:' + element.attributes['src'];
        final img = new entitiesHelper.ClickableImage(image: new ImageWithLoader(imgSrc));
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

        // if contains only one text node
        if ( element.hasContent() && ( element.nodes.length == 1 ) && ( element.firstChild.nodeType == html.Node.TEXT_NODE ) ) {
          final text = element.text;
          final href = element.attributes['href'];

          _appendToCurrentTextSpans(entitiesHelper.textLink(context: context, text: text, href: href));

          return;
        }

        // citing ref
        // <a href=\"#cite_note-18\" style=\"counter-reset: mw-Ref 13;\"><span class=\"mw-reflink-text\">[13]</span></a></span>
        if ( element.attributes['href'].startsWith('#cite_note-') ) {
          if (appContext['entity'] == null) { return; } // NOT THAT ELEGANT

          final text = element.text;
          final anchor = element.attributes['href'].replaceFirst('#', '');

          _appendToCurrentTextSpans(entitiesHelper.refLink(entity: appContext['entity'], context: context, text: text, anchor: anchor));

          return;
        }

        // still traverse down the tree
        for (var subNode in element.nodes) { _parseNode(subNode); }

        return;
      default:
        print('=== MET UNSUPPORTED TAG: ${element.localName}');

        // still traverse down the tree
        for (var subNode in element.nodes) { _parseNode(subNode); }

        return;
    }
  }

  void _tryCloseCurrentTextSpan() {
    // print('=== closingCurrentTextSpan ===' + _currentTextSpans.length.toString());

    if (_currentTextSpans.isEmpty) { return; }

    _widgets.add(new RichText(
      text: new TextSpan(
        style: textTheme.body1,
        children: new List.from(_currentTextSpans)
      )
    ));

    _currentTextSpans.clear();
  }

  void _appendToCurrentTextSpans(dynamic stringOrTextSpan){
    // print('=== appending to _currentTextSpan: ' + textOrLink.toString());

    switch (stringOrTextSpan.runtimeType) {
      case String:
        // NOTE if the widget to be added, and the current last widget, are both Text, then we should append the text instead of widgets.
        if (_currentTextSpans.length > 0 && _currentTextSpans.last.runtimeType == Text) {
          final String originalText = _currentTextSpans.last.text;
          final String mergedText = originalText + stringOrTextSpan;
          _currentTextSpans[_currentTextSpans.length - 1] = new TextSpan(text: mergedText);
        } else {
          _currentTextSpans.add(new TextSpan(text: stringOrTextSpan));
        }
        break;
      case TextSpan:
        _currentTextSpans.add(stringOrTextSpan);
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

// for section name, entity title, etc
// this is a quick, yet not elegant way to parse inline html
// it just remove all expecting tags and return a string
parseInlineHtml(String htmlStr) {
  print('*** parsing inline html...');

  return htmlStr.replaceAll(new RegExp("<\/*(i|b|span)>"), '');
}
