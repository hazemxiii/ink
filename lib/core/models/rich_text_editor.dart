import 'package:flutter/material.dart';

class RichTextEditingController extends TextEditingController {
  RichTextEditingController({super.text});

  // Inline patterns (matched within a single line), in order of priority:
  // 1) [color=xxx]...[/color]
  // 2) **bold**
  // 3) *italic*
  // 4) [font=xxx]...[/font]
  static final RegExp _pattern = RegExp(
    r'\[color=(#[0-9A-Fa-f]{6}|\w+)\](.*?)\[/color\]|\*\*(.*?)\*\*|\*(.*?)\*|\[font=(\d+)\](.*?)\[/font\]',
  );

  // Block (line-start) patterns for lists.
  static final RegExp _unorderedLine = RegExp(r'^-\s+');
  static final RegExp _orderedLine = RegExp(r'^(\d+)\.\s+');

  // ---------------------------------------------------------------------
  // Enter-key handling: auto-continue lists, or exit the list when the
  // current item is empty.
  // ---------------------------------------------------------------------
  @override
  set value(TextEditingValue newValue) {
    final oldValue = value;
    final isSingleNewlineInsertion =
        newValue.text.length == oldValue.text.length + 1 &&
        oldValue.selection.isCollapsed &&
        newValue.selection.isCollapsed &&
        newValue.selection.baseOffset == oldValue.selection.baseOffset + 1 &&
        oldValue.selection.baseOffset >= 0 &&
        oldValue.selection.baseOffset <= newValue.text.length - 1 &&
        newValue.text[oldValue.selection.baseOffset] == '\n';

    if (isSingleNewlineInsertion) {
      final handled = _handleListContinuation(
        newValue,
        oldValue.selection.baseOffset,
      );
      if (handled != null) {
        super.value = handled;
        return;
      }
    }

    super.value = newValue;
  }

