import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/topics_data.dart';
import '../services/window_transparency/window_transparency.dart';

const List<double> kFontSteps = [0.85, 1.0, 1.15, 1.3, 1.45];

const List<int> kTextColorOptions = [
  0xFFF7FAFC,
  0xFF000000,
  0xFFFFFFFF,
  0xFF1A202C,
  0xFF2D3748,
  0xFFE53E3E,
  0xFFDD6B20,
  0xFFD69E2E,
  0xFF38A169,
  0xFF3182CE,
  0xFF805AD5,
  0xFFD53F8C,
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _VisiblePoint {
  final Topic topic;
  final LevelSection section;
  final ConceptPoint point;
  final int index;

  const _VisiblePoint({
    required this.topic,
    required this.section,
    required this.point,
    required this.index,
  });

  String get id => '${topic.id}:${section.level}:$index';
}

class _HomeScreenState extends State<HomeScreen> {
  String activeTopicId = kTopics.first.id;
  String activeLevel = 'mid';
  int fontStepIndex = 1;
  int? expandedIndex;
  bool stickerMode = false;
  bool alwaysOnTop = true;
  bool hideTitleBar = false;
  bool clickThrough = false;
  bool readingMode = false;
  bool interviewMode = false;
  bool showInterviewAnswer = false;
  double windowOpacity = 0.82;
  int textColorValue = 0xFFF7FAFC;
  String searchQuery = '';
  _VisiblePoint? interviewPoint;
  final Set<String> favorites = <String>{};
  final Map<String, int> confidence = <String, int>{};
  final TextEditingController searchController = TextEditingController();

  double get scale => kFontSteps[fontStepIndex];
  double fs(double px) => px * scale;
  Color get textColor => Color(textColorValue);
  Color get secondaryTextColor => textColor.withValues(alpha: 0.72);
  Color get mutedTextColor => textColor.withValues(alpha: 0.52);

  Topic get activeTopic => kTopics.firstWhere((t) => t.id == activeTopicId);
  LevelSection get activeSection => activeTopic.sections.firstWhere((s) => s.level == activeLevel);

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fontStepIndex = prefs.getInt('fontStepIndex') ?? fontStepIndex;
      windowOpacity = prefs.getDouble('windowOpacity') ?? windowOpacity;
      textColorValue = prefs.getInt('textColorValue') ?? textColorValue;
      favorites
        ..clear()
        ..addAll(prefs.getStringList('favorites') ?? const []);
      final confidenceRows = prefs.getStringList('confidence') ?? const [];
      confidence.clear();
      for (final row in confidenceRows) {
        final parts = row.split('|');
        if (parts.length == 2) confidence[parts[0]] = int.tryParse(parts[1]) ?? 0;
      }
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('fontStepIndex', fontStepIndex);
    await prefs.setDouble('windowOpacity', windowOpacity);
    await prefs.setInt('textColorValue', textColorValue);
    await prefs.setStringList('favorites', favorites.toList());
    await prefs.setStringList('confidence', confidence.entries.map((e) => '${e.key}|${e.value}').toList());
  }

  List<_VisiblePoint> get _allVisiblePoints {
    final rows = <_VisiblePoint>[];
    for (final topic in kTopics) {
      for (final section in topic.sections) {
        for (var i = 0; i < section.points.length; i++) {
          rows.add(_VisiblePoint(topic: topic, section: section, point: section.points[i], index: i));
        }
      }
    }
    return rows;
  }

  List<_VisiblePoint> get _currentPoints {
    final query = searchQuery.trim().toLowerCase();
    if (interviewMode && interviewPoint != null) return [interviewPoint!];
    if (query.isNotEmpty) {
      return _allVisiblePoints.where((row) {
        final haystack = '${row.topic.label} ${row.section.title} ${row.point.question} ${row.point.explanation} ${row.point.code}'.toLowerCase();
        return haystack.contains(query);
      }).toList();
    }
    return List.generate(
      activeSection.points.length,
      (i) => _VisiblePoint(topic: activeTopic, section: activeSection, point: activeSection.points[i], index: i),
    );
  }

  void _selectTopic(String id) {
    setState(() {
      activeTopicId = id;
      expandedIndex = null;
      interviewMode = false;
      searchQuery = '';
      searchController.clear();
    });
  }

  void _increaseFont() {
    if (fontStepIndex < kFontSteps.length - 1) {
      setState(() => fontStepIndex++);
      _savePrefs();
    }
  }

  void _decreaseFont() {
    if (fontStepIndex > 0) {
      setState(() => fontStepIndex--);
      _savePrefs();
    }
  }

  Future<void> _applyStickerSettings() async {
    if (!WindowTransparencyService.isSupported) return;
    await WindowTransparencyService.setStickerMode(
      enabled: stickerMode,
      opacity: windowOpacity,
      hideTitleBar: hideTitleBar,
      clickThrough: clickThrough,
    );
    if (!alwaysOnTop && stickerMode) {
      await WindowTransparencyService.setAlwaysOnTop(false);
    }
  }

  Future<void> _toggleStickerMode() async {
    if (!WindowTransparencyService.isSupported) return;
    setState(() => stickerMode = !stickerMode);
    await _applyStickerSettings();
    _savePrefs();
  }

  Future<void> _changeWindowOpacity(double value) async {
    setState(() => windowOpacity = value);
    if (stickerMode) await WindowTransparencyService.setOpacity(value);
    _savePrefs();
  }

  void _changeTextColor(int value) {
    setState(() => textColorValue = value);
    _savePrefs();
  }

  String _textColorLabel(int value) {
    if (value == 0xFF000000) return 'Black';
    if (value == 0xFFFFFFFF) return 'White';
    return '#${value.toRadixString(16).substring(2).toUpperCase()}';
  }

  void _toggleFavorite(String id) {
    setState(() {
      if (!favorites.add(id)) favorites.remove(id);
    });
    _savePrefs();
  }

  void _setConfidence(String id, int value) {
    setState(() => confidence[id] = value);
    _savePrefs();
  }

  void _startInterviewMode() {
    final points = _allVisiblePoints;
    if (points.isEmpty) return;
    setState(() {
      interviewMode = true;
      readingMode = true;
      showInterviewAnswer = false;
      interviewPoint = points[Random().nextInt(points.length)];
      expandedIndex = 0;
    });
  }

  void _nextInterviewQuestion() {
    final points = _allVisiblePoints;
    if (points.isEmpty) return;
    setState(() {
      interviewPoint = points[Random().nextInt(points.length)];
      showInterviewAnswer = false;
      expandedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width >= 1100;
        final isTablet = width >= 720 && width < 1100;

        return Scaffold(
          backgroundColor: stickerMode ? const Color(0xAA0F1117) : const Color(0xFF0F1117),
          drawer: isDesktop || readingMode
              ? null
              : _TopicDrawer(activeTopicId: activeTopicId, onSelect: (id) { Navigator.of(context).maybePop(); _selectTopic(id); }, fs: fs),
          appBar: isDesktop || readingMode
              ? null
              : AppBar(
                  backgroundColor: const Color(0xFF121826),
                  elevation: 0,
                  titleSpacing: 0,
                  title: Text('Flutter Interview Prep', style: TextStyle(fontSize: fs(18), fontWeight: FontWeight.w700)),
                  actions: [_buildTopControls(compact: true), const SizedBox(width: 8)],
                ),
          body: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isDesktop && !readingMode)
                  _DesktopSidebar(activeTopicId: activeTopicId, onSelect: _selectTopic, fs: fs),
                Expanded(
                  child: SelectionArea(
                    child: CustomScrollView(
                      slivers: [
                        if (!readingMode)
                          SliverToBoxAdapter(child: _buildTopHeader(showTopicScroller: !isDesktop, compact: !isDesktop, maxContentWidth: _maxContentWidth(width))),
                        SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: readingMode ? 12 : (isTablet ? 24 : 16), vertical: readingMode ? 12 : 18),
                          sliver: SliverToBoxAdapter(
                            child: Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: readingMode ? 820 : _maxContentWidth(width)),
                                child: _buildContentGrid(width),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: readingMode ? _readingModeFab() : null,
        );
      },
    );
  }

  double _maxContentWidth(double width) {
    if (width >= 1400) return 1080;
    if (width >= 900) return 940;
    return double.infinity;
  }

  Widget _buildTopHeader({required bool showTopicScroller, required bool compact, required double maxContentWidth}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1A1F2E), Color(0xFF0F1117)]),
        border: Border(bottom: BorderSide(color: Color(0xFF2D3748))),
      ),
      padding: EdgeInsets.fromLTRB(compact ? 16 : 28, 20, compact ? 16 : 28, 16),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('🎯', style: TextStyle(fontSize: fs(compact ? 24 : 30))),
              const SizedBox(width: 12),
              Expanded(child: Text(compact ? 'Senior Flutter Interview Handbook' : 'Flutter Senior Interview Prep', style: TextStyle(fontSize: fs(compact ? 20 : 26), fontWeight: FontWeight.bold, color: textColor, letterSpacing: -0.4))),
              if (!compact) _buildTopControls(),
            ]),
            const SizedBox(height: 8),
            Text('Interview companion with responsive layout, desktop sticker mode, search, bookmarks, reading mode, and mock interview mode.', style: TextStyle(fontSize: fs(14), color: secondaryTextColor, height: 1.45)),
            const SizedBox(height: 14),
            _buildSearchAndActions(compact: compact),
            const SizedBox(height: 12),
            Wrap(spacing: 10, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [
              _buildLevelToggle(),
              _buildStatChip('${kTopics.length} topics'),
              _buildStatChip('${_currentPoints.length} cards'),
              _buildStatChip('${favorites.length} favorites'),
            ]),
            if (WindowTransparencyService.isSupported) ...[
              const SizedBox(height: 12),
              _buildStickerPanel(compact: compact),
            ],
            if (showTopicScroller) ...[
              const SizedBox(height: 16),
              _buildTopicScroller(),
            ],
          ]),
        ),
      ),
    );
  }

  Widget _buildSearchAndActions({required bool compact}) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: compact ? double.infinity : 420,
          child: TextField(
            controller: searchController,
            onChanged: (value) => setState(() { searchQuery = value; expandedIndex = null; interviewMode = false; }),
            decoration: InputDecoration(
              hintText: 'Search: RenderObject, Future.wait, Firebase...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isEmpty ? null : IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() { searchController.clear(); searchQuery = ''; })),
              filled: true,
              fillColor: const Color(0xFF1A202C),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2D3748))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2D3748))),
            ),
          ),
        ),
        _actionChip(icon: Icons.menu_book, label: readingMode ? 'Exit Reading' : 'Reading', selected: readingMode, onTap: () => setState(() => readingMode = !readingMode)),
        _actionChip(icon: Icons.mic, label: 'CEO Mode', selected: interviewMode, onTap: _startInterviewMode),
      ],
    );
  }

  Widget _buildTopControls({bool compact = false}) {
    return Container(
      margin: EdgeInsets.only(left: compact ? 0 : 8),
      decoration: BoxDecoration(color: const Color(0xFF1A202C), border: Border.all(color: const Color(0xFF2D3748)), borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.all(3),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _fontButton('−', fontStepIndex == 0, _decreaseFont),
        SizedBox(width: compact ? 30 : 42, child: Text('${(scale * 100).round()}%', textAlign: TextAlign.center, style: TextStyle(fontSize: compact ? 10 : 11, color: const Color(0xFF718096), fontWeight: FontWeight.w700))),
        _fontButton('+', fontStepIndex == kFontSteps.length - 1, _increaseFont),
        if (WindowTransparencyService.isSupported) ...[const SizedBox(width: 4), _stickerButton(), const SizedBox(width: 2), _textColorButton()],
      ]),
    );
  }

  Widget _stickerButton() {
    return Tooltip(
      message: stickerMode ? 'Turn off sticker mode' : 'Turn on sticker transparency',
      child: Material(
        color: stickerMode ? const Color(0xFF4F6AF0) : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        child: InkWell(onTap: _toggleStickerMode, borderRadius: BorderRadius.circular(7), child: const SizedBox(width: 30, height: 30, child: Icon(Icons.push_pin, size: 17, color: Color(0xFFCBD5E0)))),
      ),
    );
  }

  Widget _textColorButton() {
    return PopupMenuButton<int>(
      tooltip: 'Text color',
      onSelected: _changeTextColor,
      color: const Color(0xFF1A202C),
      itemBuilder: (context) => [
        for (final value in kTextColorOptions)
          PopupMenuItem<int>(
            value: value,
            child: Row(children: [
              Container(width: 18, height: 18, decoration: BoxDecoration(color: Color(value), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF718096)))),
              const SizedBox(width: 10),
              Text(_textColorLabel(value), style: const TextStyle(color: Color(0xFFE2E8F0), fontWeight: FontWeight.w600)),
              const Spacer(),
              if (textColorValue == value) const Icon(Icons.check, size: 18, color: Color(0xFF38A169)),
            ]),
          ),
      ],
      child: SizedBox(
        width: 30,
        height: 30,
        child: Stack(alignment: Alignment.center, children: [
          Icon(Icons.format_color_text, size: 17, color: textColor),
          Positioned(bottom: 5, child: Container(width: 16, height: 3, decoration: BoxDecoration(color: textColor, borderRadius: BorderRadius.circular(999)))),
        ]),
      ),
    );
  }
  Widget _buildStickerPanel({required bool compact}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(color: stickerMode ? const Color(0x22148A5D) : const Color(0xFF141A26), borderRadius: BorderRadius.circular(14), border: Border.all(color: stickerMode ? const Color(0xFF38A169) : const Color(0xFF2D3748))),
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.push_pin, size: 18, color: Color(0xFFCBD5E0)),
          const SizedBox(width: 8),
          Expanded(child: Text('Desktop Sticker Mode', style: TextStyle(fontSize: fs(14), fontWeight: FontWeight.w800, color: textColor))),
          Switch(value: stickerMode, onChanged: (_) => _toggleStickerMode()),
        ]),
        if (stickerMode) ...[
          Text('Opacity ${(windowOpacity * 100).round()}%', style: TextStyle(fontSize: fs(12.5), color: secondaryTextColor)),
          Slider(value: windowOpacity, min: 0.2, max: 1.0, divisions: 16, label: '${(windowOpacity * 100).round()}%', onChanged: _changeWindowOpacity),
          Wrap(spacing: 12, runSpacing: 6, children: [
            _checkControl('Always on top', alwaysOnTop, (v) async { setState(() => alwaysOnTop = v); await WindowTransparencyService.setAlwaysOnTop(v); }),
            _checkControl('Hide title bar', hideTitleBar, (v) async { setState(() => hideTitleBar = v); await WindowTransparencyService.setTitleBarHidden(v); }),
            Tooltip(
              message: 'Click-through needs a global shortcut or tray menu to disable safely. The UI is prepared, but native click-through is intentionally disabled in this safe build.',
              child: FilterChip(
                selected: false,
                label: const Text('Click through planned'),
                onSelected: null,
                backgroundColor: const Color(0xFF1A202C),
                disabledColor: const Color(0xFF1A202C),
                labelStyle: const TextStyle(color: Color(0xFF718096), fontWeight: FontWeight.w600),
              ),
            ),
          ]),
          const SizedBox(height: 6),
          Text('Plugin: window_manager. It controls opacity, always-on-top, title bar style, and click-through on supported desktop platforms. Mobile/web keep a safe fallback.', style: TextStyle(fontSize: fs(12.3), color: secondaryTextColor, height: 1.45)),
        ],
      ]),
    );
  }

  Widget _checkControl(String label, bool value, ValueChanged<bool> onChanged) {
    return FilterChip(
      selected: value,
      label: Text(label),
      onSelected: onChanged,
      selectedColor: const Color(0xFF2B6CB0),
      backgroundColor: const Color(0xFF1A202C),
      checkmarkColor: textColor,
      labelStyle: const TextStyle(color: Color(0xFFE2E8F0), fontWeight: FontWeight.w600),
    );
  }

  Widget _actionChip({required IconData icon, required String label, required bool selected, required VoidCallback onTap}) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: selected ? Colors.white : const Color(0xFFCBD5E0)),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: selected ? const Color(0xFF4F6AF0) : const Color(0xFF1A202C),
      labelStyle: TextStyle(color: textColor, fontSize: fs(13), fontWeight: FontWeight.w700),
      side: const BorderSide(color: Color(0xFF2D3748)),
    );
  }

  Widget _fontButton(String label, bool disabled, VoidCallback onTap) {
    return Material(color: Colors.transparent, child: InkWell(onTap: disabled ? null : onTap, borderRadius: BorderRadius.circular(7), child: SizedBox(width: 30, height: 30, child: Center(child: Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: disabled ? const Color(0xFF3A4452) : const Color(0xFFCBD5E0)))))));
  }

  Widget _buildStatChip(String text) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: const Color(0xFF1A202C), borderRadius: BorderRadius.circular(999), border: Border.all(color: const Color(0xFF2D3748))), child: Text(text, style: TextStyle(fontSize: fs(12.5), color: textColor, fontWeight: FontWeight.w600)));
  }

  Widget _buildLevelToggle() {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF1A202C), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2D3748))),
      padding: const EdgeInsets.all(4),
      child: Row(mainAxisSize: MainAxisSize.min, children: ['mid', 'senior'].map((lvl) {
        final isActive = activeLevel == lvl;
        final color = lvl == 'mid' ? const Color(0xFF3182CE) : const Color(0xFF805AD5);
        return Material(color: isActive ? color : Colors.transparent, borderRadius: BorderRadius.circular(9), child: InkWell(borderRadius: BorderRadius.circular(9), onTap: () => setState(() { activeLevel = lvl; expandedIndex = null; interviewMode = false; }), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9), child: Text(lvl == 'mid' ? 'Core' : 'Senior Depth', style: TextStyle(fontSize: fs(13.5), fontWeight: FontWeight.w700, color: isActive ? Colors.white : const Color(0xFFA0AEC0))))));
      }).toList()),
    );
  }

  Widget _buildTopicScroller() {
    return SizedBox(
      height: 46,
      child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: kTopics.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (context, index) {
        final topic = kTopics[index];
        return _TopicPill(topic: topic, isActive: topic.id == activeTopicId, onTap: () => _selectTopic(topic.id), fs: fs);
      }),
    );
  }

  Widget _buildContentGrid(double width) {
    final rows = _currentPoints;
    final useTwoColumns = !readingMode && width >= 1180 && rows.length >= 4;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (!readingMode) _buildSectionHeader(),
      if (interviewMode) _buildInterviewBar(),
      const SizedBox(height: 16),
      if (rows.isEmpty)
        _emptyState()
      else if (useTwoColumns)
        Wrap(spacing: 14, runSpacing: 14, children: rows.asMap().entries.map((entry) => SizedBox(width: 516, child: _buildPointCard(entry.value, entry.key))).toList())
      else
        ...rows.asMap().entries.map((entry) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildPointCard(entry.value, entry.key))),
      if (!readingMode) ...[const SizedBox(height: 18), _buildFooterTip()],
    ]);
  }

  Widget _buildSectionHeader() {
    final color = Color(activeTopic.colorValue);
    final title = searchQuery.isNotEmpty ? 'Search Results' : activeTopic.label;
    final subtitle = searchQuery.isNotEmpty ? 'Across all topics and levels' : '${activeSection.title} • ${activeSection.points.length} interview cards';
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(gradient: LinearGradient(colors: [color.withOpacity(0.16), color.withOpacity(0.04)]), border: Border.all(color: color.withOpacity(0.32)), borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(searchQuery.isNotEmpty ? '🔎' : activeTopic.icon, style: TextStyle(fontSize: fs(30))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: fs(21), fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: fs(13.5), color: secondaryTextColor)),
        ])),
      ]),
    );
  }

  Widget _buildInterviewBar() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1A202C), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF805AD5))),
      child: Wrap(spacing: 10, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [
        Text('🎤 CEO Mode', style: TextStyle(fontSize: fs(14), fontWeight: FontWeight.bold, color: textColor)),
        _actionChip(icon: showInterviewAnswer ? Icons.visibility_off : Icons.visibility, label: showInterviewAnswer ? 'Hide answer' : 'Reveal answer', selected: showInterviewAnswer, onTap: () => setState(() => showInterviewAnswer = !showInterviewAnswer)),
        _actionChip(icon: Icons.shuffle, label: 'Next question', selected: false, onTap: _nextInterviewQuestion),
        _actionChip(icon: Icons.close, label: 'Exit', selected: false, onTap: () => setState(() { interviewMode = false; readingMode = false; interviewPoint = null; })),
      ]),
    );
  }

  Widget _emptyState() {
    return Container(width: double.infinity, padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: const Color(0xFF1A202C), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF2D3748))), child: Text('No cards found. Try another search term.', style: TextStyle(fontSize: fs(15), color: secondaryTextColor)));
  }

  Widget _buildPointCard(_VisiblePoint row, int displayIndex) {
    final topicColor = Color(row.topic.colorValue);
    final isOpen = expandedIndex == displayIndex || readingMode;
    final isFav = favorites.contains(row.id);
    final conf = confidence[row.id] ?? 0;
    final shouldShowAnswer = !interviewMode || showInterviewAnswer;
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF1A202C), border: Border.all(color: isOpen ? topicColor.withOpacity(0.48) : const Color(0xFF2D3748)), borderRadius: BorderRadius.circular(14), boxShadow: [if (isOpen) BoxShadow(color: topicColor.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8))]),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Material(color: Colors.transparent, child: InkWell(onTap: readingMode ? null : () => setState(() => expandedIndex = isOpen ? null : displayIndex), child: Padding(padding: const EdgeInsets.all(16), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: topicColor.withOpacity(0.2), shape: BoxShape.circle), child: Center(child: Text('${row.index + 1}', style: TextStyle(fontSize: fs(13), fontWeight: FontWeight.bold, color: topicColor)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (searchQuery.isNotEmpty || interviewMode) Text('${row.topic.icon} ${row.topic.label} • ${row.section.title}', style: TextStyle(fontSize: fs(11.5), color: secondaryTextColor, fontWeight: FontWeight.w700)),
            Text(row.point.question, style: TextStyle(fontSize: fs(readingMode ? 20 : 16), fontWeight: FontWeight.w700, color: textColor, height: 1.35)),
          ])),
          IconButton(tooltip: 'Favorite', icon: Icon(isFav ? Icons.star : Icons.star_border, color: isFav ? const Color(0xFFF6E05E) : const Color(0xFF718096)), onPressed: () => _toggleFavorite(row.id)),
          if (!readingMode) Icon(isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: const Color(0xFF718096)),
        ])))) ,
        AnimatedCrossFade(firstChild: const SizedBox.shrink(), secondChild: shouldShowAnswer ? _buildExpandedContent(row, conf) : _hiddenAnswer(), crossFadeState: isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst, duration: const Duration(milliseconds: 180), sizeCurve: Curves.easeOut),
      ]),
    );
  }

  Widget _hiddenAnswer() {
    return Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: const BoxDecoration(color: Color(0xFF161B27), border: Border(top: BorderSide(color: Color(0xFF2D3748)))), child: Text('Answer hidden. Say your answer first, then press Reveal answer.', style: TextStyle(fontSize: fs(15), color: secondaryTextColor, height: 1.5)));
  }

  Widget _buildExpandedContent(_VisiblePoint row, int conf) {
    final point = row.point;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: double.infinity, decoration: const BoxDecoration(color: Color(0xFF161B27), border: Border(top: BorderSide(color: Color(0xFF2D3748)))), padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('EXPLANATION'),
        const SizedBox(height: 8),
        Text(point.explanation, style: TextStyle(fontSize: fs(readingMode ? 17 : 15), color: textColor, height: 1.65)),
        const SizedBox(height: 12),
        _confidenceBar(row.id, conf),
      ])),
      if (point.code.isNotEmpty)
        Container(width: double.infinity, decoration: const BoxDecoration(color: Color(0xFF0D1117), border: Border(top: BorderSide(color: Color(0xFF2D3748)))), padding: const EdgeInsets.fromLTRB(16, 12, 16, 16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionLabel('INTERVIEW PHRASE / CODE'),
          const SizedBox(height: 10),
          Scrollbar(thumbVisibility: true, child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: SelectableText(point.code, style: TextStyle(fontSize: fs(readingMode ? 15 : 13.5), height: 1.65, color: textColor, fontFamily: 'monospace')))),
        ])),
    ]);
  }

  Widget _confidenceBar(String id, int conf) {
    return Wrap(spacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
      Text('My confidence:', style: TextStyle(fontSize: fs(12.5), color: secondaryTextColor, fontWeight: FontWeight.w700)),
      for (var i = 1; i <= 5; i++) IconButton(visualDensity: VisualDensity.compact, iconSize: 19, padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 24, minHeight: 24), onPressed: () => _setConfidence(id, i), icon: Icon(i <= conf ? Icons.star : Icons.star_border, color: i <= conf ? const Color(0xFFF6E05E) : const Color(0xFF718096))),
    ]);
  }

  Widget _sectionLabel(String text) => Text(text, style: TextStyle(fontSize: fs(11), fontWeight: FontWeight.bold, color: secondaryTextColor, letterSpacing: 1));

  Widget _buildFooterTip() {
    return Container(decoration: BoxDecoration(color: const Color(0xFF1A202C), border: Border.all(color: const Color(0xFF2D3748)), borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.all(14), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('💡'),
      const SizedBox(width: 10),
      Expanded(child: Text('Use the 6-step interview formula: what it is, why it exists, how it works, where you used it, trade-offs, and limitations. Keep your answers honest and connect them to 4iCAD, ASD, Phillips, or Toyota when relevant.', style: TextStyle(fontSize: fs(13.5), color: secondaryTextColor, height: 1.45))),
    ]));
  }

  Widget _readingModeFab() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      FloatingActionButton.small(heroTag: 'reading_exit', tooltip: 'Exit reading mode', onPressed: () => setState(() { readingMode = false; if (interviewMode) interviewMode = false; }), child: const Icon(Icons.close)),
      const SizedBox(height: 8),
      FloatingActionButton.small(heroTag: 'reading_font', tooltip: 'Bigger text', onPressed: _increaseFont, child: const Icon(Icons.add)),
    ]);
  }
}

