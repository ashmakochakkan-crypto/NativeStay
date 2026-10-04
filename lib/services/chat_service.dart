import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat.dart';

class ChatService {
  static CollectionReference<Map<String, dynamic>> get _threads =>
      FirebaseFirestore.instance.collection('chat_threads');

  /// Deterministic thread id: listingId + two uids sorted.
  static String threadId({
    required String listingId,
    required String uidA,
    required String uidB,
  }) {
    final sorted = [uidA, uidB]..sort();
    final safeListing = listingId.isEmpty ? 'direct' : listingId;
    return '${safeListing}_${sorted[0]}_${sorted[1]}';
  }

  /// Ensure thread exists, then return its id.
  static Future<String> ensureThread({
    required String listingId,
    required String listingType,
    required String listingName,
    required String listingPhoto,
    required String myUid,
    required String myName,
    required String otherUid,
    required String otherName,
    required String hostUid,
  }) async {
    final tid = threadId(listingId: listingId, uidA: myUid, uidB: otherUid);
    final ref = _threads.doc(tid);
    final snap = await ref.get();

    if (!snap.exists) {
      final sorted = [myUid, otherUid]..sort();
      final names = {myUid: myName, otherUid: otherName};
      await ref.set({
        'participants': sorted,
        'participantNames': names,
        'listingId': listingId,
        'listingType': listingType,
        'listingName': listingName,
        'listingPhoto': listingPhoto,
        'hostUid': hostUid,
        'lastMessage': '',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'unreadCounts': {myUid: 0, otherUid: 0},
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return tid;
  }

  /// Stream messages for a thread (oldest → newest).
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamMessages(
      String threadId) {
    return _threads
        .doc(threadId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  /// Stream of threads I'm part of (sorted client-side).
  static Stream<List<ChatThread>> streamMyThreads(String uid) {
    return _threads
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => ChatThread.fromDoc(d.id, d.data()))
          .toList();
      list.sort((a, b) {
        final ad = a.lastMessageAt ?? DateTime(1970);
        final bd = b.lastMessageAt ?? DateTime(1970);
        return bd.compareTo(ad);
      });
      return list;
    });
  }

  /// Send a message.
  static Future<void> sendMessage({
    required String threadId,
    required String senderId,
    required String otherUid,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final tRef = _threads.doc(threadId);
    await tRef.collection('messages').add({
      'senderId': senderId,
      'text': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await tRef.update({
      'lastMessage': trimmed,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'unreadCounts.$senderId': 0,
      'unreadCounts.$otherUid': FieldValue.increment(1),
    });
  }

  /// Mark thread as read for me.
  static Future<void> markRead({
    required String threadId,
    required String uid,
  }) async {
    await _threads.doc(threadId).update({
      'unreadCounts.$uid': 0,
    });
  }
}