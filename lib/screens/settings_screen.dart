import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:red_panda_tracker/providers/food_provider.dart';
import 'package:red_panda_tracker/providers/log_provider.dart';
import 'package:red_panda_tracker/providers/settings_provider.dart';
import 'package:red_panda_tracker/services/sheet_api.dart';
import 'package:red_panda_tracker/widgets/calorie_commander_logo.dart';
import 'package:red_panda_tracker/screens/food_management_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final logProvider = Provider.of<LogProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final settings = settingsProvider.settings;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Logo & header
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: CalorieCommanderLogo(size: 80, showText: false),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Calorie Commander',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4A342E),
                  ),
            ),
          ),
          const SizedBox(height: 24),

          // Daily Calorie Target
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF27D52).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.fire_truck,
                      color: Color(0xFFF27D52),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Daily Calorie Target',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF27D52),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 130,
                    child: TextField(
                      controller: TextEditingController(
                        text: settings.dailyCalorieTarget.toInt().toString(),
                      ),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF27D52),
                      ),
                      decoration: InputDecoration(
                        suffixText: 'kcal/day',
                        suffixStyle: TextStyle(
                          fontSize: 9,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF27D52).withValues(alpha: 0.05),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: const Color(0xFFF27D52).withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: const Color(0xFFF27D52).withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFF27D52),
                            width: 2,
                          ),
                        ),
                      ),
                      onSubmitted: (text) {
                        final value = double.tryParse(text);
                        if (value != null && value > 0) {
                          settingsProvider.updateDailyCalorieTarget(value);
                        }
                      },
                      onTapOutside: (_) {
                        final controller = TextEditingController(
                          text: settings.dailyCalorieTarget.toInt().toString(),
                        );
                        final value = double.tryParse(controller.text);
                        if (value != null && value > 0) {
                          settingsProvider.updateDailyCalorieTarget(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Macro Targets
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.balance,
                          color: Colors.purple.shade600,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Macro Targets',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Protein • Carbs • Fat',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: const Color(0xFF4A342E).withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Protein Target
                  _buildMacroInput(
                    context,
                    'Protein',
                    settings.proteinTarget,
                    (value) => settingsProvider.updateProteinTarget(value),
                    'g/day',
                    Colors.blue,
                    'Builds muscle & recovery',
                  ),
                  const SizedBox(height: 16),
                  // Carbs Target
                  _buildMacroInput(
                    context,
                    'Carbs',
                    settings.carbsTarget,
                    (value) => settingsProvider.updateCarbsTarget(value),
                    'g/day',
                    Colors.green,
                    'Energy for activity',
                  ),
                  const SizedBox(height: 16),
                  // Fat Target
                  _buildMacroInput(
                    context,
                    'Fat',
                    settings.fatTarget,
                    (value) => settingsProvider.updateFatTarget(value),
                    'g/day',
                    Colors.amber,
                    'Hormone & vitamin support',
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Install prompt helper (show on all platforms to guide users)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF27D52).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.ios_share, color: Color(0xFFF27D52)),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Install this app',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _installHint(defaultTargetPlatform),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // App Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(context, 'App Name', 'Calorie Commander'),
                  const SizedBox(height: 8),
                  _buildInfoRow(context, 'Version', '1.0.0'),
                  const SizedBox(height: 8),
                  _buildInfoRow(context, 'Storage', 'Local (Offline-first)'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF4A342E).withValues(alpha: 0.6),
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _buildMacroInput(
    BuildContext context,
    String label,
    double value,
    Function(double) onChanged,
    String unit,
    Color color,
    String description,
  ) {
    final controller = TextEditingController(text: value.toInt().toString());
    
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 11,
                  color: const Color(0xFF4A342E).withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 100,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            decoration: InputDecoration(
              suffixText: unit,
              suffixStyle: TextStyle(
                fontSize: 10,
                color: color.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
              filled: true,
              fillColor: color.withValues(alpha: 0.08),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: color.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: color.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: color,
                  width: 2.5,
                ),
              ),
            ),
            onSubmitted: (text) {
              final parsedValue = double.tryParse(text);
              if (parsedValue != null && parsedValue > 0) {
                onChanged(parsedValue);
              } else {
                controller.text = value.toInt().toString();
              }
            },
            onTapOutside: (_) {
              final parsedValue = double.tryParse(controller.text);
              if (parsedValue != null && parsedValue > 0) {
                onChanged(parsedValue);
              } else {
                controller.text = value.toInt().toString();
              }
            },
          ),
        ),
      ],
    );
  }

  String _installHint(TargetPlatform platform) {
    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      return 'On iPhone/iPad: tap Share, then “Add to Home Screen.” On macOS Safari: File → Add to Dock.';
    }
    return 'On Chrome/Edge: open the browser menu and choose “Install app” or “Add to Home screen.”';
  }
}
