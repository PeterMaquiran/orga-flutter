import 'package:flutter/material.dart';

import '../../../shared/navigationBar.dart';

class _BoardItem {
  const _BoardItem({
    required this.title,
    required this.accent,
    this.subtitle,
  });

  final String title;
  final Color accent;
  final String? subtitle;
}

class BoardsScreen extends StatelessWidget {
  const BoardsScreen({super.key});

  static const List<_BoardItem> _boards = [
    _BoardItem(
      title: 'Personal',
      accent: Color(0xFF0B84FF),
      subtitle: '3 lists',
    ),
    _BoardItem(
      title: 'Work projects',
      accent: Color(0xFF34C759),
      subtitle: '5 lists',
    ),
    _BoardItem(
      title: 'Ideas',
      accent: Color(0xFFFF9F0A),
      subtitle: '2 lists',
    ),
    _BoardItem(
      title: 'Shared with team',
      accent: Color(0xFFAF52DE),
      subtitle: '4 lists',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF8F9FA),
                    Color(0xFFE9ECEF),
                    Color(0xFFDEE2E6),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, safeTop + 16, 20, 120),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Boards',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your workspaces',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black.withValues(alpha: 0.45),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ...List.generate(_boards.length, (i) {
                          final b = _boards[i];
                          return Padding(
                            padding: EdgeInsets.only(bottom: i == _boards.length - 1 ? 0 : 10),
                            child: _BoardRow(item: b),
                          );
                        }),
                        const SizedBox(height: 12),
                        Material(
                          color: Colors.white.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_circle_outline_rounded,
                                    size: 22,
                                    color: Colors.black.withValues(alpha: 0.45),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Create board',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black.withValues(alpha: 0.55),
                                    ),
                                  ),
                                ],
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
        ],
      ),
      bottomNavigationBar: const FloatingNavBar(),
    );
  }
}

class _BoardRow extends StatelessWidget {
  const _BoardRow({required this.item});

  final _BoardItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 44,
                decoration: BoxDecoration(
                  color: item.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (item.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.black.withValues(alpha: 0.2),
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
