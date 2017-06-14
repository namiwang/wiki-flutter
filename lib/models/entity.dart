import '../views/shared/html_wrapper.dart';

class Entity {
  final String displayTitle;
  final String description;
  final String coverImgSrc;
  final List<Section> sections;

  Entity(Map map)
    : displayTitle = parseInlineHtml( map['lead']['displaytitle'] as String ),
      description = map['lead']['description'],
      coverImgSrc = _extractCoverImgSrc(map),
      sections = _extractSections(map)
    {
      // TODO cite refs
    }
}

String _extractCoverImgSrc(Map map){
  return ( map['lead']['image'] != null ) ? ( 'https:' + map['lead']['image']['urls'][map['lead']['image']['urls'].keys.last] ) : ( null );
}

List<Section> _extractSections(Map map){
  return ( map['lead']['sections'] as List ).map((Map section){
    final int id = section['id'];
    final int tocLevel = id == 0 ? 0 : section['toclevel'];
    final String title = id == 0 ? null : parseInlineHtml(section['line']);
    final String anchor = id == 0 ? null : section['anchor'];
    final String htmlText = id == 0 ? section['text'] : map['remaining']['sections'][id - 1]['text'];

    return new Section(id: id, tocLevel: tocLevel, title: title, anchor: anchor, htmlText: htmlText);
  }).toList();
}

class Section {
  final int id;
  final int tocLevel; // NOTE main title (with id 0) has no tocLevel
  final String title; // NOTE main title (with id 0) has no title
  final String anchor; // NOTE main title (with id 0) has no anchor
  final String htmlText;
  // TODO PERFORMANCE cache html widget

  Section({this.id, this.tocLevel, this.title, this.anchor ,this.htmlText});
}
