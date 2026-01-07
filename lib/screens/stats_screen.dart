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

class _StatsScreenState extends State<StatsScreen> with TickerProviderStateMixin {
  String _selectedPeriod = 'Week'; // Week, Month, Year
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

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
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView(
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
            _buildTotalLogsCard(logProvider),
          ],
        ),
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
        onTap: () {
          setState(() => _selectedPeriod = period);
          _fadeController.reset();
          _fadeController.forward();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF27D52) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFFF27D52).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
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
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 700),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Card(
            elevation: 6,
            shadowColor: const Color(0xFFF27D52).withValues(alpha: 0.4),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFF27D52),
                    const Color(0xFFE8654A),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.today, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Today\'s Summary',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Updated now',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Calories Progress
                  _buildMacroProgressItem(
                    '🔥 Calories',
                    calories,
                    settings.dailyCalorieTarget,
                    'kcal',
                    Colors.yellow.shade600,
                  ),
                  const SizedBox(height: 16),
                  // Macros Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildMacroProgressItem(
                          '💪 Protein',
                          protein,
                          settings.proteinTarget,
                          'g',
                          Colors.blue.shade400,
                          compact: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMacroProgressItem(
                          '🌾 Carbs',
                          carbs,
                          settings.carbsTarget,
                          'g',
                          Colors.green.shade400,
                          compact: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMacroProgressItem(
                          '🥑 Fat',
                          fat,
                          settings.fatTarget,
                          'g',
                          Colors.amber.shade400,
                          compact: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMacroProgressItem(
    String label,
    double current,
    double target,
    String unit,
    Color color, {
    bool compact = false,
  }) {
    final percentage = (current / target * 100).clamp(0, 100);
    
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (percentage / 100).clamp(0, 1),
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${percentage.toInt()}%',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${current.toInt()}/$target $unit',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${percentage.toInt()}%',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (percentage / 100).clamp(0, 1),
            minHeight: 10,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${current.toInt()} $unit',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Target: ${target.toInt()}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalorieChart(LogProvider logProvider, AppSettings settings) {
    final days = _selectedPeriod == 'Week' ? 7 : (_selectedPeriod == 'Month' ? 30 : 365);
    final chartData = _getLogsForPeriod(logProvider, days);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last $_selectedPeriod',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A342E),
                      ),
                    ),
                    Text(
                      'Daily calorie intake',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF27D52).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFF27D52).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'Target: ${settings.dailyCalorieTarget.toInt()} kcal',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF27D52),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: chartData.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bar_chart, size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            'No data yet',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Start logging meals to see your trends',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
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
    final normalizedMax = (maxCalories * 1.2).roundToDouble(); // Add 20% padding
    final sortedDates = data.keys.toList()..sort();
    final displayDates = days <= 7 
        ? sortedDates 
        : days <= 30 
            ? sortedDates.where((d) => d.day % 3 == 0).toList()
            : sortedDates.where((d) => d.day == 1).toList();
    
    // Calculate target line position (as percentage of total height)
    final targetLinePosition = (settings.dailyCalorieTarget / normalizedMax) * 130;
    
    return Stack(
      children: [
        // Target reference line
        Positioned(
          bottom: targetLinePosition,
          left: 0,
          right: 0,
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  '${settings.dailyCalorieTarget.toInt()}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomPaint(
                  size: const Size(double.infinity, 1),
                  painter: DashedLinePainter(color: const Color(0xFFF27D52).withValues(alpha: 0.5)),
                ),
              ),
            ],
          ),
        ),
        // Bars
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: displayDates.asMap().entries.map((entry) {
            final index = entry.key;
            final date = entry.value;
            final calories = data[date] ?? 0;
            final height = normalizedMax > 0 ? (calories / normalizedMax) * 130 : 0.0;
            final target = settings.dailyCalorieTarget;
            final color = calories >= target * 0.9 && calories <= target * 1.1
                ? const Color(0xFF2ECC71)  // Green for on-target
                : calories > target * 1.1
                    ? const Color(0xFFF27D52)  // Orange for over
                    : const Color(0xFF3498DB).withValues(alpha: 0.6);  // Blue for under
            
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 800 + (index * 100)),
              tween: Tween(begin: 0.0, end: height.clamp(3.0, 130.0)),
              curve: Curves.easeOutCubic,
              builder: (context, animatedHeight, child) {
                final formattedDate = DateFormat('dd MMM').format(date);
                final tooltipText = '${calories.toStringAsFixed(0)} kcal';
                final targetText = 'Target: ${settings.dailyCalorieTarget.toStringAsFixed(0)} kcal';
                final percentOfTarget = (calories / target * 100).toStringAsFixed(0);
                
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Tooltip(
                      message: '$formattedDate\n$tooltipText\n$targetText\n$percentOfTarget%',
                      waitDuration: const Duration(milliseconds: 200),
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    formattedDate,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('$tooltipText / $targetText'),
                                  const SizedBox(height: 4),
                                  Text('$percentOfTarget% of target'),
                                ],
                              ),
                              duration: const Duration(seconds: 3),
                              backgroundColor: Colors.grey.shade800,
                            ),
                          );
                        },
                        child: Container(
                          width: days <= 7 ? 32 : days <= 30 ? 22 : 16,
                          height: animatedHeight,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                color,
                                color.withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormat(days <= 7 ? 'EEE' : days <= 30 ? 'dd' : 'MMM').format(date),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                );
              },
            );
          }).toList(),
        ),
      ],
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
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Card(
            elevation: 4,
            shadowColor: color.withValues(alpha: 0.3),
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
          ),
        );
      },
    );
  }
  
  Widget _buildTotalLogsCard(LogProvider logProvider) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Card(
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
        );
      },
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
              ...topFoods.asMap().entries.map((entry) {
                final index = entry.key;
                final foodEntry = entry.value;
                
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 500 + (index * 100)),
                  tween: Tween(begin: -50.0, end: 0.0),
                  curve: Curves.easeOutQuart,
                  builder: (context, offset, child) {
                    return Transform.translate(
                      offset: Offset(offset, 0),
                      child: Opacity(
                        opacity: (offset + 50) / 50,
                        child: Padding(
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
                                  foodEntry.key,
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
                                  '${foodEntry.value}×',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFF27D52),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
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
class DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;

  DashedLinePainter({
    required this.color,
    this.dashWidth = 6.0,
    this.dashSpace = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset((startX + dashWidth).clamp(0, size.width), size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(DashedLinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}