import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';

class CodeEditorWidget extends StatefulWidget {
  final String initialContent;
  final ValueChanged<String>? onChanged;
  final bool readOnly;

  const CodeEditorWidget({
    super.key,
    this.initialContent = '',
    this.onChanged,
    this.readOnly = false,
  });

  @override
  State<CodeEditorWidget> createState() => _CodeEditorWidgetState();
}

class _CodeEditorWidgetState extends State<CodeEditorWidget> {
  late CodeLineEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CodeLineEditingController.fromText(widget.initialContent);
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(CodeEditorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialContent != widget.initialContent) {
      _controller.removeListener(_onTextChanged);
      _controller = CodeLineEditingController.fromText(widget.initialContent);
      _controller.addListener(_onTextChanged);
    }
  }

  void _onTextChanged() {
    widget.onChanged?.call(_controller.text);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  String get text => _controller.text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CodeEditor(
          controller: _controller,
          readOnly: widget.readOnly,
          style: CodeEditorStyle(
            fontSize: 14,
            fontFamily: 'monospace',
            backgroundColor: isDark
                ? theme.colorScheme.surfaceContainerHighest
                : theme.colorScheme.surface,
            textColor: theme.colorScheme.onSurface,
          ),
          indicatorBuilder: (context, editingController, chunkController, notifier) {
            return Row(
              children: [
                DefaultCodeLineNumber(
                  controller: editingController,
                  notifier: notifier,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
