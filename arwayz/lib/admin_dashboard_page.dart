import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_lastDeletedData!['name'] ?? 'Destination'} restored.',
            ),
            backgroundColor: Colors.blue,
          ),
        );
      }

      _lastDeletedData = null;
      _lastDeletedDocId = null;
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error restoring document.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddDestinationDialog() {
    final docIdCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final latCtrl = TextEditingController();
    final lonCtrl = TextEditingController();
    final floorsCtrl = TextEditingController(text: '1');
    bool isAdding = false;
    String? errorMsg;

    showDialog(
      context: context,
      barrierDismissible: !isAdding,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('🏢 Add Destination'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: docIdCtrl,
                      enabled: !isAdding,
                      decoration: InputDecoration(
                        labelText: 'Document ID',
                        hintText: 'eng_faculty_CEE',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.description),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameCtrl,
                      enabled: !isAdding,
                      decoration: InputDecoration(
                        labelText: 'Building Name',
                        hintText: 'Department of Civil Engineering',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.business),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      enabled: !isAdding,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'Ruhuna Engineering Faculty - CEE',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.info),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: floorsCtrl,
                      enabled: !isAdding,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Floors',
                        hintText: '1',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.layers),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: latCtrl,
                      enabled: !isAdding,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Latitude',
                        hintText: '6.078071',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.map),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: lonCtrl,
                      enabled: !isAdding,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Longitude',
                        hintText: '80.191551',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.map),
                      ),
                    ),
                    if (errorMsg != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Text(
                          errorMsg!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                    if (isAdding) ...[
                      const SizedBox(height: 16),
                      const CircularProgressIndicator(),
                    ],
                  ],
                ),
              ),
              actions: [
                if (!isAdding)
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      docIdCtrl.dispose();
                      nameCtrl.dispose();
                      descCtrl.dispose();
                      latCtrl.dispose();
                      lonCtrl.dispose();
                      floorsCtrl.dispose();
                    },
                    child: const Text('Cancel'),
                  ),
                if (!isAdding)
                  ElevatedButton(
                    onPressed: () async {
                      if (docIdCtrl.text.isEmpty) {
                        setState(() => errorMsg = 'Enter Document ID');
                        return;
                      }
                      if (nameCtrl.text.isEmpty) {
                        setState(() => errorMsg = 'Enter Building Name');
                        return;
                      }
                      if (descCtrl.text.isEmpty) {
                        setState(() => errorMsg = 'Enter Description');
                        return;
                      }

                      double? lat = double.tryParse(latCtrl.text);
                      double? lon = double.tryParse(lonCtrl.text);

                      if (lat == null || lat < -90 || lat > 90) {
                        setState(
                          () => errorMsg = 'Invalid latitude (-90 to 90)',
                        );
                        return;
                      }
                      if (lon == null || lon < -180 || lon > 180) {
                        setState(
                          () => errorMsg = 'Invalid longitude (-180 to 180)',
                        );
                        return;
                      }

                      setState(() => isAdding = true);

                      try {
                        await FirebaseFirestore.instance
                            .collection('buildings')
                            .doc(docIdCtrl.text)
                            .set({
                              'name': nameCtrl.text,
                              'description': descCtrl.text,
                              'latitude': lat,
                              'longitude': lon,
                              'floors': floorsCtrl.text,
                              'createdAt': FieldValue.serverTimestamp(),
                            });

                        if (mounted && dialogContext.mounted) {
                          Navigator.pop(dialogContext);

                          Future.delayed(const Duration(milliseconds: 300), () {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${nameCtrl.text} added!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          });
                        }
                      } catch (e) {
                        if (mounted) {
                          setState(() {
                            isAdding = false;
                            errorMsg = 'Error: $e';
                          });
                        }
                      } finally {
                        docIdCtrl.dispose();
                        nameCtrl.dispose();
                        descCtrl.dispose();
                        latCtrl.dispose();
                        lonCtrl.dispose();
                        floorsCtrl.dispose();
                      }
                    },
                    child: const Text('Save'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteDestination(BuildContext mainContext, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final pwCtrl = TextEditingController();
    const pw = "ruhuna123";
    bool isDeleting = false;

    showDialog(
      context: mainContext,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                '⚠️ Delete?',
                style: TextStyle(color: Colors.red),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Delete: ${data['name'] ?? 'Unknown'}?'),
                  const SizedBox(height: 16),
                  if (!isDeleting)
                    TextField(
                      controller: pwCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Admin Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                      ),
                    )
                  else
                    const CircularProgressIndicator(),
                ],
              ),
              actions: [
                if (!isDeleting)
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      pwCtrl.dispose();
                    },
                    child: const Text('Cancel'),
                  ),
                if (!isDeleting)
                  TextButton(
                    onPressed: () async {
                      if (pwCtrl.text == pw) {
                        setState(() => isDeleting = true);
                        try {
                          _lastDeletedData = doc.data() as Map<String, dynamic>;
                          _lastDeletedDocId = doc.id;
                          await doc.reference.delete();

                          Navigator.pop(dialogContext);

                          // Show SnackBar immediately after closing dialog
                          ScaffoldMessenger.of(mainContext).clearSnackBars();
                          ScaffoldMessenger.of(mainContext).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${data['name'] ?? 'Destination'} deleted - Press UNDO to restore',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              backgroundColor: Colors.red[700],
                              duration: const Duration(seconds: 20),
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 10,
                              action: SnackBarAction(
                                label: 'UNDO',
                                textColor: Colors.yellow[300],
                                onPressed: () {
                                  _undoDelete();
                                },
                              ),
                            ),
                          );
                        } catch (e) {
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(mainContext).showSnackBar(
                            const SnackBar(
                              content: Text('Error deleting'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } finally {
                          pwCtrl.dispose();
                        }
                      } else {
                        ScaffoldMessenger.of(mainContext).showSnackBar(
                          const SnackBar(
                            content: Text('Wrong password'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
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
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.domain, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No destinations',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Click + to add',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>? ?? {};
              var name = data['name'] ?? 'Unknown';
              var desc = data['description'] ?? 'No description';
              var lat = data['latitude'] ?? 0.0;
              var lon = data['longitude'] ?? 0.0;
              var floors = data['floors']?.toString() ?? '0';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  desc,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteDestination(context, doc),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Coordinates:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Lat: $lat | Lon: $lon',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Floors: $floors',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDestinationDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
