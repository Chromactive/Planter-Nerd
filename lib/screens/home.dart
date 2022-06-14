import 'package:flutter/material.dart';
import 'package:planter_squared/screens/dashboard.dart';
import 'package:planter_squared/screens/plant_list.dart';
import 'package:planter_squared/util.dart';
import 'package:planter_squared/widgets/navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedTab);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    _pageController.jumpToPage(index);
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      extendBody: true,
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 64.0,
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: () {/*NOOP*/},
            elevation: 2.0,
            child: const Icon(Icons.crop_free),
          ),
        ),
      ),
      bottomNavigationBar: CenteredBottomNavigationBar(
        notchMargin: 6.0,
        iconSize: 28.0,
        notchedShape: const CircularNotchedRectangle(),
        showSelectedTabLabel: false,
        showUnselectedTabLabel: false,
        onTabSelected: _onTabSelected,
        items: pages.map(CenteredBottomNavigationBarItem.fromNavigationItem).toList(),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: pages.map((e) => e.page).toList(),
      ),
    );
  }
}

class MainNavigationItem {
  const MainNavigationItem({
    required this.page,
    required this.label,
    required this.icon,
    this.activeIcon,
  });

  final Widget page;
  final String label;
  final IconData icon;
  final IconData? activeIcon;
}

const pages = [
  MainNavigationItem(
    page: PlanterDashboard(),
    activeIcon: Icons.home,
    icon: Icons.home_outlined,
    label: 'Home',
  ),
  MainNavigationItem(
    page: PlantListScreen(),
    icon: Icons.search,
    label: 'Find plants',
  ),
];
