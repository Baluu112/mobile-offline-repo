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
      expect(() => doc.insertIntoList([], 0, 4), throwsPathError);
    });

    test('if it is a scalar', () {
      final doc = YamlEditor('1');
      expect(() => doc.insertIntoList([], 0, 4), throwsPathError);
    });
  });

  test('throws RangeError if index is out of range', () {
    final doc = YamlEditor('[1, 2]');
    expect(() => doc.insertIntoList([], -1, 0), throwsRangeError);
    expect(() => doc.insertIntoList([], 3, 0), throwsRangeError);
  });

  group('block list', () {
    test('(1)', () {
      final doc = YamlEditor('''
- 1
- 2''');
      doc.insertIntoList([], 0, 0);
      expect(doc.toString(), equals('''
- 0
- 1
- 2'''));
      expectYamlBuilderValue(doc, [0, 1, 2]);
    });

    test('(2)', () {
      final doc = YamlEditor('''
- 1
- 2''');
      doc.insertIntoList([], 1, 3);
      expect(doc.toString(), equals('''
- 1
- 3
- 2'''));
      expectYamlBuilderValue(doc, [1, 3, 2]);
    });

    test('(3)', () {
      final doc = YamlEditor('''
- 1
- 2
''');
      doc.insertIntoList([], 2, 3);
      expect(doc.toString(), equals('''
- 1
- 2
- 3
'''));
      expectYamlBuilderValue(doc, [1, 2, 3]);
    });

    test('(4)', () {
      final doc = YamlEditor('''
- 1
- 3
''');
      doc.insertIntoList([], 1, [4, 5, 6]);
      expect(doc.toString(), equals('''
- 1
- - 4
  - 5
  - 6
- 3
'''));
      expectYamlBuilderValue(doc, [
        1,
        [4, 5, 6],
        3
      ]);
    });

    test(' with comments', () {
      final doc = YamlEditor('''
- 0 # comment a
- 2 # comment b
''');
      doc.insertIntoList([], 1, 1);
      expect(doc.toString(), equals('''
- 0 # comment a
- 1
- 2 # comment b
'''));
      expectYamlBuilderValue(doc, [0, 1, 2]);
    });

    for (var i = 0; i < 3; i++) {
      test('block insert(1) at $i', () {
        final yamlEditor = YamlEditor('''
# comment
- z:
    x: 1
    y: 2
- z:
    x: 3
    y: 4
''');
        expect(
            () => yamlEditor.insertIntoList(
                [],
                i,
                {
                  'z': {'x': 5, 'y': 6}
                }),
            returnsNormally);
      });
    }

    for (var i = 0; i < 3; i++) {
      test('block insert(2) at $i', () {
        final yamlEditor = YamlEditor('''
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
        expect(
            () => yamlEditor.insertIntoList(
                ['a'],
                i,
                {
                  'z': {'x': 5, 'y': 6}
                }),
            returnsNormally);
      });
    }

    for (var i = 0; i < 2; i++) {
      test('block insert nested and with comments at $i', () {
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
            () => yamlEditor.insertIntoList(
                ['a', 'b'],
                i,
                {
                  'g': {'e': 3, 'f': 4}
                }),
            returnsNormally);
      });
    }
  });

  group('flow list', () {
    test('(1)', () {
      final doc = YamlEditor('[1, 2]');
      doc.insertIntoList([], 0, 0);
      expect(doc.toString(), equals('[0, 1, 2]'));
      expectYamlBuilderValue(doc, [0, 1, 2]);
    });

    test('(2)', () {
      final doc = YamlEditor('[1, 2]');
      doc.insertIntoList([], 1, 3);
      expect(doc.toString(), equals('[1, 3, 2]'));
      expectYamlBuilderValue(doc, [1, 3, 2]);
    });

    test('(3)', () {
      final doc = YamlEditor('[1, 2]');
      doc.insertIntoList([], 2, 3);
      expect(doc.toString(), equals('[1, 2, 3]'));
      expectYamlBuilderValue(doc, [1, 2, 3]);
    });

    test('(4)', () {
      final doc = YamlEditor('["[],", "[],"]');
      doc.insertIntoList([], 1, 'test');
      expect(doc.toString(), equals('["[],", test, "[],"]'));
      expectYamlBuilderValue(doc, ['[],', 'test', '[],']);
    });
  });
}
