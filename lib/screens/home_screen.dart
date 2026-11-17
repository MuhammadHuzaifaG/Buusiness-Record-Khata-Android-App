import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'customers_screen.dart';
import 'products_screen.dart';
import 'logs_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';
import 'add_customer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    final List<Widget> pages = [
      const CustomersScreen(),
      const ProductsScreen(),
      const LogsScreen(),
      const AnalyticsScreen(),
      const SettingsScreen(),
    ];

    final List<String> titles = [
      provider.isUrdu ? 'گاہک' : 'Customers',
      provider.isUrdu ? 'مصنوعات' : 'Products',
      provider.isUrdu ? 'لاگز' : 'Activity Logs',
      provider.isUrdu ? 'رپورٹس' : 'Summary & Analytics',
      provider.isUrdu ? 'ترتیبات' : 'Settings',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          if (_selectedIndex == 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: const Icon(Icons.person_add_rounded, color: Colors.white),
                tooltip: 'Add Customer',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddCustomerScreen()),
                  );
                },
              ),
            ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Colors.blue.shade100,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5));
            }
            return const TextStyle(fontSize: 12, color: Colors.grey);
          }),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          elevation: 8,
          backgroundColor: Colors.white,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.people_outline_rounded),
              selectedIcon: Icon(Icons.people_rounded, color: Color(0xFF1E88E5)),
              label: 'Customers',
            ),
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2_rounded, color: Color(0xFF1E88E5)),
              label: 'Products',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_rounded),
              selectedIcon: Icon(Icons.history_toggle_off_rounded, color: Color(0xFF1E88E5)),
              label: 'Logs',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart_rounded, color: Color(0xFF1E88E5)),
              label: 'Summary',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded, color: Color(0xFF1E88E5)),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}