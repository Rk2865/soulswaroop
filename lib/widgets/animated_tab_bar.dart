import 'package:flutter/material.dart';
import 'animated_tab_button.dart';

class AnimatedTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<AnimatedTabData> tabs;

  const AnimatedTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          int index = entry.key;
          AnimatedTabData tab = entry.value;
          bool isSelected = selectedIndex == index;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: AnimatedTabButton(
                text: tab.text,
                icon: tab.icon,
                isSelected: isSelected,
                onTap: () => onTap(index),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class AnimatedTabData {
  final String text;
  final IconData icon;

  const AnimatedTabData({
    required this.text,
    required this.icon,
  });
}
