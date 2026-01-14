import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:red_panda_tracker/providers/index.dart';
import 'package:red_panda_tracker/providers/profile_provider.dart';
import 'package:red_panda_tracker/widgets/index.dart';
import 'package:red_panda_tracker/screens/index.dart';
import 'package:red_panda_tracker/models/index.dart';
import 'package:red_panda_tracker/services/sheet_api.dart';
import 'dart:html' as html;
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String _searchQuery = '';
  String? _selectedCategory; // null means all categories
  bool _isSyncing = false;
  bool _isInitialSyncing = true;
  DateTimeRange? _dateRange;
  bool _includeNotesInSearch = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _dateRange = _todayRange();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 0), // Disabled for faster startup
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
    
    // Initialize scroll controller with snap behavior
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    
    // Auto-sync on app start (non-blocking - background sync)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performStartupSync();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Snap to cards when scroll ends
    if (!_scrollController.position.isScrollingNotifier.value) {
      _snapToCard();
    }
  }

  void _snapToCard() {
    if (!_scrollController.hasClients) return;
    
    final itemHeight = 460.0; // Approximate card height + padding
    final offset = _scrollController.offset;
    final nearestItem = (offset / itemHeight).round();
    final targetOffset = nearestItem * itemHeight;
    
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuad,
    );
  }

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
        width: 320,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            bottomLeft: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF27D52), Color(0xFFEF6A48)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: CalorieCommanderLogo(size: 56, showText: false),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Calorie Commander',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF27D52).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Color(0xFFF27D52)),
                ),
                title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.w600)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF27D52).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.restaurant_menu, color: Color(0xFFF27D52)),
                ),
                title: const Text('My Food Pantry', style: TextStyle(fontWeight: FontWeight.w600)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FoodManagementScreen()),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bar_chart, color: Color(0xFF6C63FF)),
                ),
                title: const Text('Statistics', style: TextStyle(fontWeight: FontWeight.w600)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StatsScreen()),
                  );
                },
              ),
              Consumer<LogProvider>(
                builder: (context, logProvider, _) => ListTile(
                  leading: _isSyncing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: (logProvider.unsyncedCount > 0
                                    ? const Color(0xFFF27D52)
                                    : const Color(0xFF4CAF50))
                                .withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            logProvider.unsyncedCount > 0 ? Icons.cloud_upload : Icons.sync,
                            color: logProvider.unsyncedCount > 0 ? const Color(0xFFF27D52) : const Color(0xFF4CAF50),
                          ),
                        ),
                  title: const Text('Sync Data', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    logProvider.unsyncedCount > 0
                        ? '${logProvider.unsyncedCount} unsynced'
                        : 'All synced',
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  onTap: _isSyncing ? null : () {
                    Navigator.pop(context);
                    _runFullSync(context);
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(height: 28),
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.refresh, color: Color(0xFF2196F3)),
                ),
                title: const Text('Refresh App', style: TextStyle(fontWeight: FontWeight.w600)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                onTap: () {
                  html.window.location.reload();
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C27B0).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.settings, color: Color(0xFF9C27B0)),
                ),
                title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w600)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      body: _isInitialSyncing || _isSyncing
          ? PandaLoadingOverlay(
              message: _isInitialSyncing ? 'Syncing data...' : 'Syncing...',
            )
          : Consumer<LogProvider>(
        builder: (context, logProvider, _) {
          final settingsProvider = Provider.of<SettingsProvider>(context);
          final settings = settingsProvider.settings;
          
          final todayCalories = logProvider.getTodayCalories();
          final todayLogs = logProvider.getTodayLogs();
          final filteredLogs = _filterLogs(logProvider.logs);

          // Get food provider for macro calculations
          final foodProvider = Provider.of<FoodProvider>(context);
          final macros = logProvider.getTodayMacros(todayLogs, foodProvider);

          return Column(
            children: [
              // Offline indicator banner
              const OfflineIndicator(),
              
              // Main content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // Balance Circle
                            TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 0), // Disabled for faster startup
                        tween: Tween(begin: 0.0, end: 1.0),
                        curve: Curves.elasticOut,
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: BalanceCircle(
                              current: todayCalories,
                              target: settings.dailyCalorieTarget,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Macro Progress Bars
                      _buildAnimatedMacroBar(
                        0,
                        'Protein',
                        macros['protein'] ?? 0.0,
                        settings.proteinTarget,
                        Colors.blue,
                        Icons.fitness_center,
                      ),
                      const SizedBox(height: 12),
                      _buildAnimatedMacroBar(
                        100,
                        'Carbs',
                        macros['carbs'] ?? 0.0,
                        settings.carbsTarget,
                        Colors.green,
                        Icons.grain,
                      ),
                      const SizedBox(height: 12),
                      _buildAnimatedMacroBar(
                        200,
                        'Fat',
                        macros['fat'] ?? 0.0,
                        settings.fatTarget,
                        Colors.amber.shade700,
                        Icons.water_drop,
                      ),
                      const SizedBox(height: 32),

                      // Global Search & Filters
                      if (logProvider.logs.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Search foods or notes...',
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

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final picked = await showDateRangePicker(
                                    context: context,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                    initialDateRange: _dateRange ?? _todayRange(),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _dateRange = picked;
                                    });
                                  }
                                },
                                icon: const Icon(Icons.date_range),
                                label: Text(
                                  _dateRange == null
                                      ? 'All time'
                                      : _formatRangeLabel(_dateRange!),
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _dateRange = _todayRange();
                                });
                              },
                              child: const Text('Today'),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _dateRange = null;
                                });
                              },
                              child: const Text('All time'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Switch(
                                value: _includeNotesInSearch,
                                onChanged: (value) {
                                  setState(() {
                                    _includeNotesInSearch = value;
                                  });
                                },
                                activeColor: const Color(0xFFF27D52),
                              ),
                              const SizedBox(width: 8),
                              const Text('Match daily notes'),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 16, right: 12),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            clipBehavior: Clip.none,
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
                      ],

                      // Today's Meals Header (two-row layout with right-aligned count)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _isTodayRange(_dateRange ?? _todayRange())
                                      ? 'Today\'s Meals'
                                      : 'Meals',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: const Color(0xFF4A342E),
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              if (logProvider.logs.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF27D52).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '${filteredLogs.length} ${_searchQuery.isNotEmpty ? 'found' : 'entries'}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: const Color(0xFF4A342E),
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _dateRange == null
                                ? 'All time'
                                : (_rangePresetLabel(_dateRange!) ?? _formatCompactRange(_dateRange!)),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF4A342E).withValues(alpha: 0.6),
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ]),
                  ),
                ),

                if (filteredLogs.isEmpty && (_searchQuery.isNotEmpty || _dateRange != null || _selectedCategory != null))
                  SliverToBoxAdapter(
                    child: Center(
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
                              'Try a different search term or range',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF4A342E).withValues(alpha: 0.4),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (logProvider.logs.isEmpty)
                  SliverToBoxAdapter(
                    child: Center(
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
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final log = filteredLogs[index];
                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 400 + (index * 50)),
                          tween: Tween(begin: 0.0, end: 1.0),
                          curve: Curves.easeOutQuart,
                          builder: (context, opacity, child) {
                            return Transform.translate(
                              offset: Offset(0, 20 * (1 - opacity)),
                              child: Opacity(
                                opacity: opacity,
                                child: LogEntryCard(
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
                                ),
                              ),
                            );
                          },
                        );
                      },
                      childCount: filteredLogs.length,
                    ),
                  ),
                // Invisible cushion to prevent FAB overlap
                SliverToBoxAdapter(
                  child: const SizedBox(height: 200),
                ),
                ],
              ),
            ),
          ),
        ],
      );
    },
  ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF27D52), Color(0xFFEF6A48)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF27D52).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.large(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const CalculatorSheet(),
            );
          },
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: const Icon(Icons.add, size: 32),
        ),
      ),
    );
  }

  void _performStartupSync() {
    // Show cached UI immediately, sync in background
    if (mounted) {
      setState(() => _isInitialSyncing = false);
    }
    _syncInBackground();
  }

  Future<void> _syncInBackground() async {
    final logProvider = context.read<LogProvider>();
    final foodProvider = context.read<FoodProvider>();
    final settingsProvider = context.read<SettingsProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final sheetApi = SheetApi();

    try {
      // Fetch all data from backend
      final response = await sheetApi.fetchAll().timeout(const Duration(seconds: 20));
      if (response == null) {
        print('⚠️ Background sync: Failed to fetch data from backend');
        return;
      }

      // Backend wraps data in {ok: true, data: {...}}
      final data = response['data'] as Map<String, dynamic>? ?? response;

      // Run all sync operations in parallel
      await Future.wait<dynamic>([
        foodProvider.refreshFromSheets(data),
        logProvider.refreshFromSheets(data),
        settingsProvider.refreshFromSheets(data),
        profileProvider.refreshFromSheets(data),
      ]);
      
      print('✓ Background sync complete');
      
      // Refresh UI after sync completes
      if (mounted) {
        setState(() {}); // Trigger rebuild with updated data
      }
    } catch (e) {
      print('❌ Background sync failed: $e');
    }
  }

  Future<void> _runFullSync(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isSyncing = true);

    final logProvider = context.read<LogProvider>();
    final foodProvider = context.read<FoodProvider>();
    final settingsProvider = context.read<SettingsProvider>();
    final sheetApi = SheetApi();

    try {
      // Push any pending logs first
      await logProvider.syncLogs();

      // Pull everything from Sheets and merge locally
      final response = await sheetApi.fetchAll();
      if (response == null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Sync failed: cannot reach server'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      // Backend wraps data in {ok: true, data: {...}}
      final data = response['data'] as Map<String, dynamic>? ?? response;

      final foods = await foodProvider.refreshFromSheets(data);
      final logs = await logProvider.refreshFromSheets(data);
      final settingsChanged = await settingsProvider.refreshFromSheets(data);

      if (!mounted) return;

      final changes = foods + logs + (settingsChanged ? 1 : 0);
      final message = changes > 0
          ? 'Synced: $foods foods, $logs logs${settingsChanged ? ', settings' : ''}'
          : 'Already up to date';

      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  DateTimeRange _todayRange() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return DateTimeRange(start: start, end: start.add(const Duration(days: 1)));
  }

  bool _isTodayRange(DateTimeRange range) {
    final today = _todayRange();
    return range.start.isAtSameMomentAs(today.start) && range.end.isAtSameMomentAs(today.end);
  }

  String _formatRangeLabel(DateTimeRange range) {
    String fmt(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')} ${d.month.toString().padLeft(2, '0')} ${d.year}';
    final adjustedEnd = range.end.subtract(const Duration(milliseconds: 1));
    return '${fmt(range.start)} – ${fmt(adjustedEnd)}';
  }

  String _formatCompactRange(DateTimeRange range) {
    final start = range.start;
    final end = range.end.subtract(const Duration(milliseconds: 1));
    final locale = Intl.getCurrentLocale();
    if (start.year == end.year) {
      if (start.month == end.month) {
        return '${DateFormat.MMMd(locale).format(start)} – ${DateFormat('d', locale).format(end)}';
      }
      return '${DateFormat.MMMd(locale).format(start)} – ${DateFormat.MMMd(locale).format(end)}';
    }
    final fmt = DateFormat('MMM d, y', locale);
    return '${fmt.format(start)} – ${fmt.format(end)}';
  }

  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTimeRange _thisWeekRange() {
    final now = DateTime.now();
    final today = _startOfDay(now);
    final mondayIndex = 1; // Monday as start of week
    final start = today.subtract(Duration(days: (today.weekday - mondayIndex) % 7));
    return DateTimeRange(start: start, end: start.add(const Duration(days: 7)));
  }

  String? _rangePresetLabel(DateTimeRange range) {
    // Normalize end to exclusive day boundary
    final normalized = DateTimeRange(
      start: _startOfDay(range.start),
      end: _startOfDay(range.end),
    );

    final thisWeek = _thisWeekRange();
    if (normalized.start.isAtSameMomentAs(thisWeek.start) &&
        normalized.end.isAtSameMomentAs(thisWeek.end)) {
      return 'This Week';
    }

    final today = _startOfDay(DateTime.now());
    final last7Days = DateTimeRange(start: today.subtract(const Duration(days: 7)), end: today.add(const Duration(days: 1)));
    if (normalized.start.isAtSameMomentAs(last7Days.start) &&
        normalized.end.isAtSameMomentAs(last7Days.end)) {
      return 'Last 7 Days';
    }
    return null;
  }

  List<LogEntry> _filterLogs(List<LogEntry> source) {
    Iterable<LogEntry> results = source;

    if (_dateRange != null) {
      final start = _dateRange!.start;
      final endExclusive = DateTime(
        _dateRange!.end.year,
        _dateRange!.end.month,
        _dateRange!.end.day,
      ).add(const Duration(days: 1));
      results = results.where(
        (log) => !log.timestamp.isBefore(start) && log.timestamp.isBefore(endExclusive),
      );
    }

    if (_selectedCategory != null) {
      results = results.where((log) => log.mealCategory == _selectedCategory);
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      results = results.where((log) => log.foodName.toLowerCase().contains(query));
    }

    final list = results.toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  Widget _buildAnimatedMacroBar(
    int delayMs,
    String label,
    double current,
    double target,
    Color color,
    IconData icon,
  ) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + delayMs),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: MacroProgressBar(
            label: label,
            current: current,
            target: target,
            color: color,
            icon: icon,
          ),
        );
      },
    );
  }
}
