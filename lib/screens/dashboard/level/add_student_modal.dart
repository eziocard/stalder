import 'package:flutter/material.dart';
import 'package:stalder/models/User/user_detail.dart';

class AddStudentModal extends StatefulWidget {
  final List<UserDetail> students;
  final Function(UserDetail) onAdd;

  const AddStudentModal({
    super.key,
    required this.students,
    required this.onAdd,
  });

  @override
  State<AddStudentModal> createState() => _AddStudentModalState();
}

class _AddStudentModalState extends State<AddStudentModal> {
  UserDetail? _selected;
  bool _isLoading = false;
  String _searchText = '';
  List<UserDetail> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.students;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchText = query;
      _filtered = widget.students.where((s) {
        final fullName = '${s.name} ${s.lastname}'.toLowerCase();
        return fullName.contains(query.toLowerCase());
      }).toList();
      if (_selected != null && !_filtered.contains(_selected)) {
        _selected = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Agregar Alumno',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Buscador
          TextField(
            decoration: InputDecoration(
              labelText: 'Buscar alumno',
              hintText: 'Ej: Juan Pérez',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: _searchText.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _onSearchChanged(''),
                    )
                  : null,
            ),
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 12),

          // Lista filtrada
          if (_filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: Text('No se encontraron alumnos')),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final s = _filtered[index];
                  final isSelected = _selected == s;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        s.name[0].toUpperCase(),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    title: Text('${s.name} ${s.lastname}'),
                    subtitle: Text(s.email),
                    selected: isSelected,
                    selectedTileColor:
                        Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    onTap: () => setState(() => _selected = isSelected ? null : s),
                  );
                },
              ),
            ),

          const SizedBox(height: 16),

          // Botón agregar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading || _selected == null
                  ? null
                  : () async {
                      setState(() => _isLoading = true);
                      await widget.onAdd(_selected!);
                      setState(() => _isLoading = false);
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Agregar'),
            ),
          ),
        ],
      ),
    );
  }
}