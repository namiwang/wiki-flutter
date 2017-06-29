// import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:html/dom.dart' as html;
import 'package:html/parser.dart' as html show parse;
import 'package:url_launcher/url_launcher.dart';

import '../../models/entry.dart';

import './html_parser.dart';
import './html_wrap.dart';

class SectionHtmlWrapper extends StatelessWidget {
  final Entry entry;
  final int sectionId;

  SectionHtmlWrapper({ Key key, this.entry, this.sectionId }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (new HtmlParser(context, appContext: {'entry': entry}).parseFromStr(entry.sections[sectionId].htmlText));
  }
}

// NOTE disabled suffixIcon due to vendor issue: https://github.com/flutter/flutter/issues/10623
// besides, it did not look good

TextSpan textLink({BuildContext context, String text, String href}) {
  // static const style = const TextStyle(color: Colors.blue, decoration: TextDecoration.underline);
  final linkStyle = Theme.of(context).textTheme.body1.copyWith(color: Colors.blue);
  // static final suffixIconString = new String.fromCharCode(Icons.open_in_browser.codePoint);
  // static final suffixIconStyle = linkStyle.apply(fontFamily: 'MaterialIcons');

  TextSpan _textSpanForInternalEntryLink(String targetEntryTitle) {
    final recognizer = new TapGestureRecognizer()
      ..onTap = (){
        Navigator.pushNamed(context, "/entries/$targetEntryTitle");
      };

    return new TextSpan(
      text: text,
      style: linkStyle,
      recognizer: recognizer
    );
  }

  TextSpan _textSpanForExternalLink() {
    final recognizer = new TapGestureRecognizer()
      ..onTap = (){ launch(href); };

    return new TextSpan(
      text: text,
      style: linkStyle,
      recognizer: recognizer
    );
  }

  // internal link to another entry
  // <a href=\"/wiki/Political_union\" title=\"Political union\">political</a> and <a href=\"/wiki/Economic_union\" title=\"Economic union\">economic union</a>
  if ( href.startsWith('/wiki/') ) {
    final String targetEntryTiele = href.replaceAll('/wiki/', '');
    return _textSpanForInternalEntryLink(targetEntryTiele);
  }

  // default as an external link
  return _textSpanForExternalLink();
}

TextSpan refLink({Entry entry, BuildContext context, String anchor, String text}){
  final refLinkStyle = Theme.of(context).textTheme.caption.copyWith(color: Colors.blue);

  final recognizer = new TapGestureRecognizer()
    ..onTap = (){
      final citingHtmlStr = entry.citings[anchor] ?? 'citing not found';

      showModalBottomSheet(context: context, builder: (BuildContext context) {
        return new Container(
          child: new Padding(
            padding: const EdgeInsets.all(32.0),
            child: new HtmlWrap(htmlStr: citingHtmlStr),
          )
        );
      });
    };

  return new TextSpan(text: text, style: refLinkStyle, recognizer: recognizer);
}

class HintTile extends Container {
  HintTile({ @required String text, Icon icon: const Icon(Icons.info_outline), bool botPadding = true}) : super(
    padding: new EdgeInsets.fromLTRB(16.0, 16.0, 16.0, ( botPadding ? 16.0 : 0.0 )),
    child: new ListTile(
      dense: true,
      leading: icon,
      title: new Text(text),
    )
  );

  // TODO there must be a better way, instead of writing most code twice
  HintTile.withHtmlStr({ @required String htmlStr, Icon icon: const Icon(Icons.info_outline), bool botPadding = true}) : super(
    padding: new EdgeInsets.fromLTRB(16.0, 16.0, 16.0, ( botPadding ? 16.0 : 0.0 )),
    child: new ListTile(
      leading: icon,
      title: new HtmlWrap(htmlStr: htmlStr),
      dense: true,
    )
  );
}

// TODO refine
// only used for extractionHatnotes in section's content
// PERFORMANCE HELL this is another time of parsing
// and currently we're parsing all sections when parsing the entry, which lead to freezing
// maybe should the htmlParser.parse return both widget and hatenotes list
List<String> extractHatnotes(String htmlStr) {
  final elements = html.parse(htmlStr).querySelectorAll('div.hatnote');
  if (elements.isEmpty) { return []; }
  return elements.map((html.Element e){ return e.innerHtml ;}).toList();
}
