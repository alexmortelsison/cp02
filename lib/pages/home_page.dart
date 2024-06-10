import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cp02/services/firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirestoreService firestoreService = FirestoreService();
  final textController = TextEditingController();
  void openNoteBox(String? docID) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: TextField(
            controller: textController,
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (docID == null) {
                  firestoreService.addNote(textController.text);
                } else {
                  firestoreService.updateNote(docID, textController.text);
                }
                textController.clear();
                Navigator.pop(context);
              },
              child: Text(
                'Add',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => openNoteBox(null),
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.tertiary,
        ),
      ),
      appBar: AppBar(
        title: Center(
          child: Text(
            'C R U D',
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List notesList = snapshot.data!.docs;
            return ListView.builder(
              itemCount: notesList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = notesList[index];
                String docID = document.id;
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String noteText = data['note'];
                return ListTile(
                  title: Text(noteText),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => openNoteBox(docID),
                        icon: const Icon(
                          Icons.edit_outlined,
                        ),
                      ),
                      IconButton(
                        onPressed: () => firestoreService.deleteNote(docID),
                        icon: const Icon(
                          Icons.delete_outlined,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text('No notes...'),
            );
          }
        },
      ),
    );
  }
}
