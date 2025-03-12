import 'package:chat_app/data/models/chat_message.dart';
import 'package:chat_app/data/models/chat_room_model.dart';
import 'package:chat_app/data/services/base_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRepository extends BaseRepository {
  CollectionReference get _chatRooms => db.collection("ChatRooms");

  CollectionReference getChatRoomMessages(String chatRoomId) =>
      _chatRooms.doc(chatRoomId).collection("Messages");

  Future<ChatRoomModel> getOrCreateChatRoom({
    required String currentUserId,
    required String otherUserId,
  }) async {
    final users = [currentUserId, otherUserId]..sort();
    final roomId = users.join("_");
    final roomDoc = await _chatRooms.doc(roomId).get();
    if (roomDoc.exists) {
      return ChatRoomModel.fromFirestore(roomDoc);
    }
    final currentUserDoc =
        (await db.collection("Users").doc(currentUserId).get()).data()
            as Map<String, dynamic>;
    final otherUserDoc =
        (await db.collection("Users").doc(currentUserId).get()).data()
            as Map<String, dynamic>;

    final participantsName = {
      currentUserId: currentUserDoc['fullName']?.toString() ?? "",
      otherUserId: otherUserDoc['fullName']?.toString() ?? "",
    };

    final newRoom = ChatRoomModel(
      id: roomId,
      participants: users,
      participantsName: participantsName,
      lastReadTime: {
        currentUserId: Timestamp.now(),
        otherUserId: Timestamp.now(),
      },
    );

    await _chatRooms.doc(roomId).set(newRoom.toMap());
    return newRoom;
  }

  Future<void> sendMessage({
    required String chatRoomId,
    required String content,
    required String senderId,
    required String receiverId,
  }) async {
    final batch = db.batch();

    // get message subcollection
    final messageRef = getChatRoomMessages(chatRoomId);
    final messageDoc = await messageRef.doc();

    // Chat message
    final message = ChatMessage(
      id: messageDoc.id,
      chatRoomId: chatRoomId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      timestamp: Timestamp.now(),
      readBy: [senderId],
    );

    batch.set(messageDoc, message.toMap());
    batch.update(_chatRooms.doc(chatRoomId), {
      "lastMessage": content,
      "lastMessageSenderId": senderId,
      "lastMessageTime": message.timestamp,
    });
    await batch.commit();
  }

  Stream<List<ChatMessage>> getMessages({
    required String chatRoomId,
    DocumentSnapshot? last,
  }) {
    var query = getChatRoomMessages(
      chatRoomId,
    ).orderBy('timestamp', descending: true).limit(20);
    if (last != null) {
      query = query.startAfterDocument(last);
    }
    return query.snapshots().map(
      (event) => event.docs.map((e) => ChatMessage.fromFirestore(e)).toList(),
    );
  }

  Future<List<ChatMessage>> getMoreMessage({
    required String chatRoomId,
    required DocumentSnapshot last,
  }) async {
    final query = getChatRoomMessages(
      chatRoomId,
    ).orderBy('timestamp', descending: true).startAfterDocument(last).limit(20);
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList();
  }

  Stream<List<ChatRoomModel>> getChatRooms({required String userId}) {
    return _chatRooms
        .where("participants", arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((e) => ChatRoomModel.fromFirestore(e)).toList(),
        );
  }

  Stream<int> getUnreadMessageCount({
    required String chatRoomId,
    required String userId,
  }) {
    return getChatRoomMessages(chatRoomId)
        .where("receiverId", isEqualTo: userId)
        .where("status", isEqualTo: MessageStatus.sent.toString())
        .snapshots()
        .map((snap) =>
    snap.docs.length
    );
  }
}
