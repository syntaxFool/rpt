import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:red_panda_tracker/providers/profile_provider.dart';
import 'package:red_panda_tracker/screens/profile_form_screen.dart';
import 'package:red_panda_tracker/screens/settings_screen.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFFF27D52),
        foregroundColor: Colors.white,
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          final profile = provider.profile;

          if (profile == null) {
            return _buildEmptyState(context);
          }

          return _buildProfileContent(context, provider);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_outline,
              size: 120,
              color: Color(0xFFF27D52),
            ),
            const SizedBox(height: 24),
            const Text(
              'Create Your Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A342E),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Track your progress, BMI, and achievements',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _navigateToForm(context, null),
              icon: const Icon(Icons.add),
              label: const Text('Create Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF27D52),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, ProfileProvider provider) {
    final profile = provider.profile!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFFF27D52),
                    child: Text(
                      profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A342E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${profile.age} years • ${profile.gender}',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _navigateToForm(context, profile),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // BMI Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Body Mass Index',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A342E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              profile.bmi.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF27D52),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile.bmiCategory,
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const VerticalDivider(width: 32),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('Height', '${profile.heightCm.toInt()} cm'),
                            const SizedBox(height: 8),
                            _buildInfoRow('Current', '${profile.currentWeightKg.toStringAsFixed(1)} kg'),
                            const SizedBox(height: 8),
                            _buildInfoRow('Goal', '${profile.goalWeightKg.toStringAsFixed(1)} kg'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Weight Progress Card
          if (profile.weightHistory.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Weight Progress',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A342E),
                          ),
                        ),
                        Text(
                          profile.weightChange,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: profile.weightChange.startsWith('-')
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: profile.weightHistory.length,
                        itemBuilder: (context, index) {
                          final entry = profile.weightHistory[index];
                          return ListTile(
                            leading: const Icon(Icons.scale, color: Color(0xFFF27D52)),
                            title: Text('${entry.weight.toStringAsFixed(1)} kg'),
                            subtitle: Text(
                              DateFormat('MMM dd, yyyy').format(entry.date),
                            ),
                            trailing: entry.note != null
                                ? Tooltip(
                                    message: entry.note!,
                                    child: const Icon(Icons.note, size: 16),
                                  )
                                : null,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Weekly Check-in Prompt
          if (profile.isWeeklyCheckInDue)
            Card(
              color: const Color(0xFFFFF3E0),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.notification_important, color: Color(0xFFF27D52)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Time for your weekly weigh-in!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A342E),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _navigateToForm(context, profile),
                      child: const Text('Update'),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Macro Settings Link
          Card(
            child: ListTile(
              leading: const Icon(Icons.restaurant_menu, color: Color(0xFFF27D52)),
              title: const Text('Macro Targets'),
              subtitle: const Text('Update your daily nutrition goals'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Achievements
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Achievements',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A342E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: provider.badges.map((badge) {
                      return Chip(
                        avatar: Text(
                          badge['icon'] as String,
                          style: const TextStyle(fontSize: 20),
                        ),
                        label: Text(
                          badge['label'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: const Color(0xFFFFF3E0),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow('Days Tracked', provider.daysTracked.toString()),
                  const SizedBox(height: 8),
                  _buildStatRow('Current Streak', '${provider.currentStreak} days'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A342E),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Color(0xFF4A342E)),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF27D52),
          ),
        ),
      ],
    );
  }

  void _navigateToForm(BuildContext context, dynamic profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileFormScreen(existingProfile: profile),
      ),
    );
  }
}
