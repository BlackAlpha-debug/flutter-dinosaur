import 'package:flutter/material.dart';
import 'constants.dart';
import 'game_engine.dart';
import 'rain.dart';
import 'dino.dart';
import 'dino_avatar.dart';

class GameScene extends StatelessWidget {
  const GameScene({
    super.key,
    required this.game,
    required this.effects,
    this.color = 0,
  });
  final GameEngine game;
  final bool effects;
  final int color;
  @override
  Widget build(BuildContext context) {
    final colors = skyGradients[game.skyPhase];
    return LayoutBuilder(
      builder: (context, constraints) {
        // Short/wide windows crop unused underground space, not the jump arc.
        final logicalHeight = constraints.maxWidth > constraints.maxHeight
            ? 540.0
            : 720.0;
        return ColoredBox(
          color: colors.last,
          child: Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: GameEngine.viewport.width,
                height: logicalHeight,
                child: ClipRect(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: colors,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: 38,
                          top: 65,
                          child: Icon(
                            game.skyPhase >= 3
                                ? Icons.nightlight_round
                                : Icons.wb_sunny_rounded,
                            size: 55,
                            color: const Color(0xFFFFE9A8),
                          ),
                        ),
                        for (var i = 0; i < 4; i++)
                          Positioned(
                            left:
                                ((i * 150 + 70 - game.distance * 1.5) % 600) -
                                100,
                            top: 100.0 + (i % 2) * 55,
                            child: Image.asset(
                              'assets/images/cloud filled.png',
                              width: 92,
                              height: 45,
                              cacheWidth: 184,
                            ),
                          ),
                        Positioned(
                          left: 0,
                          right: 0,
                          top: GameEngine.floorY + 15,
                          bottom: 0,
                          child: ColoredBox(
                            color: [
                              const Color(0xFF98724A),
                              const Color(0xFF65716B),
                              const Color(0xFF91BFC7),
                            ][game.terrain],
                          ),
                        ),
                        for (var i = 0; i < 2; i++)
                          Positioned(
                            left:
                                i * 500 -
                                (game.distance * worlToPixelRatio % 500),
                            top:
                                GameEngine.floorY -
                                [425.0, 460.0, 455.0][game.terrain],
                            width: 500,
                            height: 500,
                            child: Image.asset(
                              [
                                'assets/images/Grass Ground.png',
                                'assets/images/Stone Ground.png',
                                'assets/images/Ice Ground.png',
                              ][game.terrain],
                              filterQuality: FilterQuality.low,
                            ),
                          ),
                        for (final star in game.coins)
                          Positioned.fromRect(
                            rect: star.rect(game.distance),
                            child: const Icon(
                              Icons.monetization_on_rounded,
                              size: 28,
                              color: Color(0xFFFFC745),
                            ),
                          ),
                        for (final object in [...game.obstacles, game.dino])
                          Positioned.fromRect(
                            rect: object.getRect(
                              GameEngine.viewport,
                              game.distance,
                            ),
                            child: object == game.dino
                                ? DinoAvatar(
                                    time: game.time,
                                    running:
                                        game.dino.state == DinoState.running,
                                    jumping:
                                        game.dino.state == DinoState.jumping,
                                    effects: effects,
                                    color: color,
                                  )
                                : object.render(),
                          ),
                        if (effects && game.skyPhase >= 2)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: CustomPaint(
                                painter: RainPainter(
                                  time: game.time,
                                  intensity: (game.skyPhase - 1) / 4,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