  TextEditingValue? _handleListContinuation(
    TextEditingValue newValue,
    int newlineIndex,
  ) {
    final text = newValue.text;
    final lineStart = text.lastIndexOf('\n', newlineIndex - 1) + 1;
    final lineContent = text.substring(lineStart, newlineIndex);

    final unordered = _unorderedLine.firstMatch(lineContent);
    final ordered = _orderedLine.firstMatch(lineContent);
    if (unordered == null && ordered == null) return null;

    final marker = (unordered ?? ordered)!.group(0)!;
    final contentAfterMarker = lineContent.substring(marker.length);

    if (contentAfterMarker.trim().isEmpty) {
      // Pressing Enter on an empty list item exits the list: strip the
      // marker from that (now-blank) line instead of continuing it.
      final newText = text.replaceRange(lineStart, newlineIndex, '');
      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: lineStart + 1),
      );
    }

    // Otherwise, continue the list onto the new line.
    final nextMarker = ordered != null
        ? '${int.parse(ordered.group(1)!) + 1}. '
        : marker;
    final insertAt = newlineIndex + 1;
    final newText = text.replaceRange(insertAt, insertAt, nextMarker);
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: insertAt + nextMarker.length),
    );
  }

  // ---------------------------------------------------------------------
  // Rendering
  // ---------------------------------------------------------------------
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final resolvedBase = style ?? const TextStyle();
    final children = <InlineSpan>[];
    final lines = text.split('\n');
    int offset = 0;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      children.addAll(_parseLine(line, resolvedBase, offset));
      offset += line.length;
      if (i != lines.length - 1) {
        children.add(TextSpan(text: '\n', style: resolvedBase));
        offset += 1;
      }
    }

    return TextSpan(style: style, children: children);
  }

  /// Handles the list marker (if any) at the start of a line, then hands
  /// the remainder of the line off to the inline [_parse] pass.
  List<InlineSpan> _parseLine(
    String line,
    TextStyle baseStyle,
    int lineOffset,
  ) {
    final unorderedMatch = _unorderedLine.firstMatch(line);
    final orderedMatch = _orderedLine.firstMatch(line);
    final match = unorderedMatch ?? orderedMatch;

    if (match == null) {
      return _parse(line, baseStyle, lineOffset);
    }

    final marker = match.group(0)!;
    final rest = line.substring(marker.length);
    final markerStyle = baseStyle.copyWith(fontWeight: FontWeight.bold);

    // Unordered marker is stored as "- " but displayed as "• " - same
    // length, so cursor offsets stay perfectly aligned with the real text.
    final display = unorderedMatch != null
        ? '\u2022${marker.substring(1)}'
        : marker;

    return [
      TextSpan(text: display, style: markerStyle),
      ..._parse(rest, baseStyle, lineOffset + marker.length),
    ];
  }

  /// True if the current selection/cursor overlaps [start, end] (absolute
  /// offsets into the full text) - i.e. the user is currently editing
  /// somewhere inside that formatted span, including its delimiters.
  bool _isEditing(int start, int end) {
    if (!selection.isValid) return false;
    return selection.start <= end && selection.end >= start;
  }

  /// Style used for delimiter characters (`**`, `*`, `[color=...]`) when
  /// they should be hidden because the user isn't editing that span.
  /// We keep the characters in the tree (so cursor offsets still line up
  /// with the real text) but collapse them visually.
  TextStyle _hiddenStyle(TextStyle base) {
    return base.copyWith(
      color: Colors.transparent,
      fontSize: 0.01,
      height: 0.01,
      letterSpacing: 0,
    );
  }

  /// [source] is the substring currently being parsed (a single line, or a
  /// nested chunk within one), [offset] is the absolute index of source[0]
  /// within the full `text`, so we can compare match positions against the
  /// real cursor/selection.
  List<InlineSpan> _parse(String source, TextStyle? baseStyle, int offset) {
    final spans = <InlineSpan>[];
    final resolvedBase = baseStyle ?? const TextStyle();
    int start = 0;

    for (final match in _pattern.allMatches(source)) {
      if (match.start > start) {
        spans.add(
          TextSpan(
            text: source.substring(start, match.start),
            style: resolvedBase,
          ),
        );
      }

      final absStart = offset + match.start;
      final absEnd = offset + match.end;
      final editing = _isEditing(absStart, absEnd);

      if (match.group(5) != null) {
        // [font=xxx]...[/font]
        final fontToken = match.group(5)!;
        final inner = match.group(6)!;
        final openTag = '[font=$fontToken]';
        final newStyle = resolvedBase.copyWith(
          fontSize: double.parse(fontToken),
        );
        final delimStyle = editing ? newStyle : _hiddenStyle(newStyle);

        spans.add(TextSpan(text: openTag, style: delimStyle));
        spans.addAll(_parse(inner, newStyle, absStart + openTag.length));
        spans.add(TextSpan(text: '[/font]', style: delimStyle));
      } else if (match.group(1) != null) {
        // [color=xxx]...[/color]
        final colorToken = match.group(1)!;
        final inner = match.group(2)!;
        final openTag = '[color=$colorToken]';
        final newStyle = resolvedBase.copyWith(color: _parseColor(colorToken));
        final delimStyle = editing ? newStyle : _hiddenStyle(newStyle);

        spans.add(TextSpan(text: openTag, style: delimStyle));
        spans.addAll(_parse(inner, newStyle, absStart + openTag.length));
        spans.add(TextSpan(text: '[/color]', style: delimStyle));
      } else if (match.group(3) != null) {
        // **bold**
        final inner = match.group(3)!;
        final newStyle = resolvedBase.copyWith(fontWeight: FontWeight.bold);
        final delimStyle = editing ? newStyle : _hiddenStyle(newStyle);

        spans.add(TextSpan(text: '**', style: delimStyle));
        spans.addAll(_parse(inner, newStyle, absStart + 2));
        spans.add(TextSpan(text: '**', style: delimStyle));
      } else if (match.group(4) != null) {
        // *italic*
        final inner = match.group(4)!;
        final newStyle = resolvedBase.copyWith(fontStyle: FontStyle.italic);
        final delimStyle = editing ? newStyle : _hiddenStyle(newStyle);

        spans.add(TextSpan(text: '*', style: delimStyle));
        spans.addAll(_parse(inner, newStyle, absStart + 1));
        spans.add(TextSpan(text: '*', style: delimStyle));
      }

      start = match.end;
    }

    if (start < source.length) {
      spans.add(TextSpan(text: source.substring(start), style: resolvedBase));
    }

    return spans;
  }

  Color _parseColor(String token) {
    if (token.startsWith('#')) {
      final hex = token.substring(1);
      return Color(int.parse('FF$hex', radix: 16));
    }
    switch (token.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'black':
        return Colors.black;
      default:
        return Colors.black;
    }
  }
}

