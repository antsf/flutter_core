// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

void main() {
  const text = '  ';
  print(text.isNullOrEmpty); // true

  final list = <int>[1, 2, 3];
  print(list.second); // 2

  final map = {'a': 1};
  print(map.isNullOrEmpty); // false
  print(map.pretty());

  const maybe = null;
  maybe.let((v) => print(v)) ?? print('was null');

  'hello world'.capitalizeWords; // Hello World
  DateTime.now().toIndonesianDate(); // 26 Juni 2025
  60000.toRupiah(); // Rp60.000,00

  Column(
    children: [
      const Text('A'),
      const Text('B'),
      const Text('C'),
    ].spaceBetween(16), // 16 logical-pixels between each
  );

  Row(
    children: [
      const Icon(Icons.star),
      const Icon(Icons.star),
    ].separatedBy(const VerticalDivider(width: 1)),
  );

  bool showLast = true;

  Column(
    children: [
      const Text('First'),
    ]
        .addIf(showLast, const Text('Last'))
        .surroundWith(leading: const Text('Header')),
  );
}
