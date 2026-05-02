import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  // Store last deleted document for undo functionality
  Map<String, dynamic>? _lastDeletedData;
  String? _lastDeletedDocId;

  Future<void> _undoDelete() async {
    if (_lastDeletedData == null || _lastDeletedDocId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No deletion to undo.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('buildings')
          .doc(_lastDeletedDocId)
          .set(_lastDeletedData!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_lastDeletedData!['name']} has been restored.'),
          backgroundColor: Colors.blue,
        ),
      );

      // Clear the undo data
      _lastDeletedData = null;
      _lastDeletedDocId = null;
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error restoring document.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    DocumentSnapshot doc,
  ) {
    final passwordController = TextEditingController();
    const String deletePassword = "ruhuna123";
    bool isDeleting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                '⚠️ Confirm Deletion',
                style: TextStyle(color: Colors.red),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You are about to delete: ${doc['name']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'This action cannot be undone. Enter your admin password to confirm deletion.',
                    style: TextStyle(color: Colors.orange),
                  ),
                  const SizedBox(height: 16),
                  if (!isDeleting)
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Admin Password',
                        hintText: 'Enter password to confirm',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                      ),
                    )
                  else
                    const Center(
                      child: SizedBox(
                        height: 30,
                        width: 30,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
              actions: [
                if (!isDeleting)
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      passwordController.dispose();
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                if (!isDeleting)
                  TextButton(
                    onPressed: () async {
                      if (passwordController.text == deletePassword) {
                        setState(() => isDeleting = true);
                        try {
                          // Save the document data before deleting
                          _lastDeletedData = doc.data() as Map<String, dynamic>;
                          _lastDeletedDocId = doc.id;

                          await doc.reference.delete();
                          if (mounted && dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${doc['name']} deleted successfully.',
                                ),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 5),
                                action: SnackBarAction(
                                  label: 'UNDO',
                                  textColor: Colors.white,
                                  onPressed: () => _undoDelete(),
                                ),
                              ),
                            );
                          }
                        } catch (error) {
                          if (mounted && dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Permission Error: Check Firebase rules',
                                ),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 5),
                              ),
                            );
                          }
                        } finally {
                          passwordController.dispose();
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Incorrect password. Try again.'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('buildings').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              return ListTile(
                title: Text(doc['name']),
                subtitle: Text(
                  "Lat: ${doc['latitude']}, Lon: ${doc['longitude']}",
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteConfirmationDialog(context, doc),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // You can add a dialog here later to "Add New Building"
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