/// =====================================================================
/// RichTextEditor
/// ---------------------------------------------------------------------
/// Drop-in widget: a small formatting toolbar + a multiline TextField
/// wired up to a RichTextEditingController.
/// =====================================================================
class RichTextEditor extends StatefulWidget {
  const RichTextEditor({super.key, required this.controller, this.hintText});
  final RichTextEditingController controller;
  final String? hintText;

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  static const Map<String, Color> _swatches = {
    'Red': Colors.red,
    'Blue': Colors.blue,
    'Green': Colors.green,
    'Orange': Colors.orange,
    'Purple': Colors.purple,
    'Black': Colors.black,
  };

  static final RegExp _anyListMarker = RegExp(r'^-\s+|^\d+\.\s+');

  void _wrapSelection(String prefix, String suffix) {
    final controller = widget.controller;
    final selection = controller.selection;
    final text = controller.text;

    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;

    if (start == end) {
      final newText = text.replaceRange(start, start, '$prefix$suffix');
      controller.text = newText;
      controller.selection = TextSelection.collapsed(
        offset: start + prefix.length,
      );
      return;
    }

    final selectedText = text.substring(start, end);
    final newText = text.replaceRange(
      start,
      end,
      '$prefix$selectedText$suffix',
    );
    controller.text = newText;
    controller.selection = TextSelection(
      baseOffset: start,
      extentOffset: start + prefix.length + selectedText.length + suffix.length,
    );
  }

  void _applyColor(Color color) {
    final hex =
        '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
    _wrapSelection('[color=$hex]', '[/color]');
  }

  Future<void> _pickColor() async {
    final selected = await showModalBottomSheet<Color>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: _swatches.entries
              .map(
                (e) => ListTile(
                  leading: CircleAvatar(backgroundColor: e.value, radius: 10),
                  title: Text(e.key),
                  onTap: () => Navigator.pop(ctx, e.value),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (selected != null) _applyColor(selected);
  }

  /// Toggles a bulleted or numbered list on the line(s) covered by the
  /// current selection. If every covered (non-blank) line already has that
  /// kind of marker, the markers are removed instead.
  void _toggleList(bool ordered) {
    final controller = widget.controller;
    final text = controller.text;
    final selection = controller.selection;

    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;

    final lineStart = text.lastIndexOf('\n', start - 1) + 1;
    var lineEnd = text.indexOf('\n', end);
    if (lineEnd == -1) lineEnd = text.length;

    final lines = text.substring(lineStart, lineEnd).split('\n');
    final markerRegex = ordered ? RegExp(r'^\d+\.\s+') : RegExp(r'^-\s+');
    final alreadyListed = lines.every(
      (l) => l.trim().isEmpty || markerRegex.hasMatch(l),
    );

    var counter = 1;
    final newLines = lines.map((line) {
      if (alreadyListed) {
        return line.replaceFirst(markerRegex, '');
      }
      if (line.trim().isEmpty) return line;
      final cleaned = line.replaceFirst(_anyListMarker, '');
      final withMarker = ordered ? '${counter++}. $cleaned' : '- $cleaned';
      return withMarker;
    }).toList();

    final newBlock = newLines.join('\n');
    final newText = text.replaceRange(lineStart, lineEnd, newBlock);
    controller.text = newText;
    controller.selection = TextSelection.collapsed(
      offset: lineStart + newBlock.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Bold',
              icon: const Icon(Icons.format_bold),
              onPressed: () => _wrapSelection('**', '**'),
            ),
            IconButton(
              tooltip: 'Italic',
              icon: const Icon(Icons.format_italic),
              onPressed: () => _wrapSelection('*', '*'),
            ),
            IconButton(
              tooltip: 'Text color',
              icon: const Icon(Icons.color_lens_outlined),
              onPressed: _pickColor,
            ),
            IconButton(
              tooltip: 'Bulleted list',
              icon: const Icon(Icons.format_list_bulleted),
              onPressed: () => _toggleList(false),
            ),
            IconButton(
              tooltip: 'Numbered list',
              icon: const Icon(Icons.format_list_numbered),
              onPressed: () => _toggleList(true),
            ),
          ],
        ),
        TextField(
          controller: widget.controller,
          maxLines: null,
          minLines: 4,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: widget.hintText ?? 'Type here...',
          ),
        ),
      ],
    );
  }
}
