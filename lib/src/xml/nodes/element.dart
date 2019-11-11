library xml.nodes.element;

import '../utils/name.dart';
import '../utils/name_matcher.dart';
import '../utils/named.dart';
import '../utils/node_list.dart';
import '../utils/node_type.dart';
import '../visitors/visitor.dart';
import 'attribute.dart';
import 'node.dart';
import 'parent.dart';

/// XML element node.
class XmlElement extends XmlParent implements XmlNamed {
  /// Create an element node with the provided [name], [attributes], and
  /// [children].
  XmlElement(this.name,
      [Iterable<XmlAttribute> attributesIterable = const [],
      Iterable<XmlNode> children = const [],
      this.isSelfClosing = true])
      : attributes = XmlNodeList(attributeNodeTypes),
        super(childrenNodeTypes, children) {
    name.attachParent(this);
    attributes.attachParent(this);
    attributes.addAll(attributesIterable);
  }

  /// Return the name of the node.
  @override
  final XmlName name;

  /// Return the attribute nodes of this node.
  @override
  final XmlNodeList<XmlAttribute> attributes;

  /// Defines whether the element should be self-closing when empty.
  bool isSelfClosing;

  /// Return the attribute value with the given `name`.
  String getAttribute(String name, {String namespace}) =>
      getAttributeNode(name, namespace: namespace)?.value;

  /// Return the attribute node with the given `name`.
  XmlAttribute getAttributeNode(String name, {String namespace}) => attributes
      .firstWhere(createNameMatcher(name, namespace), orElse: () => null);

  @override
  XmlNodeType get nodeType => XmlNodeType.ELEMENT;

  @override
  dynamic accept(XmlVisitor visitor) => visitor.visitElement(this);
}

/// Supported child node types.
const Set<XmlNodeType> childrenNodeTypes = {
  XmlNodeType.CDATA,
  XmlNodeType.COMMENT,
  XmlNodeType.ELEMENT,
  XmlNodeType.PROCESSING,
  XmlNodeType.TEXT,
};

/// Supported attribute node types.
const Set<XmlNodeType> attributeNodeTypes = {
  XmlNodeType.ATTRIBUTE,
};
