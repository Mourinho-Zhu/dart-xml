library xml.utils.entities;

import 'package:petitparser/petitparser.dart' show char, digit, pattern, word;
import 'package:petitparser/petitparser.dart' show Context, Result, Parser;

import 'attribute_type.dart';

// Hexadecimal character reference.
final Parser<String> _entityHex = pattern('xX')
    .seq(pattern('A-Fa-f0-9')
        .plus()
        .flatten('Expected hexadecimal character reference')
        .map((value) => String.fromCharCode(int.parse(value, radix: 16))))
    .pick(1);

// Decimal character reference.
final Parser<String> _entityDigit = char('#')
    .seq(_entityHex.or(digit()
        .plus()
        .flatten('Expected decimal character reference')
        .map((value) => String.fromCharCode(int.parse(value)))))
    .pick(1);

// Named character reference.
final Parser<String> _entity = char('&')
    .seq(_entityDigit.or(word()
        .plus()
        .flatten('Expected named character reference')
        .map((value) => entityToChar[value])))
    .seq(char(';'))
    .pick(1);

/// Optimized parser to read character data.
class XmlCharacterDataParser extends Parser<String> {
  final String _stopper;
  final int _stopperCode;
  final int _minLength;

  XmlCharacterDataParser(String stopper, int minLength)
      : _stopper = stopper,
        _stopperCode = stopper.codeUnitAt(0),
        _minLength = minLength;

  @override
  Result<String> parseOn(Context context) {
    final input = context.buffer;
    final length = input.length;
    final output = StringBuffer();
    var position = context.position;
    var start = position;

    // scan over the characters as fast as possible
    while (position < length) {
      final value = input.codeUnitAt(position);
      if (value == _stopperCode) {
        break;
      } else if (value == 38) {
        final result = _entity.parseOn(context.success(null, position));
        if (result.isSuccess && result.value != null) {
          output.write(input.substring(start, position));
          output.write(result.value);
          position = result.position;
          start = position;
        } else {
          position++;
        }
      } else {
        position++;
      }
    }
    output.write(input.substring(start, position));

    // check for the minimum length
    return output.length < _minLength
        ? context.failure('Unable to parse chracter data.')
        : context.success(output.toString(), position);
  }

  @override
  int fastParseOn(String buffer, int position) {
    final start = position;
    final length = buffer.length;
    while (position < length) {
      final value = buffer.codeUnitAt(position);
      if (value == _stopperCode) {
        break;
      } else {
        position++;
      }
    }
    return position - start < _minLength ? -1 : position;
  }

  @override
  List<Parser> get children => [_entity];

  @override
  XmlCharacterDataParser copy() => XmlCharacterDataParser(_stopper, _minLength);

  @override
  bool hasEqualProperties(XmlCharacterDataParser other) =>
      super.hasEqualProperties(other) &&
      _stopper == other._stopper &&
      _minLength == other._minLength;
}

