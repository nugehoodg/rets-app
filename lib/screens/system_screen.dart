import 'package:flutter/material.dart';
import 'hardware_customizer.dart';

class SystemScreen extends StatelessWidget {
  const SystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: HardwareCustomizer(),
    );
  }
}
