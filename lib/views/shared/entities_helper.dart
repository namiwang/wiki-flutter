// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../models/entity.dart';

import './html_parser.dart';
import './html_wrapper.dart';

class SectionHtmlWrapper extends StatelessWidget {
  final Entity entity;
  final int sectionId;

  SectionHtmlWrapper({ Key key, this.entity, this.sectionId }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (new HtmlParser(context, appContext: {'entity': entity}).parse(entity.sections[sectionId].htmlText));
  }
}

// NOTE disabled suffixIcon due to vendor issue: https://github.com/flutter/flutter/issues/10623
TextSpan textLink({BuildContext context, String text, String href}) {
  // static const style = const TextStyle(color: Colors.blue, decoration: TextDecoration.underline);
  const linkStyle = const TextStyle(color: Colors.blue);
  // static final suffixIconString = new String.fromCharCode(Icons.open_in_browser.codePoint);
  // static final suffixIconStyle = linkStyle.apply(fontFamily: 'MaterialIcons');

  TextSpan _textSpanForInternalEntityLink(String targetEntityTitle) {
    final recognizer = new TapGestureRecognizer()
      ..onTap = (){
        Navigator.pushNamed(context, "/entities/$targetEntityTitle");
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

  // internal link to another entity
  // <a href=\"/wiki/Political_union\" title=\"Political union\">political</a> and <a href=\"/wiki/Economic_union\" title=\"Economic union\">economic union</a>
  if ( href.startsWith('/wiki/') ) {
    final String targetEntityTiele = href.replaceAll('/wiki/', '');
    return _textSpanForInternalEntityLink(targetEntityTiele);
  }

  // default as an external link
  return _textSpanForExternalLink();
}

TextSpan refLink({Entity entity, BuildContext context, String anchor, String text}){
  const refLinkStyle = const TextStyle(color: Colors.blue);

  final recognizer = new TapGestureRecognizer()
    ..onTap = (){
      final citingHtmlStr = entity.citings[anchor] ?? 'citing not found';

      showModalBottomSheet(context: context, builder: (BuildContext context) {
        return new Container(
          child: new Padding(
            padding: const EdgeInsets.all(32.0),
            child: new HtmlWrapper(htmlStr: citingHtmlStr),
          )
        );
      });
    };

  return new TextSpan(text: text, style: refLinkStyle, recognizer: recognizer);
}
