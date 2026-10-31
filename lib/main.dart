import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'game_engine.dart';
import 'game_scene.dart';
import 'game_audio.dart';
import 'player_progress.dart';
import 'app_info.dart';
import 'dino_avatar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final progress = PlayerProgress(backend: DeviceProgressBackend());
  await progress.load();
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks([
      'Little Dino — original project',
    ], await rootBundle.loadString('LICENSE'));
    yield LicenseEntryWithLineBreaks([
      'Roboto',
    ], await rootBundle.loadString('assets/fonts/roboto_license.txt'));
    yield LicenseEntryWithLineBreaks([
      'Noto Sans Symbols',
    ], await rootBundle.loadString('assets/fonts/OFL_NotoSansSymbols.txt'));
  });
  runApp(MyApp(progress: progress, audio: LocalGameAudio()));
}

const ink = Color(0xFF173C35);
const leaf = Color(0xFF276B4D);
const cream = Color(0xFFFFF9EC);

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.progress, this.audio});
  final PlayerProgress? progress;
  final GameAudio? audio;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Little Dino',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: cream,
      colorScheme: ColorScheme.fromSeed(seedColor: leaf),
      textTheme: ThemeData().textTheme.apply(
        bodyColor: ink,
        displayColor: ink,
        fontFamily: 'Roboto',
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: leaf,
          foregroundColor: Colors.white,
          minimumSize: const Size(64, 56),
          textStyle: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
      ),
    ),
    home: GameScreen(progress: progress, audio: audio),
  );
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, this.engine, this.progress, this.audio});
  final GameEngine? engine;
  final PlayerProgress? progress;
  final GameAudio? audio;
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final GameEngine game;
  late final Ticker _ticker;
  Duration? _previous;
  late final PlayerProgress progress;
  int _bankedStars = 0;
  RunState _lastState = RunState.menu;
  Difficulty get _difficulty => progress.difficulty;
  bool get _effects => progress.effects;

  @override
  void initState() {
    super.initState();
    game = widget.engine ?? GameEngine();
    progress = widget.progress ?? PlayerProgress();
    progress.addListener(_progressChanged);
    WidgetsBinding.instance.addObserver(this);
    _ticker = createTicker(_tick);
    game.addListener(_gameChanged);
  }

  void _tick(Duration elapsed) {
    final previous = _previous;
    _previous = elapsed;
    if (previous != null) {
      game.advance((elapsed - previous).inMicroseconds / 1000000);
    }
  }

  void _progressChanged() {
    if (mounted) setState(() {});
  }

  void _sound(String name) {
    if (progress.sound) unawaited(widget.audio?.play(name));
  }

  void _jump() {
    if (game.jump()) _sound('jump');
  }

  void _gameChanged() {
    final earned = game.runStars - _bankedStars;
    if (earned > 0) {
      _bankedStars = game.runStars;
      progress.addStars(earned);
      _sound('star');
    }
    if (game.state == RunState.paused || game.state == RunState.gameOver) {
      progress.record(game.difficulty, game.score);
    }
    if (game.state != _lastState) {
      if (game.state == RunState.paused || game.state == RunState.menu) {
        unawaited(widget.audio?.stop());
      }
      if (game.state == RunState.gameOver) _sound('finish');
      _lastState = game.state;
    }
    if (game.state == RunState.playing && !_ticker.isActive) {
      _previous = null;
      _ticker.start();
    } else if (game.state != RunState.playing && _ticker.isActive) {
      _ticker.stop();
      _previous = null;
    }
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      game.pause();
      unawaited(widget.audio?.stop());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    game.removeListener(_gameChanged);
    progress.removeListener(_progressChanged);
    if (widget.progress == null) progress.dispose();
    unawaited(widget.audio?.dispose());
    _ticker.dispose();
    if (widget.engine == null) game.dispose();
    super.dispose();
  }

  void _start() {
    _bankedStars = 0;
    game.start(_difficulty);
  }

  Future<void> _settings() async {
    game.pause();
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, updateDialog) => AlertDialog(
          title: const Text('Make it your adventure'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Difficulty changes apply to your next run.'),
                const SizedBox(height: 16),
                for (final option in Difficulty.values)
                  ListTile(
                    title: Text(option.label),
                    subtitle: Text(
                      option == Difficulty.easy
                          ? 'A gentle start with more space'
                          : 'A little faster, a little trickier',
                    ),
                    leading: Icon(
                      _difficulty == option
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                    ),
                    onTap: () {
                      progress.setDifficulty(option);
                      updateDialog(() {});
                    },
                  ),
                SwitchListTile(
                  title: const Text('Extra effects'),
                  subtitle: const Text('Rain and playful movement'),
                  value: _effects,
                  onChanged: (value) {
                    progress.setEffects(value);
                    updateDialog(() {});
                  },
                ),
                SwitchListTile(
                  title: const Text('Sound effects'),
                  value: progress.sound,
                  onChanged: (value) {
                    progress.setSound(value);
                    if (!value) unawaited(widget.audio?.stop());
                    updateDialog(() {});
                  },
                ),
                const Divider(),
                const Text(
                  'Your dinosaur colors',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                for (var i = 0; i < 3; i++)
                  ListTile(
                    title: Text(
                      ['Fern green', 'Sunshine gold', 'Berry purple'][i],
                    ),
                    subtitle: Text(
                      progress.unlocked(i)
                          ? 'Ready to wear'
                          : 'Collect ${PlayerProgress.colorCosts[i]} stars to unlock',
                    ),
                    leading: Icon(
                      progress.color == i
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                    ),
                    enabled: progress.unlocked(i),
                    onTap: () {
                      progress.setColor(i);
                      updateDialog(() {});
                    },
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _grownUps() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('For grown-ups'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Publisher: $publisherName',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Privacy & offline play',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(privacySummary),
              if (supportEmail != '') ...[
                SizedBox(height: 12),
                SelectableText('Support: $supportEmail'),
              ],
              if (privacyPolicyUrl != '') ...[
                SizedBox(height: 8),
                SelectableText('Public policy: $privacyPolicyUrl'),
              ],
              SizedBox(height: 12),
              Text('Designed for ages 6–8. Take breaks and play together.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => showLicensePage(
              context: context,
              applicationName: 'Little Dino',
              applicationLegalese: 'Publisher: $publisherName',
            ),
            child: const Text('Licenses'),
          ),
          TextButton(
            onPressed: () async {
              final reset = await showDialog<bool>(
                context: dialogContext,
                builder: (confirmationContext) => AlertDialog(
                  title: const Text('Erase local progress?'),
                  content: const Text(
                    'This resets all scores, stars, colors and settings on this device.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(confirmationContext, false),
                      child: const Text('Keep progress'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(confirmationContext, true),
                      child: const Text('Erase progress'),
                    ),
                  ],
                ),
              );
              if (reset == true && mounted) {
                progress.reset();
                _bankedStars = 0;
                game.home();
              }
            },
            child: const Text('Reset progress'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: game.state == RunState.menu,
    onPopInvokedWithResult: (didPop, _) {
      if (didPop) return;
      if (game.state == RunState.playing) {
        game.pause();
      } else {
        game.home();
      }
    },
    child: Scaffold(
      body: SafeArea(
        child: game.state == RunState.menu ? _menu() : _playfield(),
      ),
    ),
  );

  Widget _menu() => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'A LITTLE HOP. A BIG ADVENTURE.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 1.6,
                fontWeight: FontWeight.bold,
                color: leaf,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Little Dino',
              style: TextStyle(
                fontSize: 46,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: SizedBox(
                width: 170,
                height: 170,
                child: DinoAvatar(color: progress.color, effects: false),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Ready, little explorer?',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const _HowToJump(),
            const SizedBox(height: 12),
            Text(
              'Best ${progress.best(_difficulty)} · Stars ${progress.stars}',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            if (progress.storageError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  children: [
                    const Text(
                      'Progress could not be saved on this device. You can still play.',
                      textAlign: TextAlign.center,
                    ),
                    TextButton(
                      onPressed: progress.retrySave,
                      child: const Text('Try saving again'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _start,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text('Play · ${_difficulty.label}'),
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: _settings,
              icon: const Icon(Icons.tune_rounded),
              label: const Text('Settings', style: TextStyle(fontSize: 17)),
            ),
            const SizedBox(height: 10),
            const Text(
              'Offline fun. No ads. Just adventure.',
              textAlign: TextAlign.center,
              style: TextStyle(color: leaf),
            ),
            TextButton(
              onPressed: _grownUps,
              child: const Text('For grown-ups'),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _playfield() => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Score ${game.score}',
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Semantics(
              label: '${game.runStars} stars this run',
              child: Text(
                'Stars ${game.runStars}',
                style: const TextStyle(fontSize: 20, color: leaf),
              ),
            ),
            const SizedBox(width: 12),
            IconButton.filledTonal(
              tooltip: 'Pause game',
              onPressed: game.state == RunState.playing ? game.pause : null,
              icon: const Icon(Icons.pause_rounded),
              constraints: const BoxConstraints(minWidth: 52, minHeight: 52),
            ),
          ],
        ),
      ),
      Expanded(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Semantics(
              label:
                  'Dinosaur play area. Tap to jump; tap again to double jump.',
              button: true,
              onTap: _jump,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _jump,
                child: ExcludeSemantics(
                  child: GameScene(
                    game: game,
                    color: progress.color,
                    effects:
                        _effects && !MediaQuery.disableAnimationsOf(context),
                  ),
                ),
              ),
            ),
            if (game.state == RunState.paused ||
                game.state == RunState.gameOver)
              ColoredBox(
                color: ink.withValues(alpha: 0.3),
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: Card(
                        color: cream,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                game.state == RunState.paused
                                    ? Icons.coffee_rounded
                                    : Icons.emoji_events_rounded,
                                color: leaf,
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                game.state == RunState.paused
                                    ? 'Take a little break'
                                    : 'What an adventure!',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Score ${game.score} · ${game.runStars} stars',
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Best ${progress.best(game.difficulty)} · ${game.difficulty.label}',
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: game.state == RunState.paused
                                      ? game.resume
                                      : _start,
                                  child: Text(
                                    game.state == RunState.paused
                                        ? 'Keep going'
                                        : 'Try again',
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: _settings,
                                child: const Text('Settings'),
                              ),
                              TextButton(
                                onPressed: game.home,
                                child: const Text('Back home'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Text(
          game.state == RunState.playing
              ? 'Tap to hop · Tap again to go higher!'
              : 'Your next adventure is just a hop away.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    ],
  );
}

class _HowToJump extends StatelessWidget {
  const _HowToJump();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFE7EEDC),
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Row(
      children: [
        Icon(Icons.touch_app_rounded, color: leaf, size: 38),
        SizedBox(width: 14),
        Expanded(
          child: Text(
            'Tap to jump.\nTap again to jump higher!',
            style: TextStyle(fontSize: 17, height: 1.4),
          ),
        ),
      ],
    ),
  );
}
