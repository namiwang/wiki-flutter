import 'package:flutter/material.dart';

import 'package:html/parser.dart' as html show parse;
import 'package:html/dom.dart' as html;

import './entries_helper.dart' as entriesHelper;

import './image_with_loader.dart';

class HtmlParser {
  final BuildContext context;
  final Map appContext; // possible keys: [entry], TODO REFINE not that elegant, should pass-in, say, a refTextBuilder
  final TextTheme textTheme;

  HtmlParser(this.context, {this.appContext: const {}})
    : textTheme = Theme.of(context).textTheme {}

  List<Widget> _widgets = [];
  List<TextSpan> _currentTextSpans = [];

  Widget parseFromElement (html.Element element) {
    // print('*** parsing html...');

    _parseNode(element);
    _tryCloseCurrentTextSpan();

    return new Wrap(children: _widgets);
  }

  Widget parseFromStr (String htmlStr) {
    // print('*** parsing html...');

    final html.Node body = html.parse(htmlStr).body;

    _parseNode(body);
    _tryCloseCurrentTextSpan();

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
        // NOTE if is contains only `\n`'s
        if ( node.text.runes.toSet().difference(new Set.from([ new Runes('\n').first ])).isEmpty ) {
          _tryCloseCurrentTextSpan();
          return;
        }

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
      case 'body':
        // traverse down the tree
        for (var subNode in element.nodes) { _parseNode(subNode); }

        _tryCloseCurrentTextSpan();

        return;
      case 'div':
        // ignore hatnotes
        if ( element.classes.contains('hatnote') ){ return; }

        // traverse down the tree
        for (var subNode in element.nodes) { _parseNode(subNode); }

        return;
      case 'li':
        // TODO missing key features, treating just as div
        _tryCloseCurrentTextSpan();

        // traverse down the tree
        for (var subNode in element.nodes) { _parseNode(subNode); }

        return;
      case 'figure': // TODO
        _tryCloseCurrentTextSpan();

        // traverse down the tree
        for (var subNode in element.nodes) { _parseNode(subNode); }

        return;
      // TODO fig caption
      case 'img':
        // NOTE assuming img with width=height=11 as inline image icon

        final isInlineIcon = (element.attributes['height'] == "11" && element.attributes['width'] == "11");
        final imgSrc = 'https:' + element.attributes['src'];

        if ( isInlineIcon ) {
          // TODO REPLY ON VENDOR
          // flutter currently dont support inline image/icon in textspan
          // final icon = new ImageIcon(new NetworkImage(imgSrc));
        } else {
          _tryCloseCurrentTextSpan();

          final img = new ImageWithLoader(imgSrc);
          _widgets.add(
            new Container(
              padding: const EdgeInsets.all(8.0),
              alignment: FractionalOffset.center,
              child: img
            )
          );
        }

        return;
      case 'table':
        _tryCloseCurrentTextSpan();

        // infobox
        if (element.classes.contains('infobox')) {
          _widgets.add(
            new Container(
              padding: const EdgeInsets.all(8.0),
              child: new Container(
                padding: const EdgeInsets.all(8.0),
                alignment: FractionalOffset.center,
                child: _parseInfobox(element)
              ),
            )
          );

          return;
        }

        _widgets.add(
          new entriesHelper.HintTile(
            text: 'WikiFlutter is still in alpha and doesn\'t support complex tables for now.',
            icon: const Icon(Icons.border_all),
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

          _appendToCurrentTextSpans(entriesHelper.textLink(context: context, text: text, href: href));

          return;
        }

        // citing ref
        // <a href=\"#cite_note-18\" style=\"counter-reset: mw-Ref 13;\"><span class=\"mw-reflink-text\">[13]</span></a></span>
        if ( element.attributes['href'].startsWith('#cite_note-') ) {
          if (appContext['entry'] == null) { return; } // NOT THAT ELEGANT

          final text = element.text;
          final anchor = element.attributes['href'].replaceFirst('#', '');

          _appendToCurrentTextSpans(entriesHelper.refLink(entry: appContext['entry'], context: context, text: text, anchor: anchor));

          return;
        }

        // still traverse down the tree
        for (var subNode in element.nodes) { _parseNode(subNode); }

        return;
      default:
        // print('=== MET UNSUPPORTED TAG: ${element.localName}');

        // still traverse down the tree
        for (var subNode in element.nodes) { _parseNode(subNode); }

        return;
    }
  }

  void _tryCloseCurrentTextSpan() {
    // print('=== closingCurrentTextSpan ===' + _currentTextSpans.length.toString());

    if (_currentTextSpans.isEmpty) { return; }

    _widgets.add(
      new Container(
        padding: const EdgeInsets.all(8.0),
        child: new RichText(
          text: new TextSpan(
            style: textTheme.body1,
            children: new List.from(_currentTextSpans)
          )
        )
      )
    );

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

  Column _parseInfobox(html.Element table) {
    final borderColor = Theme.of(context).accentColor;
    final borderSide = new BorderSide(color: borderColor);
    final borderForFirstRow = new Border.all(color: borderColor);
    final borderForRemainingRows = new Border(
      left: borderSide, top: BorderSide.none, right: borderSide, bottom: borderSide
    );

    final List<html.Element> rowElements = table.querySelectorAll('tr').toList();
    List<Widget> rows = [];
    for (int i = 0; i < rowElements.length; i++){
      final r = rowElements[i];
      List<Widget> columns = r.children.where((html.Element e) => e.localName == 'td' || e.localName == 'th').map((td){
        return new Expanded(
          child: new Container(
            alignment: FractionalOffset.center,
            child: ( new HtmlParser(context).parseFromElement(td) ),
          ),
        );
      }).toList();

      rows.add(
        new Container(
          child: new Row(
            children: columns
          ),
          decoration: new BoxDecoration( border: i == 0 ? borderForFirstRow : borderForRemainingRows ),
        )
      );
    }

    return new Column(
      children: rows
    );
  }
}
