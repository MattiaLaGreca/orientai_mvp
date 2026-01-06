import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/ai_service.dart';
import '../services/database_service.dart';
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
  final OrientAIService _aiService = OrientAIService();
  final DatabaseService _dbService = DatabaseService();
  
  bool _isAiTyping = true;
  bool _isInitializing = true;
  String fullResponse = "";

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _streamedResponseNotifier.dispose();
    super.dispose();
  }

  Future<void> _initChat() async {
    // Recupera la cronologia dal DB (metodo aggiunto al punto A)
    String promptDetails = "Interessi: ${widget.interests}; Frequenta: ${widget.schoolType}";
    List<Map<String, dynamic>> chatHistory = await _dbService.getChatHistoryForAI(); 
    String previousSummary = await _dbService.getSummary();
    
    if (previousSummary.isNotEmpty) {
      chatHistory.insert(0, {
        'role': 'system',
        'content': previousSummary,
      });
    }

    // Inizializza l'AI con la cronologia reale
    _aiService.init(widget.studentName, promptDetails, widget.isPremium);
    
    String summary = await _aiService.summarizeChat(widget.isPremium, chatHistory);
    await _dbService.saveSummary("Sommario Chat:\n$summary");
    print("DEBUG: Sommario Chat Iniziale:\n$summary");

    fullResponse = await _aiService.sendMessage(summary);
    await _dbService.sendMessage(fullResponse, false);
    
    if (mounted) {
      setState(() {
        _isInitializing = false;
        _isAiTyping = false;
      });
    }
  }

  // Feature: Scroll automatico all'ultimo messaggio
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0, // ListView ha reverse: true, quindi 0 è la fine
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    
    // Salva messaggio UTENTE
    await _dbService.sendMessage(text, true);
    
    _streamedResponseNotifier.value = "";
    setState(() {
      _isAiTyping = true;
    });
    
    if (widget.isPremium) {
      fullResponse = await _aiService.sendMessageWithStreaming(text, (chunk) {
        if (mounted) {
          _streamedResponseNotifier.value = chunk; // Aggiorna UI in tempo reale
          _scrollToBottom();
        }
      });
    }
    else {
      fullResponse = await _aiService.sendMessage(text);
    }

    // Salva risposta AI
    await _dbService.sendMessage(fullResponse, false);
    
    if (mounted) {
      setState(() {
        _isAiTyping = false;
      });
    }
  }

  Future<void> _logout() async {
    await _dbService.signOut();
    // Il main.dart riporterà l'utente al Login
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
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout))
        ],
      ),
      body: _isInitializing 
          ? const Center(child: CircularProgressIndicator()) 
          : Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _dbService.getMessagesStream(widget.isPremium),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data!.docs;

                      return ListView.builder(
                        controller: _scrollController, // Colleghiamo il controller
                        reverse: true,
                        padding: const EdgeInsets.all(16),
                        // Aggiungiamo +1 al count se l'AI sta scrivendo per mostrare il messaggio "fantasma"
                        itemCount: docs.length + (_isAiTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Se stiamo scrivendo, il primo elemento (index 0) è lo stream
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
                                    return MarkdownBody(data: "$value ▋");
                                  },
                                ), // Cursore lampeggiante
                              ),
                            );
                          }

                          // Shift dell'indice se c'è lo stream in corso
                          final dbIndex = _isAiTyping ? index - 1 : index;
                          final data = docs[dbIndex].data() as Map<String, dynamic>;
                          final isUser = data['isUser'] ?? false;

                          return Align(
                            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(12),
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
                              decoration: BoxDecoration(
                                color: isUser ? themeColor : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                              ),
                              child: MarkdownBody(
                                data: data['text'] ?? '',
                                styleSheet: MarkdownStyleSheet(
                                  p: TextStyle(color: isUser ? Colors.white : Colors.black87),
                                  strong: TextStyle(color: isUser ? Colors.white : themeColor, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                // Input Area (rimane simile ma invoca il nuovo _handleSend)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: "Scrivi un messaggio...",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                          onSubmitted: (_) => _isAiTyping ? null : _handleSend(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _isAiTyping ? null : _handleSend,
                        color: themeColor,
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }
}