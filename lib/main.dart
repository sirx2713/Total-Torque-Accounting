import 'package:flutter/material.dart';
import 'views/calculator_view.dart';
import 'views/pdf_form_view.dart';
import 'views/invoice_list_view.dart';
import 'views/chatbot_view.dart';

void main() {
  runApp(const MyApp());
}

// Define brand colors based on the logo
class TorqueColors {
  static const Color primaryRed = Color(0xFFFF0000);
  static const Color primaryBlue = Color(0xFF0000FF);
  static const Color white = Colors.white;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Total Torque Accounting',
      theme: ThemeData(
        primaryColor: TorqueColors.primaryRed,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const CalculatorView(),
    const PdfFormView(),
    const InvoiceListView(),
    const ChatbotView(),
  ];

  final List<String> _titles = [
    'Calculator',
    'Create Invoice',
    'Saved Invoices',
    'Chat Assistant',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: TorqueColors.primaryRed,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 70,
            child: CustomBottomNavBar(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
              0,
              selectedIndex == 0
                  ? Icons.architecture_rounded
                  : Icons.architecture_outlined,
              'Torque Calc'
          ),
          _buildNavItem(
              1,
              selectedIndex == 1
                  ? Icons.post_add_rounded
                  : Icons.post_add_outlined,
              'New Invoice'
          ),
          _buildNavItem(
              2,
              selectedIndex == 2
                  ? Icons.inventory_2_rounded
                  : Icons.inventory_2_outlined,
              'Documents'
          ),
          _buildNavItem(
              3,
              selectedIndex == 3
                  ? Icons.support_agent_rounded
                  : Icons.support_agent_outlined,
              'Assistant'
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onItemSelected(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? TorqueColors.primaryRed.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: isSelected ? 1.2 : 1.0,
              child: AnimatedRotation(
                duration: const Duration(milliseconds: 200),
                turns: isSelected ? 0.05 : 0,
                child: Icon(
                  icon,
                  color: isSelected
                      ? TorqueColors.primaryRed
                      : Colors.grey,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected
                    ? TorqueColors.primaryRed
                    : Colors.grey,
                fontSize: isSelected ? 13 : 12,
                fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
                letterSpacing: isSelected ? 0.5 : 0,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

