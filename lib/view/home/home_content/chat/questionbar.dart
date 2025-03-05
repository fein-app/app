import 'package:fein_app/view/home/home_content/chat/questionbar/sendbutton.dart';
import 'package:flutter/material.dart';

class QuestionBar extends StatefulWidget {
  final Future<void> Function(String) onSubmitted;
  const QuestionBar({super.key, required this.onSubmitted});

  @override
  State<QuestionBar> createState() => _QuestionBarState();
}

class _QuestionBarState extends State<QuestionBar> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _handleSubmit(String value) async {
    if (value.trim().isEmpty) return;
    await widget.onSubmitted(value);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 700,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF2c2c2c),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.only(left: 20, right: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 400,
              ),
              child: SingleChildScrollView(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Message ...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey),
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onSubmitted: _handleSubmit,
                  maxLines: null,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  scrollPhysics: const ClampingScrollPhysics(),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: SendButton(
              onSubmitted: _handleSubmit,
              controller: _controller,
            )
          )
        ],
      ),
    );
  }
}