/// Mapping from entity name to character.
const Map<String, String> entityToChar = {
  // xml entities
  'lt': '<',
  'gt': '>',
  'amp': '&',
  'apos': "'",
  'quot': '"',

  // html entities
  'Aacute': '\u00C1',
  'aacute': '\u00E1',
  'Acirc': '\u00C2',
  'acirc': '\u00E2',
  'acute': '\u00B4',
  'AElig': '\u00C6',
  'aelig': '\u00E6',
  'Agrave': '\u00C0',
  'agrave': '\u00E0',
  'alefsym': '\u2135',
  'Alpha': '\u0391',
  'alpha': '\u03B1',
  'and': '\u2227',
  'ang': '\u2220',
  'Aring': '\u00C5',
  'aring': '\u00E5',
  'asymp': '\u2248',
  'Atilde': '\u00C3',
  'atilde': '\u00E3',
  'Auml': '\u00C4',
  'auml': '\u00E4',
  'bdquo': '\u201E',
  'Beta': '\u0392',
  'beta': '\u03B2',
  'brvbar': '\u00A6',
  'bull': '\u2022',
  'cap': '\u2229',
  'Ccedil': '\u00C7',
  'ccedil': '\u00E7',
  'cedil': '\u00B8',
  'cent': '\u00A2',
  'Chi': '\u03A7',
  'chi': '\u03C7',
  'circ': '\u02C6',
  'clubs': '\u2663',
  'cong': '\u2245',
  'copy': '\u00A9',
  'crarr': '\u21B5',
  'cup': '\u222A',
  'curren': '\u00A4',
  'dagger': '\u2020',
  'Dagger': '\u2021',
  'darr': '\u2193',
  'dArr': '\u21D3',
  'deg': '\u00B0',
  'Delta': '\u0394',
  'delta': '\u03B4',
  'diams': '\u2666',
  'divide': '\u00F7',
  'Eacute': '\u00C9',
  'eacute': '\u00E9',
  'Ecirc': '\u00CA',
  'ecirc': '\u00EA',
  'Egrave': '\u00C8',
  'egrave': '\u00E8',
  'empty': '\u2205',
  'emsp': '\u2003',
  'ensp': '\u2002',
  'Epsilon': '\u0395',
  'epsilon': '\u03B5',
  'equiv': '\u2261',
  'Eta': '\u0397',
  'eta': '\u03B7',
  'ETH': '\u00D0',
  'eth': '\u00F0',
  'Euml': '\u00CB',
  'euml': '\u00EB',
  'euro': '\u20AC',
  'exist': '\u2203',
  'fnof': '\u0192',
  'forall': '\u2200',
  'frac12': '\u00BD',
  'frac14': '\u00BC',
  'frac34': '\u00BE',
  'frasl': '\u2044',
  'Gamma': '\u0393',
  'gamma': '\u03B3',
  'ge': '\u2265',
  'harr': '\u2194',
  'hArr': '\u21D4',
  'hearts': '\u2665',
  'hellip': '\u2026',
  'Iacute': '\u00CD',
  'iacute': '\u00ED',
  'Icirc': '\u00CE',
  'icirc': '\u00EE',
  'iexcl': '\u00A1',
  'Igrave': '\u00CC',
  'igrave': '\u00EC',
  'image': '\u2111',
  'infin': '\u221E',
  'int': '\u222B',
  'Iota': '\u0399',
  'iota': '\u03B9',
  'iquest': '\u00BF',
  'isin': '\u2208',
  'Iuml': '\u00CF',
  'iuml': '\u00EF',
  'Kappa': '\u039A',
  'kappa': '\u03BA',
  'Lambda': '\u039B',
  'lambda': '\u03BB',
  'lang': '\u2329',
  'laquo': '\u00AB',
  'larr': '\u2190',
  'lArr': '\u21D0',
  'lceil': '\u2308',
  'ldquo': '\u201C',
  'le': '\u2264',
  'lfloor': '\u230A',
  'lowast': '\u2217',
  'loz': '\u25CA',
  'lrm': '\u200E',
  'lsaquo': '\u2039',
  'lsquo': '\u2018',
  'macr': '\u00AF',
  'mdash': '\u2014',
  'micro': '\u00B5',
  'middot': '\u00B7',
  'minus': '\u2212',
  'Mu': '\u039C',
  'mu': '\u03BC',
  'nabla': '\u2207',
  'nbsp': '\u00A0',
  'ndash': '\u2013',
  'ne': '\u2260',
  'ni': '\u220B',
  'not': '\u00AC',
  'notin': '\u2209',
  'nsub': '\u2284',
  'Ntilde': '\u00D1',
  'ntilde': '\u00F1',
  'Nu': '\u039D',
  'nu': '\u03BD',
  'Oacute': '\u00D3',
  'oacute': '\u00F3',
  'Ocirc': '\u00D4',
  'ocirc': '\u00F4',
  'OElig': '\u0152',
  'oelig': '\u0153',
  'Ograve': '\u00D2',
  'ograve': '\u00F2',
  'oline': '\u203E',
  'Omega': '\u03A9',
  'omega': '\u03C9',
  'Omicron': '\u039F',
  'omicron': '\u03BF',
  'oplus': '\u2295',
  'or': '\u2228',
  'ordf': '\u00AA',
  'ordm': '\u00BA',
  'Oslash': '\u00D8',
  'oslash': '\u00F8',
  'Otilde': '\u00D5',
  'otilde': '\u00F5',
  'otimes': '\u2297',
  'Ouml': '\u00D6',
  'ouml': '\u00F6',
  'para': '\u00B6',
  'part': '\u2202',
  'permil': '\u2030',
  'perp': '\u22A5',
  'Phi': '\u03A6',
  'phi': '\u03C6',
  'Pi': '\u03A0',
  'pi': '\u03C0',
  'piv': '\u03D6',
  'plusmn': '\u00B1',
  'pound': '\u00A3',
  'prime': '\u2032',
  'Prime': '\u2033',
  'prod': '\u220F',
  'prop': '\u221D',
  'Psi': '\u03A8',
  'psi': '\u03C8',
  'radic': '\u221A',
  'rang': '\u232A',
  'raquo': '\u00BB',
  'rarr': '\u2192',
  'rArr': '\u21D2',
  'rceil': '\u2309',
  'rdquo': '\u201D',
  'real': '\u211C',
  'reg': '\u00AE',
  'rfloor': '\u230B',
  'Rho': '\u03A1',
  'rho': '\u03C1',
  'rlm': '\u200F',
  'rsaquo': '\u203A',
  'rsquo': '\u2019',
  'sbquo': '\u201A',
  'Scaron': '\u0160',
  'scaron': '\u0161',
  'sdot': '\u22C5',
  'sect': '\u00A7',
  'shy': '\u00AD',
  'Sigma': '\u03A3',
  'sigma': '\u03C3',
  'sigmaf': '\u03C2',
  'sim': '\u223C',
  'spades': '\u2660',
  'sub': '\u2282',
  'sube': '\u2286',
  'sum': '\u2211',
  'sup': '\u2283',
  'sup1': '\u00B9',
  'sup2': '\u00B2',
  'sup3': '\u00B3',
  'supe': '\u2287',
  'szlig': '\u00DF',
  'Tau': '\u03A4',
  'tau': '\u03C4',
  'there4': '\u2234',
  'Theta': '\u0398',
  'theta': '\u03B8',
  'thetasym': '\u03D1',
  'thinsp': '\u2009',
  'THORN': '\u00DE',
  'thorn': '\u00FE',
  'tilde': '\u02DC',
  'times': '\u00D7',
  'trade': '\u2122',
  'Uacute': '\u00DA',
  'uacute': '\u00FA',
  'uarr': '\u2191',
  'uArr': '\u21D1',
  'Ucirc': '\u00DB',
  'ucirc': '\u00FB',
  'Ugrave': '\u00D9',
  'ugrave': '\u00F9',
  'uml': '\u00A8',
  'upsih': '\u03D2',
  'Upsilon': '\u03A5',
  'upsilon': '\u03C5',
  'Uuml': '\u00DC',
  'uuml': '\u00FC',
  'weierp': '\u2118',
  'Xi': '\u039E',
  'xi': '\u03BE',
  'Yacute': '\u00DD',
  'yacute': '\u00FD',
  'yen': '\u00A5',
  'yuml': '\u00FF',
  'Yuml': '\u0178',
  'Zeta': '\u0396',
  'zeta': '\u03B6',
  'zwj': '\u200D',
  'zwnj': '\u200C'
};

