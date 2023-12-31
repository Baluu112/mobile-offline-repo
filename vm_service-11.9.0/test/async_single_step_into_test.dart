// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:developer';
import 'common/service_test_common.dart';
import 'common/test_helper.dart';

const LINE_A = 16;
const LINE_B = 17;
const LINE_0 = 21;
const LINE_C = 22;
const LINE_D = 23;

helper() async {
  print('helper'); // LINE_A.
  print('foobar'); // LINE_B.
}

testMain() {
  debugger(); // LINE_0.
  print('mmmmm'); // LINE_C.
  helper(); // LINE_D.
  print('z');
}

var tests = <IsolateTest>[
  hasStoppedAtBreakpoint,
  stoppedAtLine(LINE_0),
  stepOver, // print.

  stoppedAtLine(LINE_C),
  stepOver, // print.

  hasStoppedAtBreakpoint,
  stoppedAtLine(LINE_D),
  stepInto,

  hasStoppedAtBreakpoint,
  stoppedAtLine(LINE_A),
  stepOver, // print.

  hasStoppedAtBreakpoint,
  stoppedAtLine(LINE_B),
  resumeIsolate
];

main([args = const <String>[]]) => runIsolateTestsSynchronous(
      args,
      tests,
      'async_single_step_into_test.dart',
      testeeConcurrent: testMain,
      extraArgs: extraDebuggingArgs,
    );
