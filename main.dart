import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const SnakeGameApp());

class SnakeGameApp extends StatelessWidget {
  const SnakeGameApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SnakeGame(),
    );
  }
}

class SnakeGame extends StatefulWidget {
  const SnakeGame({Key? key}) : super(key: key);

  @override
  _SnakeGameState createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  final int squaresPerRow = 20;
  final int squaresPerCol = 30;

  List<int> snakePosition = [45, 65, 85, 105];
  int foodPosition = 300;
  String direction = 'down';
  bool isPlaying = false;
  int score = 0;
  Timer? timer;

  void startGame() {
    if (isPlaying) return;
    isPlaying = true;
    score = 0;
    snakePosition = [45, 65, 85, 105];
    direction = 'down';
    generateNewFood();
    timer = Timer.periodic(const Duration(milliseconds: 200), (Timer t) {
      updateSnake();
    });
  }

  void generateNewFood() {
    final random = Random();
    while (true) {
      int nextFood = random.nextInt(squaresPerRow * squaresPerCol);
      if (!snakePosition.contains(nextFood)) {
        setState(() {
          foodPosition = nextFood;
        });
        break;
      }
    }
  }

  void updateSnake() {
    setState(() {
      switch (direction) {
        case 'down':
          if (snakePosition.last > squaresPerRow * (squaresPerCol - 1)) {
            snakePosition.add(snakePosition.last + squaresPerRow - (squaresPerRow * squaresPerCol));
          } else {
            snakePosition.add(snakePosition.last + squaresPerRow);
          }
          break;
        case 'up':
          if (snakePosition.last < squaresPerRow) {
            snakePosition.add(snakePosition.last - squaresPerRow + (squaresPerRow * squaresPerCol));
          } else {
            snakePosition.add(snakePosition.last - squaresPerRow);
          }
          break;
        case 'left':
          if (snakePosition.last % squaresPerRow == 0) {
            snakePosition.add(snakePosition.last - 1 + squaresPerRow);
          } else {
            snakePosition.add(snakePosition.last - 1);
          }
          break;
        case 'right':
          if ((snakePosition.last + 1) % squaresPerRow == 0) {
            snakePosition.add(snakePosition.last + 1 - squaresPerRow);
          } else {
            snakePosition.add(snakePosition.last + 1);
          }
          break;
      }

      if (snakePosition.last == foodPosition) {
        score += 10;
        generateNewFood();
      } else {
        snakePosition.removeAt(0);
      }

      List<int> body = List.from(snakePosition);
      body.removeLast();
      if (body.contains(snakePosition.last)) {
        gameOver();
      }
    });
  }

  void gameOver() {
    timer?.cancel();
    isPlaying = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('انتهت اللعبة!'),
          content: Text('نقاطك الإجمالية: $score'),
          actions: [
            TextButton(
              child: const Text('إعادة المحاولة'),
              onPressed: () {
                Navigator.of(context).pop();
                startGame();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text('لعبة الدودة - النقاط: $score'),
        backgroundColor: Colors.green[800],
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (direction != 'up' && details.delta.dy > 0) direction = 'down';
                if (direction != 'down' && details.delta.dy < 0) direction = 'up';
              },
              onHorizontalDragUpdate: (details) {
                if (direction != 'left' && details.delta.dx > 0) direction = 'right';
                if (direction != 'right' && details.delta.dx < 0) direction = 'left';
              },
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: squaresPerRow * squaresPerCol,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: squaresPerRow,
                ),
                itemBuilder: (BuildContext context, int index) {
                  if (snakePosition.contains(index)) {
                    if (index == snakePosition.last) {
                      return Center(
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.greenAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    }
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green[500],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    );
                  }
                  if (index == foodPosition) {
                    return Container(
                      padding: const EdgeInsets.all(2),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }
                  return Container(
                    padding: const EdgeInsets.all(1),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (!isPlaying)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                onPressed: startGame,
                child: const Text('ابدأ اللعب الآن', style: TextStyle(fontSize: 20, color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}
