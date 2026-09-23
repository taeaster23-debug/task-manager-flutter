import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/task.dart';
import '../../providers/task_provider.dart';

class TaskFormScreen extends StatefulWidget {
  final String uid;
  final Task? task;
  const TaskFormScreen({super.key, required this.uid, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  DateTime? _dueDate;

  bool get editing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.task?.title ?? '');
    _description = TextEditingController(text: widget.task?.description ?? '');
    _dueDate = widget.task?.dueDate;
  }

  @override
  void dispose() { _title.dispose(); _description.dispose(); super.dispose(); }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime(2100), initialDate: _dueDate ?? DateTime.now());
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<TaskProvider>();
    final ok = editing
        ? await provider.updateTask(uid: widget.uid, task: Task(id: widget.task!.id, title: _title.text, description: _description.text, isCompleted: widget.task!.isCompleted, dueDate: _dueDate, createdAt: widget.task!.createdAt))
        : await provider.addTask(uid: widget.uid, title: _title.text, description: _description.text, dueDate: _dueDate);
    if (!mounted) return;
    if (ok) Navigator.pop(context);
    else if (provider.error != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.error!)));
  }

  
@override
Widget build(BuildContext context) {
  final loading = context.watch<TaskProvider>().loading;

  return Scaffold(
    appBar: AppBar(
      title: Text(editing ? 'Edit Task' : 'Add Task'),
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(
                  labelText: 'Task title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? 'Enter a task title'
                        : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _description,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? 'Enter a description'
                        : null,
              ),
              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_month_outlined),
                label: Text(
                  _dueDate == null
                      ? 'Choose due date (optional)'
                      : 'Due: ${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                ),
              ),

              if (_dueDate != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => setState(() => _dueDate = null),
                    child: const Text('Clear date'),
                  ),
                ),

              const SizedBox(height: 20),

              FilledButton.icon(
                onPressed: loading ? null : _save,
                icon: const Icon(Icons.save_outlined),
                label: Text(
                  editing ? 'Update Task' : 'Add Task',
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
