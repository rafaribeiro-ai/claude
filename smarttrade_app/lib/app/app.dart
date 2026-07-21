import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:smarttrade_app/app/theme/app_theme.dart';
import 'package:smarttrade_app/features/boleta_inteligente/presentation/screens/smart_order_ticket_screen.dart';
import 'package:smarttrade_app/features/chart_analysis/presentation/screens/trading_chart_screen.dart';
import 'package:smarttrade_app/features/trading_journal/presentation/screens/trading_journal_screen.dart';

class SmartTradeApp extends StatelessWidget {
  const SmartTradeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartTrade App',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.dark,
      theme: AppTheme.dark,
      home: const HomeShell(),
    );
  }
}

/// Bottom-nav shell for the MVP's three screens: the Boleta Inteligente
/// (the core feature), the chart, and the offline trading journal.
class HomeShell extends HookWidget {
  const HomeShell({super.key});

  static const _screens = [
    SmartOrderTicketScreen(),
    TradingChartScreen(),
    TradingJournalScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = useState(0);

    return Scaffold(
      body: IndexedStack(index: currentIndex.value, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex.value,
        onTap: (index) => currentIndex.value = index,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Boleta',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart_outlined),
            activeIcon: Icon(Icons.show_chart),
            label: 'Gráfico',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Diário',
          ),
        ],
      ),
    );
  }
}
