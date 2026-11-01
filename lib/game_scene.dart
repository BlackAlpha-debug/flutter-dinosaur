import 'dart:math';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'game_engine.dart';
import 'rain.dart';
import 'dino.dart';
import 'dino_avatar.dart';
import 'cactus.dart';
import 'world_scenery.dart';

class GameScene extends StatelessWidget {
  const GameScene({
    super.key,
    required this.game,
    required this.effects,
    this.color = 0,
    this.characterId = 'sprout',
  });
  final GameEngine game;
  final bool effects;
  final int color;
  final String characterId;
  @override
  Widget build(BuildContext context) {
    final colors = skyGradients[game.skyPhase];
    final pickupAge = game.time - game.lastPickupTime;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Short/wide windows crop unused underground space, not the jump arc.
        final logicalHeight = constraints.maxWidth > constraints.maxHeight
            ? 540.0
            : 720.0;
        // Keep the action near the lower quarter rather than filling almost
        // half the screen with underground. All world visuals move together;
        // physics/collisions continue using the original logical coordinates.
        final cameraY = (logicalHeight * .78 - GameEngine.floorY).clamp(
          0.0,
          160.0,
        );
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
                        Positioned.fill(
                          child: WorldScenery(
                            terrain: game.terrain,
                            distance: game.distance,
                            skyPhase: game.skyPhase,
                            effects: effects,
                          ),
                        ),
                        Positioned(
                          top: 18,
                          left: 18,
                          right: 18,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFFFF9EC,
                                ).withValues(alpha: .94),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                worldNames[game.terrain],
                                style: const TextStyle(
                                  color: Color(0xFF173C35),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // The illustrated clearing is the surface. Contact
                        // shadows anchor grounded actors without another belt
                        // of scenery crossing the painted foreground.
                        for (final object in [
                          ...game.obstacles.whereType<Cactus>(),
                          game.dino,
                        ])
                          Positioned(
                            left:
                                object
                                    .getRect(GameEngine.viewport, game.distance)
                                    .center
                                    .dx -
                                object
                                        .getRect(
                                          GameEngine.viewport,
                                          game.distance,
                                        )
                                        .width *
                                    .30,
                            top: GameEngine.floorY + cameraY - 3,
                            width:
                                object
                                    .getRect(GameEngine.viewport, game.distance)
                                    .width *
                                .60,
                            height: 7,
                            child: Opacity(
                              opacity: object == game.dino
                                  ? (1 - game.dino.dispY / 450).clamp(.15, 1.0)
                                  : 1,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: _shadowColor(game.terrain),
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _shadowColor(game.terrain),
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        for (final star in game.coins)
                          Positioned.fromRect(
                            rect: star
                                .rect(game.distance)
                                .shift(Offset(0, cameraY)),
                            child: Transform.translate(
                              offset: Offset(
                                0,
                                effects
                                    ? sin(game.time * 4 + star.location.dx) * 3
                                    : 0,
                              ),
                              child: const Icon(
                                Icons.monetization_on_rounded,
                                size: 28,
                                color: Color(0xFFFFC745),
                                shadows: [
                                  Shadow(
                                    color: Color(0xFF805410),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        for (final object in [...game.obstacles, game.dino])
                          Positioned.fromRect(
                            rect: object
                                .getRect(GameEngine.viewport, game.distance)
                                .shift(Offset(0, cameraY)),
                            child: object == game.dino
                                ? DinoAvatar(
                                    characterId: characterId,
                                    time: game.time,
                                    distance: game.distance,
                                    landing: game.dino.landingRemaining > 0,
                                    running:
                                        game.dino.state == DinoState.running ||
                                        game.dino.state == DinoState.dead,
                                    jumping: game.dino.dispY > 0,
                                    effects: effects,
                                    color: color,
                                  )
                                : object.render(),
                          ),
                        if (effects && pickupAge >= 0 && pickupAge < .45)
                          for (var i = 0; i < 6; i++)
                            Positioned(
                              left:
                                  game.dino
                                      .getRect(
                                        GameEngine.viewport,
                                        game.distance,
                                      )
                                      .center
                                      .dx +
                                  cos(i * pi / 3) * pickupAge * 85 -
                                  7,
                              top:
                                  game.dino
                                      .getRect(
                                        GameEngine.viewport,
                                        game.distance,
                                      )
                                      .top +
                                  cameraY +
                                  30 +
                                  sin(i * pi / 3) * pickupAge * 55 -
                                  pickupAge * 60,
                              child: Opacity(
                                opacity: 1 - pickupAge / .45,
                                child: const Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFFFD45C),
                                  size: 16,
                                  shadows: [
                                    Shadow(
                                      color: Color(0xFF805410),
                                      blurRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
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

  Color _shadowColor(int terrain) => [
    const Color(0x28334E21),
    const Color(0x286B3B28),
    const Color(0x28404B83),
  ][terrain];
}
