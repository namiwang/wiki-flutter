// import 'dart:developer';

import 'dart:async';

import 'package:html/parser.dart' as html show parse;
import 'package:html/dom.dart' as html;

import '../shared/wiki_client.dart' as wikiClient;

import '../views/shared/html_parser.dart';

class Entity {
  final String displayTitle;
  final String description;
  final String coverImgSrc;
  final List<Section> sections;
  // TODO footnotes;
  Map<String, String> citings;

  Entity(Map map)
    : displayTitle = parseInlineHtml( map['lead']['displaytitle'] as String ),
      description = map['lead']['description'],
      coverImgSrc = _extractCoverImgSrc(map),
      sections = _extractSections(map)
    {
      // TODO footnotes

      // citings
      citings = _extractCitings();
    }

  static Future<Entity> fetch({String title}) async {
    final Map entityMap = await wikiClient.Restful.getEntity(title);
    return new Entity(entityMap);
  }

  static String _extractCoverImgSrc(Map map){
    return ( map['lead']['image'] != null ) ? ( 'https:' + map['lead']['image']['urls'][map['lead']['image']['urls'].keys.last] ) : ( null );
  }

  static List<Section> _extractSections(Map map){
    return ( map['lead']['sections'] as List ).map((Map section){
      final int id = section['id'];
      final int tocLevel = id == 0 ? 0 : section['toclevel'];
      final String title = id == 0 ? null : parseInlineHtml(section['line']);
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

  Section({this.id, this.tocLevel, this.title, this.anchor, this.htmlText, this.isReferenceSection});
}

class Citing {
  final String anchor;
  final String htmlText;

  Citing({this.anchor, this.htmlText});
}
