import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:red_panda_tracker/providers/index.dart';
import 'package:red_panda_tracker/models/app_settings.dart';
import 'package:intl/intl.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String _selectedPeriod = 'Week'; // Week, Month, Year

  @override
  Widget build(BuildContext context) {
    final logProvider = Provider.of<LogProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final foodProvider = Provider.of<FoodProvider>(context);
    
    final settings = settingsProvider.settings;
    final todayLogs = logProvider.getTodayLogs();
    final todayMacros = logProvider.getTodayMacros(todayLogs, foodProvider);
    final todayCalories = logProvider.getTodayCalories();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Period Selector
          _buildPeriodSelector(),
          const SizedBox(height: 16),

          // Today's Summary Card
          _buildTodaySummaryCard(
            todayCalories,
            todayMacros['protein'] ?? 0.0,
            todayMacros['carbs'] ?? 0.0,
            todayMacros['fat'] ?? 0.0,
            settings,
          ),
          const SizedBox(height: 16),

          // Chart
          _buildCalorieChart(logProvider, settings),
          const SizedBox(height: 16),

          // Quick Stats
          _buildQuickStats(logProvider),
          const SizedBox(height: 16),

          // Most Logged Foods
          _buildMostLoggedFoods(logProvider),
          const SizedBox(height: 16),

          // Total Logs
          Card(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF27D52).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: Color(0xFFF27D52),
                ),
              ),
              title: const Text(
                'Total Meal Logs',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: Text(
                logProvider.logs.length.toString(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFFF27D52),
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildPeriodButton('Week'),
          _buildPeriodButton('Month'),
          _buildPeriodButton('Year'),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String period) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = period),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF27D52) : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            period,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF4A342E),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodaySummaryCard(
    double calories,
    double protein,
    double carbs,
    double fat,
    AppSettings settings,
  ) {
    return Card(
      color: const Color(0xFFF27D52),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.today, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Today\'s Summary',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMacroStat('🔥', calories.toInt(), settings.dailyCalorieTarget.toInt(), 'kcal'),
                _buildMacroStat('💪', protein.toInt(), settings.proteinTarget.toInt(), 'g'),
                _buildMacroStat('🌾', carbs.toInt(), settings.carbsTarget.toInt(), 'g'),
                _buildMacroStat('🥑', fat.toInt(), settings.fatTarget.toInt(), 'g'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroStat(String emoji, int current, int target, String unit) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          '$current/$target',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          unit,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildCalorieChart(LogProvider logProvider, AppSettings settings) {
    final days = _selectedPeriod == 'Week' ? 7 : (_selectedPeriod == 'Month' ? 30 : 365);
    final chartData = _getLogsForPeriod(logProvider, days);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last $_selectedPeriod',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A342E),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: chartData.isEmpty
                  ? const Center(
                      child: Text(
                        'No data yet. Start logging meals!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : _buildBarChart(chartData, days, settings),
            ),
          ],
        ),
      ),
    );
  }

  Map<DateTime, double> _getLogsForPeriod(LogProvider logProvider, int days) {
    final now = DateTime.now();
    final Map<DateTime, double> dailyCalories = {};
    
    for (int i = 0; i < days; i++) {
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      dailyCalories[date] = 0;
    }
    
    for (final log in logProvider.logs) {
      final logDate = DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);
      if (dailyCalories.containsKey(logDate)) {
        dailyCalories[logDate] = dailyCalories[logDate]! + log.calories;
      }
    }
    
    return dailyCalories;
  }

  Widget _buildBarChart(Map<DateTime, double> data, int days, AppSettings settings) {
    final maxCalories = data.values.isEmpty ? 2000.0 : data.values.reduce((a, b) => a > b ? a : b);
    final sortedDates = data.keys.toList()..sort();
    final displayDates = days <= 7 
        ? sortedDates 
        : days <= 30 
            ? sortedDates.where((d) => d.day % 3 == 0).toList()
            : sortedDates.where((d) => d.day == 1).toList();
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: displayDates.map((date) {
        final calories = data[date] ?? 0;
        final height = maxCalories > 0 ? (calories / maxCalories) * 130 : 0.0;
        final target = settings.dailyCalorieTarget;
        final color = calories >= target * 0.9 && calories <= target * 1.1
            ? Colors.green
            : calories > target * 1.1
                ? Colors.orange
                : Colors.blue.withValues(alpha: 0.6);
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: days <= 7 ? 30 : days <= 30 ? 20 : 15,
              height: height.clamp(5.0, 130.0),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat(days <= 7 ? 'E' : days <= 30 ? 'd' : 'MMM').format(date),
              style: const TextStyle(fontSize: 9, color: Colors.grey),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildQuickStats(LogProvider logProvider) {
    final avgCalories = _calculateAverageCalories(logProvider);
    final streak = _calculateStreak(logProvider);
    final daysLogged = _calculateDaysLogged(logProvider);
    
    return Row(
      children: [
        Expanded(child: _buildStatCard2('Avg/Day', '${avgCalories.toInt()} kcal', Icons.trending_up, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard2('Streak', '$streak days', Icons.local_fire_department, Colors.orange)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard2('Logged', '$daysLogged', Icons.calendar_today, Colors.green)),
      ],
    );
  }

  Widget _buildStatCard2(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMostLoggedFoods(LogProvider logProvider) {
    final foodCounts = <String, int>{};
    
    for (final log in logProvider.logs) {
      foodCounts[log.foodName] = (foodCounts[log.foodName] ?? 0) + 1;
    }
    
    final sortedFoods = foodCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topFoods = sortedFoods.take(5).toList();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Most Logged Foods',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A342E),
              ),
            ),
            const SizedBox(height: 12),
            if (topFoods.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No food logs yet', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ...topFoods.map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF27D52).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(child: Text('🍱', style: TextStyle(fontSize: 18))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF27D52).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${entry.value}×',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF27D52),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  double _calculateAverageCalories(LogProvider logProvider) {
    if (logProvider.logs.isEmpty) return 0;
    final days = _selectedPeriod == 'Week' ? 7 : (_selectedPeriod == 'Month' ? 30 : 365);
    final chartData = _getLogsForPeriod(logProvider, days);
    final daysWithData = chartData.values.where((cal) => cal > 0).length;
    if (daysWithData == 0) return 0;
    final total = chartData.values.reduce((a, b) => a + b);
    return total / daysWithData;
  }

  int _calculateStreak(LogProvider logProvider) {
    if (logProvider.logs.isEmpty) return 0;
    
    final now = DateTime.now();
    int streak = 0;

    for (int i = 0; i < 365; i++) {
      final date = now.subtract(Duration(days: i));
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final hasLog = logProvider.logs.any((log) =>
          log.timestamp.isAfter(startOfDay) &&
          log.timestamp.isBefore(endOfDay));

      if (hasLog) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  int _calculateDaysLogged(LogProvider logProvider) {
    final uniqueDays = <String>{};
    for (final log in logProvider.logs) {
      uniqueDays.add(DateFormat('yyyy-MM-dd').format(log.timestamp));
    }
    return uniqueDays.length;
  }
}
