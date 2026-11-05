import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:desapegai/app.dart';

void main() {
  testWidgets('Login navega para cadastro e retorna', (tester) async {
    await tester.pumpWidget(const DesapegaiApp());
    expect(find.text('Entrar'), findsWidgets);
    await tester.ensureVisible(find.text('Criar conta'));
    await tester.tap(find.text('Criar conta'));
    await tester.pumpAndSettle();
    expect(find.text('Nome completo'), findsOneWidget);
    await tester.ensureVisible(find.text('Já tenho conta — voltar ao login'));
    await tester.tap(find.text('Já tenho conta — voltar ao login'));
    await tester.pumpAndSettle();
    expect(find.text('Esqueci minha senha'), findsOneWidget);
  });

  testWidgets('Login navega para recuperação e retorna', (tester) async {
    await tester.pumpWidget(const DesapegaiApp());
    await tester.tap(find.text('Esqueci minha senha'));
    await tester.pumpAndSettle();
    expect(find.text('E-mail cadastrado'), findsOneWidget);
    await tester.tap(find.text('Voltar ao login'));
    await tester.pumpAndSettle();
    expect(find.text('Esqueci minha senha'), findsOneWidget);
  });
}
