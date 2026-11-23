import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_colors.dart';

/// Round avatar for a person: their emoji, or the first letter of their name
/// on a pastel circle (the same name always gets the same colour).
class PersonAvatar extends StatelessWidget {
  const PersonAvatar({super.key, required this.person, this.size = 32});

  final Person person;
  final double size;

  @override
  Widget build(BuildContext context) {
    final index = AppColors.avatarIndexFor(person.name);
    final emoji = person.emoji;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: emoji == null
            ? AppColors.avatarPastels[index]
            : AppColors.surfaceTint,
        shape: BoxShape.circle,
      ),
      child: emoji != null
          ? Text(emoji, style: TextStyle(fontSize: size * 0.55))
          : Text(
              person.initial,
              style: TextStyle(
                fontSize: size * 0.45,
                fontWeight: FontWeight.w800,
                color: AppColors.avatarInks[index],
              ),
            ),
    );
  }
}
