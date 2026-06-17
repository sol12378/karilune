import 'package:carilune/widgets/ad_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AdGridDelegate uses maxCrossAxisExtent', () {
    final delegate = AdGridDelegate.delegateFor(1200);
    expect(delegate, isA<SliverGridDelegateWithMaxCrossAxisExtent>());
    final ext = delegate as SliverGridDelegateWithMaxCrossAxisExtent;
    expect(ext.maxCrossAxisExtent, AdGridDelegate.maxCardWidth);
    expect(ext.mainAxisExtent, AdGridDelegate.cardHeight);
  });
}
