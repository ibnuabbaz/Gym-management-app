// Flutter Project Updated with Joy's Gym Color Theme

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "JMC",
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C0A02),
          primary: const Color(0xFFFFD700),
          secondary: const Color(0xFFB22222),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF7C0A02),
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD700),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        cardColor: Colors.white,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  final List<_DashboardItem> dashboardItems = const [
    _DashboardItem(title: 'Add Member', icon: Icons.person_add,),
    _DashboardItem(title: 'View Members', icon: Icons.people),
    //_DashboardItem(title: 'Attendance', icon: Icons.check_circle),
   // _DashboardItem(title: 'Payments', icon: Icons.payment),
    _DashboardItem(title: 'Membership', icon: Icons.monitor_heart),
  ];

  void addTestMember() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firestore.collection('members').add({
        'name': 'Test Member',
        'membershipStatus': 'active',
        'joinedDate': DateTime.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Test Member Added Successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed to Add Member: $e')),
        );
      }
      print('Error adding member: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void handleDashboardTap(String title) {
    if (title == 'Add Member') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddMemberPage()),
      );
    } else if (title == 'View Members') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ViewMembersPage()),
      );
    } else if (title == 'Membership') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MembershipMonitoringPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$title tapped')),
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym Management Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
          itemCount: dashboardItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final item = dashboardItems[index];
            return GestureDetector(
              onTap: () => handleDashboardTap(item.title),
              child: Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon with black circular background
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.black, // Black background
                        shape: BoxShape.circle, // Circular shape
                      ),
                      child: Icon(item.icon, size: 40, color: Color(0xFFFFD700)), // Golden icon
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.title,
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ],
                ),
              ),

            );
          },
        ),
      ),
    );
  }
}

class _DashboardItem {
  final String title;
  final IconData icon;

  const _DashboardItem({required this.title, required this.icon});
}
class AddMemberPage extends StatefulWidget {
  const AddMemberPage({super.key});

  @override
  State<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final TextEditingController _admissionNumberController = TextEditingController();