class _DesktopSidebar extends StatelessWidget {
  final String activeTopicId;
  final ValueChanged<String> onSelect;
  final double Function(double) fs;

  const _DesktopSidebar({required this.activeTopicId, required this.onSelect, required this.fs});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 292,
      decoration: const BoxDecoration(color: Color(0xFF121826), border: Border(right: BorderSide(color: Color(0xFF2D3748)))),
      child: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(18, 18, 18, 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('🎯 Flutter Prep', style: TextStyle(fontSize: fs(20), fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text('Senior interview map', style: TextStyle(fontSize: fs(12.5), color: const Color(0xFFA0AEC0))),
        ])),
        Expanded(child: ListView.separated(padding: const EdgeInsets.fromLTRB(10, 4, 10, 14), itemCount: kTopics.length, separatorBuilder: (_, __) => const SizedBox(height: 4), itemBuilder: (context, index) {
          final topic = kTopics[index];
          return _TopicTile(topic: topic, isActive: topic.id == activeTopicId, onTap: () => onSelect(topic.id), fs: fs);
        })),
      ])),
    );
  }
}

class _TopicDrawer extends StatelessWidget {
  final String activeTopicId;
  final ValueChanged<String> onSelect;
  final double Function(double) fs;

  const _TopicDrawer({required this.activeTopicId, required this.onSelect, required this.fs});

