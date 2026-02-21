import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_reserve_admin/utils/firebase_constants.dart';
import 'package:flutter/material.dart';

import 'package:smart_reserve_admin/widgets/ui/background_shapes.dart';

class StaffSlotsScreen extends StatefulWidget {
  const StaffSlotsScreen({super.key});

  @override
  State<StaffSlotsScreen> createState() => _StaffSlotsScreenState();
}

class _StaffSlotsScreenState extends State<StaffSlotsScreen> {
  // Stream to listen to changes in allotedSlot collection
  final Stream<QuerySnapshot> _slotsStream = FirebaseFirestore.instance
      .collection(FirebaseConstants.allottedSlots)
      .snapshots();

  // Cache futures to prevent re-fetching on scroll/rebuild
  final Map<String, Future<DocumentSnapshot>> _userFutureCache = {};

  // Cache resolved user data to avoid showing loading on scroll
  final Map<String, Map<String, dynamic>?> _resolvedUserData = {};

  // Search state
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Edit mode state
  bool _isEditing = false;
  bool _isSaving = false;
  final Map<String, int> _editedSlots = {};

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

  void _toggleEditMode(List<QueryDocumentSnapshot> docs) {
    setState(() {
      if (!_isEditing) {
        // Entering edit mode — populate editable map with current values
        _editedSlots.clear();
        for (var doc in docs) {
          final data = doc.data()! as Map<String, dynamic>;
          _editedSlots[doc.id] = data['allottedSlots'] ?? 0;
        }
      }
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveEdits() async {
    setState(() => _isSaving = true);
    try {
      final batch = FirebaseFirestore.instance.batch();
      for (var entry in _editedSlots.entries) {
        batch.update(
          FirebaseFirestore.instance
              .collection(FirebaseConstants.allottedSlots)
              .doc(entry.key),
          {'allottedSlots': entry.value},
        );
      }
      await batch.commit();
      setState(() {
        _isEditing = false;
        _editedSlots.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Slot counts updated successfully!',
              style: TextStyle(
                fontFamily: 'Poppins',
              ),
            ),
            backgroundColor: const Color(0xFF2D9596),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update: $e',
              style: TextStyle(
                fontFamily: 'Poppins',
              ),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
                  "Staff Slot Counts",
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
            StreamBuilder<QuerySnapshot>(
              stream: _slotsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const SizedBox.shrink();
                }
                return IconButton(
                  icon: Icon(
                    _isEditing ? Icons.close_rounded : Icons.edit_rounded,
                    color: _isEditing ? Colors.redAccent : Colors.black,
                  ),
                  tooltip: _isEditing ? 'Cancel' : 'Edit Slots',
                  onPressed: () => _toggleEditMode(snapshot.data!.docs),
                );
              },
            ),
          ],
        ),
        floatingActionButton: _isEditing
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FloatingActionButton.extended(
                    onPressed: _isSaving ? null : _saveEdits,
                    backgroundColor: const Color(0xFF2D9596),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    label: _isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'SAVE CHANGES',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                    icon: _isSaving
                        ? null
                        : const Icon(Icons.check_rounded, color: Colors.white),
                  ),
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: StreamBuilder<QuerySnapshot>(
          stream: _slotsStream,
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
                    Icon(Icons.inbox_rounded, size: 64, color: Colors.black54),
                    const SizedBox(height: 16),
                    Text(
                      "No staff slots data available.",
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
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 8, bottom: 80),
              itemCount: filteredDocs.length,
              itemBuilder: (context, index) {
                final document = filteredDocs[index];
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                String uid = document.id;
                int slotCount = _isEditing
                    ? (_editedSlots[uid] ?? data['allottedSlots'] ?? 0)
                    : (data['allottedSlots'] ?? 0);

                // Use cached data if available to avoid loading flicker
                if (_resolvedUserData.containsKey(uid)) {
                  final userData = _resolvedUserData[uid];
                  if (userData == null) {
                    return _buildCard(
                      leading: _buildAvatar('?', Colors.grey),
                      title: "Unknown User",
                      trailing: _buildTrailing(uid, slotCount),
                    );
                  }
                  String paramName = userData['name'] ?? 'No Name';
                  return _buildCard(
                    leading: _buildAvatar(
                      paramName.isNotEmpty ? paramName[0].toUpperCase() : '?',
                      const Color(0xFF2D9596),
                    ),
                    title: paramName,
                    trailing: _buildTrailing(uid, slotCount),
                  );
                }

                return FutureBuilder<DocumentSnapshot>(
                  future: _getUserFuture(uid),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return _buildCard(
                        leading: _buildAvatar('?', Colors.grey),
                        title: "Loading name...",
                        trailing: _buildTrailing(uid, slotCount),
                      );
                    }

                    if (userSnapshot.hasError ||
                        !userSnapshot.hasData ||
                        !userSnapshot.data!.exists) {
                      return _buildCard(
                        leading: _buildAvatar('?', Colors.grey),
                        title: "Unknown User",
                        trailing: _buildTrailing(uid, slotCount),
                      );
                    }

                    Map<String, dynamic> userData =
                        userSnapshot.data!.data()! as Map<String, dynamic>;
                    String paramName = userData['name'] ?? 'No Name';

                    return _buildCard(
                      leading: _buildAvatar(
                        paramName.isNotEmpty ? paramName[0].toUpperCase() : '?',
                        const Color(0xFF2D9596),
                      ),
                      title: paramName,
                      trailing: _buildTrailing(uid, slotCount),
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

  Widget _buildTrailing(String uid, int slotCount) {
    if (!_isEditing) return _buildSlotBadge(slotCount);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStepperButton(
          icon: Icons.remove_rounded,
          onTap: () {
            setState(() {
              if ((_editedSlots[uid] ?? 0) > 0) {
                _editedSlots[uid] = (_editedSlots[uid] ?? 0) - 1;
              }
            });
          },
        ),
        Container(
          width: 44,
          alignment: Alignment.center,
          child: Text(
            '${_editedSlots[uid] ?? slotCount}',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: const Color(0xFF1A6B6C),
            ),
          ),
        ),
        _buildStepperButton(
          icon: Icons.add_rounded,
          onTap: () {
            setState(() {
              _editedSlots[uid] = (_editedSlots[uid] ?? 0) + 1;
            });
          },
        ),
      ],
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFF2D9596).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF2D9596).withValues(alpha:0.40),
          ),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF2D9596)),
      ),
    );
  }

  Widget _buildCard({
    required Widget leading,
    required String title,
    required Widget trailing,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha:0.60)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: leading,
        title: Text(
          title,
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        trailing: trailing,
      ),
    );
  }

  Widget _buildAvatar(String letter, Color color) {
    return CircleAvatar(
      backgroundColor: color,
      child: Text(
        letter,
        style: TextStyle(
          fontFamily: 'Poppins',
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSlotBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF2D9596).withValues(alpha:0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2D9596).withValues(alpha:0.40),
        ),
      ),
      child: Text(
        "$count Slots",
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: const Color(0xFF1A6B6C),
        ),
      ),
    );
  }
}
