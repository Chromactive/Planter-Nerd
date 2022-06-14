import 'package:flutter/material.dart';
import 'package:planter_squared/screens/home.dart';

class CenteredBottomNavigationBarItem {
  const CenteredBottomNavigationBarItem({
    required this.icon,
    required this.label,
    this.activeIcon,
  });

  CenteredBottomNavigationBarItem.fromNavigationItem(MainNavigationItem item)
      : icon = item.icon,
        label = item.label,
        activeIcon = item.activeIcon;

  final IconData icon;
  final IconData? activeIcon;
  final String label;
}

class CenteredBottomNavigationBar extends StatefulWidget {
  const CenteredBottomNavigationBar({
    Key? key,
    required this.items,
    required this.onTabSelected,
    this.height = kBottomNavigationBarHeight,
    this.iconSize = 24.0,
    this.notchedShape,
    this.backgroundColor,
    this.color,
    this.selectedColor,
    this.notchMargin = 4.0,
    this.showSelectedTabLabel = true,
    this.showUnselectedTabLabel = true,
  }) : super(key: key);

  final List<CenteredBottomNavigationBarItem> items;
  final Color? backgroundColor;
  final Color? color;
  final Color? selectedColor;
  final ValueChanged<int> onTabSelected;
  final NotchedShape? notchedShape;
  final double height;
  final double iconSize;
  final double notchMargin;
  final bool showSelectedTabLabel;
  final bool showUnselectedTabLabel;

  @override
  State<CenteredBottomNavigationBar> createState() => _CenteredBottomNavigationBarState();
}

class _CenteredBottomNavigationBarState extends State<CenteredBottomNavigationBar> {
  int _selectedIndex = 0;

  void _updateIndex(int index) {
    widget.onTabSelected(index);
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color baseColor = widget.color ?? Theme.of(context).unselectedWidgetColor;
    final Color selectedColor = widget.color ?? Theme.of(context).colorScheme.primary;
    final items = List.generate(widget.items.length, (i) => _buildTabItem(i, baseColor, selectedColor));
    items.insert(items.length >> 1, _centerTabItem());
    return BottomAppBar(
      shape: widget.notchedShape,
      notchMargin: widget.notchMargin,
      color: widget.backgroundColor,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: widget.height,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items,
        ),
      ),
    );
  }

  Widget _centerTabItem() {
    return Expanded(
      flex: 2,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
  }

  Widget _buildTabItem(int index, Color baseColor, Color selectedColor) {
    final Color tabColor = _selectedIndex == index ? selectedColor : baseColor;
    final tabItem = widget.items[index];
    final IconData icon = _selectedIndex == index ? tabItem.activeIcon ?? tabItem.icon : tabItem.icon;
    return Expanded(
      flex: 3,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => _updateIndex(index),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: tabColor,
                size: widget.iconSize,
              ),
              if ((_selectedIndex == index && widget.showSelectedTabLabel) ||
                  (_selectedIndex != index && widget.showUnselectedTabLabel))
                Text(
                  tabItem.label,
                  style: TextStyle(color: tabColor),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
