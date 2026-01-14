import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:red_panda_tracker/providers/profile_provider.dart';
import 'package:red_panda_tracker/models/profile.dart';

class ProfileFormScreen extends StatefulWidget {
  final UserProfile? existingProfile;

  const ProfileFormScreen({super.key, this.existingProfile});

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _currentWeightController;
  late TextEditingController _goalWeightController;
  late TextEditingController _weightNoteController;
  String _selectedGender = 'Other';
  bool _isNewWeightEntry = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.existingProfile;
    
    _nameController = TextEditingController(text: profile?.name ?? '');
    _ageController = TextEditingController(text: profile?.age.toString() ?? '');
    _heightController = TextEditingController(text: profile?.heightCm.toStringAsFixed(0) ?? '');
    _currentWeightController = TextEditingController(text: profile?.currentWeightKg.toStringAsFixed(1) ?? '');
    _goalWeightController = TextEditingController(text: profile?.goalWeightKg.toStringAsFixed(1) ?? '');
    _weightNoteController = TextEditingController();
    _selectedGender = profile?.gender ?? 'Other';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _currentWeightController.dispose();
    _goalWeightController.dispose();
    _weightNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingProfile != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Profile' : 'Create Profile'),
        backgroundColor: const Color(0xFFF27D52),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Personal Info Section
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A342E),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'Age',
                prefixIcon: Icon(Icons.cake),
                suffixText: 'years',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v?.isEmpty ?? true) return 'Age is required';
                final age = int.tryParse(v!);
                if (age == null || age < 1 || age > 150) {
                  return 'Enter valid age';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                prefixIcon: Icon(Icons.wc),
              ),
              items: ['Male', 'Female', 'Other']
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedGender = v!),
            ),
            const SizedBox(height: 24),
            
            // Physical Stats Section
            const Text(
              'Physical Stats',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A342E),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _heightController,
              decoration: const InputDecoration(
                labelText: 'Height',
                prefixIcon: Icon(Icons.height),
                suffixText: 'cm',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v?.isEmpty ?? true) return 'Height is required';
                final h = double.tryParse(v!);
                if (h == null || h < 50 || h > 300) {
                  return 'Enter valid height';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _currentWeightController,
              decoration: const InputDecoration(
                labelText: 'Current Weight',
                prefixIcon: Icon(Icons.scale),
                suffixText: 'kg',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
              ],
              validator: (v) {
                if (v?.isEmpty ?? true) return 'Weight is required';
                final w = double.tryParse(v!);
                if (w == null || w < 20 || w > 500) {
                  return 'Enter valid weight';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _goalWeightController,
              decoration: const InputDecoration(
                labelText: 'Goal Weight',
                prefixIcon: Icon(Icons.flag),
                suffixText: 'kg',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
              ],
              validator: (v) {
                if (v?.isEmpty ?? true) return 'Goal weight is required';
                final w = double.tryParse(v!);
                if (w == null || w < 20 || w > 500) {
                  return 'Enter valid goal weight';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            
            // Weight Entry Section (only when editing)
            if (isEditing) ...[
              const Text(
                'Weight Check-in',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A342E),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add a new weight entry to track your progress',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              
              CheckboxListTile(
                value: _isNewWeightEntry,
                onChanged: (v) => setState(() => _isNewWeightEntry = v ?? false),
                title: const Text('Log current weight as new entry'),
                contentPadding: EdgeInsets.zero,
              ),
              
              if (_isNewWeightEntry) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _weightNoteController,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                    prefixIcon: Icon(Icons.note),
                    hintText: 'e.g., After workout',
                  ),
                  maxLength: 100,
                ),
              ],
            ],
            
            const SizedBox(height: 32),
            
            // Save Button
            ElevatedButton.icon(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save),
              label: Text(isEditing ? 'Update Profile' : 'Create Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF27D52),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ProfileProvider>();
    final name = _nameController.text.trim();
    final age = int.parse(_ageController.text);
    final heightCm = double.parse(_heightController.text);
    final currentWeightKg = double.parse(_currentWeightController.text);
    final goalWeightKg = double.parse(_goalWeightController.text);

    try {
      if (widget.existingProfile == null) {
        // Create new profile
        final newProfile = UserProfile(
          name: name,
          age: age,
          gender: _selectedGender,
          heightCm: heightCm,
          currentWeightKg: currentWeightKg,
          goalWeightKg: goalWeightKg,
          lastWeightCheckIn: null,
          weightHistory: [],
          createdAt: DateTime.now(),
          lastModified: DateTime.now(),
        );
        await provider.createProfile(newProfile);
      } else {
        // Update existing profile
        final updatedProfile = UserProfile(
          name: name,
          age: age,
          gender: _selectedGender,
          heightCm: heightCm,
          currentWeightKg: currentWeightKg,
          goalWeightKg: goalWeightKg,
          lastWeightCheckIn: widget.existingProfile!.lastWeightCheckIn,
          weightHistory: widget.existingProfile!.weightHistory,
          createdAt: widget.existingProfile!.createdAt,
          lastModified: DateTime.now(),
        );
        await provider.updateProfile(updatedProfile);

        // Add weight entry if checkbox is checked
        if (_isNewWeightEntry) {
          final entry = WeightEntry(
            weight: currentWeightKg,
            date: DateTime.now(),
            note: _weightNoteController.text.trim().isEmpty
                ? null
                : _weightNoteController.text.trim(),
          );
          await provider.addWeightEntry(entry);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingProfile == null
                ? 'Profile created successfully!'
                : 'Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