  @override
  Widget build(BuildContext context) {
    return Drawer(backgroundColor: const Color(0xFF121826), child: SafeArea(child: ListView(padding: const EdgeInsets.all(12), children: [
      Padding(padding: const EdgeInsets.fromLTRB(8, 8, 8, 16), child: Text('Topics', style: TextStyle(fontSize: fs(22), fontWeight: FontWeight.bold, color: Colors.white))),
      ...kTopics.map((topic) => Padding(padding: const EdgeInsets.only(bottom: 6), child: _TopicTile(topic: topic, isActive: topic.id == activeTopicId, onTap: () => onSelect(topic.id), fs: fs))),
    ])));
  }
}

class _TopicTile extends StatelessWidget {
  final Topic topic;
  final bool isActive;
  final VoidCallback onTap;
  final double Function(double) fs;

  const _TopicTile({required this.topic, required this.isActive, required this.onTap, required this.fs});

  @override
  Widget build(BuildContext context) {
    final color = Color(topic.colorValue);
    return Material(color: isActive ? color.withOpacity(0.18) : Colors.transparent, borderRadius: BorderRadius.circular(12), child: InkWell(borderRadius: BorderRadius.circular(12), onTap: onTap, child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: isActive ? color.withOpacity(0.7) : Colors.transparent)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11), child: Row(children: [
      Text(topic.icon, style: TextStyle(fontSize: fs(20))),
      const SizedBox(width: 10),
      Expanded(child: Text(topic.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: fs(14), fontWeight: FontWeight.w700, color: isActive ? Colors.white : const Color(0xFFCBD5E0)))),
    ]))));
  }
}

class _TopicPill extends StatelessWidget {
  final Topic topic;
  final bool isActive;
  final VoidCallback onTap;
  final double Function(double) fs;

  const _TopicPill({required this.topic, required this.isActive, required this.onTap, required this.fs});

  @override
  Widget build(BuildContext context) {
    final color = Color(topic.colorValue);
    return Material(color: isActive ? color : const Color(0xFF1A202C), borderRadius: BorderRadius.circular(999), child: InkWell(borderRadius: BorderRadius.circular(999), onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), border: Border.all(color: isActive ? color : const Color(0xFF2D3748))), child: Text('${topic.icon} ${topic.label}', style: TextStyle(fontSize: fs(13.5), fontWeight: FontWeight.w700, color: isActive ? Colors.white : const Color(0xFFA0AEC0))))));
  }
}
