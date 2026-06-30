import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/topics_data.dart';
import '../services/text_reader/text_reader.dart';
import '../services/window_transparency/window_transparency.dart';

const List<double> kFontSteps = [0.85, 1.0, 1.15, 1.3, 1.45];

enum AnswerMode { shortAnswer, detailedAnswer, interviewAnswer }

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

const List<int> kBackgroundColorOptions = [
  0xFF0F1117,
  0xFFFFFFFF,
  0xFFF7FAFC,
  0xFFEDF2F7,
  0xFF1A202C,
  0xFF000000,
  0xFF1A1F2E,
  0xFF102A43,
  0xFF1C4532,
  0xFF3C2A1E,
  0xFF2D1B45,
  0xFF742A2A,
];

const List<int> kCardColorOptions = [
  0xFF1A202C,
  0xFFFFFFFF,
  0xFFF7FAFC,
  0xFFEDF2F7,
  0xFF0F1117,
  0xFF000000,
  0xFF102A43,
  0xFF1C4532,
  0xFF3C2A1E,
  0xFF2D1B45,
  0xFF742A2A,
  0xFF2B6CB0,
];

const List<int> kSectionColorOptions = [
  0xFF1A1F2E,
  0xFF0F1117,
  0xFF1A202C,
  0xFFFFFFFF,
  0xFFF7FAFC,
  0xFFEDF2F7,
  0xFF000000,
  0xFF102A43,
  0xFF1C4532,
  0xFF3C2A1E,
  0xFF2D1B45,
  0xFF742A2A,
  0xFF2B6CB0,
  0xFF805AD5,
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
  String? activeTrackId;
  String activeTopicId = kTracks.first.topics.first.id;
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
  int backgroundColorValue = 0xFF0F1117;
  int cardColorValue = 0xFF1A202C;
  int headerColorValue = 0xFF1A1F2E;
  int footerColorValue = 0xFF1A202C;
  String searchQuery = '';
  _VisiblePoint? interviewPoint;
  final Set<String> favorites = <String>{};
  final Map<String, int> confidence = <String, int>{};
  final Map<String, String> notes = <String, String>{};
  final TextEditingController searchController = TextEditingController();
  String? speakingPointId;
  String? speakingSectionKey;
  int readerRunId = 0;
  AnswerMode answerMode = AnswerMode.detailedAnswer;

  double get scale => kFontSteps[fontStepIndex];
  double fs(double px) => px * scale;
  Color get textColor => Color(textColorValue);
  Color get backgroundColor => Color(backgroundColorValue);
  Color get cardColor => Color(cardColorValue);
  Color get headerColor => Color(headerColorValue);
  Color get footerColor => Color(footerColorValue);
  Color get cardSectionColor => Color.lerp(cardColor, backgroundColor, 0.18)!;
  Color get cardCodeColor => Color.lerp(cardColor, Colors.black, 0.22)!;
  Color get cardBorderColor => textColor.withValues(alpha: 0.18);
  Color get menuSurfaceColor => backgroundColor;
  Color get controlSurfaceColor =>
      Color.lerp(backgroundColor, textColor, 0.10)!;
  Color get controlBorderColor => textColor.withValues(alpha: 0.18);
  Color get secondaryTextColor => textColor.withValues(alpha: 0.72);
  Color get mutedTextColor => textColor.withValues(alpha: 0.52);
  Color get buttonSurfaceColor => const Color(0xFF4A5568);
  Color get buttonBorderColor => Colors.white.withValues(alpha: 0.92);
  Color get buttonTextColor => Colors.white;

  ButtonStyle get iconButtonStyle => IconButton.styleFrom(
        backgroundColor: buttonSurfaceColor,
        foregroundColor: buttonTextColor,
        disabledBackgroundColor: const Color(0xFF2D3748),
        disabledForegroundColor: Colors.white.withValues(alpha: 0.38),
        side: BorderSide(color: buttonBorderColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      );

  AppTrack? get activeTrack => activeTrackId == null
      ? null
      : kTracks.firstWhere((track) => track.id == activeTrackId);
  List<Topic> get activeTopics => activeTrack?.topics ?? kTracks.first.topics;
  Topic get activeTopic =>
      activeTopics.firstWhere((t) => t.id == activeTopicId);

  @override
  void initState() {
    super.initState();
    _configureReader();
    _loadPrefs();
  }

  @override
  void dispose() {
    TextReaderService.stop();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _configureReader() => TextReaderService.configure();

  void _clearSpeakingPoint() {
    if (!mounted) return;
    setState(() {
      speakingPointId = null;
      speakingSectionKey = null;
    });
  }

  String _sectionReaderKey(LevelSection section) =>
      '${activeTopic.id}:${section.level}:${section.title}';

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fontStepIndex = prefs.getInt('fontStepIndex') ?? fontStepIndex;
      windowOpacity = prefs.getDouble('windowOpacity') ?? windowOpacity;
      textColorValue = prefs.getInt('textColorValue') ?? textColorValue;
      backgroundColorValue =
          prefs.getInt('backgroundColorValue') ?? backgroundColorValue;
      cardColorValue = prefs.getInt('cardColorValue') ?? cardColorValue;
      headerColorValue = prefs.getInt('headerColorValue') ?? headerColorValue;
      footerColorValue = prefs.getInt('footerColorValue') ?? footerColorValue;
      favorites
        ..clear()
        ..addAll(prefs.getStringList('favorites') ?? const []);
      final confidenceRows = prefs.getStringList('confidence') ?? const [];
      confidence.clear();
      for (final row in confidenceRows) {
        final parts = row.split('|');
        if (parts.length == 2) {
          confidence[parts[0]] = int.tryParse(parts[1]) ?? 0;
        }
      }
      final noteRows = prefs.getStringList('notes') ?? const [];
      notes.clear();
      for (final row in noteRows) {
        final splitAt = row.indexOf('|');
        if (splitAt > 0) {
          notes[row.substring(0, splitAt)] =
              Uri.decodeComponent(row.substring(splitAt + 1));
        }
      }
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('fontStepIndex', fontStepIndex);
    await prefs.setDouble('windowOpacity', windowOpacity);
    await prefs.setInt('textColorValue', textColorValue);
    await prefs.setInt('backgroundColorValue', backgroundColorValue);
    await prefs.setInt('cardColorValue', cardColorValue);
    await prefs.setInt('headerColorValue', headerColorValue);
    await prefs.setInt('footerColorValue', footerColorValue);
    await prefs.setStringList('favorites', favorites.toList());
    await prefs.setStringList('confidence',
        confidence.entries.map((e) => '${e.key}|${e.value}').toList());
  }

  List<_VisiblePoint> get _allVisiblePoints {
    final rows = <_VisiblePoint>[];
    for (final topic in activeTopics) {
      for (final section in topic.sections) {
        for (var i = 0; i < section.points.length; i++) {
          rows.add(_VisiblePoint(
              topic: topic,
              section: section,
              point: section.points[i],
              index: i));
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
        final haystack =
            '${row.topic.label} ${row.section.title} ${row.point.question} ${row.point.explanation} ${row.point.code}'
                .toLowerCase();
        return haystack.contains(query);
      }).toList();
    }
    final rows = <_VisiblePoint>[];
    for (final section in activeTopic.sections) {
      for (var i = 0; i < section.points.length; i++) {
        rows.add(_VisiblePoint(
            topic: activeTopic,
            section: section,
            point: section.points[i],
            index: i));
      }
    }
    return rows;
  }

  void _selectTopic(String id) {
    readerRunId++;
    TextReaderService.stop();
    setState(() {
      activeTopicId = id;
      expandedIndex = null;
      interviewMode = false;
      speakingPointId = null;
      speakingSectionKey = null;
      searchQuery = '';
      searchController.clear();
    });
  }

  void _selectTrack(AppTrack track) {
    readerRunId++;
    TextReaderService.stop();
    setState(() {
      activeTrackId = track.id;
      activeTopicId = track.topics.first.id;
      expandedIndex = null;
      interviewMode = false;
      readingMode = false;
      speakingPointId = null;
      speakingSectionKey = null;
      searchQuery = '';
      searchController.clear();
    });
  }

  void _showTrackMenu() {
    readerRunId++;
    TextReaderService.stop();
    setState(() {
      activeTrackId = null;
      expandedIndex = null;
      interviewMode = false;
      readingMode = false;
      speakingPointId = null;
      speakingSectionKey = null;
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

  void _changeBackgroundColor(int value) {
    setState(() => backgroundColorValue = value);
    _savePrefs();
  }

  void _changeCardColor(int value) {
    setState(() => cardColorValue = value);
    _savePrefs();
  }

  void _changeHeaderColor(int value) {
    setState(() => headerColorValue = value);
    _savePrefs();
  }

  void _changeFooterColor(int value) {
    setState(() => footerColorValue = value);
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

  Future<void> _toggleReadAloud(_VisiblePoint row) async {
    if (speakingPointId == row.id && speakingSectionKey == null) {
      await _stopReading();
      return;
    }

    await TextReaderService.stop();
    if (!mounted || !TextReaderService.isSupported) return;
    final runId = ++readerRunId;
    setState(() {
      speakingPointId = row.id;
      speakingSectionKey = null;
    });
    final result = await TextReaderService.speak(_readerText(row));
    if (mounted && runId == readerRunId && result != 1) _clearSpeakingPoint();
    if (mounted && runId == readerRunId) _clearSpeakingPoint();
  }

  Future<void> _readSection(LevelSection section) async {
    final sectionKey = _sectionReaderKey(section);
    if (speakingSectionKey == sectionKey) {
      await _stopReading();
      return;
    }

    await TextReaderService.stop();
    if (!mounted || !TextReaderService.isSupported) return;
    final runId = ++readerRunId;
    final rows = _currentPoints.asMap().entries.where((entry) {
      final row = entry.value;
      return row.topic.id == activeTopic.id &&
          row.section.level == section.level &&
          row.section.title == section.title;
    }).toList();

    for (final entry in rows) {
      if (!mounted || runId != readerRunId) return;
      final row = entry.value;
      setState(() {
        expandedIndex = entry.key;
        speakingPointId = row.id;
        speakingSectionKey = sectionKey;
      });
      final result = await TextReaderService.speak(_readerText(row));
      if (!mounted || runId != readerRunId || result != 1) return;
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }

    if (mounted && runId == readerRunId) _clearSpeakingPoint();
  }

  Future<void> _stopReading() async {
    readerRunId++;
    await TextReaderService.stop();
    _clearSpeakingPoint();
  }

  String _answerText(ConceptPoint point) {
    switch (answerMode) {
      case AnswerMode.shortAnswer:
        return point.shortAnswer ?? point.explanation;
      case AnswerMode.detailedAnswer:
        return point.detailedAnswer ?? point.explanation;
      case AnswerMode.interviewAnswer:
        return point.interviewAnswer ?? point.explanation;
    }
  }

  String _answerModeTitle() {
    switch (answerMode) {
      case AnswerMode.shortAnswer:
        return 'Short answer';
      case AnswerMode.detailedAnswer:
        return 'Detailed answer';
      case AnswerMode.interviewAnswer:
        return 'Interview answer';
    }
  }

  void _setNote(String id, String value) {
    notes[id] = value;
    _savePrefs();
  }

  String _readerText(_VisiblePoint row) {
    final point = row.point;
    final buffer = StringBuffer()
      ..write(point.question)
      ..write('. ')
      ..write(_answerText(point));

    if (point.code.isNotEmpty && activeTrackId == 'flutter') {
      buffer
        ..write(' A simple way to say it in an interview is: ')
        ..write(_speechFriendlyCode(point.code));
    }

    return buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _speechFriendlyCode(String value) {
    return value
        .replaceAll('=>', ' returns ')
        .replaceAll('->', ' to ')
        .replaceAll('&&', ' and ')
        .replaceAll('||', ' or ')
        .replaceAll('&', ' and ')
        .replaceAll(RegExp(r'[`{}<>()[\];]'), ' ')
        .replaceAll(RegExp(r'[_=:+*/\\]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  void _startInterviewMode() {
    final points = _allVisiblePoints;
    if (points.isEmpty) return;
    readerRunId++;
    TextReaderService.stop();
    setState(() {
      interviewMode = true;
      readingMode = true;
      showInterviewAnswer = false;
      speakingPointId = null;
      speakingSectionKey = null;
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
    if (activeTrackId == null) return _buildTrackMenu();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width >= 1100;
        final isTablet = width >= 720 && width < 1100;

        return Scaffold(
          backgroundColor: stickerMode
              ? backgroundColor.withValues(alpha: 0.67)
              : backgroundColor,
          drawer: isDesktop || readingMode
              ? null
              : _TopicDrawer(
                  topics: activeTopics,
                  activeTopicId: activeTopicId,
                  onSelect: (id) {
                    Navigator.of(context).maybePop();
                    _selectTopic(id);
                  },
                  fs: fs,
                  menuTextColor: textColor,
                  menuSecondaryTextColor: secondaryTextColor,
                  menuSurfaceColor: menuSurfaceColor),
          appBar: isDesktop || readingMode
              ? null
              : AppBar(
                  backgroundColor: menuSurfaceColor,
                  elevation: 0,
                  titleSpacing: 0,
                  title: Text('Flutter Interview Prep',
                      style: TextStyle(
                          fontSize: fs(18), fontWeight: FontWeight.w700)),
                  actions: [
                    _buildTopControls(compact: true),
                    const SizedBox(width: 8)
                  ],
                ),
          body: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isDesktop && !readingMode)
                  _DesktopSidebar(
                      topics: activeTopics,
                      activeTopicId: activeTopicId,
                      onSelect: _selectTopic,
                      fs: fs,
                      menuTextColor: textColor,
                      menuSecondaryTextColor: secondaryTextColor,
                      menuSurfaceColor: menuSurfaceColor),
                Expanded(
                  child: SelectionArea(
                    child: CustomScrollView(
                      slivers: [
                        if (!readingMode)
                          SliverToBoxAdapter(
                              child: _buildTopHeader(
                                  showTopicScroller: !isDesktop,
                                  compact: !isDesktop,
                                  maxContentWidth: _maxContentWidth(width))),
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  readingMode ? 12 : (isTablet ? 24 : 16),
                              vertical: readingMode ? 12 : 18),
                          sliver: SliverToBoxAdapter(
                            child: Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxWidth: readingMode
                                        ? 820
                                        : _maxContentWidth(width)),
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
          floatingActionButton: readingMode
              ? _readingModeFab()
              : (isDesktop ? _floatingTopControls() : null),
        );
      },
    );
  }

  Widget _buildTrackMenu() {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Interview Prep Tracks',
                      style: TextStyle(
                          fontSize: fs(30),
                          fontWeight: FontWeight.bold,
                          color: textColor)),
                  const SizedBox(height: 8),
                  Text('Choose what you want to study today.',
                      style: TextStyle(
                          fontSize: fs(15),
                          color: secondaryTextColor,
                          height: 1.45)),
                  const SizedBox(height: 22),
                  LayoutBuilder(builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 720;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: kTracks
                          .map((track) => SizedBox(
                                width: isWide
                                    ? (constraints.maxWidth - 16) / 2
                                    : constraints.maxWidth,
                                child: _trackChoiceCard(track),
                              ))
                          .toList(),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _trackChoiceCard(AppTrack track) {
    final color = Color(track.colorValue);
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _selectTrack(track),
        child: Container(
          constraints: const BoxConstraints(minHeight: 190),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: buttonBorderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.72)),
                ),
                child: Center(
                  child: Text(track.icon,
                      style: TextStyle(
                          color: textColor,
                          fontSize: fs(16),
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              Text(track.label,
                  style: TextStyle(
                      color: textColor,
                      fontSize: fs(22),
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(track.description,
                  style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: fs(14),
                      height: 1.45)),
              const SizedBox(height: 14),
              Text('${track.topics.length} categories',
                  style: TextStyle(
                      color: mutedTextColor,
                      fontSize: fs(12.5),
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  double _maxContentWidth(double width) {
    if (width >= 1400) return 1080;
    if (width >= 900) return 940;
    return double.infinity;
  }

  Widget _buildTopHeader(
      {required bool showTopicScroller,
      required bool compact,
      required double maxContentWidth}) {
    return Container(
      decoration: BoxDecoration(
        color: headerColor,
        border: Border(bottom: BorderSide(color: controlBorderColor)),
      ),
      padding:
          EdgeInsets.fromLTRB(compact ? 16 : 28, 20, compact ? 16 : 28, 16),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('🎯', style: TextStyle(fontSize: fs(compact ? 24 : 30))),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(compact ? activeTrack!.label : ' Interview Prep',
                      style: TextStyle(
                          fontSize: fs(compact ? 20 : 26),
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          letterSpacing: -0.4))),
              if (!compact) _buildTopControls(),
            ]),
            const SizedBox(height: 8),
            Text(activeTrack!.description,
                style: TextStyle(
                    fontSize: fs(14), color: secondaryTextColor, height: 1.45)),
            const SizedBox(height: 14),
            _buildSearchAndActions(compact: compact),
            const SizedBox(height: 12),
            Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
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
            onChanged: (value) => setState(() {
              searchQuery = value;
              expandedIndex = null;
              interviewMode = false;
            }),
            decoration: InputDecoration(
              hintText: 'Search: RenderObject, Future.wait, Firebase...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isEmpty
                  ? null
                  : IconButton(
                      style: iconButtonStyle,
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() {
                            searchController.clear();
                            searchQuery = '';
                          })),
              filled: true,
              fillColor: const Color(0xFF1A202C),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2D3748))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2D3748))),
            ),
          ),
        ),
        _actionChip(
            icon: Icons.apps,
            label: 'Tracks',
            selected: false,
            onTap: _showTrackMenu),
        _buildAnswerModeFilter(),
        _actionChip(
            icon: Icons.menu_book,
            label: readingMode ? 'Exit Reading' : 'Reading',
            selected: readingMode,
            onTap: () => setState(() => readingMode = !readingMode)),
        _actionChip(
            icon: Icons.mic,
            label: 'CEO Mode',
            selected: interviewMode,
            onTap: _startInterviewMode),
      ],
    );
  }

  Widget _buildAnswerModeFilter() {
    return Wrap(spacing: 6, runSpacing: 6, children: [
      _answerModeChip(AnswerMode.shortAnswer, 'Short'),
      _answerModeChip(AnswerMode.detailedAnswer, 'Detailed'),
      _answerModeChip(AnswerMode.interviewAnswer, 'Interview'),
    ]);
  }

  Widget _answerModeChip(AnswerMode mode, String label) {
    return _actionChip(
        icon: answerMode == mode ? Icons.check : Icons.notes,
        label: label,
        selected: answerMode == mode,
        onTap: () => setState(() => answerMode = mode));
  }

  Widget _buildTopControls({bool compact = false}) {
    return Container(
      margin: EdgeInsets.only(left: compact ? 0 : 8),
      decoration: BoxDecoration(
          color: buttonSurfaceColor,
          border: Border.all(color: buttonBorderColor),
          borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.all(3),
      child: Wrap(
          spacing: 2,
          runSpacing: 2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _fontButton('−', fontStepIndex == 0, _decreaseFont),
            SizedBox(
                width: compact ? 30 : 42,
                child: Text('${(scale * 100).round()}%',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: compact ? 10 : 11,
                        color: secondaryTextColor,
                        fontWeight: FontWeight.w700))),
            _fontButton(
                '+', fontStepIndex == kFontSteps.length - 1, _increaseFont),
            _backgroundColorButton(),
            _cardColorButton(),
            _headerColorButton(),
            _footerColorButton(),
            if (WindowTransparencyService.isSupported) ...[
              _stickerButton(),
              _textColorButton()
            ],
          ]),
    );
  }

  Widget _stickerButton() {
    return Tooltip(
      message: stickerMode
          ? 'Turn off sticker mode'
          : 'Turn on sticker transparency',
      child: Material(
        color: buttonSurfaceColor,
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
            onTap: _toggleStickerMode,
            borderRadius: BorderRadius.circular(7),
            child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    border: Border.all(color: buttonBorderColor),
                    borderRadius: BorderRadius.circular(7)),
                child: Icon(Icons.push_pin,
                    size: 17,
                    color: stickerMode
                        ? const Color(0xFFF6E05E)
                        : buttonTextColor))),
      ),
    );
  }

  Widget _backgroundColorButton() {
    return _colorMenuButton(
      tooltip: 'Background color',
      icon: Icons.format_color_fill,
      selectedValue: backgroundColorValue,
      options: kBackgroundColorOptions,
      onSelected: _changeBackgroundColor,
    );
  }

  Widget _cardColorButton() {
    return _colorMenuButton(
      tooltip: 'Card background color',
      icon: Icons.dashboard_customize_outlined,
      selectedValue: cardColorValue,
      options: kCardColorOptions,
      onSelected: _changeCardColor,
    );
  }

  Widget _headerColorButton() {
    return _colorMenuButton(
      tooltip: 'Header background color',
      icon: Icons.web_asset_outlined,
      selectedValue: headerColorValue,
      options: kSectionColorOptions,
      onSelected: _changeHeaderColor,
    );
  }

  Widget _footerColorButton() {
    return _colorMenuButton(
      tooltip: 'Footer background color',
      icon: Icons.vertical_align_bottom_outlined,
      selectedValue: footerColorValue,
      options: kSectionColorOptions,
      onSelected: _changeFooterColor,
    );
  }

  Widget _textColorButton() {
    return _colorMenuButton(
      tooltip: 'Text color',
      icon: Icons.format_color_text,
      selectedValue: textColorValue,
      options: kTextColorOptions,
      onSelected: _changeTextColor,
    );
  }

  Widget _colorMenuButton({
    required String tooltip,
    required IconData icon,
    required int selectedValue,
    required List<int> options,
    required ValueChanged<int> onSelected,
  }) {
    final selectedColor = Color(selectedValue);
    return PopupMenuButton<int>(
      tooltip: tooltip,
      onSelected: onSelected,
      color: controlSurfaceColor,
      itemBuilder: (context) => [
        for (final value in options)
          PopupMenuItem<int>(
            value: value,
            child: Row(children: [
              Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                      color: Color(value),
                      shape: BoxShape.circle,
                      border: Border.all(color: buttonBorderColor))),
              const SizedBox(width: 10),
              Text(_textColorLabel(value),
                  style:
                      TextStyle(color: textColor, fontWeight: FontWeight.w600)),
              const Spacer(),
              if (selectedValue == value)
                Icon(Icons.check, size: 18, color: textColor),
            ]),
          ),
      ],
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
            color: buttonSurfaceColor,
            border: Border.all(color: buttonBorderColor),
            borderRadius: BorderRadius.circular(7)),
        child: Stack(alignment: Alignment.center, children: [
          Icon(icon, size: 17, color: selectedColor),
          Positioned(
              bottom: 5,
              child: Container(
                  width: 16,
                  height: 3,
                  decoration: BoxDecoration(
                      color: selectedColor,
                      borderRadius: BorderRadius.circular(999)))),
        ]),
      ),
    );
  }

  Widget _buildStickerPanel({required bool compact}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
          color:
              stickerMode ? const Color(0x22148A5D) : const Color(0xFF141A26),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: stickerMode
                  ? const Color(0xFF38A169)
                  : const Color(0xFF2D3748))),
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.push_pin, size: 18, color: Color(0xFFCBD5E0)),
          const SizedBox(width: 8),
          Expanded(
              child: Text('Desktop Sticker Mode',
                  style: TextStyle(
                      fontSize: fs(14),
                      fontWeight: FontWeight.w800,
                      color: textColor))),
          Switch(value: stickerMode, onChanged: (_) => _toggleStickerMode()),
        ]),
        if (stickerMode) ...[
          Text('Opacity ${(windowOpacity * 100).round()}%',
              style: TextStyle(fontSize: fs(12.5), color: secondaryTextColor)),
          Slider(
              value: windowOpacity,
              min: 0.2,
              max: 1.0,
              divisions: 16,
              label: '${(windowOpacity * 100).round()}%',
              onChanged: _changeWindowOpacity),
          Wrap(spacing: 12, runSpacing: 6, children: [
            _checkControl('Always on top', alwaysOnTop, (v) async {
              setState(() => alwaysOnTop = v);
              await WindowTransparencyService.setAlwaysOnTop(v);
            }),
            _checkControl('Hide title bar', hideTitleBar, (v) async {
              setState(() => hideTitleBar = v);
              await WindowTransparencyService.setTitleBarHidden(v);
            }),
            Tooltip(
              message:
                  'Click-through needs a global shortcut or tray menu to disable safely. The UI is prepared, but native click-through is intentionally disabled in this safe build.',
              child: FilterChip(
                selected: false,
                label: const Text('Click through planned'),
                onSelected: null,
                backgroundColor: buttonSurfaceColor,
                disabledColor: buttonSurfaceColor,
                side: BorderSide(color: buttonBorderColor),
                labelStyle: TextStyle(
                    color: buttonTextColor.withValues(alpha: 0.62),
                    fontWeight: FontWeight.w600),
              ),
            ),
          ]),
          const SizedBox(height: 6),
          Text(
              'Plugin: window_manager. It controls opacity, always-on-top, title bar style, and click-through on supported desktop platforms. Mobile/web keep a safe fallback.',
              style: TextStyle(
                  fontSize: fs(12.3), color: secondaryTextColor, height: 1.45)),
        ],
      ]),
    );
  }

  Widget _checkControl(String label, bool value, ValueChanged<bool> onChanged) {
    return FilterChip(
      selected: value,
      label: Text(label),
      onSelected: onChanged,
      selectedColor: buttonSurfaceColor,
      backgroundColor: buttonSurfaceColor,
      checkmarkColor: buttonTextColor,
      side: BorderSide(color: buttonBorderColor),
      labelStyle:
          TextStyle(color: buttonTextColor, fontWeight: FontWeight.w600),
    );
  }

  Widget _actionChip(
      {required IconData icon,
      required String label,
      required bool selected,
      required VoidCallback onTap}) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: buttonTextColor),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: buttonSurfaceColor,
      labelStyle: TextStyle(
          color: buttonTextColor,
          fontSize: fs(13),
          fontWeight: FontWeight.w700),
      side: BorderSide(color: buttonBorderColor),
    );
  }

  Widget _fontButton(String label, bool disabled, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(7),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: buttonSurfaceColor,
            border: Border.all(color: buttonBorderColor),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: disabled
                    ? Colors.white.withValues(alpha: 0.38)
                    : buttonTextColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String text) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            color: const Color(0xFF1A202C),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFF2D3748))),
        child: Text(text,
            style: TextStyle(
                fontSize: fs(12.5),
                color: textColor,
                fontWeight: FontWeight.w600)));
  }

  Widget _buildTopicScroller() {
    return SizedBox(
      height: 46,
      child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: activeTopics.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final topic = activeTopics[index];
            return _TopicPill(
                topic: topic,
                isActive: topic.id == activeTopicId,
                onTap: () => _selectTopic(topic.id),
                fs: fs);
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
        Wrap(
            spacing: 14,
            runSpacing: 14,
            children: rows
                .asMap()
                .entries
                .map((entry) => SizedBox(
                    width: 516, child: _buildPointCard(entry.value, entry.key)))
                .toList())
      else
        ...rows.asMap().entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildPointCard(entry.value, entry.key))),
      if (!readingMode) ...[const SizedBox(height: 18), _buildFooterTip()],
    ]);
  }

  Widget _buildSectionHeader() {
    final color = Color(activeTopic.colorValue);
    final title = searchQuery.isNotEmpty ? 'Search Results' : activeTopic.label;
    final totalCards = activeTopic.sections
        .fold<int>(0, (sum, section) => sum + section.points.length);
    final subtitle = searchQuery.isNotEmpty
        ? 'Across all topics'
        : 'All $totalCards interview cards in one list';
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [color.withOpacity(0.16), color.withOpacity(0.04)]),
          border: Border.all(color: color.withOpacity(0.32)),
          borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(searchQuery.isNotEmpty ? '🔎' : activeTopic.icon,
            style: TextStyle(fontSize: fs(30))),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: TextStyle(
                  fontSize: fs(21),
                  fontWeight: FontWeight.bold,
                  color: textColor)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: TextStyle(fontSize: fs(13.5), color: secondaryTextColor)),
          if (searchQuery.isEmpty && !interviewMode) ...[
            const SizedBox(height: 12),
            _buildSectionReadControls(),
          ],
        ])),
      ]),
    );
  }

  Widget _buildSectionReadControls() {
    if (!TextReaderService.isSupported) {
      return Text('Read section is available on desktop builds.',
          style: TextStyle(fontSize: fs(12.5), color: mutedTextColor));
    }

    return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: activeTopic.sections.map((section) {
          final sectionKey = _sectionReaderKey(section);
          final selected = speakingSectionKey == sectionKey;
          return _actionChip(
              icon: selected ? Icons.stop : Icons.play_arrow,
              label:
                  selected ? 'Stop ${section.title}' : 'Read ${section.title}',
              selected: selected,
              onTap: () {
                _readSection(section);
              });
        }).toList());
  }

  Widget _buildInterviewBar() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFF1A202C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF805AD5))),
      child: Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('🎤 CEO Mode',
                style: TextStyle(
                    fontSize: fs(14),
                    fontWeight: FontWeight.bold,
                    color: textColor)),
            _actionChip(
                icon: showInterviewAnswer
                    ? Icons.visibility_off
                    : Icons.visibility,
                label: showInterviewAnswer ? 'Hide answer' : 'Reveal answer',
                selected: showInterviewAnswer,
                onTap: () =>
                    setState(() => showInterviewAnswer = !showInterviewAnswer)),
            _actionChip(
                icon: Icons.shuffle,
                label: 'Next question',
                selected: false,
                onTap: _nextInterviewQuestion),
            _actionChip(
                icon: Icons.close,
                label: 'Exit',
                selected: false,
                onTap: () => setState(() {
                      interviewMode = false;
                      readingMode = false;
                      interviewPoint = null;
                    })),
          ]),
    );
  }

  Widget _emptyState() {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cardBorderColor)),
        child: Text('No cards found. Try another search term.',
            style: TextStyle(fontSize: fs(15), color: secondaryTextColor)));
  }

  Widget _buildPointCard(_VisiblePoint row, int displayIndex) {
    final topicColor = Color(row.topic.colorValue);
    final isOpen = expandedIndex == displayIndex || readingMode;
    final isFav = favorites.contains(row.id);
    final isSpeaking = speakingPointId == row.id;
    final conf = confidence[row.id] ?? 0;
    final shouldShowAnswer = !interviewMode || showInterviewAnswer;
    return Container(
      decoration: BoxDecoration(
          color: cardColor,
          border: Border.all(
              color: isOpen ? topicColor.withOpacity(0.48) : cardBorderColor),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            if (isOpen)
              BoxShadow(
                  color: topicColor.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8))
          ]),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Material(
            color: Colors.transparent,
            child: InkWell(
                onTap: readingMode
                    ? null
                    : () => setState(
                        () => expandedIndex = isOpen ? null : displayIndex),
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                  color: topicColor.withOpacity(0.2),
                                  shape: BoxShape.circle),
                              child: Center(
                                  child: Text('${displayIndex + 1}',
                                      style: TextStyle(
                                          fontSize: fs(13),
                                          fontWeight: FontWeight.bold,
                                          color: topicColor)))),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                if (searchQuery.isNotEmpty || interviewMode)
                                  Text(
                                      '${row.topic.icon} ${row.topic.label} • ${row.section.title}',
                                      style: TextStyle(
                                          fontSize: fs(11.5),
                                          color: secondaryTextColor,
                                          fontWeight: FontWeight.w700)),
                                Text(row.point.question,
                                    style: TextStyle(
                                        fontSize: fs(readingMode ? 20 : 16),
                                        fontWeight: FontWeight.w700,
                                        color: textColor,
                                        height: 1.35)),
                              ])),
                          IconButton(
                              style: iconButtonStyle,
                              tooltip: 'Favorite',
                              icon: Icon(isFav ? Icons.star : Icons.star_border,
                                  color: isFav
                                      ? const Color(0xFFF6E05E)
                                      : const Color(0xFF718096)),
                              onPressed: () => _toggleFavorite(row.id)),
                          IconButton(
                              style: iconButtonStyle,
                              tooltip: isSpeaking
                                  ? 'Stop reading'
                                  : 'Read naturally',
                              icon: Icon(
                                  isSpeaking
                                      ? Icons.stop_circle_outlined
                                      : Icons.record_voice_over_outlined,
                                  color: isSpeaking
                                      ? const Color(0xFF38A169)
                                      : const Color(0xFF718096)),
                              onPressed: () {
                                _toggleReadAloud(row);
                              }),
                          if (!readingMode)
                            Icon(
                                isOpen
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: const Color(0xFF718096)),
                        ])))),
        AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: shouldShowAnswer
                ? _buildExpandedContent(row, conf)
                : _hiddenAnswer(),
            crossFadeState:
                isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
            sizeCurve: Curves.easeOut),
      ]),
    );
  }

  Widget _hiddenAnswer() {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: cardSectionColor,
            border: Border(top: BorderSide(color: cardBorderColor))),
        child: Text(
            'Answer hidden. Say your answer first, then press Reveal answer.',
            style: TextStyle(
                fontSize: fs(15), color: secondaryTextColor, height: 1.5)));
  }

  Widget _buildExpandedContent(_VisiblePoint row, int conf) {
    final point = row.point;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          width: double.infinity,
          decoration: BoxDecoration(
              color: cardSectionColor,
              border: Border(top: BorderSide(color: cardBorderColor))),
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _sectionLabel('READ ALOUD'),
            const SizedBox(height: 8),
            _readAloudRow(row),
            const SizedBox(height: 14),
            _sectionLabel(_answerModeTitle().toUpperCase()),
            const SizedBox(height: 8),
            Text(_answerText(point),
                style: TextStyle(
                    fontSize: fs(readingMode ? 17 : 15),
                    color: textColor,
                    height: 1.65)),
            const SizedBox(height: 12),
            _confidenceBar(row.id, conf),
            const SizedBox(height: 14),
            _sectionLabel('NOTES'),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: notes[row.id] ?? '',
              minLines: 2,
              maxLines: 4,
              onChanged: (value) => _setNote(row.id, value),
              style: TextStyle(color: textColor, fontSize: fs(13.5)),
              decoration: InputDecoration(
                hintText: 'Add your own example or reminder...',
                hintStyle: TextStyle(color: mutedTextColor),
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: cardBorderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: cardBorderColor),
                ),
              ),
            ),
          ])),
      if (point.code.isNotEmpty && activeTrackId == 'flutter')
        Container(
            width: double.infinity,
            decoration: BoxDecoration(
                color: cardCodeColor,
                border: Border(top: BorderSide(color: cardBorderColor))),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _sectionLabel('INTERVIEW PHRASE / CODE'),
              const SizedBox(height: 10),
              Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SelectableText(point.code,
                          style: TextStyle(
                              fontSize: fs(readingMode ? 15 : 13.5),
                              height: 1.65,
                              color: textColor,
                              fontFamily: 'monospace')))),
            ])),
    ]);
  }

  Widget _readAloudRow(_VisiblePoint row) {
    final isSpeaking = speakingPointId == row.id;
    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: Color.lerp(cardSectionColor, textColor, 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: controlBorderColor)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(children: [
          Icon(Icons.record_voice_over_outlined,
              size: 20,
              color: isSpeaking ? const Color(0xFF38A169) : secondaryTextColor),
          const SizedBox(width: 10),
          Expanded(
              child: Text(
                  isSpeaking
                      ? 'Reading this answer in a slower natural voice.'
                      : TextReaderService.isSupported
                          ? 'Read this answer aloud in a slower natural voice.'
                          : 'Read aloud is available on desktop builds.',
                  style: TextStyle(
                      fontSize: fs(13.5),
                      color: secondaryTextColor,
                      height: 1.35))),
          TextButton.icon(
              onPressed: () {
                _toggleReadAloud(row);
              },
              icon: Icon(isSpeaking ? Icons.stop : Icons.play_arrow, size: 18),
              label: Text(isSpeaking ? 'Stop' : 'Read'),
              style: TextButton.styleFrom(
                  backgroundColor: buttonSurfaceColor,
                  foregroundColor: buttonTextColor,
                  side: BorderSide(color: buttonBorderColor),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7))))
        ]));
  }

  Widget _confidenceBar(String id, int conf) {
    return Wrap(
        spacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('My confidence:',
              style: TextStyle(
                  fontSize: fs(12.5),
                  color: secondaryTextColor,
                  fontWeight: FontWeight.w700)),
          for (var i = 1; i <= 5; i++)
            IconButton(
                style: iconButtonStyle,
                visualDensity: VisualDensity.compact,
                iconSize: 19,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                onPressed: () => _setConfidence(id, i),
                icon: Icon(i <= conf ? Icons.star : Icons.star_border,
                    color: i <= conf
                        ? const Color(0xFFF6E05E)
                        : const Color(0xFF718096))),
        ]);
  }

  Widget _sectionLabel(String text) => Text(text,
      style: TextStyle(
          fontSize: fs(11),
          fontWeight: FontWeight.bold,
          color: secondaryTextColor,
          letterSpacing: 1));

  Widget _buildFooterTip() {
    return Container(
        decoration: BoxDecoration(
            color: footerColor,
            border: Border.all(color: controlBorderColor),
            borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.all(14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('💡'),
          const SizedBox(width: 10),
          Expanded(
              child: Text(
                  'Use the 6-step interview formula: what it is, why it exists, how it works, where you used it, trade-offs, and limitations. Keep your answers honest and connect them to 4iCAD, ASD, Phillips, or Toyota when relevant.',
                  style: TextStyle(
                      fontSize: fs(13.5),
                      color: secondaryTextColor,
                      height: 1.45))),
        ]));
  }

  Widget _floatingTopControls() {
    return Material(
      color: Colors.transparent,
      child: _buildTopControls(compact: true),
    );
  }

  Widget _readingModeFab() {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildTopControls(compact: true),
          const SizedBox(height: 8),
          FloatingActionButton.small(
              backgroundColor: buttonSurfaceColor,
              foregroundColor: buttonTextColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: buttonBorderColor)),
              heroTag: 'reading_exit',
              tooltip: 'Exit reading mode',
              onPressed: () => setState(() {
                    readingMode = false;
                    if (interviewMode) interviewMode = false;
                  }),
              child: const Icon(Icons.close)),
        ]);
  }
}

