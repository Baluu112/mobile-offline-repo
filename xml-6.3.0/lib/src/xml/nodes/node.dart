import '../enums/node_type.dart';
import '../mixins/has_attributes.dart';
import '../mixins/has_children.dart';
import '../mixins/has_parent.dart';
import '../mixins/has_value.dart';
import '../mixins/has_visitor.dart';
import '../mixins/has_writer.dart';

/// Immutable abstract XML node.
abstract class XmlNode extends Object
    with
        XmlAttributesBase,
        XmlChildrenBase,
        XmlHasVisitor,
        XmlHasWriter,
        XmlParentBase,
        XmlValueBase {
  /// Return the node type of this node.
  XmlNodeType get nodeType;

  /// Return a copy of this node and all its children.
  XmlNode copy();
}
