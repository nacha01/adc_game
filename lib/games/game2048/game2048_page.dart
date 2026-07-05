import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/game_info.dart';
import '../../services/api_service.dart';
import '../../services/user_session.dart';

import '../../main.dart';
import '../../pages/game_result_page.dart';

class Game2048Page extends StatefulWidget {
  final GameInfo gameInfo;

  const Game2048Page({
    super.key,
    required this.gameInfo,
  });

  @override
  State<Game2048Page> createState() => _Game2048PageState();
}

class _Game2048PageState extends State<Game2048Page> {
  static const int boardSize = 4;
  static const int timeLimit = 60;

  static const double minSwipeDistance = 90;
  static const double directionRatio = 1.8;
  static const int inputDelayMs = 500;

  final Random random = Random();

  List<List<int>> board = [];
  int score = 0;
  int bestScore = 0;
  int remainingTime = timeLimit;
  int selectedRow = 0;

  bool gameOver = false;
  bool win = false;
  bool inputLocked = false;

  Offset swipeDelta = Offset.zero;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startGame();
    loadBestScoreFromDb();
  }
  Future<void> loadBestScoreFromDb() async {
    if (!UserSession.isLoggedIn) return;

    final result = await ApiService.getMyBestScore(
      userId: UserSession.userId!,
      gameCode: widget.gameInfo.id,
    );

    if (result["success"] == true) {
      setState(() {
        bestScore = int.tryParse(result["best_score"].toString()) ?? 0;
      });
    }
  }
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startGame() {
    board = List.generate(boardSize, (_) => List.filled(boardSize, 0));
    score = 0;
    remainingTime = timeLimit;
    selectedRow = 0;
    gameOver = false;
    win = false;
    inputLocked = false;
    swipeDelta = Offset.zero;

    addRandomTile();
    addRandomTile();

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingTime > 0 && !gameOver) {
        setState(() {
          remainingTime--;
        });
      } else {
        t.cancel();
        finishGame('시간 종료');
      }
    });

    setState(() {});
  }

  void finishGame(String reason) {
    if (gameOver) return;

    timer?.cancel();
    gameOver = true;

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GameResultPage(
          gameInfo: widget.gameInfo,
          score: score,
          bestScore: bestScore,
          success: win,
          reason: reason,
        ),
      ),
    );
  }

  void addRandomTile() {
    List<Point<int>> emptyCells = [];

    for (int r = 0; r < boardSize; r++) {
      for (int c = 0; c < boardSize; c++) {
        if (board[r][c] == 0) {
          emptyCells.add(Point(r, c));
        }
      }
    }

    if (emptyCells.isNotEmpty) {
      final cell = emptyCells[random.nextInt(emptyCells.length)];
      board[cell.x][cell.y] = random.nextDouble() < 0.9 ? 2 : 4;
    }
  }

  List<int> compress(List<int> line) {
    List<int> result = line.where((value) => value != 0).toList();

    while (result.length < boardSize) {
      result.add(0);
    }

    return result;
  }

  MoveLineResult merge(List<int> line) {
    int gain = 0;

    for (int i = 0; i < boardSize - 1; i++) {
      if (line[i] != 0 && line[i] == line[i + 1]) {
        int originalValue = line[i];
        line[i] *= 2;
        line[i + 1] = 0;
        gain += originalValue;
      }
    }

    return MoveLineResult(line, gain);
  }

  MoveResult moveLeftLogic(List<List<int>> currentBoard) {
    List<List<int>> newBoard = [];
    int totalGain = 0;
    bool moved = false;

    for (final row in currentBoard) {
      List<int> original = List.from(row);

      List<int> newRow = compress(row);
      MoveLineResult merged = merge(newRow);
      newRow = compress(merged.line);

      if (!_sameList(original, newRow)) {
        moved = true;
      }

      totalGain += merged.gain;
      newBoard.add(newRow);
    }

    return MoveResult(newBoard, moved, totalGain);
  }

  bool _sameList(List<int> a, List<int> b) {
    if (a.length != b.length) return false;

    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }

    return true;
  }

  List<List<int>> reverseBoard(List<List<int>> target) {
    return target.map((row) => row.reversed.toList()).toList();
  }

  List<List<int>> transposeBoard(List<List<int>> target) {
    return List.generate(
      boardSize,
          (r) => List.generate(boardSize, (c) => target[c][r]),
    );
  }

  void moveLeft() {
    applyMoveResult(moveLeftLogic(board));
  }

  void moveRight() {
    final reversed = reverseBoard(board);
    final result = moveLeftLogic(reversed);

    applyMoveResult(
      MoveResult(
        reverseBoard(result.board),
        result.moved,
        result.gain,
      ),
    );
  }

  void moveUp() {
    final transposed = transposeBoard(board);
    final result = moveLeftLogic(transposed);

    applyMoveResult(
      MoveResult(
        transposeBoard(result.board),
        result.moved,
        result.gain,
      ),
    );
  }

  void moveDown() {
    final transposed = transposeBoard(board);
    final reversed = reverseBoard(transposed);
    final result = moveLeftLogic(reversed);

    applyMoveResult(
      MoveResult(
        transposeBoard(reverseBoard(result.board)),
        result.moved,
        result.gain,
      ),
    );
  }

  void applyMoveResult(MoveResult result) {
    if (gameOver) return;

    if (result.moved) {
      setState(() {
        board = result.board;
        score += result.gain;
        bestScore = max(bestScore, score);

        addRandomTile();

        if (hasWon()) {
          win = true;
        }

        if (!canMove()) {
          finishGame('더 이상 이동할 수 없음');
        }
      });
    }
  }

  bool hasWon() {
    for (final row in board) {
      for (final value in row) {
        if (value >= 2048) {
          return true;
        }
      }
    }

    return false;
  }

  bool canMove() {
    for (int r = 0; r < boardSize; r++) {
      for (int c = 0; c < boardSize; c++) {
        if (board[r][c] == 0) return true;

        if (c < boardSize - 1 && board[r][c] == board[r][c + 1]) {
          return true;
        }

        if (r < boardSize - 1 && board[r][c] == board[r + 1][c]) {
          return true;
        }
      }
    }

    return false;
  }

  void sortSelectedRow() {
    if (gameOver) return;

    setState(() {
      List<int> row = board[selectedRow];
      List<int> nonZero = row.where((value) => value != 0).toList();
      int zeroCount = boardSize - nonZero.length;

      nonZero.sort();

      board[selectedRow] = [
        ...nonZero,
        ...List.filled(zeroCount, 0),
      ];

      if (hasWon()) {
        win = true;
      }

      if (!canMove()) {
        finishGame('더 이상 이동할 수 없음');
      }
    });
  }

  void handleSwipeStart(DragStartDetails details) {
    swipeDelta = Offset.zero;
  }

  void handleSwipeUpdate(DragUpdateDetails details) {
    swipeDelta += details.delta;
  }

  void handleSwipeEnd(DragEndDetails details) {
    if (gameOver || inputLocked) return;

    final double dx = swipeDelta.dx;
    final double dy = swipeDelta.dy;

    final double absDx = dx.abs();
    final double absDy = dy.abs();

    if (swipeDelta.distance < minSwipeDistance) {
      return;
    }

    if (absDx > absDy) {
      if (absDx < absDy * directionRatio) {
        return;
      }
    } else {
      if (absDy < absDx * directionRatio) {
        return;
      }
    }

    inputLocked = true;

    if (absDx > absDy) {
      if (dx > 0) {
        moveRight();
      } else {
        moveLeft();
      }
    } else {
      if (dy > 0) {
        moveDown();
      } else {
        moveUp();
      }
    }

    Future.delayed(const Duration(milliseconds: inputDelayMs), () {
      if (mounted) {
        inputLocked = false;
      }
    });
  }

  Future<void> confirmExit() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('게임 종료'),
          content: Text('게임을 종료하시겠습니까?\n현재 점수는 $score점입니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('종료'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      finishGame('사용자 종료');
    }
  }

  Color tileColor(int value) {
    switch (value) {
      case 0:
        return const Color(0xFFF0F0F0);
      case 2:
        return Colors.white;
      case 4:
        return const Color(0xFFFFF5F5);
      case 8:
        return const Color(0xFFFFE1E1);
      case 16:
        return const Color(0xFFFFCDCD);
      case 32:
        return const Color(0xFFFFB4B4);
      case 64:
        return const Color(0xFFFF9696);
      case 128:
        return const Color(0xFFFF7878);
      case 256:
        return const Color(0xFFFF5A5A);
      case 512:
        return const Color(0xFFF54646);
      case 1024:
        return const Color(0xFFE63232);
      case 2048:
        return const Color(0xFFD21E1E);
      default:
        return const Color(0xFF3C3A32);
    }
  }

  Color textColor(int value) {
    if (value == 2 || value == 4) {
      return const Color(0xFF373737);
    }

    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 14),
            topPanel(),
            const SizedBox(height: 12),
            timerText(),
            const SizedBox(height: 12),
            boardView(),
            const SizedBox(height: 12),
            selectedRowText(),
            const SizedBox(height: 8),
            buttonArea(),
            const SizedBox(height: 8),
            statusText(),
          ],
        ),
      ),
    );
  }

  Widget topPanel() {
    return Container(
      width: 340,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE62D2D),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            widget.gameInfo.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '게임 개발자 : ${widget.gameInfo.developer} - ${widget.gameInfo.school}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              scoreBox('점수', score),
              const SizedBox(width: 18),
              scoreBox('나의 최고', bestScore),
            ],
          ),
        ],
      ),
    );
  }

  Widget scoreBox(String title, int value) {
    return Container(
      width: 120,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFC81E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget timerText() {
    return Text(
      '남은 시간 : $remainingTime초',
      style: TextStyle(
        color: remainingTime <= 10
            ? const Color(0xFFB40000)
            : const Color(0xFFE62D2D),
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget boardView() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: handleSwipeStart,
      onPanUpdate: handleSwipeUpdate,
      onPanEnd: handleSwipeEnd,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE62D2D),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: List.generate(boardSize, (r) {
              final bool isSelected = r == selectedRow;

              return Expanded(
                child: AnimatedScale(
                  scale: isSelected ? 1.03 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  child: Row(
                    children: List.generate(boardSize, (c) {
                      int value = board[r][c];

                      return Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            setState(() {
                              selectedRow = r;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: tileColor(value),
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(
                                color: const Color(0xFFFFD6D6),
                                width: 4,
                              )
                                  : null,
                            ),
                            child: Center(
                              child: value == 0
                                  ? const SizedBox()
                                  : Text(
                                '$value',
                                style: TextStyle(
                                  color: textColor(value),
                                  fontSize: value < 100
                                      ? 34
                                      : value < 1000
                                      ? 28
                                      : 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget selectedRowText() {
    return Text(
      '현재 선택 : ${selectedRow + 1}행',
      style: const TextStyle(
        fontSize: 20,
        color: Color(0xFFE62D2D),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget buttonArea() {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        ElevatedButton(
          onPressed: sortSelectedRow,
          child: Text('${selectedRow + 1}행 정렬하기'),
        ),
        ElevatedButton(
          onPressed: startGame,
          child: const Text('다시 시작'),
        ),
        ElevatedButton(
          onPressed: confirmExit,
          child: const Text('게임 종료'),
        ),
      ],
    );
  }

  Widget statusText() {
    if (win) {
      return const Text(
        '2048 달성! 계속 진행 가능',
        style: TextStyle(
          color: Colors.green,
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return const Text(
      '행을 터치해 선택하고, 게임판을 밀어 이동하세요.',
      style: TextStyle(
        color: Color(0xFF373737),
        fontSize: 15,
      ),
    );
  }
}

class MoveLineResult {
  final List<int> line;
  final int gain;

  MoveLineResult(this.line, this.gain);
}

class MoveResult {
  final List<List<int>> board;
  final bool moved;
  final int gain;

  MoveResult(this.board, this.moved, this.gain);
}