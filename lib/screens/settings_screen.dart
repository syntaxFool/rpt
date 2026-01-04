import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:red_panda_tracker/providers/log_provider.dart';
import 'package:red_panda_tracker/providers/settings_provider.dart';
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

          // My Food Pantry
          Card(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF27D52).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: Color(0xFFF27D52),
                ),
              ),
              title: const Text(
                'My Food Pantry',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text('Manage your custom foods'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FoodManagementScreen(),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Daily Calorie Target
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Calorie Target',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: settings.dailyCalorieTarget,
                          min: 1200,
                          max: 3500,
                          divisions: 46,
                          label: '${settings.dailyCalorieTarget.toInt()} kcal',
                          onChanged: (value) {
                            settingsProvider.updateDailyCalorieTarget(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${settings.dailyCalorieTarget.toInt()}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'kcal/day',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF4A342E).withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Macro Targets
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Macro Targets',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  // Protein Target
                  _buildMacroSlider(
                    context,
                    'Protein',
                    settings.proteinTarget,
                    (value) => settingsProvider.updateProteinTarget(value),
                    50,
                    250,
                    'g/day',
                    Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  // Carbs Target
                  _buildMacroSlider(
                    context,
                    'Carbs',
                    settings.carbsTarget,
                    (value) => settingsProvider.updateCarbsTarget(value),
                    100,
                    500,
                    'g/day',
                    Colors.green,
                  ),
                  const SizedBox(height: 16),
                  // Fat Target
                  _buildMacroSlider(
                    context,
                    'Fat',
                    settings.fatTarget,
                    (value) => settingsProvider.updateFatTarget(value),
                    20,
                    150,
                    'g/day',
                    Colors.amber,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Sync Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data Sync',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  if (logProvider.unsyncedCount > 0)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF27D52).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.cloud_upload,
                            color: Color(0xFFF27D52),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${logProvider.unsyncedCount} unsynced ${logProvider.unsyncedCount == 1 ? "entry" : "entries"}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.cloud_done,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'All entries synced',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: logProvider.isSyncing
                          ? null
                          : () async {
                              final count = await logProvider.syncLogs();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      count > 0
                                          ? 'Synced $count ${count == 1 ? "entry" : "entries"}'
                                          : 'No new entries to sync',
                                    ),
                                    backgroundColor: const Color(0xFFF27D52),
                                  ),
                                );
                              }
                            },
                      icon: logProvider.isSyncing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Icon(Icons.sync),
                      label: Text(logProvider.isSyncing ? 'Syncing...' : 'Sync Now'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Note: Set your Google Apps Script URL in sync_service.dart',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF4A342E).withValues(alpha: 0.5),
                          fontStyle: FontStyle.italic,
                        ),
                  ),
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

  Widget _buildMacroSlider(
    BuildContext context,
    String label,
    double value,
    Function(double) onChanged,
    double min,
    double max,
    String unit,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
            ),
            Text(
              '${value.toStringAsFixed(0)} $unit',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) / 5).toInt(),
          label: value.toStringAsFixed(0),
          activeColor: color,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
