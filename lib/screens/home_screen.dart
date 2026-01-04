import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:red_panda_tracker/providers/index.dart';
import 'package:red_panda_tracker/widgets/index.dart';
import 'package:red_panda_tracker/screens/index.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String? _selectedCategory; // null means all categories

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CalorieCommanderLogo(size: 32, showText: false),
            ),
            const SizedBox(width: 12),
            const Text('Calorie Commander'),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFFF27D52),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CalorieCommanderLogo(size: 60, showText: false),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Calorie Commander',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: const Text('Food Management'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FoodManagementScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Statistics'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StatsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Consumer<LogProvider>(
        builder: (context, logProvider, _) {
          final settingsProvider = Provider.of<SettingsProvider>(context);
          final settings = settingsProvider.settings;
          
          final todayCalories = logProvider.getTodayCalories();
          final todayLogs = logProvider.getTodayLogs();

          // Filter logs based on search query and category
          var filteredLogs = todayLogs;
          
          if (_searchQuery.isNotEmpty) {
            filteredLogs = filteredLogs.where((log) => 
              log.foodName.toLowerCase().contains(_searchQuery.toLowerCase())
            ).toList();
          }
          
          if (_selectedCategory != null) {
            filteredLogs = filteredLogs.where((log) => 
              log.mealCategory == _selectedCategory
            ).toList();
          }

          // Get food provider for macro calculations
          final foodProvider = Provider.of<FoodProvider>(context);
          final macros = logProvider.getTodayMacros(todayLogs, foodProvider);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Balance Circle
                BalanceCircle(
                  current: todayCalories,
                  target: settings.dailyCalorieTarget,
                ),
                const SizedBox(height: 24),

                // Macro Progress Bars
                MacroProgressBar(
                  label: 'Protein',
                  current: macros['protein'] ?? 0.0,
                  target: settings.proteinTarget,
                  color: Colors.blue,
                  icon: Icons.fitness_center,
                ),
                const SizedBox(height: 12),
                MacroProgressBar(
                  label: 'Carbs',
                  current: macros['carbs'] ?? 0.0,
                  target: settings.carbsTarget,
                  color: Colors.green,
                  icon: Icons.grain,
                ),
                const SizedBox(height: 12),
                MacroProgressBar(
                  label: 'Fat',
                  current: macros['fat'] ?? 0.0,
                  target: settings.fatTarget,
                  color: Colors.amber.shade700,
                  icon: Icons.water_drop,
                ),
                const SizedBox(height: 32),

                // Search Bar
                if (todayLogs.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search meals...',
                        prefixIcon: const Icon(Icons.search, color: Color(0xFFF27D52)),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),

                // Category Filter Chips
                if (todayLogs.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('All'),
                            selected: _selectedCategory == null,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = null;
                              });
                            },
                            selectedColor: const Color(0xFFF27D52).withValues(alpha: 0.3),
                            checkmarkColor: const Color(0xFF4A342E),
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('🌅 Breakfast'),
                            selected: _selectedCategory == 'Breakfast',
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = selected ? 'Breakfast' : null;
                              });
                            },
                            selectedColor: Colors.orange.withValues(alpha: 0.3),
                            checkmarkColor: const Color(0xFF4A342E),
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('☀️ Lunch'),
                            selected: _selectedCategory == 'Lunch',
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = selected ? 'Lunch' : null;
                              });
                            },
                            selectedColor: Colors.blue.withValues(alpha: 0.3),
                            checkmarkColor: const Color(0xFF4A342E),
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('🌙 Dinner'),
                            selected: _selectedCategory == 'Dinner',
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = selected ? 'Dinner' : null;
                              });
                            },
                            selectedColor: Colors.purple.withValues(alpha: 0.3),
                            checkmarkColor: const Color(0xFF4A342E),
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('🍿 Snack'),
                            selected: _selectedCategory == 'Snack',
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = selected ? 'Snack' : null;
                              });
                            },
                            selectedColor: Colors.green.withValues(alpha: 0.3),
                            checkmarkColor: const Color(0xFF4A342E),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Daily Note Card
                const DailyNoteCard(),
                const SizedBox(height: 24),

                // Today's Meals Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Today\'s Meals',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: const Color(0xFF4A342E),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (todayLogs.isNotEmpty)
                      Text(
                        '${filteredLogs.length} ${_searchQuery.isNotEmpty ? 'found' : 'entries'}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Meal List
                if (filteredLogs.isEmpty && _searchQuery.isNotEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          const Text(
                            '🔍',
                            style: TextStyle(fontSize: 64),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No meals found',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: const Color(0xFF4A342E).withValues(alpha: 0.6),
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try a different search term',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF4A342E).withValues(alpha: 0.4),
                                ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (todayLogs.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          const Text(
                            '🍽️',
                            style: TextStyle(fontSize: 64),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No meals logged yet',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: const Color(0xFF4A342E).withValues(alpha: 0.6),
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the + button to start tracking',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF4A342E).withValues(alpha: 0.4),
                                ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = filteredLogs[index];
                      return LogEntryCard(
                        log: log,
                        onEdit: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => EditLogSheet(log: log),
                          );
                        },
                        onDelete: () async {
                          await logProvider.deleteLog(log.id);
                        },
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const CalculatorSheet(),
          );
        },
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }
}
