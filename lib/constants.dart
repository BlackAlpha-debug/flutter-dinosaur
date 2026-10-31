import 'package:flutter/material.dart';

const int gravity = 2200;
const int worlToPixelRatio = 10;
const double initialVelocity = 28;
const double acceleration = 0.5;
const double jumpVelocity = 760;

const int skyPhaseInterval = 100;

const List<List<Color>> skyGradients = [
  [Color(0xFF87CEEB), Color(0xFFE0F7FA)], // day
  [Color(0xFFFDB813), Color(0xFFFF8C00)], // early sunset
  [Color(0xFFFF6B35), Color(0xFF9B2335)], // deep sunset
  [Color(0xFF4A0E4E), Color(0xFF1A1A2E)], // dusk
  [Color(0xFF0D1B2A), Color(0xFF1B2838)], // night
];
