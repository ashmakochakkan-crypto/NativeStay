import 'package:cloud_firestore/cloud_firestore.dart';

class ChatThread {
  final String id;
  final List<String> participants; // [uid1, uid2] sorted
  final Map<String, String> participantNames;
  final String listingId;     // '' for direct
  final String listingType;   // 'homestay' | 'guide' | 'vehicle' | 'direct'
  final String listingName;
  final String listingPhoto;
  final String hostUid;       // owner of the listing (for role tag)
  final String lastMessage;
  final DateTime? lastMessageAt;
  final Map<String, int> unreadCounts; // uid -> count

  const ChatThread({
    required this.id,
    required this.participants,
    required this.participantNames,
    required this.listingId,
    required this.listingType,
    required this.listingName,
    required this.listingPhoto,
    required this.hostUid,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCounts,
  });

  /// Am I the host (owner of the listing) in this chat?
  bool amHost(String me) => hostUid.isNotEmpty && hostUid == me;

  /// Role label shown next to my name in the chat list.
  String roleLabel(String me) {
    if (hostUid.isEmpty) return '';
    return amHost(me) ? 'Host' : 'Traveller';
  }

  String otherUid(String me) =>
      participants.firstWhere((p) => p != me, orElse: () => me);

  String otherName(String me) => participantNames[otherUid(me)] ?? 'User';

  int unreadFor(String uid) => unreadCounts[uid] ?? 0;

  factory ChatThread.fromDoc(String id, Map<String, dynamic> m) {
    DateTime? last;
    final raw = m['lastMessageAt'];
    if (raw is Timestamp) last = raw.toDate();

    return ChatThread(
      id: id,
      participants: List<String>.from(m['participants'] ?? []),
      participantNames: Map<String, String>.from(m['participantNames'] ?? {}),
      listingId: (m['listingId'] ?? '').toString(),
      listingType: (m['listingType'] ?? 'direct').toString(),
      listingName: (m['listingName'] ?? '').toString(),
      listingPhoto: (m['listingPhoto'] ?? '').toString(),
      hostUid: (m['hostUid'] ?? '').toString(),
      lastMessage: (m['lastMessage'] ?? '').toString(),
      lastMessageAt: last,
      unreadCounts: Map<String, int>.from(
        (m['unreadCounts'] ?? {}).map(
            (k, v) => MapEntry(k.toString(), (v as num).toInt())),
      ),
    );
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime? createdAt;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.createdAt,
  });

  factory ChatMessage.fromDoc(String id, Map<String, dynamic> m) {
    DateTime? ts;
    final raw = m['createdAt'];
    if (raw is Timestamp) ts = raw.toDate();
    return ChatMessage(
      id: id,
      senderId: (m['senderId'] ?? '').toString(),
      text: (m['text'] ?? '').toString(),
      createdAt: ts,
    );
  }
}