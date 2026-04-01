import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() => runApp(const ChessApp());

class ChessApp extends StatelessWidget {
  const ChessApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const BoardScreen(),
    );
  }
}

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key});
  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  late List<List<String?>> grid;
  int? selR, selC;
  bool whiteTurn = true;
  List<Offset> moves = [];

  @override
  void initState() {
    super.initState();
    setupBoard();
  }

  void setupBoard() {
    grid = List.generate(8, (_) => List.filled(8, null));
    for (int i = 0; i < 8; i++) {
      grid[1][i] = 'bp'; 
      grid[6][i] = 'wp';
    }
    var layout = ['r', 'n', 'b', 'q', 'k', 'b', 'n', 'r'];
    for (int i = 0; i < 8; i++) {
      grid[0][i] = 'b${layout[i]}';
      grid[7][i] = 'w${layout[i]}';
    }
  }

  void tapSquare(int r, int c) {
    setState(() {
      if (selR != null && moves.contains(Offset(c.toDouble(), r.toDouble()))) {
        grid[r][c] = grid[selR!][selC!];
        grid[selR!][selC!] = null;
        selR = null; selC = null; moves = [];
        whiteTurn = !whiteTurn;
      } else {
        String? p = grid[r][c];
        if (p != null && (whiteTurn ? p.startsWith('w') : p.startsWith('b'))) {
          selR = r; selC = c;
          moves = getMoves(r, c);
        } else {
          selR = null; selC = null; moves = [];
        }
      }
    });
  }

  List<Offset> getMoves(int r, int c) {
    List<Offset> list = [];
    String p = grid[r][c]!;
    bool isW = p.startsWith('w');
    String type = p[1];

    void slide(List<Offset> dirs) {
      for (var d in dirs) {
        for (int i = 1; i < 8; i++) {
          int nr = r + (d.dy * i).toInt(), nc = c + (d.dx * i).toInt();
          if (nr < 0 || nr >= 8 || nc < 0 || nc >= 8) break;
          if (grid[nr][nc] == null) {
            list.add(Offset(nc.toDouble(), nr.toDouble()));
          } else {
            if (grid[nr][nc]![0] != p[0]) list.add(Offset(nc.toDouble(), nr.toDouble()));
            break;
          }
        }
      }
    }

    if (type == 'p') {
      int d = isW ? -1 : 1;
      if (grid[r + d][c] == null) {
        list.add(Offset(c.toDouble(), (r + d).toDouble()));
        if (((isW && r == 6) || (!isW && r == 1)) && grid[r + d * 2][c] == null) {
          list.add(Offset(c.toDouble(), (r + d * 2).toDouble()));
        }
      }
      for (int s in [-1, 1]) {
        int nc = c + s, nr = r + d;
        if (nc >= 0 && nc < 8 && nr >= 0 && nr < 8 && grid[nr][nc] != null && grid[nr][nc]![0] != p[0]) {
          list.add(Offset(nc.toDouble(), nr.toDouble()));
        }
      }
    } else if (type == 'n') {
      var jumps = [const Offset(-2,-1),const Offset(-2,1),const Offset(2,-1),const Offset(2,1),const Offset(-1,-2),const Offset(-1,2),const Offset(1,-2),const Offset(1,2)];
      for (var j in jumps) {
        int nr = r + j.dy.toInt(), nc = c + j.dx.toInt();
        if (nr >= 0 && nr < 8 && nc >= 0 && nc < 8 && (grid[nr][nc] == null || grid[nr][nc]![0] != p[0])) {
          list.add(Offset(nc.toDouble(), nr.toDouble()));
        }
      }
    } else if (type == 'r') {
      slide([const Offset(0,1), const Offset(0,-1), const Offset(1,0), const Offset(-1,0)]);
    } else if (type == 'b') {
      slide([const Offset(1,1), const Offset(1,-1), const Offset(-1,1), const Offset(-1,-1)]);
    } else if (type == 'q' || type == 'k') {
      var dirs = [const Offset(0,1),const Offset(0,-1),const Offset(1,0),const Offset(-1,0),const Offset(1,1),const Offset(1,-1),const Offset(-1,1),const Offset(-1,-1)];
      if (type == 'q') slide(dirs);
      else {
        for (var d in dirs) {
          int nr = r + d.dy.toInt(), nc = c + d.dx.toInt();
          if (nr >= 0 && nr < 8 && nc >= 0 && nc < 8 && (grid[nr][nc] == null || grid[nr][nc]![0] != p[0])) list.add(Offset(nc.toDouble(), nr.toDouble()));
        }
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF302E2B),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(children: [const CircleAvatar(child: Icon(Icons.person)), const SizedBox(width: 10), Text(whiteTurn ? "Opponent" : "Opponent (Turn)", style: const TextStyle(color: Colors.white))]),
            ),
            Expanded(
              child: Center(
                child: LayoutBuilder(builder: (context, constraints) {
                  double s = constraints.maxWidth < constraints.maxHeight ? constraints.maxWidth : constraints.maxHeight;
                  return SizedBox(
                    width: s, height: s,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
                      itemCount: 64,
                      itemBuilder: (context, i) {
                        int r = i ~/ 8, c = i % 8;
                        bool dark = (r + c) % 2 != 0;
                        return GestureDetector(
                          onTap: () => tapSquare(r, c),
                          child: Container(
                            color: selR == r && selC == c ? const Color(0xFFF7F769) : (dark ? const Color(0xFF779556) : const Color(0xFFEBECD0)),
                            child: Stack(
                              children: [
                                if (moves.contains(Offset(c.toDouble(), r.toDouble()))) Center(child: Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.black12, shape: BoxShape.circle))),
                                Center(child: drawPiece(grid[r][c])),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(children: [const CircleAvatar(child: Icon(Icons.person)), const SizedBox(width: 10), Text(whiteTurn ? "You (Turn)" : "You", style: const TextStyle(color: Colors.white))]),
            ),
          ],
        ),
      ),
    );
  }

  Widget drawPiece(String? code) {
    if (code == null) return const SizedBox();
    final Map<String, String> data = {
      'p': '<svg viewBox="0 0 45 45"><path d="M22 9c-2.2 0-4 1.8-4 4 0 .9.3 1.7.8 2.4C16.3 16.5 15 18.5 15 21c0 2 1 3.7 2.5 4.7l-1.5 5.3h12l-1.5-5.3c1.5-1 2.5-2.7 2.5-4.7 0-2.5-1.3-4.5-3.8-5.6.5-.7.8-1.5.8-2.4 0-2.2-1.8-4-4-4z" fill="currentColor"/></svg>',
      'r': '<svg viewBox="0 0 45 45"><path d="M9 39h27v-3H9v3zM12 36h21l-2-6H14l-2 6zm0-11h21v-3H12v3zm0-3l-1-7h3v4h4v-4h3v4h3v-4h3v4h4v-4h3l-1 7H12z" fill="currentColor"/></svg>',
      'n': '<svg viewBox="0 0 45 45"><path d="M22 10c10.5 1 16.5 8 16 29H15c0-9 10-6.5 8-21" fill="currentColor"/></svg>',
      'b': '<svg viewBox="0 0 45 45"><path d="M9 36c3.39-.47 3.39-2.33 3.39-2.33s.47-5.12 1.39-10.7c.93-5.58 3.26-11.16 8.22-11.16 4.97 0 7.29 5.58 8.22 11.16.93 5.58 1.4 10.7 1.4 10.7s0 1.86 3.39 2.33c0 0 0 1.86-13 1.86-13 0-13-1.86-13-1.86z" fill="currentColor"/></svg>',
      'q': '<svg viewBox="0 0 45 45"><path d="M8 12l3 20h23l3-20-7 8-5-12-5 12-7-8z" fill="currentColor"/></svg>',
      'k': '<svg viewBox="0 0 45 45"><path d="M22.5 11.63V6M20 8h5M22.5 25s4.5-7.5 4.5-11.25c0-2.5-2-4.5-4.5-4.5s-4.5 2-4.5 4.5c0 3.75 4.5 11.25 4.5 11.25z" fill="currentColor"/></svg>',
    };
    return SvgPicture.string(
      data[code[1]]!,
      height: 35,
      colorFilter: ColorFilter.mode(code.startsWith('w') ? Colors.white : Colors.black, BlendMode.srcIn),
    );
  }
}