import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stalder/models/Auth/auth.dart';
import 'package:stalder/models/Role/role.dart';

import 'package:stalder/models/Role/role_repository.dart';
import 'package:stalder/models/User/repository/user_repository.dart';
import 'package:stalder/models/User/user_detail.dart';
import 'package:stalder/screens/dashboard/studentinf/manage_user.dart';
import 'package:stalder/screens/register_students/register_form.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final User? firebaseUser = Auth().currentUser;
  final _userRepository = UserRepository();
  final _roleRepository = RoleRepository();

  Future<List<UserDetail>?>? _userFuture;
  List<Role> _roles = [];
  String _searchText = '';
  int? _selectedRoleId; // null = todos los roles

  @override
  void initState() {
    super.initState();
    _loadRoles();
    _loadUsers();
  }

  Future<void> _loadRoles() async {
    final token = await firebaseUser?.getIdToken();
    if (token == null) return;
    final roles = await _roleRepository.fetchRoles(token);
    setState(() {
      _roles = roles ?? [];
    });
  }

  Future<void> _loadUsers() async {
    final token = await firebaseUser?.getIdToken();
    if (token == null) return;
    setState(() {
      _userFuture = _userRepository.fetchUser(token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users Information')),
      body: Column(
        children: [
          // Buscador
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search Users',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (text) {
                setState(() => _searchText = text);
              },
            ),
          ),

          // Filtro por roles
          if (_roles.isNotEmpty)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Chip "Todos"
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('Todos'),
                      selected: _selectedRoleId == null,
                      onSelected: (_) {
                        setState(() => _selectedRoleId = null);
                      },
                    ),
                  ),
                  // Chip por cada rol
                  ..._roles.map((role) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(role.name),
                          selected: _selectedRoleId == role.id,
                          onSelected: (_) {
                            setState(() {
                              _selectedRoleId = _selectedRoleId == role.id
                                  ? null
                                  : role.id;
                            });
                          },
                        ),
                      )),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Lista de usuarios
          Expanded(
            child: FutureBuilder<List<UserDetail>?>(
              future: _userFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay usuarios'));
                }

                // Filtro por búsqueda + rol
                final users = snapshot.data!.where((u) {
                  final matchesSearch =
                      u.name.toLowerCase().contains(_searchText.toLowerCase()) ||
                      u.lastname.toLowerCase().contains(_searchText.toLowerCase()) ||
                      u.email.toLowerCase().contains(_searchText.toLowerCase());

                  final matchesRole = _selectedRoleId == null ||
                      _roles.any((r) =>
                          r.id == _selectedRoleId &&
                          r.name.toLowerCase() == u.roleName.toLowerCase());

                  return matchesSearch && matchesRole;
                }).toList();

                if (users.isEmpty) {
                  return const Center(child: Text('No se encontraron usuarios'));
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final u = users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(u.name[0].toUpperCase()),
                      ),
                      title: Text('${u.name} ${u.lastname}'),
                      subtitle: Text(u.email),
                      trailing: Chip(
                        label: Text(
                          u.roleName,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ManageUser(user: u),
                          ),
                        ).then((_) => _loadUsers());
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RegisterForm()),
          ).then((_) => _loadUsers());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}