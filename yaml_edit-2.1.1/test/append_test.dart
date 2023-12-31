// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'test_utils.dart';

void main() {
  group('throws PathError', () {
    test('if it is a map', () {
      final doc = YamlEditor('a:1');
      expect(() => doc.appendToList([], 4), throwsPathError);
    });

    test('if it is a scalar', () {
      final doc = YamlEditor('1');
      expect(() => doc.appendToList([], 4), throwsPathError);
    });
  });

  group('block list', () {
    test('(1)', () {
      final doc = YamlEditor('''
- 0
- 1
- 2
- 3
''');
      doc.appendToList([], 4);
      expect(doc.toString(), equals('''
- 0
- 1
- 2
- 3
- 4
'''));
      expectYamlBuilderValue(doc, [0, 1, 2, 3, 4]);
    });

    test('null path', () {
      final doc = YamlEditor('''
~:
  - 0
  - 1
  - 2
  - 3
''');
      doc.appendToList([null], 4);
      expect(doc.toString(), equals('''
~:
  - 0
  - 1
  - 2
  - 3
  - 4
'''));
      expectYamlBuilderValue(doc, {
        null: [0, 1, 2, 3, 4]
      });
    });

    test('element to simple block list ', () {
      final doc = YamlEditor('''
- 0
- 1
- 2
- 3
''');
      doc.appendToList([], [4, 5, 6]);
      expect(doc.toString(), equals('''
- 0
- 1
- 2
- 3
- - 4
  - 5
  - 6
'''));
      expectYamlBuilderValue(doc, [
        0,
        1,
        2,
        3,
        [4, 5, 6]
      ]);
    });

    test('nested', () {
      final doc = YamlEditor('''
- 0
- - 1
  - 2
''');
      doc.appendToList([1], 3);
      expect(doc.toString(), equals('''
- 0
- - 1
  - 2
  - 3
'''));
      expectYamlBuilderValue(doc, [
        0,
        [1, 2, 3]
      ]);
    });

    test('block list element to nested block list ', () {
      final doc = YamlEditor('''
- 0
- - 1
  - 2
''');
      doc.appendToList([1], [3, 4, 5]);

      expect(doc.toString(), equals('''
- 0
- - 1
  - 2
  - - 3
    - 4
    - 5
'''));
      expectYamlBuilderValue(doc, [
        0,
        [
          1,
          2,
          [3, 4, 5]
        ]
      ]);
    });

    test('nested', () {
      final yamlEditor = YamlEditor('''
a:
  1:
    - null
  2: null
''');
      yamlEditor.appendToList(['a', 1], false);

      expect(yamlEditor.toString(), equals('''
a:
  1:
    - null
    - false
  2: null
'''));
    });

    test('block append (1)', () {
      final yamlEditor = YamlEditor('''
# comment
- z:
    x: 1
    y: 2
- z:
    x: 3
    y: 4
''');
      yamlEditor.appendToList([], {
        'z': {'x': 5, 'y': 6}
      });

      expect(yamlEditor.toString(), equals('''
# comment
- z:
    x: 1
    y: 2
- z:
    x: 3
    y: 4
- z:
    x: 5
    y: 6
'''));
    });

    test('block append (2)', () {
      final yamlEditor = YamlEditor('''
# comment
a:
  - z:
      x: 1
      y: 2
  - z:
      x: 3
      y: 4
b:
  - w:
      m: 2
      n: 4
''');
      yamlEditor.appendToList([
        'a'
      ], {
        'z': {'x': 5, 'y': 6}
      });

      expect(yamlEditor.toString(), equals('''
# comment
a:
  - z:
      x: 1
      y: 2
  - z:
      x: 3
      y: 4
  - z:
      x: 5
      y: 6
b:
  - w:
      m: 2
      n: 4
'''));
    });

    test('block append nested and with comments', () {
      final yamlEditor = YamlEditor('''
a:
  b:
    - c:
        d: 1
    - c:
        d: 2
# comment
  e:
    - g:
        e: 1
        f: 2 
# comment
''');
      expect(
          () => yamlEditor.appendToList([
                'a',
                'e'
              ], {
                'g': {'e': 3, 'f': 4}
              }),
          returnsNormally);
    });
  });

  group('flow list', () {
    test('(1)', () {
      final doc = YamlEditor('[0, 1, 2]');
      doc.appendToList([], 3);
      expect(doc.toString(), equals('[0, 1, 2, 3]'));
      expectYamlBuilderValue(doc, [0, 1, 2, 3]);
    });

    test('null value', () {
      final doc = YamlEditor('[0, 1, 2]');
      doc.appendToList([], null);
      expect(doc.toString(), equals('[0, 1, 2, null]'));
      expectYamlBuilderValue(doc, [0, 1, 2, null]);
    });

    test('empty ', () {
      final doc = YamlEditor('[]');
      doc.appendToList([], 0);
      expect(doc.toString(), equals('[0]'));
      expectYamlBuilderValue(doc, [0]);
    });
  });
}