  //String _membershipStatus = 'active';
  DateTime? _expiryDate;
  bool _isSubmitting = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (selectedDate != null) {
      setState(() {
        _expiryDate = selectedDate;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() != true || _expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❗ Please complete all required fields')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final name = _nameController.text.trim();
      final admissionNumber = _admissionNumberController.text.trim();

      // 🔍 Check if member already exists
      final existing = await _firestore
          .collection('members')
          .where('admissionNumber', isEqualTo: admissionNumber)
          .get();

      if (existing.docs.isNotEmpty) {
        // ❌ Show message: member already exists
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ A member with this admission number already exists!'),
          ),
        );
        return;
      }

      // ✅ Member does not exist, proceed to add
      await _firestore.collection('members').add({
        'name': name,
        'admissionNumber': admissionNumber,
        'joinedDate': Timestamp.now(),
        'expiryDate': Timestamp.fromDate(_expiryDate!),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Member added successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed to add member: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }


  @override
  void dispose() {
    _nameController.dispose();
    _admissionNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Member'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                style: const TextStyle(
                  color: Colors.black, // <-- Member Name input text color
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  labelText: 'Member Name',
                  labelStyle: TextStyle(
                    color: Colors.black, // <-- Label color (Joy's Gym dark red)
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _admissionNumberController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  color: Colors.black, // Input text color
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  labelText: 'Admission Number',
                  labelStyle: TextStyle(
                    color: Colors.black, // Joy's Gym Red for the label
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter admission number' : null,
              ),
              const SizedBox(height: 16),
              /*DropdownButtonFormField<String>(
                value: _membershipStatus,
                decoration: const InputDecoration(labelText: 'Membership Status'),
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                  DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
                ],
                onChanged: (value) {
                  setState(() {
                    _membershipStatus = value!;
                  });
                },
              ),
              const SizedBox(height: 16),*/
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Membership Expiry Date'),
                subtitle: Text(
                  _expiryDate == null
                      ? 'Select expiry date'
                      : '${_expiryDate!.toLocal()}'.split(' ')[0],
                  style: TextStyle(
                    color: _expiryDate == null
                        ? Colors.red
                        : Colors.black,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickExpiryDate,
                ),
              ),
              const SizedBox(height: 24),
              _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Add Member'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class ViewMembersPage extends StatefulWidget {
  const ViewMembersPage({super.key});

  @override
  State<ViewMembersPage> createState() => _ViewMembersPageState();
}

class _ViewMembersPageState extends State<ViewMembersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';


  Future<void> _deleteMember(String memberId) async {
    try {
      await _firestore.collection('members').doc(memberId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Member deleted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed to delete member: $e')),
        );
      }
    }
  }

  void _confirmDelete(String memberId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Member'),
        content: const Text('Are you sure you want to delete this member?',style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            child: const Text('Cancel',style: TextStyle(color: Colors.green)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(context).pop();
              _deleteMember(memberId);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Members'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(style: const TextStyle(
              color: Colors.black,),
              decoration: InputDecoration(
                hintText: 'Search by name or admission number',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('members').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading members.'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allMembers = snapshot.data!.docs;

                // ✅ Filter by name or admission number
                final members = allMembers.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  final admissionNumber = (data['admissionNumber'] ?? '').toString().toLowerCase();

                  return name.contains(_searchQuery) || admissionNumber.contains(_searchQuery);
                }).toList();

                if (members.isEmpty) {
                  return const Center(child: Text('No matching members found.'));
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 24,
                    headingRowColor: MaterialStateProperty.all(Colors.grey),
                    columns: const [
                      DataColumn(label: Text('Sl No.')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Admission No')),
                      DataColumn(label: Text('Joined Date')),
                      DataColumn(label: Text('Expiry Date')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: List<DataRow>.generate(
                      members.length,
                          (index) {
                        final doc = members[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final joinedDate = (data['joinedDate'] as Timestamp).toDate();
                        final expiryDate = (data['expiryDate'] as Timestamp).toDate();

                        return DataRow(cells: [
                          DataCell(Text('${index + 1}', style: TextStyle(color: Colors.black))),
                          DataCell(Text(data['name'] ?? '', style: TextStyle(color: Colors.black))),
                          DataCell(Text(data['admissionNumber'] ?? '', style: TextStyle(color: Colors.black))),
                          DataCell(Text('${joinedDate.toLocal()}'.split(' ')[0], style: TextStyle(color: Colors.black))),
                          DataCell(Text('${expiryDate.toLocal()}'.split(' ')[0], style: TextStyle(color: Colors.red))),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.green),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => UpdateMemberPage(memberId: doc.id),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDelete(doc.id),
                              ),
                            ],
                          )),
                        ]);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

    );
  }
}

class UpdateMemberPage extends StatefulWidget {
  final String memberId;

  const UpdateMemberPage({required this.memberId, super.key});

  @override
  State<UpdateMemberPage> createState() => _UpdateMemberPageState();
}

class _UpdateMemberPageState extends State<UpdateMemberPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _admissionNumberController  = TextEditingController();
  String _membershipStatus = 'active';
  DateTime? _expiryDate;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadMemberData();
  }

  Future<void> _loadMemberData() async {
    try {
      final doc = await _firestore.collection('members').doc(widget.memberId).get();
      if (doc.exists) {
        final data = doc.data()!;
        _nameController.text = data['name'] ?? '';
        _admissionNumberController.text = data['admissionNumber'] ?? '';
        _membershipStatus = data['membershipStatus'] ?? 'active';
        Timestamp? expiryTimestamp = data['expiryDate'];
        if (expiryTimestamp != null) {
          _expiryDate = expiryTimestamp.toDate();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load member: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? now,
      firstDate: now.subtract(const Duration(days: 365 * 5)), // 5 years back
      lastDate: DateTime(now.year + 5),
    );

    if (selectedDate != null) {
      setState(() {
        _expiryDate = selectedDate;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() != true || _expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❗ Please complete all required fields')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _firestore.collection('members').doc(widget.memberId).update({
        'name': _nameController.text.trim(),
        'admissionNumber':_admissionNumberController.text.trim(),
        //'membershipStatus': _membershipStatus,
        'expiryDate': Timestamp.fromDate(_expiryDate!),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Member updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed to update member: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _admissionNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Member'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                style: const TextStyle(
                  color: Colors.black, // <-- Member Name input text color
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  labelText: 'Member Name',
                  labelStyle: TextStyle(
                    color: Colors.black, // <-- Label color (Joy's Gym dark red)
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _admissionNumberController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  color: Colors.black, // Input text color
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  labelText: 'Admission Number',
                  labelStyle: TextStyle(
                    color: Colors.black, // Joy's Gym Red for the label
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter admission number' : null,
              ),

              const SizedBox(height: 16),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Membership Expiry Date'),
                subtitle: Text(
                  _expiryDate == null
                      ? 'Select expiry date'
                      : '${_expiryDate!.toLocal()}'.split(' ')[0],
                  style: TextStyle(
                    color: _expiryDate == null ? Colors.red : Colors.black,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickExpiryDate,
                ),
              ),
              const SizedBox(height: 24),
              _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Update Member'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class MembershipMonitoringPage extends StatefulWidget {
  const MembershipMonitoringPage({super.key});

  @override
  State<MembershipMonitoringPage> createState() => _MembershipMonitoringPageState();
}

class _MembershipMonitoringPageState extends State<MembershipMonitoringPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';

  bool isExpired(DateTime expiryDate) {
    return expiryDate.isBefore(DateTime.now());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Membership'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          // 🔍 Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(style: const TextStyle(
              color: Colors.black,),
              decoration: InputDecoration(
                hintText: 'Search by name or admission number',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('members').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading data.'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final members = snapshot.data!.docs;

                // 🔍 Filter based on search query
                final filteredMembers = members.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  final admissionNumber = (data['admissionNumber'] ?? '').toString().toLowerCase();

                  return name.contains(_searchQuery) || admissionNumber.contains(_searchQuery);
                }).toList();

                if (filteredMembers.isEmpty) {
                  return const Center(child: Text('No matching members found.'));
                }

                // 🧮 Count expired and active based on filtered list
                int expiredCount = 0;
                int activeCount = 0;

                for (var member in filteredMembers) {
                  final expiryDate = (member['expiryDate'] as Timestamp).toDate();
                  if (isExpired(expiryDate)) {
                    expiredCount++;
                  } else {
                    activeCount++;
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Active Members: $activeCount', style: const TextStyle(color: Colors.green, fontSize: 20)),
                          Text('Expired Members: $expiredCount', style: const TextStyle(color: Colors.red, fontSize: 20)),
                        ],
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredMembers.length,
                        itemBuilder: (context, index) {
                          final member = filteredMembers[index];
                          final data = member.data() as Map<String, dynamic>;
                          final name = data['name'] ?? '';
                          final admissionNumber = data['admissionNumber'] ?? '';
                          final expiryDate = (data['expiryDate'] as Timestamp).toDate();
                          final expired = isExpired(expiryDate);

                          return ListTile(
                            title: Text(
                              name,
                              style: TextStyle(
                                color: expired ? Colors.red : Colors.green,
                                fontWeight: expired ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              'Admission #: $admissionNumber\nExpiry: ${expiryDate.toLocal().toString().split(' ')[0]}',
                              style: TextStyle(
                                color: expired ? Colors.red : Colors.green[700],
                              ),
                            ),
                            leading: Icon(
                              expired ? Icons.warning : Icons.check_circle,
                              color: expired ? Colors.red : Colors.green,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
class MemberDetailsPage extends StatelessWidget {
  final String name;
  final String admissionNumber;
  final DateTime joinedDate;
  final DateTime expiryDate;
  final String membershipStatus;

  const MemberDetailsPage({
    super.key,
    required this.name,
    required this.admissionNumber,
    required this.joinedDate,
    required this.expiryDate,
    required this.membershipStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Details'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: $name', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Admission Number: $admissionNumber', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Joined Date: ${joinedDate.toLocal().toString().split(' ')[0]}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Expiry Date: ${expiryDate.toLocal().toString().split(' ')[0]}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Status: $membershipStatus', style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
