import 'package:belaraby/constant/colors.dart';
import 'package:flutter/material.dart';

/// A single row inside a [Card]-backed settings section.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    required this.icon,
    required this.label,
    this.onTap,
    this.trailing,
    this.iconColor = yellow120,
    this.labelColor,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color iconColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: labelColor ?? grey190,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      enabled: onTap != null || trailing != null,
    );
  }
}
