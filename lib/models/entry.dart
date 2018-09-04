// import 'dart:developer';

import 'dart:async';

import 'package:html/parser.dart' as html show parse;
import 'package:html/dom.dart' as html;

import '../shared/wiki_client.dart' as wikiClient;

import '../views/shared/html_wrap.dart';
import '../views/shared/entries_helper.dart';

class Entry {
  final String displayTitle;
  final String description;
  final String coverImgSrc;
  final List<String> hatnotes; // NOTE html string
  final List<Section> sections;
  // TODO footnotes;
  Map<String, String> citings;

  Entry(Map map)
    : displayTitle = inlineHtmlWrap( map['lead']['displaytitle'] as String ),
      description = map['lead']['description'],
      coverImgSrc = _extractCoverImgSrc(map),
      hatnotes = _extractHatnotes(map),
      sections = _extractSections(map)
    {
      // TODO footnotes

      // citings
      citings = _extractCitings();
    }

  static Future<Entry> fetch({String title}) async {
    return await wikiClient.Restful.getEntry(title);
  }

  static String _extractCoverImgSrc(Map map){
    return ( map['lead']['image'] != null ) ? ( 'https:' + map['lead']['image']['urls'][map['lead']['image']['urls'].keys.last] ) : ( null );
  }

  static List<String> _extractHatnotes(Map map) {
    if ( map['lead']['hatnotes'] == null ) { return []; }

    return ( map['lead']['hatnotes'] as List ).map((h){ return h as String; }).toList();
  }

  static List<Section> _extractSections(Map map){
    return ( map['lead']['sections'] as List ).cast<Map>().map((Map section){
      final int id = section['id'];
      final int tocLevel = id == 0 ? 0 : section['toclevel'];
      final String title = id == 0 ? null : inlineHtmlWrap(section['line']);
      final String anchor = id == 0 ? null : section['anchor'];
      final String htmlText = id == 0 ? section['text'] : map['remaining']['sections'][id - 1]['text'];
      final bool isReferenceSection = id == 0 ? false : ( map['remaining']['sections'][id - 1]['isReferenceSection'] ?? false );

      return new Section(id: id, tocLevel: tocLevel, title: title, anchor: anchor, htmlText: htmlText, isReferenceSection: isReferenceSection);
    }).toList();
  }

  Map<String, String> _extractCitings() {
    final Section refSection = this.sections.lastWhere((Section s) => s.title == 'References' && s.isReferenceSection, orElse: () => null);
    if ( refSection == null ) { return new Map(); }

    // <li id="cite_note-capital-1">
    return new Map.fromIterable(
      html.parse(refSection.htmlText).body.querySelectorAll('ol.mw-references > li'),
      key: (liElement) => liElement.id,
      value: (liElement) => liElement.innerHtml
    );
  }
}

class Section {
  final int id;
  final int tocLevel; // NOTE main title (with id 0) has no tocLevel
  final String title; // NOTE main title (with id 0) has no title
  final String anchor; // NOTE main title (with id 0) has no anchor
  final String htmlText;
  // TODO PERFORMANCE cache html widget
  final bool isReferenceSection;
  final List<String> hatnotes;

  // PERFORMANCE HELL
  // currently we're parsing all sections when parsing the entry, which lead to freezing
  Section({this.id, this.tocLevel, this.title, this.anchor, this.htmlText, this.isReferenceSection}) :
    hatnotes = extractHatnotes(htmlText);
}

class Citing {
  final String anchor;
  final String htmlText;

  Citing({this.anchor, this.htmlText});
}
