import 'package:flutter_test/flutter_test.dart';
import 'package:finvo/shared/utils/map_extensions.dart';

void main() {
  group('SafeMapExtension', () {
    test('getDouble parses numbers, strings, and default fallback', () {
      final map = <String, dynamic>{
        'num_val': 42.5,
        'int_val': 10,
        'str_val': '99.9',
        'invalid_str': 'abc',
        'null_val': null,
      };

      expect(map.getDouble('num_val'), 42.5);
      expect(map.getDouble('int_val'), 10.0);
      expect(map.getDouble('str_val'), 99.9);
      expect(map.getDouble('invalid_str', defaultValue: -1.0), -1.0);
      expect(map.getDouble('null_val', defaultValue: 0.0), 0.0);
      expect(map.getDouble('missing', defaultValue: 5.0), 5.0);
    });

    test('getInt parses numbers, strings, and default fallback', () {
      final map = <String, dynamic>{
        'num_val': 42,
        'double_val': 10.8,
        'str_val': '100',
        'invalid_str': 'xyz',
      };

      expect(map.getInt('num_val'), 42);
      expect(map.getInt('double_val'), 10);
      expect(map.getInt('str_val'), 100);
      expect(map.getInt('invalid_str', defaultValue: 7), 7);
      expect(map.getInt('missing', defaultValue: 3), 3);
    });

    test('getString returns string or default fallback', () {
      final map = <String, dynamic>{
        'str': 'hello',
        'num': 123,
        'null_val': null,
      };

      expect(map.getString('str'), 'hello');
      expect(map.getString('num'), '123');
      expect(map.getString('null_val', defaultValue: 'fallback'), 'fallback');
      expect(map.getString('missing', defaultValue: 'none'), 'none');
    });

    test('getMap converts dynamic map to Map<String, dynamic>', () {
      final map = <String, dynamic>{
        'nested': {'a': 1, 'b': 'two'},
        'invalid': 'not a map',
      };

      final nested = map.getMap('nested');
      expect(nested, isNotNull);
      expect(nested!['a'], 1);
      expect(nested['b'], 'two');

      expect(map.getMap('invalid'), isNull);
      expect(map.getMap('missing'), isNull);
    });

    test('getList safely maps list items', () {
      final map = <String, dynamic>{
        'items': [
          {'name': 'item1', 'value': 10},
          {'name': 'item2', 'value': 20},
          'invalid item',
        ],
        'not_a_list': 'string',
      };

      final result = map.getList('items', (m) => '${m['name']}_${m['value']}');

      expect(result.length, 2);
      expect(result[0], 'item1_10');
      expect(result[1], 'item2_20');

      expect(map.getList('not_a_list', (m) => m), isEmpty);
      expect(map.getList('missing', (m) => m), isEmpty);
    });
  });
}
