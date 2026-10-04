import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/chat.dart';
import '../../services/chat_service.dart';
import 'chat_room_screen.dart';

class ChatsListScreen extends StatelessWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        final user = authSnap.data;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title:
                const Text('Chats', style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: user == null
              ? const Center(
                  child: Text('Log in to see chats',
                      style: TextStyle(color: Colors.black54)))
              : StreamBuilder<List<ChatThread>>(
                  stream: ChatService.streamMyThreads(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFFF3BDC3)));
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Could not load chats.\n${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.black54, fontSize: 13),
                          ),
                        ),
                      );
                    }
                    final threads = snapshot.data ?? [];
                    if (threads.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline_rounded,
                                  size: 64, color: Colors.black38),
                              SizedBox(height: 16),
                              Text('No chats yet',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Text(
                                  'Start a conversation from any listing, guide, or vehicle.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                      height: 1.4)),
                            ],
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: threads.length,
                      separatorBuilder: (_, __) => const Divider(
                          height: 1, color: Colors.black12),
                      itemBuilder: (context, i) {
                        final t = threads[i];
                        final unread = t.unreadFor(user.uid);
                        return ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 6),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 52,
                              height: 52,
                              child: t.listingPhoto.isNotEmpty
                                  ? Image.network(t.listingPhoto,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => _ph())
                                  : _ph(),
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(t.otherName(user.uid),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                              ),
                              if (t.roleLabel(user.uid).isNotEmpty)
                                Container(
                                  margin:
                                      const EdgeInsets.only(left: 6),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: t.amHost(user.uid)
                                        ? const Color(0xFFE8F5E9)
                                        : const Color(0xFFFFF0F3),
                                    borderRadius:
                                        BorderRadius.circular(8),
                                    border: Border.all(
                                      color: t.amHost(user.uid)
                                          ? Colors.green.shade200
                                          : const Color(0xFFF3BDC3),
                                    ),
                                  ),
                                  child: Text(
                                    t.roleLabel(user.uid),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: t.amHost(user.uid)
                                          ? Colors.green.shade800
                                          : const Color(0xFFE91E63),
                                    ),
                                  ),
                                ),
                              if (unread > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE91E63),
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                  child: Text('$unread',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (t.listingName.isNotEmpty)
                                Text(t.listingName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.black45)),
                              const SizedBox(height: 2),
                              Text(
                                  t.lastMessage.isEmpty
                                      ? 'Say hi 👋'
                                      : t.lastMessage,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: unread > 0
                                        ? Colors.black87
                                        : Colors.black54,
                                    fontWeight: unread > 0
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  )),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatRoomScreen(thread: t),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _ph() => Container(
        color: const Color(0xFFFFF0F3),
        child: const Icon(Icons.chat_bubble_outline,
            color: Color(0xFFF3BDC3)),
      );
}