/// Internal type definition for string replacement functions.
typedef ReplaceFunction = String Function(Match match);

/// Encode a string to be serialized as an XML text node.
String encodeXmlText(String input) =>
    input.replaceAllMapped(_textPattern, _textReplace);

final Pattern _textPattern = RegExp(r'[&<]|]]>');

String _textReplace(Match match) {
  switch (match.group(0)) {
    case '<':
      return '&lt;';
    case '&':
      return '&amp;';
    case ']]>':
      return ']]&gt;';
    default:
      throw AssertionError();
  }
}

/// Encode a string to be serialized as an XML attribute value.
String encodeXmlAttributeValue(String input, XmlAttributeType attributeType) =>
    input.replaceAllMapped(
        _attributePattern[attributeType], _attributeReplace[attributeType]);

/// Encode a string to be serialized as an XML attribute value with quotes.
String encodeXmlAttributeValueWithQuotes(
    String input, XmlAttributeType attributeType) {
  final quote = attributeQuote[attributeType];
  final buffer = StringBuffer();
  buffer.write(quote);
  buffer.write(encodeXmlAttributeValue(input, attributeType));
  buffer.write(quote);
  return buffer.toString();
}

final Map<XmlAttributeType, String> attributeQuote = {
  XmlAttributeType.SINGLE_QUOTE: "'",
  XmlAttributeType.DOUBLE_QUOTE: '"'
};

final Map<XmlAttributeType, Pattern> _attributePattern = {
  XmlAttributeType.SINGLE_QUOTE: RegExp(r"['&<\n\r\t]"),
  XmlAttributeType.DOUBLE_QUOTE: RegExp(r'["&<\n\r\t]')
};

final Map<XmlAttributeType, ReplaceFunction> _attributeReplace = {
  XmlAttributeType.SINGLE_QUOTE: (match) {
    switch (match.group(0)) {
      case "'":
        return '&apos;';
      case '&':
        return '&amp;';
      case '<':
        return '&lt;';
      case '\n':
        return '&#xA;';
      case '\r':
        return '&#xD;';
      case '\t':
        return '&#x9;';
      default:
        throw AssertionError();
    }
  },
  XmlAttributeType.DOUBLE_QUOTE: (match) {
    switch (match.group(0)) {
      case '"':
        return '&quot;';
      case '&':
        return '&amp;';
      case '<':
        return '&lt;';
      case '\n':
        return '&#xA;';
      case '\r':
        return '&#xD;';
      case '\t':
        return '&#x9;';
      default:
        throw AssertionError();
    }
  },
};
