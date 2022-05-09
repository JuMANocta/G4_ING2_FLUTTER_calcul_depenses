import 'package:intl/intl.dart';

class Expense {
  final int id;
  final double montant;
  final DateTime date;
  final String category;

  Expense(this.id, this.montant, this.date, this.category);
  String get formattedDate {
    var formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(date);
  }

  static final colums = ['id', 'montant', 'date', 'category'];
  factory Expense.fromMap(Map<dynamic, dynamic> data) {
    return Expense(data['id'], data['montant'], DateTime.parse(data['date']),data['category']);
  }
  Map<String, dynamic> toMap() => {
        'id': id,
        'montant': montant,
        'date': date.toString(),
        'category': category,
      };
}
