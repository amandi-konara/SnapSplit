import 'package:flutter/material.dart';

/// SnapSplit palette, taken from the Base44 mockups and the mascot logo.
///
/// Use these through `Theme.of(context)` where a Material role fits, and
/// directly for SnapSplit-specific things (status chips, avatars).
abstract final class AppColors {
  // Brand
  static const coral = Color(0xFFFF6253);
  static const coralPressed = Color(0xFFE9503F);
  static const coralSoft = Color(0xFFFFE6E1); // icon circles, selected nav
  static const coralFaded = Color(0xFFFFB3AA); // disabled coral button
  static const mint = Color(0xFFA8E6CF); // mascot accent
  static const mintSoft = Color(0xFFE4F7EF); // "All assigned!" chip
  static const mintInk = Color(0xFF1F7A57);

  // Neutrals (warm, leaning toward the coral)
  static const cream = Color(0xFFFFFCF3); // page background
  static const surface = Color(0xFFFFFFFF); // cards, inputs
  static const surfaceTint = Color(0xFFFFF5EE); // total pills, soft panels
  static const line = Color(0xFFF1E6DA); // card and input borders
  static const ink = Color(0xFF2D2420); // headings and body text
  static const inkMuted = Color(0xFF8A7D77); // subtitles, hints
  static const outline = Color(0xFF3A2A25); // mascot outline brown

  // Status
  static const warningSoft = Color(0xFFFFF3D6); // "Rs. 450 still to assign"
  static const warningInk = Color(0xFFB07400);
  static const error = Color(0xFFD93A2B);

  /// Pastel backgrounds for letter avatars, picked by name.
  static const avatarPastels = <Color>[
    Color(0xFFD9D8F4), // lavender
    Color(0xFFFBE3C2), // peach
    Color(0xFFCDEFE1), // mint
    Color(0xFFFFD6D0), // coral blush
    Color(0xFFD5E8F8), // sky
    Color(0xFFF3DDF0), // pink
  ];

  /// Matching text colours for [avatarPastels].
  static const avatarInks = <Color>[
    Color(0xFF5B57B0),
    Color(0xFFB0700F),
    Color(0xFF1F7A57),
    Color(0xFFD9473A),
    Color(0xFF2F6FA8),
    Color(0xFFA0478F),
  ];

  /// Stable avatar colour index for a name (same name, same colour).
  static int avatarIndexFor(String name) {
    var hash = 0;
    for (final unit in name.toLowerCase().codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return hash % avatarPastels.length;
  }
}
