import 'package:chat_app/data/models/chat_message.dart';
import 'package:equatable/equatable.dart';

enum ChatStatus { initial, loading, loaded, error }

class ChatState extends Equatable {
  final ChatStatus status;
  final String? error;
  final String? receiverId;
  final String? chatRoomId;

  final List<ChatMessage> messages;

  const ChatState({
    this.status = ChatStatus.initial,
    this.error,
    this.receiverId,
    this.chatRoomId,
    this.messages = const [],
  });

  ChatState copyWith({ChatStatus? status, String? error, String? receiverId, String? chatRoomId,List<ChatMessage>? messages}) {
    return ChatState(
      status: status ?? this.status,
      error: error ?? this.error,
      receiverId: receiverId ?? this.receiverId,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [status, error, receiverId, chatRoomId,messages];
}
