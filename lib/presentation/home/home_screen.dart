import 'package:chat_app/data/repositories/chat_repository.dart';
import 'package:chat_app/data/repositories/contact_repository.dart';
import 'package:chat_app/data/services/service_locator.dart';
import 'package:chat_app/logic/cubits/auth/auth_cubit.dart';
import 'package:chat_app/presentation/chat/chat_message_screen.dart';
import 'package:chat_app/router/app_router.dart';
import 'package:chat_app/widgets/chat_list_tile.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ContactRepository _contactRepository;
  late ChatRepository _chatRepository;

  late String currentUserId;

  @override
  void initState() {
    _contactRepository = getIt<ContactRepository>();
    _chatRepository = getIt<ChatRepository>();
    currentUserId = getIt<AuthCubit>().state.user!.uid;
    super.initState();
  }

  void _showContactList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Contacts",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: FutureBuilder(
                  future: _contactRepository.getRegisteredContacts(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text("Error : ${snapshot.error}"));
                    }
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final contacts = snapshot.data!;
                    if (contacts.isEmpty) {
                      return Center(child: Text("No Contacts Found"));
                    }
                    return ListView.builder(
                      itemBuilder: (contxt, int) {
                        final Map<String, dynamic> contact = contacts[int];
                        return ListTile(
                          onTap:
                              () => getIt<AppRouter>().push(
                                ChatMessageScreen(
                                  receiverId: contact["id"],
                                  receiverName: contact['name'],
                                ),
                              ),
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.1),
                            child: Text(contact["name"][0].toUpperCase()),
                          ),
                          title: Text(contact['name']),
                          subtitle: Text(contact['phoneNumber']),
                        );
                      },
                      itemCount: contacts.length,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chats"),
        actions: [
          IconButton(
            onPressed: () => getIt<AuthCubit>().signOut(),
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showContactList(context),
        child: Icon(Icons.chat, color: Colors.white),
      ),
      body: StreamBuilder(
        stream: _chatRepository.getChatRooms(userId: currentUserId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error : ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final chats = snapshot.data!;
          if (chats.isEmpty) {
            return Center(child: Text("No Chats Found"));
          }
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return ChatListTile(
                chat: chat,
                currentUserId: currentUserId,
                onTap: () {
                  final otherUserId = chat.participants.firstWhere(
                    (id) => id != currentUserId,
                  );
                  final otherUserName =
                      chat.participantsName![otherUserId] ?? "Unknown";
                  getIt<AppRouter>().push(
                    ChatMessageScreen(
                      receiverName: otherUserName,
                      receiverId: otherUserId,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
