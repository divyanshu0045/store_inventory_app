import 'package:drift/drift.dart';
import 'package:drift/web.dart';

QueryExecutor connect() {
  return DatabaseConnection.delayed(Future(() {
    return WebDatabase('db');
  }));
}