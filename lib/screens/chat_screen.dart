import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/ai_service.dart';
import '../services/database_service.dart';
import '../utils/secure_logger.dart';
import '../utils/validators.dart';
import 'profile_screen.dart';

class ChatScreen extends StatefulWidget {
  final String studentName;
  final String interests;
  final String schoolType;
  final bool isPremium;

  const ChatScreen({
    super.key,
    required this.studentName,
    required this.interests,
    required this.schoolType,
    required this.isPremium,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<String> _streamedResponseNotifier = ValueNotifier("");
  final ValueNotifier<bool> _showClearButtonNotifier = ValueNotifier(false);
  final OrientAIService _aiService = OrientAIService();
  final DatabaseService _dbService = DatabaseService();

  late Stream<QuerySnapshot> _messagesStream;
  late final MarkdownStyleSheet _userStyleSheet;
  late final MarkdownStyleSheet _aiStyleSheet;

  bool _isAiTyping = true;
  bool _isInitializing = true;
  String fullResponse = "";

  // Ads
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _messagesStream = _dbService.getMessagesStream(widget.isPremium);

    // ⚡ Bolt Optimization: Pre-calculate stylesheets to avoid recreation
    final themeColor = widget.isPremium ? Colors.black87 : Colors.indigo;
    _userStyleSheet = MarkdownStyleSheet(
      p: const TextStyle(color: Colors.white),
      strong: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    );
    _aiStyleSheet = MarkdownStyleSheet(
      p: const TextStyle(color: Colors.black87),
      strong: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
    );

    _initChat();

    // Inizializza Ads solo se non è premium
    if (!widget.isPremium) {
      _loadBannerAd();
    }
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test ID
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          SecureLogger.log('BannerAd', 'Failed to load: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _scrollController.dispose();
    _streamedResponseNotifier.dispose();
    _showClearButtonNotifier.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _initChat() async {
    try {
      final results = await Future.wait([
        _dbService.getChatHistoryForAI(widget.isPremium),
        _dbService.getSummary(),
      ]);

    List<Map<String, dynamic>> newMessages =
        results[0] as List<Map<String, dynamic>>;
    String previousSummary = results[1] as String;

    String promptDetails =
        "Interessi: ${widget.interests}; Frequenta: ${widget.schoolType}";

    _aiService.init(widget.studentName, promptDetails, widget.isPremium);

    String summary;
    bool shouldSaveSummary = true;

    // ⚡ Bolt Optimization: Skip redundant summarization if no new messages
    if (newMessages.isEmpty && previousSummary.isNotEmpty) {
      // Strip prefix to reuse content
      summary = previousSummary.replaceFirst("Sommario Chat:\n", "");
      shouldSaveSummary = false;
      SecureLogger.log(
          "ChatScreen", "Optimized: Skipped summarization (No new messages)");
    } else {
      List<Map<String, dynamic>> chatHistory = newMessages;
      if (previousSummary.isNotEmpty) {
        chatHistory.insert(0, {
          'role': 'system',
          'content': previousSummary,
        });
      }
      summary = await _aiService.summarizeChat(widget.isPremium, chatHistory);
      SecureLogger.log("ChatScreen", "Sommario Iniziale: $summary");
    }

    final aiResults = await Future.wait([
      _aiService.sendMessage(summary),
      shouldSaveSummary
          ? _dbService.saveSummary("Sommario Chat:\n$summary")
          : Future.value(),
    ]);

      fullResponse = aiResults[0] as String;
      await _dbService.sendMessage(fullResponse, false);
    } catch (e) {
      SecureLogger.log("ChatScreen", "Init Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _isAiTyping = false;
        });
      }
    }
  }

  void _onTextChanged() {
    // ⚡ Bolt Optimization: Use ValueNotifier instead of setState to avoid rebuilding entire ChatScreen on every keystroke
    _showClearButtonNotifier.value = _controller.text.isNotEmpty;
  }

  // 🔒 Sentinel Security: Prevent malicious links
  void _handleLinkTap(String text, String? href, String title) {
    if (href == null) return;

    if (!Validators.isSafeUrl(href)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Link bloccato per sicurezza (protocollo non supportato)."),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    // Launch safe URL
    launchUrl(Uri.parse(href), mode: LaunchMode.externalApplication).ignore();
  }

  void _sendSuggestion(String text) {
    _controller.text = text;
    _handleSend();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _handleSend() async {
    // 🔒 Sentinel Security: Input Sanitization
    var text = _controller.text;

    // 1. Enforce Max Length (DoS protection)
    if (text.length > 2000) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Messaggio troppo lungo (max 2000 caratteri)."),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // 2. Sanitize Input (remove control chars & trim)
    text = Validators.cleanMessage(text);
    if (text.isEmpty) return;

    // ⚡ Bolt Optimization: Optimistic UI Updates & Parallel Execution
    // Clear input and show typing indicator immediately (0ms latency)
    _controller.clear();
    _streamedResponseNotifier.value = "";
    if (mounted) {
      setState(() {
        _isAiTyping = true;
      });
      // ⚡ Bolt Optimization: Scroll once at start (post-frame) instead of on every chunk
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }

    try {
      // Start DB write (User Message) and AI request in parallel.
      // We don't await the DB write immediately so the AI request starts ASAP.
      final userMessageSaveFuture = _dbService.sendMessage(text, true);

      if (widget.isPremium) {
        fullResponse = await _aiService.sendMessageWithStreaming(text, (chunk) {
          if (mounted) {
            _streamedResponseNotifier.value = chunk;
            // ⚡ Bolt Optimization: Removed redundant _scrollToBottom() call
            // ListView(reverse: true) automatically handles content growth from bottom anchor.
          }
        });
      } else {
        fullResponse = await _aiService.sendMessage(text);
      }

      // Ensure user message is saved before saving AI response.
      // This maintains data integrity while having allowed parallelism during AI latency.
      await userMessageSaveFuture;

      // Save AI Response
      await _dbService.sendMessage(fullResponse, false);
    } catch (e) {
      SecureLogger.log("ChatScreen", "Send Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Errore durante l'invio: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAiTyping = false;
        });
      }
    }
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          userData: {
            'name': widget.studentName,
            'interests': widget.interests,
            'school': widget.schoolType,
            // 'isPremium': widget.isPremium // ProfileScreen might need this but checking its constructor, it takes a Map
          },
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await _dbService.signOut();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "Ciao ${widget.studentName}!",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Non ci sono messaggi. Scrivi qualcosa per iniziare la conversazione!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              alignment: WrapAlignment.center,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.school_outlined,
                      size: 16, color: Colors.indigo),
                  label: const Text("Quali facoltà esistono?"),
                  onPressed: () => _sendSuggestion("Quali facoltà esistono?"),
                  backgroundColor: Colors.indigo[50],
                  side: BorderSide.none,
                  labelStyle: const TextStyle(color: Colors.indigo),
                ),
                ActionChip(
                  avatar: const Icon(Icons.help_outline,
                      size: 16, color: Colors.indigo),
                  label: const Text("Come funziona l'università?"),
                  onPressed: () =>
                      _sendSuggestion("Come funziona l'università?"),
                  backgroundColor: Colors.indigo[50],
                  side: BorderSide.none,
                  labelStyle: const TextStyle(color: Colors.indigo),
                ),
                ActionChip(
                  avatar: const Icon(Icons.lightbulb_outline,
                      size: 16, color: Colors.indigo),
                  label: const Text("Aiutami a scegliere"),
                  onPressed: () =>
                      _sendSuggestion("Aiutami a scegliere il mio percorso."),
                  backgroundColor: Colors.indigo[50],
                  side: BorderSide.none,
                  labelStyle: const TextStyle(color: Colors.indigo),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.isPremium ? Colors.black87 : Colors.indigo;

    return Scaffold(
      appBar: AppBar(
        title: const Text("OrientAI"),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _openProfile,
            icon: const Icon(Icons.person),
            tooltip: "Profilo",
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: "Esci",
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isInitializing)
            const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: Colors.transparent,
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty && !_isAiTyping) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: docs.length + (_isAiTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isAiTyping && index == 0) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ValueListenableBuilder<String>(
                            valueListenable: _streamedResponseNotifier,
                            builder: (context, value, child) {
                              return MarkdownBody(
                                data: "$value ▋",
                                onTapLink: _handleLinkTap,
                              );
                            },
                          ),
                        ),
                      );
                    }

                    final dbIndex = _isAiTyping ? index - 1 : index;
                    final data = docs[dbIndex].data() as Map<String, dynamic>;
                    final isUser = data['isUser'] ?? false;

                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.85,
                        ),
                        decoration: BoxDecoration(
                          color: isUser ? themeColor : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 4),
                          ],
                        ),
                        child: MarkdownBody(
                          data: data['text'] ?? '',
                          styleSheet: isUser ? _userStyleSheet : _aiStyleSheet,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _showClearButtonNotifier,
                    builder: (context, showClearButton, child) {
                      return TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.send,
                        maxLength: 2000,
                        decoration: InputDecoration(
                          hintText: "Scrivi un messaggio...",
                          counterText: "",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          suffixIcon: showClearButton
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _controller.clear();
                                  },
                                  tooltip: "Cancella testo",
                                )
                              : null,
                        ),
                        onSubmitted: (_) => _isAiTyping ? null : _handleSend(),
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isAiTyping ? null : _handleSend,
                  color: themeColor,
                  tooltip: "Invia messaggio",
                ),
              ],
            ),
          ),
          if (_isBannerAdReady && _bannerAd != null)
            SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }
}