class _DesktopSidebar extends StatelessWidget {
  final List<Topic> topics;
  final String activeTopicId;
  final ValueChanged<String> onSelect;
  final double Function(double) fs;
  final Color menuTextColor;
  final Color menuSecondaryTextColor;
  final Color menuSurfaceColor;

  const _DesktopSidebar({
    required this.topics,
    required this.activeTopicId,
    required this.onSelect,
    required this.fs,
    required this.menuTextColor,
    required this.menuSecondaryTextColor,
    required this.menuSurfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 292,
      decoration: BoxDecoration(
        color: menuSurfaceColor,
        border: Border(
            right: BorderSide(
                color: menuSecondaryTextColor.withValues(alpha: 0.24))),
      ),
      child: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Interview Prep',
                  style: TextStyle(
                      fontSize: fs(20),
                      fontWeight: FontWeight.bold,
                      color: menuTextColor)),
              const SizedBox(height: 4),
              Text('Topic map',
                  style: TextStyle(
                      fontSize: fs(12.5), color: menuSecondaryTextColor)),
            ]),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 14),
              itemCount: topics.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final topic = topics[index];
                return _TopicTile(
                  topic: topic,
                  isActive: topic.id == activeTopicId,
                  onTap: () => onSelect(topic.id),
                  fs: fs,
                  menuTextColor: menuTextColor,
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

class _TopicDrawer extends StatelessWidget {
  final List<Topic> topics;
  final String activeTopicId;
  final ValueChanged<String> onSelect;
  final double Function(double) fs;
  final Color menuTextColor;
  final Color menuSecondaryTextColor;
  final Color menuSurfaceColor;

  const _TopicDrawer({
    required this.topics,
    required this.activeTopicId,
    required this.onSelect,
    required this.fs,
    required this.menuTextColor,
    required this.menuSecondaryTextColor,
    required this.menuSurfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: menuSurfaceColor,
      child: SafeArea(
        child: ListView(padding: const EdgeInsets.all(12), children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
            child: Text('Topics',
                style: TextStyle(
                    fontSize: fs(22),
                    fontWeight: FontWeight.bold,
                    color: menuTextColor)),
          ),
          ...topics.map((topic) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _TopicTile(
                  topic: topic,
                  isActive: topic.id == activeTopicId,
                  onTap: () => onSelect(topic.id),
                  fs: fs,
                  menuTextColor: menuTextColor,
                ),
              )),
        ]),
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  final Topic topic;
  final bool isActive;
  final VoidCallback onTap;
  final double Function(double) fs;
  final Color menuTextColor;

  const _TopicTile({
    required this.topic,
    required this.isActive,
    required this.onTap,
    required this.fs,
    required this.menuTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(topic.colorValue);
    return Material(
      color: isActive ? color.withOpacity(0.18) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isActive ? color.withOpacity(0.7) : Colors.transparent),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(children: [
            Text(topic.icon, style: TextStyle(fontSize: fs(20))),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                topic.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: fs(14),
                    fontWeight: FontWeight.w700,
                    color: menuTextColor),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _TopicPill extends StatelessWidget {
  final Topic topic;
  final bool isActive;
  final VoidCallback onTap;
  final double Function(double) fs;

  const _TopicPill(
      {required this.topic,
      required this.isActive,
      required this.onTap,
      required this.fs});

  @override
  Widget build(BuildContext context) {
    final color = Color(topic.colorValue);
    return Material(
        color: isActive ? color : const Color(0xFF1A202C),
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onTap,
            child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                        color: isActive ? color : const Color(0xFF2D3748))),
                child: Text('${topic.icon} ${topic.label}',
                    style: TextStyle(
                        fontSize: fs(13.5),
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? Colors.white
                            : const Color(0xFFA0AEC0))))));
  }
}
