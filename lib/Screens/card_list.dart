import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:visiting_card_app/Screens/create_card_screen.dart';
import 'package:visiting_card_app/main.dart';
import '../Database/database.dart';
import '../Model/user_profile.dart'; // contains VisitingCard
import '../Theme/theme.dart';
import 'display_profile.dart';

class CardListScreen extends StatefulWidget {
  @override
  _CardListScreenState createState() => _CardListScreenState();
}

enum SortOption { alphabetically, recentlyAdded }

class _CardListScreenState extends State<CardListScreen> {
  late Future<List<VisitingCard>> _profilesFuture;
  List<VisitingCard> _allProfiles = [];
  List<VisitingCard> _filteredProfiles = [];

  String _searchQuery = '';
  SortOption _sortOption = SortOption.recentlyAdded;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  void _loadProfiles() {
    setState(() {
      _profilesFuture = DBService.getAllVisitingCards().then((profiles) {
        _allProfiles = profiles.where((card) => card.type == CardType.other).toList();
        _applySearchAndSort();
        return profiles;
      });
    });
  }

  void _applySearchAndSort() {
    final query = _searchQuery.toLowerCase();

    List<VisitingCard> filtered =
        _allProfiles.where((card) => card.type == CardType.other).where((card) {
          final fields = card.fields;
          return fields.values.any((value) => value.toLowerCase().contains(query));
        }).toList();

    // Optional: apply sort
    if (_sortOption == SortOption.alphabetically) {
      filtered.sort((a, b) {
        final aName = a.fields['name']?.toLowerCase() ?? '';
        final bName = b.fields['name']?.toLowerCase() ?? '';
        return aName.compareTo(bName);
      });
    }

    setState(() {
      _filteredProfiles = filtered;
    });
  }

  // void _applySearchAndSort() {
  //   final query = _searchQuery.toLowerCase();
  //
  //   List<VisitingCard> filtered =
  //       _allProfiles.where((card) {
  //         final fields = card.fields;
  //         return fields.values.any((value) => value.toLowerCase().contains(query));
  //       }).toList();
  //
  //   if (_sortOption == SortOption.alphabetically) {
  //     filtered.sort((a, b) {
  //       final aName = a.fields['name']?.toLowerCase() ?? '';
  //       final bName = b.fields['name']?.toLowerCase() ?? '';
  //       return aName.compareTo(bName);
  //     });
  //   }
  //
  //   setState(() {
  //     _filteredProfiles = filtered;
  //   });
  // }

  Future<void> _deleteProfile(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Delete Contact'),
            content: Text('Are you sure you want to delete this contact?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete')),
            ],
          ),
    );

    if (confirm == true) {
      await DBService.deleteVisitingCard(id);
      _loadProfiles();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Contacts'),
        actions: [
          PopupMenuButton<SortOption>(
            onSelected: (option) {
              setState(() {
                _sortOption = option;
                _applySearchAndSort();
              });
            },
            icon: Icon(Icons.sort),
            itemBuilder:
                (_) => [
                  PopupMenuItem(value: SortOption.recentlyAdded, child: Text('Recently Added')),
                  PopupMenuItem(value: SortOption.alphabetically, child: Text('Alphabetically')),
                ],
          ),
        ],
      ),
      floatingActionButton: Container(
        padding: EdgeInsets.all(5.r),
        decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.lightPurple),
        child: IconButton(
          onPressed: () async {
            var result = await Navigator.push(context, MaterialPageRoute(builder: (_) => CreateCardScreen(isUser: false)));
            if (result) {
              _loadProfiles();
            }
          },
          icon: Icon(Icons.add, color: AppColors.white),
        ),
      ),

      body: FutureBuilder<List<VisitingCard>>(
        future: _profilesFuture,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search name, phone, email, company...',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  onChanged: (val) {
                    _searchQuery = val;
                    _applySearchAndSort();
                  },
                ),
              ),
              Expanded(
                child:
                    _filteredProfiles.isEmpty
                        ? Center(child: Text('No contacts found.'))
                        : ListView.builder(
                          padding: EdgeInsets.all(12),
                          itemCount: _filteredProfiles.length,
                          itemBuilder: (_, index) {
                            final p = _filteredProfiles[index];
                            final name = p.fields['name'] ?? '';
                            final company = p.fields['company'] ?? '';
                            final phone = p.fields['phone'] ?? '';
                            final email = p.fields['email'] ?? '';

                            return Card(
                              elevation: 3,
                              margin: EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => DisplayProfileScreen(card: p)),
                                  ).then((_) => _loadProfiles());
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 26,
                                        backgroundColor: theme.colorScheme.primary,
                                        child: Text(
                                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                                          style: TextStyle(fontSize: 22, color: Colors.white),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                            SizedBox(height: 4),
                                            if (company.isNotEmpty)
                                              Row(
                                                children: [
                                                  Icon(Icons.business, size: 16, color: Colors.grey[600]),
                                                  SizedBox(width: 4),
                                                  Expanded(child: Text(company, overflow: TextOverflow.ellipsis)),
                                                ],
                                              ),
                                            SizedBox(height: 2),
                                            if (phone.isNotEmpty)
                                              Row(
                                                children: [
                                                  Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                                                  SizedBox(width: 4),
                                                  Text(phone),
                                                ],
                                              ),
                                            if (email.isNotEmpty) ...[
                                              SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  Icon(Icons.email, size: 16, color: Colors.grey[600]),
                                                  SizedBox(width: 4),
                                                  Expanded(child: Text(email, overflow: TextOverflow.ellipsis)),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      IconButton(icon: Icon(Icons.delete, color: Colors.redAccent), onPressed: () => _deleteProfile(p.id!)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          );
        },
      ),
    );
  }
}
