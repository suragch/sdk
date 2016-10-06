// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library analyzer.test.dart.element.test_all;

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../utils.dart';
import 'element_test.dart' as element;

/// Utility for manually running all tests.
main() {
  initializeTestEnvironment();
  defineReflectiveSuite(() {
    element.main();
  }, name: 'element');
}
