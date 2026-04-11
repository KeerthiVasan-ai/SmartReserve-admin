import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_reserve_admin/services/delete_user_service.dart';
import 'package:smart_reserve_admin/utils/firebase_constants.dart';
import 'package:smart_reserve_admin/services/gcp_logging_service.dart';
import 'package:flutter/material.dart';

import 'package:smart_reserve_admin/widgets/ui/background_shapes.dart';

class StaffAccessScreen extends StatefulWidget {
  const StaffAccessScreen({super.key});

  @override
  State<StaffAccessScreen> createState() => _StaffAccessScreenState();
}

class _StaffAccessScreenState extends State<StaffAccessScreen> {
  // Stream to listen to changes in staffaccess collection
  final Stream<QuerySnapshot> _accessStream = FirebaseFirestore.instance
      .collection(FirebaseConstants.staffAccess)
      .snapshots();

  // Cache futures to prevent re-fetching on scroll/rebuild
  final Map<String, Future<DocumentSnapshot>> _userFutureCache = {};

  // Cache resolved user data to avoid showing loading on scroll
  final Map<String, Map<String, dynamic>?> _resolvedUserData = {};

  // Permanent admins list from constants/server
  List<String> _permanentAdmins = [];

  // Search state
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPermanentAdmins();
  }

  Future<void> _fetchPermanentAdmins() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirebaseConstants.constants)
          .doc(FirebaseConstants.server)
          .get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['permanentAdmins'] != null) {
          setState(() {
            _permanentAdmins = List<String>.from(data['permanentAdmins']);
          });
        } else {
        }
      } else {
      }
    } catch (_) {
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<DocumentSnapshot> _getUserFuture(String uid) {
    return _userFutureCache.putIfAbsent(
      uid,
      () => FirebaseFirestore.instance
          .collection(FirebaseConstants.userName)
          .doc(uid)
          .get()
          .then((snapshot) {
        // Cache the resolved data
        if (snapshot.exists) {
          _resolvedUserData[uid] = snapshot.data();
        } else {
          _resolvedUserData[uid] = null;
        }
        return snapshot;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundShapes(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Search staff...',
                    hintStyle:
                        TextStyle(fontFamily: 'Poppins', color: Colors.grey),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value.toLowerCase());
                  },
                )
              : Text(
                  "Staff Access Control",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
          backgroundColor: Colors.transparent,
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                _isSearching ? Icons.close_rounded : Icons.search_rounded,
                color: _isSearching ? Colors.redAccent : Colors.black,
              ),
              tooltip: _isSearching ? 'Close Search' : 'Search',
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchQuery = '';
                    _searchController.clear();
                  }
                });
              },
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _accessStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Something went wrong',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_off_rounded,
                        size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      "No staff access data available.",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Pre-fetch all user data
            for (var doc in snapshot.data!.docs) {
              _getUserFuture(doc.id);
            }

            // Filter docs by search query using cached user data
            final filteredDocs = _searchQuery.isEmpty
                ? snapshot.data!.docs
                : snapshot.data!.docs.where((doc) {
                    final cached = _resolvedUserData[doc.id];
                    if (cached == null) return true; // Show unresolved items
                    final name =
                        (cached['name'] ?? '').toString().toLowerCase();
                    return name.contains(_searchQuery);
                  }).toList();

            if (filteredDocs.isEmpty && _searchQuery.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off_rounded,
                        size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No results for "$_searchQuery"',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filteredDocs.length,
              itemBuilder: (context, index) {
                final document = filteredDocs[index];
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                String uid = document.id;
                bool isAdmin = data['isadmin'] ?? false;
                final bool isPermanent = _permanentAdmins.contains(uid);

                // Permanent admins are always ON
                if (isPermanent) isAdmin = true;

                // Use cached data if available to avoid loading flicker
                if (_resolvedUserData.containsKey(uid)) {
                  final userData = _resolvedUserData[uid];
                  String paramName = (userData != null)
                      ? (userData['name'] ?? 'No Name')
                      : 'Unknown User';
                  return _buildAccessCard(
                    name: paramName,
                    isAdmin: isAdmin,
                    isPermanentAdmin: isPermanent,
                    onDelete: () => _showDeleteDialog(context, uid, paramName),
                    onChanged: isPermanent
                        ? null
                        : (bool value) {
                            FirebaseFirestore.instance
                                .collection(FirebaseConstants.staffAccess)
                                .doc(uid)
                                .update({'isadmin': value});
                            GCPLog.info('Administrative access changed for $uid to $value', userId: uid);
                          },
                  );
                }

                return FutureBuilder<DocumentSnapshot>(
                  future: _getUserFuture(uid),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return _buildAccessCard(
                        name: "Loading name...",
                        isAdmin: isAdmin,
                        onChanged: null,
                        onDelete: null,
                      );
                    }

                    if (userSnapshot.hasError ||
                        !userSnapshot.hasData ||
                        !userSnapshot.data!.exists) {
                      return _buildAccessCard(
                        name: "Unknown User",
                        isAdmin: isAdmin,
                        isPermanentAdmin: isPermanent,
                        onDelete: () => _showDeleteDialog(context, uid, "Unknown User"),
                        onChanged: isPermanent
                            ? null
                            : (bool value) {
                                FirebaseFirestore.instance
                                    .collection(FirebaseConstants.staffAccess)
                                    .doc(uid)
                                    .update({'isadmin': value});
                                GCPLog.info('Administrative access changed for Unknown User ($uid) to $value', userId: uid);
                              },
                      );
                    }

                    Map<String, dynamic> userData =
                        userSnapshot.data!.data()! as Map<String, dynamic>;
                    String paramName = userData['name'] ?? 'No Name';

                    return _buildAccessCard(
                      name: paramName,
                      isAdmin: isAdmin,
                      isPermanentAdmin: isPermanent,
                      onDelete: () => _showDeleteDialog(context, uid, paramName),
                      onChanged: isPermanent
                          ? null
                          : (bool value) {
                              FirebaseFirestore.instance
                                  .collection(FirebaseConstants.staffAccess)
                                  .doc(uid)
                                  .update({'isadmin': value});
                              GCPLog.info('Administrative access changed for $paramName ($uid) to $value', userId: uid);
                            },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildAccessCard({
    required String name,
    required bool isAdmin,
    required ValueChanged<bool>? onChanged,
    VoidCallback? onDelete,
    bool isPermanentAdmin = false,
  }) {
    final statusColor = isAdmin
        ? const Color(0xFF2D9596) // Teal for admin
        : const Color(0xFFE57373); // Soft red for non-admin

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha:0.60)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: Icon(
            isPermanentAdmin
                ? Icons.lock_rounded
                : (isAdmin ? Icons.check : Icons.block),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          name,
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          isPermanentAdmin
              ? 'Permanent Admin'
              : (isAdmin ? 'Admin Access' : 'No Access'),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: statusColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isPermanentAdmin && onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: onDelete,
                tooltip: 'Delete User',
              ),
            Switch(
              value: isAdmin,
              onChanged: onChanged,
              activeThumbColor: const Color(0xFF2D9596),
              activeTrackColor: const Color(0xFF2D9596).withValues(alpha:0.40),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String uid, String name) {
    showDialog(
      context: context,
      builder: (context) {
        bool isDeleting = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Delete $name?',
                style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
              ),
              content: const Text(
                'Are you sure you want to delete this user? All their future bookings and account data will be permanently removed. Past bookings will be retained for historical records.',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
              ),
              actions: [
                TextButton(
                  onPressed: isDeleting ? null : () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: isDeleting
                      ? null
                      : () async {
                          setState(() => isDeleting = true);
                          final error = await DeleteUserService.deleteUserCompletely(uid);
                          setState(() => isDeleting = false);
                          
                          if (!context.mounted) return;
                          
                          Navigator.pop(context);
                          
                          if (error == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$name deleted successfully!'),
                                backgroundColor: const Color(0xFF2D9596),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $error'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                  child: isDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Delete',
                          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
