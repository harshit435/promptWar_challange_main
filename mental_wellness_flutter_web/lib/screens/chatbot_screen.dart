import 'dart:async';
import 'package:flutter/material.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Welcome message
    _messages.add(
      ChatMessage(
        text:
            "Hello! I am your ZenBot Companion. 🌿\n\nPreparing for high-stakes exams (like JEE, NEET, UPSC, or Boards) can be an intense journey. I am here 24/7 to listen, help you manage stress, reframe self-doubt, or suggest study-break exercises. How are you holding up today?",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    _inputController.clear();
    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
    });
    _scrollToBottom();

    // Simulate thinking delay (1.2 seconds)
    Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      final reply = _getBotReply(text);
      setState(() {
        _isTyping = false;
        _messages.add(
          ChatMessage(
            text: reply,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();
    });
  }

  String _getBotReply(String userMessage) {
    final msg = userMessage.toLowerCase();

    // 1. Mock tests / exam scores
    if (msg.contains('mock') ||
        msg.contains('score') ||
        msg.contains('marks') ||
        msg.contains('test') ||
        msg.contains('fail')) {
      return "I hear your worry. Mock test scores are NOT final exam results—they are diagnostic toolkits designed to highlight knowledge gaps. \n\nInstead of viewing a low score as a failure, try this framework:\n1. Dedicate 60 minutes to error analysis (where did you make silly mistakes vs. conceptual gaps?).\n2. Reframe: 'Making mistakes now is great because it means I won't make them on the actual exam day.'\n3. Take a 10-minute visual break right now.";
    }

    // 2. Backlog / syllabus / revision time
    if (msg.contains('backlog') ||
        msg.contains('syllabus') ||
        msg.contains('revision') ||
        msg.contains('time') ||
        msg.contains('study')) {
      return "Backlog anxiety is incredibly common. The secret is to avoid trying to fix it all in one day.\n\nTry the **70/30 Study Rule**:\n- Spend **70%** of your daily study block on your current running syllabus topics.\n- Spend **30%** of your time on a fixed backlog sub-topic (e.g., 1 hour daily).\n\nConsistently chipping away is far better than burning out trying to catch up in a week. You are making progress, keep going!";
    }

    // 3. Sleep / tired / exhaustion
    if (msg.contains('sleep') ||
        msg.contains('tired') ||
        msg.contains('exhaust') ||
        msg.contains('insomnia') ||
        msg.contains('night')) {
      return "Your brain consolidates all your study formulas and concepts during deep REM sleep. Cutting sleep to study actually decreases retention!\n\nIf your mind is racing tonight:\n1. Write down whatever you are worried about in our **Worry Shredder** to clear your working memory.\n2. Do a 5-minute **Box Breathing** session.\n3. Keep screens away 30 mins before bed. Prioritize getting 7+ hours. Your score will thank you!";
    }

    // 4. Parents / family expectations
    if (msg.contains('parent') ||
        msg.contains('family') ||
        msg.contains('expect') ||
        msg.contains('mother') ||
        msg.contains('father')) {
      return "Dealing with parental expectations on top of exam prep is heavy. Most parents put pressure out of care, but it can feel suffocating.\n\nRemember: **Your value as an individual is completely separate from your rank or exam scores.** \n\nTry having an honest, calm chat with them. Tell them: 'I am giving my 100% effort, and your support helps me stay focused more than pressure.' Focus on your daily effort, which is the only thing in your control.";
    }

    // 5. Peer comparison / pressure
    if (msg.contains('peer') ||
        msg.contains('friend') ||
        msg.contains('others') ||
        msg.contains('rank') ||
        msg.contains('compare')) {
      return "It is so easy to fall into the comparison trap when everyone is talking about their scores. But comparison is the thief of joy.\n\nEvery aspirant has a different learning curve. Some memorize fast, some solve problems better. \n\nThe only score that matters is your own progress. Compare yourself today to yourself last week. If you resolved even 1 concept gap, you are winning. Mute group chats that trigger anxiety.";
    }

    // 6. Stress / anxious / panic
    if (msg.contains('stress') ||
        msg.contains('anxious') ||
        msg.contains('panic') ||
        msg.contains('scared') ||
        msg.contains('worry')) {
      return "Take a slow, deep breath right now. Inhale for 4 seconds... Hold... Exhale for 4 seconds... \n\nExam anxiety is a physiological response. When you feel panic rising, your prefrontal cortex (rational brain) goes offline. \n\nLet's reset. I recommend going to the **Breathing Circle** tool on the dashboard right now, or writing your panic in the **Stress Shredder** to dump it out. You can handle this.";
    }

    // General Fallback
    return "Thank you for sharing that. Preparing for competitive exams is as much a mental game as it is academic. It is completely normal to feel overwhelmed.\n\nTell me more about what is on your mind, or try our Box Breathing and Worry Shredder tools to reset your focus. I'm right here with you.";
  }

  @override
  Widget build(BuildContext context) {
    final borderCol = Colors.white.withOpacity(0.06);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Banner introducing the assistant
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0C0E1A),
              border: Border(bottom: BorderSide(color: borderCol)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF64FFDA).withOpacity(0.1),
                  child: const Icon(Icons.smart_toy_rounded,
                      color: Color(0xFF64FFDA), size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Wellness Companion',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Mock test coaching, backlog reframing, and stress management guide.',
                        style: TextStyle(color: Colors.white38, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Typing Indicator
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 12),
              child: Row(
                children: [
                  Text(
                    'ZenBot is writing',
                    style: TextStyle(
                        color: const Color(0xFF64FFDA).withOpacity(0.7),
                        fontSize: 11,
                        fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(width: 4),
                  const _TypingDots(),
                ],
              ),
            ),

          // Input Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF090A14),
              border: Border(top: BorderSide(color: borderCol)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    onSubmitted: (_) => _sendMessage(),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText:
                          'Ask about mock test anxiety, backlogs, sleep schedules...',
                      hintStyle:
                          const TextStyle(color: Colors.white24, fontSize: 13),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide:
                            BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide:
                            BorderSide(color: Colors.white.withOpacity(0.06)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFF64FFDA)),
                      ),
                      filled: true,
                      fillColor: Colors.black12,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: _sendMessage,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF64FFDA),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: Color(0xFF0C0E1A), size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    final alignment =
        isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleBg =
        isUser ? const Color(0xFF1E293B) : Colors.white.withOpacity(0.03);
    final border = isUser
        ? Border.all(color: Colors.white.withOpacity(0.08))
        : Border.all(color: const Color(0xFF64FFDA).withOpacity(0.15));

    final radius = isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isUser) ...[
                const Icon(Icons.spa_rounded,
                    color: Color(0xFF64FFDA), size: 14),
                const SizedBox(width: 6),
                const Text('ZenBot',
                    style: TextStyle(
                        color: Color(0xFF64FFDA),
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ] else ...[
                const Text('You',
                    style: TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
                const SizedBox(width: 6),
                const Icon(Icons.person_outline_rounded,
                    color: Colors.white38, size: 14),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bubbleBg,
              borderRadius: radius,
              border: border,
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.white.withOpacity(0.9),
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

// Typing indicators micro-animation
class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final val = (_controller.value * 3).floor();
        String dots = ".";
        if (val == 1) dots = "..";
        if (val == 2) dots = "...";
        return Text(
          dots,
          style: const TextStyle(
              color: Color(0xFF64FFDA),
              fontSize: 12,
              fontWeight: FontWeight.bold),
        );
      },
    );
  }
}
