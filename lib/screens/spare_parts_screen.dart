import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SparePartsScreen extends StatefulWidget {
  const SparePartsScreen({super.key});

  @override
  State<SparePartsScreen> createState() => _SparePartsScreenState();
}

class _SparePartsScreenState extends State<SparePartsScreen> {
  final _firestore = FirebaseFirestore.instance;

  Future<String?> _pickAndEncodeImage() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 60);
    if (file == null) return null;

    late List<int> bytes;
    if (kIsWeb) {
      bytes = await file.readAsBytes();
    } else {
      final compressed = await FlutterImageCompress.compressWithFile(
        File(file.path).absolute.path,
        quality: 40,
        minWidth: 600,
        minHeight: 600,
      );
      bytes = compressed ?? await File(file.path).readAsBytes();
    }
    return base64Encode(bytes);
  }

  void _showNewRequestDialog(BuildContext context, String userId) {
    final descCtrl = TextEditingController();
    List<String> base64Images = [];
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModalState) {
          return AlertDialog(
            title: const Text("New Spare Part Request"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: descCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: "Describe the part you need",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (base64Images.isNotEmpty)
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: base64Images.length,
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(base64Decode(base64Images[i]), width: 80, height: 80, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text("Add Image"),
                    onPressed: () async {
                      final encoded = await _pickAndEncodeImage();
                      if (encoded != null) {
                        setModalState(() => base64Images.add(encoded));
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C5364), foregroundColor: Colors.white),
                onPressed: isLoading ? null : () async {
                  if (descCtrl.text.isEmpty) return;
                  setModalState(() => isLoading = true);
                  await _firestore.collection('spare_part_requests').add({
                    'user_id': userId,
                    'description': descCtrl.text,
                    'image_base64_list': base64Images,
                    'status': 'pending',
                    'proposed_price': null,
                    'created_at': DateTime.now().toIso8601String(),
                  });
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text("Submit"),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text("Spare Parts"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2C5364),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("New Request"),
        onPressed: () => _showNewRequestDialog(context, userId),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('spare_part_requests')
            .where('user_id', isEqualTo: userId)
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.settings, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No spare part requests yet.", style: TextStyle(color: Colors.grey, fontSize: 18)),
                ],
              ),
            );
          }
          final docs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final status = data['status'] ?? 'pending';
              final images = List<String>.from(data['image_base64_list'] ?? []);
              return _buildRequestCard(ctx, docs[i].id, data, status, images);
            },
          );
        },
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'accepted': return Colors.green;
      case 'declined': return Colors.red;
      case 'complete': return Colors.blue;
      default: return Colors.orange;
    }
  }

  Widget _buildRequestCard(BuildContext ctx, String docId, Map<String, dynamic> data, String status, List<String> images) {
    final proposedPrice = data['proposed_price'];
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => SparePartDetailScreen(requestId: docId, data: data))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _statusColor(status)),
                    ),
                    child: Text(status.toUpperCase(), style: TextStyle(color: _statusColor(status), fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  const Spacer(),
                  if (proposedPrice != null)
                    Text("\$${proposedPrice.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C5364), fontSize: 16)),
                ],
              ),
              const SizedBox(height: 12),
              Text(data['description'] ?? '', style: const TextStyle(fontSize: 15), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 12),
              if (images.isNotEmpty)
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length,
                    itemBuilder: (_, idx) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(base64Decode(images[idx]), width: 70, height: 70, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text("Tap to open chat", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Detail/Chat Screen ----------

class SparePartDetailScreen extends StatefulWidget {
  final String requestId;
  final Map<String, dynamic> data;

  const SparePartDetailScreen({super.key, required this.requestId, required this.data});

  @override
  State<SparePartDetailScreen> createState() => _SparePartDetailScreenState();
}

class _SparePartDetailScreenState extends State<SparePartDetailScreen> {
  final _firestore = FirebaseFirestore.instance;
  final TextEditingController _msgCtrl = TextEditingController();

  Future<void> _sendMessage(String userId, String text) async {
    if (text.trim().isEmpty) return;
    await _firestore
        .collection('spare_part_requests')
        .doc(widget.requestId)
        .collection('chats')
        .add({
      'sender_id': userId,
      'sender_role': 'user',
      'text': text.trim(),
      'timestamp': DateTime.now().toIso8601String(),
    });
    _msgCtrl.clear();
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'accepted': return Colors.green;
      case 'declined': return Colors.red;
      case 'complete': return Colors.blue;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.currentUser?.uid ?? '';
    final status = widget.data['status'] ?? 'pending';
    final images = List<String>.from(widget.data['image_base64_list'] ?? []);
    final proposedPrice = widget.data['proposed_price'];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text("Request Details"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Request summary header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _statusColor(status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _statusColor(status)),
                      ),
                      child: Text(status.toUpperCase(), style: TextStyle(color: _statusColor(status), fontWeight: FontWeight.bold)),
                    ),
                    if (proposedPrice != null) ...[
                      const Spacer(),
                      Text("Price: \$${proposedPrice.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF2C5364))),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Text(widget.data['description'] ?? '', style: const TextStyle(fontSize: 15)),
                if (images.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      itemBuilder: (_, idx) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(base64Decode(images[idx]), width: 80, height: 80, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
          const Divider(height: 1),

          // Chat messages
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('spare_part_requests')
                  .doc(widget.requestId)
                  .collection('chats')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final msgs = snap.data!.docs;
                if (msgs.isEmpty) {
                  return const Center(child: Text("No messages yet. Start the conversation.", style: TextStyle(color: Colors.grey)));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: msgs.length,
                  itemBuilder: (_, i) {
                    final msg = msgs[i].data() as Map<String, dynamic>;
                    final isUser = msg['sender_role'] == 'user';
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                        decoration: BoxDecoration(
                          color: isUser ? const Color(0xFF2C5364) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)],
                        ),
                        child: Text(
                          msg['text'] ?? '',
                          style: TextStyle(color: isUser ? Colors.white : Colors.black87),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Message input bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF2C5364),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () => _sendMessage(userId, _msgCtrl.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
