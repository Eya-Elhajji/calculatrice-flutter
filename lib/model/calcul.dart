// lib/model/calcul.dart
class Calculation {
  final int? id;
  final String expression;
  final String result;
  final String timestamp;

  Calculation({
    this.id,
    required this.expression,
    required this.result,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'expression': expression,
      'result': result,
      'timestamp': timestamp,
    };
  }

  factory Calculation.fromMap(Map<String, dynamic> map) {
    return Calculation(
      id: map['id'] is int ? map['id'] as int : int.tryParse(map['id'].toString()),
      expression: map['expression']?.toString() ?? '',
      result: map['result']?.toString() ?? '',
      timestamp: map['timestamp']?.toString() ?? '',
    );
  }
}
