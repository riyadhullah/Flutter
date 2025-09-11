import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PuzzleApp());
}

class PuzzleApp extends StatelessWidget {
  const PuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Procedural Puzzles',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.dark),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  int difficulty = 2; // 1..5

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Procedural Puzzles'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(icon: Icon(Icons.blur_linear), text: 'Maze'),
            Tab(icon: Icon(Icons.grid_on), text: 'Sudoku'),
            Tab(icon: Icon(Icons.crossword), text: 'Crossword'),
            Tab(icon: Icon(Icons.grid_3x3), text: 'Logic'),
          ],
        ),
        actions: [
          Row(children: [
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Text('Difficulty'),
            ),
            Slider(
              value: difficulty.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: difficulty.toString(),
              onChanged: (v) => setState(() => difficulty = v.round()),
            ),
          ]),
        ],
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          MazePage(difficulty: difficulty),
          SudokuPage(difficulty: difficulty),
          CrosswordPage(difficulty: difficulty),
          NonogramPage(difficulty: difficulty),
        ],
      ),
    );
  }
}

// --------------------------- Local Store ---------------------------
class LocalStore {
  static const _completedKey = 'completed_puzzles_v1';

  static Future<Set<String>> getCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_completedKey) ?? [];
    return list.toSet();
  }

  static Future<void> markCompleted(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final set = (prefs.getStringList(_completedKey) ?? []).toSet();
    set.add(id);
    await prefs.setStringList(_completedKey, set.toList());
  }

  static Future<bool> isCompleted(String id) async {
    final set = await getCompleted();
    return set.contains(id);
  }
}

// --------------------------- Maze ---------------------------
class MazePage extends StatefulWidget {
  final int difficulty; // 1..5
  const MazePage({super.key, required this.difficulty});

  @override
  State<MazePage> createState() => _MazePageState();
}

