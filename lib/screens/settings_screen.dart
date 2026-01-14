import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:red_panda_tracker/models/app_settings.dart';
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
  late TextEditingController _calorieController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final settings = settingsProvider.settings;
    
    _calorieController = TextEditingController(text: settings.dailyCalorieTarget.toInt().toString());
    _proteinController = TextEditingController(text: settings.proteinTarget.toInt().toString());
    _carbsController = TextEditingController(text: settings.carbsTarget.toInt().toString());
    _fatController = TextEditingController(text: settings.fatTarget.toInt().toString());
  }

  @override
  void dispose() {
    _calorieController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _applyCalorieChange(SettingsProvider settingsProvider, AppSettings settings) {
    final value = double.tryParse(_calorieController.text);
    if (value != null && value > 0) {
      settingsProvider.updateDailyCalorieTarget(value);
    } else {
      _calorieController.text = settings.dailyCalorieTarget.toInt().toString();
    }
  }

  void _applyProteinChange(SettingsProvider settingsProvider, AppSettings settings) {
    final value = double.tryParse(_proteinController.text);
    if (value != null && value > 0) {
      settingsProvider.updateProteinTarget(value);
    } else {
      _proteinController.text = settings.proteinTarget.toInt().toString();
    }
  }

  void _applyCarbsChange(SettingsProvider settingsProvider, AppSettings settings) {
    final value = double.tryParse(_carbsController.text);
    if (value != null && value > 0) {
      settingsProvider.updateCarbsTarget(value);
    } else {
      _carbsController.text = settings.carbsTarget.toInt().toString();
    }
  }

  void _applyFatChange(SettingsProvider settingsProvider, AppSettings settings) {
    final value = double.tryParse(_fatController.text);
    if (value != null && value > 0) {
      settingsProvider.updateFatTarget(value);
    } else {
      _fatController.text = settings.fatTarget.toInt().toString();
    }
  }

  Future<void> _saveAllChanges(SettingsProvider settingsProvider, AppSettings settings) async {
    // Validate and apply all changes
    _applyCalorieChange(settingsProvider, settings);
    _applyProteinChange(settingsProvider, settings);
    _applyCarbsChange(settingsProvider, settings);
    _applyFatChange(settingsProvider, settings);
    
    // Wait a moment for all updates to process
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Exit edit mode
    if (mounted) {
      setState(() => _isEditMode = false);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved and synced to Google Sheets'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _cancelEdit(SettingsProvider settingsProvider, AppSettings settings) {
    // Reset controllers to current values
    _calorieController.text = settings.dailyCalorieTarget.toInt().toString();
    _proteinController.text = settings.proteinTarget.toInt().toString();
    _carbsController.text = settings.carbsTarget.toInt().toString();
    _fatController.text = settings.fatTarget.toInt().toString();
    
    setState(() => _isEditMode = false);
  }

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
        actions: [
          if (_isEditMode)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: TextButton(
                  onPressed: () => _cancelEdit(settingsProvider, settings),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF4A342E)),
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: TextButton.icon(
                  onPressed: () => setState(() => _isEditMode = true),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFF27D52),
                  ),
                ),
              ),
            ),
        ],
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
                  _isEditMode
                      ? SizedBox(
                          width: 130,
                          child: TextField(
                            controller: _calorieController,
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
                          ),
                        )
                      : Text(
                          '${settings.dailyCalorieTarget.toInt()} kcal/day',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF27D52),
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
                    _proteinController,
                    settings.proteinTarget,
                    'g/day',
                    Colors.blue,
                    'Builds muscle & recovery',
                    isEditMode: _isEditMode,
                  ),
                  const SizedBox(height: 16),
                  // Carbs Target
                  _buildMacroInput(
                    context,
                    'Carbs',
                    _carbsController,
                    settings.carbsTarget,
                    'g/day',
                    Colors.green,
                    'Energy for activity',
                    isEditMode: _isEditMode,
                  ),
                  const SizedBox(height: 16),
                  // Fat Target
                  _buildMacroInput(
                    context,
                    'Fat',
                    _fatController,
                    settings.fatTarget,
                    'g/day',
                    Colors.amber,
                    'Hormone & vitamin support',
                    isEditMode: _isEditMode,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Save button (only in edit mode)
          if (_isEditMode)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () => _saveAllChanges(settingsProvider, settings),
                icon: const Icon(Icons.save),
                label: const Text('Save Settings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF27D52),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Install prompt helper
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
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMacroInput(
    BuildContext context,
    String label,
    TextEditingController controller,
    double currentValue,
    String unit,
    Color color,
    String description,
    {required bool isEditMode,
    }) {
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
        isEditMode
            ? SizedBox(
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
                ),
              )
            : Text(
                '${currentValue.toInt()} $unit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
      ],
    );
  }

  String _installHint(TargetPlatform platform) {
    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      return 'On iPhone/iPad: tap Share, then "Add to Home Screen." On macOS Safari: File → Add to Dock.';
    }
    return 'On Chrome/Edge: open the browser menu and choose "Install app" or "Add to Home screen."';
  }
}
