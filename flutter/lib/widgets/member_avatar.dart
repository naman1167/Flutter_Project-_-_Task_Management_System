import 'package:flutter/material.dart';
import '../models/models.dart';

class MemberAvatar extends StatelessWidget {
  final TeamMember? member;
  final double size;
  final bool showTooltip;

  const MemberAvatar({
    super.key,
    required this.member,
    this.size = 32,
    this.showTooltip = true,
  });

  @override
  Widget build(BuildContext context) {
    if (member == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: Icon(
          Icons.person_outline_rounded,
          size: size * 0.55,
          color: const Color(0xFF94A3B8),
        ),
      );
    }

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Color(member!.colorValue),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Color(member!.colorValue).withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        member!.initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.38,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
    );

    if (showTooltip) {
      return Tooltip(
        message: '${member!.name} (${member!.role})',
        child: avatar,
      );
    }

    return avatar;
  }
}