class _MazePageState extends State<MazePage> {
  late Maze _maze;
  late Offset _player;
  late int _rows, _cols;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  @override
  void didUpdateWidget(covariant MazePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.difficulty != widget.difficulty) {
      _generate();
    }
  }

  void _generate() {
    // Scale grid size with difficulty.
    _rows = 10 + widget.difficulty * 4;
    _cols = 10 + widget.difficulty * 4;
    _maze = Maze.generate(_rows, _cols);
    _player = const Offset(0, 0);
    setState(() {});
  }

  String get _puzzleId => 'maze_${_rows}x$_cols_${_maze.seed}';

  void _move(int dx, int dy) async {
    final nx = _player.dx.toInt() + dx;
    final ny = _player.dy.toInt() + dy;
    if (nx < 0 || ny < 0 || nx >= _cols || ny >= _rows) return;

    if (_maze.canMove(_player.dx.toInt(), _player.dy.toInt(), dx, dy)) {
      setState(() => _player = Offset(nx.toDouble(), ny.toDouble()));
      if (nx == _cols - 1 && ny == _rows - 1) {
        await LocalStore.markCompleted(_puzzleId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Maze completed! Saved locally.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              final cell = min(constraints.maxWidth / _cols, constraints.maxHeight / _rows);
              return GestureDetector(
                onPanUpdate: (d) {
                  if (d.delta.dx.abs() > d.delta.dy.abs()) {
                    if (d.delta.dx > 0) _move(1, 0); else _move(-1, 0);
                  } else {
                    if (d.delta.dy > 0) _move(0, 1); else _move(0, -1);
                  }
                },
                child: CustomPaint(
                  painter: MazePainter(_maze, _player, cell),
                  size: Size(_cols * cell, _rows * cell),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: _generate,
                icon: const Icon(Icons.refresh),
                label: const Text('New Maze'),
              ),
              const SizedBox(width: 12),
              FutureBuilder<bool>(
                future: LocalStore.isCompleted(_puzzleId),
                builder: (ctx, snap) => Chip(
                  avatar: Icon(snap.data == true ? Icons.check_circle : Icons.radio_button_unchecked),
                  label: Text(snap.data == true ? 'Completed' : 'Not completed'),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}

class MazePainter extends CustomPainter {
  final Maze maze;
  final Offset player;
  final double cellSize;
  const MazePainter(this.maze, this.player, this.cellSize);

  @override
  void paint(Canvas canvas, Size size) {
    final wall = Paint()..strokeWidth = 2;
    final start = Paint()..style = PaintingStyle.fill;
    final end = Paint()..style = PaintingStyle.fill;
    final playerPaint = Paint()..style = PaintingStyle.fill;

    // Dynamic colors from current theme
    // (Colors picked automatically by Flutter based on theme)

    // Draw cells walls
    for (int r = 0; r < maze.rows; r++) {
      for (int c = 0; c < maze.cols; c++) {
        final x = c * cellSize;
        final y = r * cellSize;
        final cell = maze.grid[r][c];
        if (cell.top)    canvas.drawLine(Offset(x, y), Offset(x + cellSize, y), wall);
        if (cell.left)   canvas.drawLine(Offset(x, y), Offset(x, y + cellSize), wall);
        if (cell.right)  canvas.drawLine(Offset(x + cellSize, y), Offset(x + cellSize, y + cellSize), wall);
        if (cell.bottom) canvas.drawLine(Offset(x, y + cellSize), Offset(x + cellSize, y + cellSize), wall);
      }
    }

    // Start & end
    canvas.drawRect(Rect.fromLTWH(1, 1, cellSize - 2, cellSize - 2), start);
    canvas.drawRect(Rect.fromLTWH((maze.cols - 1) * cellSize + 1, (maze.rows - 1) * cellSize + 1, cellSize - 2, cellSize - 2), end);

    // Player
    canvas.drawCircle(Offset(player.dx * cellSize + cellSize / 2, player.dy * cellSize + cellSize / 2), cellSize * 0.25, playerPaint);
  }

  @override
  bool shouldRepaint(covariant MazePainter oldDelegate) =>
      oldDelegate.maze != maze || oldDelegate.player != player || oldDelegate.cellSize != cellSize;
}

class MazeCell {
  bool top = true, right = true, bottom = true, left = true;
}

class Maze {
  final int rows, cols;
  final List<List<MazeCell>> grid;
  final int seed;
  Maze(this.rows, this.cols, this.grid, this.seed);

  static Maze generate(int rows, int cols) {
    final grid = List.generate(rows, (_) => List.generate(cols, (_) => MazeCell()));
    final visited = List.generate(rows, (_) => List.generate(cols, (_) => false));
    final rnd = Random();
    final seed = rnd.nextInt(1 << 31);
    final r = Random(seed);

    void carve(int r0, int c0) {
      visited[r0][c0] = true;
      final dirs = [
        const Offset(0, -1), // up
        const Offset(1, 0),  // right
        const Offset(0, 1),  // down
        const Offset(-1, 0), // left
      ]..shuffle(r);
      for (final d in dirs) {
        final nr = r0 + d.dy.toInt();
        final nc = c0 + d.dx.toInt();
        if (nr < 0 || nc < 0 || nr >= rows || nc >= cols) continue;
        if (!visited[nr][nc]) {
          // knock wall between (r0,c0) and (nr,nc)
          if (d.dy == -1) { grid[r0][c0].top = false; grid[nr][nc].bottom = false; }
          if (d.dx ==  1) { grid[r0][c0].right = false; grid[nr][nc].left = false; }
          if (d.dy ==  1) { grid[r0][c0].bottom = false; grid[nr][nc].top = false; }
          if (d.dx == -1) { grid[r0][c0].left = false; grid[nr][nc].right = false; }
          carve(nr, nc);
        }
      }
    }

    carve(0, 0);
    return Maze(rows, cols, grid, seed);
  }

  bool canMove(int x, int y, int dx, int dy) {
    final cell = grid[y][x];
    if (dx == 1 && cell.right) return false;
    if (dx == -1 && cell.left) return false;
    if (dy == 1 && cell.bottom) return false;
    if (dy == -1 && cell.top) return false;
    return true;
  }
}

// --------------------------- Sudoku ---------------------------
class SudokuPage extends StatefulWidget {
  final int difficulty; // 1..5
  const SudokuPage({super.key, required this.difficulty});

  @override
  State<SudokuPage> createState() => _SudokuPageState();
}

class _SudokuPageState extends State<SudokuPage> {
  late List<List<int>> _solution;
  late List<List<int?>> _board; // null means empty
  late String _id;

  @override
  void initState() {
    super.initState();
    _newPuzzle();
  }

  @override
  void didUpdateWidget(covariant SudokuPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.difficulty != widget.difficulty) _newPuzzle();
  }

  void _newPuzzle() {
    _solution = _generateFullSudoku();
    _board = _digHoles(_solution, holes: 30 + widget.difficulty * 8);
    _id = 'sudoku_${DateTime.now().millisecondsSinceEpoch}';
    setState(() {});
  }

  Future<void> _checkComplete() async {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if ((_board[r][c] ?? 0) != _solution[r][c]) {
          return;
        }
      }
    }
    await LocalStore.markCompleted(_id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sudoku solved! Saved locally.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: GridView.builder(
                  itemCount: 81,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 9),
                  itemBuilder: (ctx, i) {
                    final r = i ~/ 9, c = i % 9;
                    final original = _board[r][c] != null && _board[r][c] == _solution[r][c];
                    final isPrefilled = _board[r][c] != null && _board[r][c] == _solution[r][c] && _countNulls(_board) < 81; // naive prefilled flag
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(width: (c % 3 == 2) ? 2 : 0.5),
                          bottom: BorderSide(width: (r % 3 == 2) ? 2 : 0.5),
                          left: BorderSide(width: (c % 3 == 0) ? 2 : 0.5),
                          top: BorderSide(width: (r % 3 == 0) ? 2 : 0.5),
                        ),
                      ),
                      child: Center(
                        child: _board[r][c] == null || !isPrefilled
                            ? DropdownButton<int>(
                          isExpanded: true,
                          underline: const SizedBox.shrink(),
                          value: _board[r][c],
                          hint: const Text(''),
                          items: List.generate(9, (n) => n + 1)
                              .map((n) => DropdownMenuItem(value: n, child: Center(child: Text('$n'))))
                              .toList(),
                          onChanged: (v) {
                            setState(() => _board[r][c] = v);
                            _checkComplete();
                          },
                        )
                            : Text('${_board[r][c]}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(children: [
            ElevatedButton.icon(
              onPressed: _newPuzzle,
              icon: const Icon(Icons.refresh),
              label: const Text('New Sudoku'),
            ),
            const SizedBox(width: 12),
            FutureBuilder<bool>(
              future: LocalStore.isCompleted(_id),
              builder: (ctx, snap) => Chip(
                avatar: Icon(snap.data == true ? Icons.check_circle : Icons.radio_button_unchecked),
                label: Text(snap.data == true ? 'Completed' : 'In progress'),
              ),
            ),
          ]),
        )
      ],
    );
  }

  // --- Sudoku generation ---
  List<List<int>> _generateFullSudoku() {
    final grid = List.generate(9, (_) => List.filled(9, 0));
    final rand = Random();

    bool isSafe(int r, int c, int n) {
      for (int i = 0; i < 9; i++) {
        if (grid[r][i] == n || grid[i][c] == n) return false;
      }
      final br = (r ~/ 3) * 3, bc = (c ~/ 3) * 3;
      for (int rr = 0; rr < 3; rr++) {
        for (int cc = 0; cc < 3; cc++) {
          if (grid[br + rr][bc + cc] == n) return false;
        }
      }
      return true;
    }

    bool fill(int r, int c) {
      if (r == 9) return true;
      final nr = c == 8 ? r + 1 : r;
      final nc = c == 8 ? 0 : c + 1;

      final nums = List.generate(9, (i) => i + 1)..shuffle(rand);
      for (final n in nums) {
        if (isSafe(r, c, n)) {
          grid[r][c] = n;
          if (fill(nr, nc)) return true;
          grid[r][c] = 0;
        }
      }
      return false;
    }

    // seed diagonal boxes to speed up
    void seedBox(int br, int bc) {
      final nums = List.generate(9, (i) => i + 1)..shuffle(rand);
      int k = 0;
      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < 3; c++) {
          grid[br + r][bc + c] = nums[k++];
        }
      }
    }

    seedBox(0, 0);
    seedBox(3, 3);
    seedBox(6, 6);
    fill(0, 0);
    return grid;
  }

  List<List<int?>> _digHoles(List<List<int>> full, {required int holes}) {
    final board = full.map((row) => row.map<int?>((v) => v).toList()).toList();
    final rand = Random();
    int removed = 0;

    bool hasUniqueSolution() {
      int solutions = 0;

      bool solve(List<List<int?>> b) {
        for (int r = 0; r < 9; r++) {
          for (int c = 0; c < 9; c++) {
            if (b[r][c] == null) {
              for (int n = 1; n <= 9; n++) {
                if (_isSafeBoard(b, r, c, n)) {
                  b[r][c] = n;
                  if (solve(b)) return true;
                  b[r][c] = null;
                }
              }
              return false;
            }
          }
        }
        solutions++;
        return solutions > 1; // stop early if more than one
      }

      final copy = board.map((e) => List<int?>.from(e)).toList();
      solutions = 0;
      solve(copy);
      return solutions == 1;
    }

    while (removed < holes) {
      final r = rand.nextInt(9), c = rand.nextInt(9);
      if (board[r][c] != null) {
        final keep = board[r][c];
        board[r][c] = null;
        if (!hasUniqueSolution()) {
          board[r][c] = keep; // revert if multiple solutions
        } else {
          removed++;
        }
      }
    }
    return board;
  }

  bool _isSafeBoard(List<List<int?>> b, int r, int c, int n) {
    for (int i = 0; i < 9; i++) {
      if (b[r][i] == n || b[i][c] == n) return false;
    }
    final br = (r ~/ 3) * 3, bc = (c ~/ 3) * 3;
    for (int rr = 0; rr < 3; rr++) {
      for (int cc = 0; cc < 3; cc++) {
        if (b[br + rr][bc + cc] == n) return false;
      }
    }
    return true;
  }

  int _countNulls(List<List<int?>> b) {
    int k = 0;
    for (final row in b) { for (final v in row) { if (v == null) k++; } }
    return k;
  }
}

