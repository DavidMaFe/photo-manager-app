import 'package:flutter/material.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';

/// The 24 words numbered in two columns, in reading order (1-12 left, 13-24 right).
class RecoveryWordsGrid extends StatelessWidget {
  final List<String> words;

  const RecoveryWordsGrid({super.key, required this.words});

  @override
  Widget build(BuildContext context) {
    final half = (words.length / 2).ceil();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.palette.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.palette.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _column(context, 0, half)),
          const SizedBox(width: 12),
          Expanded(child: _column(context, half, words.length)),
        ],
      ),
    );
  }

  Widget _column(BuildContext context, int from, int to) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = from; i < to; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text('${i + 1}.', style: TextStyle(color: context.palette.ink3, fontSize: 14)),
                ),
                Expanded(
                  child: Text(words[i],
                      key: ValueKey('recovery-word-$i'),
                      style: TextStyle(color: context.palette.ink, fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