// --------------------------- Crossword (toy) ---------------------------
class CrosswordPage extends StatefulWidget {
  final int difficulty;
  const CrosswordPage({super.key, required this.difficulty});

  @override
  State<CrosswordPage> createState() => _CrosswordPageState();
}

class _CrosswordPageState extends State<CrosswordPage> {
  late List<List<String?>> grid;
  final words = [
    'DART','CODE','MAZE','GRID','LOGIC','RIVER','APPLE','TRAIN','BRICK','UNITY'
  ];

  @override
  void initState() {
    super.initState();
    _generate();
  }

  void _generate() {
    final size = 7 + widget.difficulty; // tiny demo grid
    grid = List.generate(size, (_) => List.filled(size, null));
    final rnd = Random();

    // Very naive fitter: place words horizontally if they fit in empty slots
    for (final w in (words..shuffle(rnd))) {
      for (int attempt = 0; attempt < 50; attempt++) {
        final r = rnd.nextInt(size);
        final c = rnd.nextInt(size - w.length + 1);
        bool can = true;
        for (int i = 0; i < w.length; i++) {
          final cell = grid[r][c + i];
          if (cell != null && cell != w[i]) { can = false; break; }
        }
        if (can) {
          for (int i = 0; i < w.length; i++) { grid[r][c + i] = w[i]; }
          break;
        }
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
        child: Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: GridView.builder(
              itemCount: grid.length * grid.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: grid.length),
              itemBuilder: (ctx, i) {
                final r = i ~/ grid.length, c = i % grid.length;
                final ch = grid[r][c];
                return Container(
                  decoration: BoxDecoration(border: Border.all(width: 0.5)),
                  child: Center(
                    child: ch == null
                        ? const Text('')
                        : Text(ch, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(children: [
          ElevatedButton.icon(onPressed: _generate, icon: const Icon(Icons.refresh), label: const Text('New Demo')),
          const SizedBox(width: 12),
          const Text('Demo fitter — expand later')
        ]),
      )
    ]);
  }
}

// --------------------------- Nonogram (logic demo) ---------------------------
class NonogramPage extends StatefulWidget {
  final int difficulty;
  const NonogramPage({super.key, required this.difficulty});

  @override
  State<NonogramPage> createState() => _NonogramPageState();
}

class _NonogramPageState extends State<NonogramPage> {
  late List<List<bool>> solution;
  late List<List<bool>> marks;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  void _generate() {
    final size = 5 + widget.difficulty; // small board
    final rnd = Random();
    solution = List.generate(size, (_) => List.generate(size, (_) => rnd.nextBool()));
    marks = List.generate(size, (_) => List.generate(size, (_) => false));
    setState(() {});
  }

  bool _isSolved() {
    for (int r = 0; r < solution.length; r++) {
      for (int c = 0; c < solution.length; c++) {
        if (solution[r][c] != marks[r][c]) return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
        child: Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: GridView.builder(
              itemCount: marks.length * marks.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: marks.length),
              itemBuilder: (ctx, i) {
                final r = i ~/ marks.length, c = i % marks.length;
                return InkWell(
                  onTap: () {
                    setState(() => marks[r][c] = !marks[r][c]);
                    if (_isSolved()) {
                      LocalStore.markCompleted('nonogram_${marks.length}');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Logic puzzle matched! Saved locally.')),
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(border: Border.all(width: 0.5)),
                    child: marks[r][c] ? const Icon(Icons.check) : const SizedBox.shrink(),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(children: [
          ElevatedButton.icon(onPressed: _generate, icon: const Icon(Icons.refresh), label: const Text('New Logic Demo')),
          const SizedBox(width: 12),
          const Text('Demo rules — replace with full Nonogram rules later')
        ]),
      )
    ]);
  }
}