import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../settings/settings_screen.dart';
import 'task_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().user?.uid;
      if (uid != null) context.read<TaskProvider>().startListening(uid);
    });
  }

  Future<void> _delete(String uid, String taskId) async {
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('Delete task?'), content: const Text('This action cannot be undone.'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete'))])) ?? false;
    if (!confirmed || !mounted) return;
    await context.read<TaskProvider>().deleteTask(uid: uid, taskId: taskId);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final uid = auth.user?.uid;
    if (uid == null) return const SizedBox.shrink();
    return Scaffold(
      appBar: AppBar(title: const Text('My Tasks'), actions: [IconButton(tooltip: 'Settings', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())), icon: const Icon(Icons.settings_outlined))]),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TaskFormScreen(uid: uid))), icon: const Icon(Icons.add), label: const Text('Add Task')),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _Stat(label: 'Total', value: taskProvider.tasks.length.toString()),
            _Stat(label: 'Pending', value: taskProvider.pendingCount.toString()),
            _Stat(label: 'Done', value: taskProvider.completedCount.toString()),
          ]))),
          const SizedBox(height: 16),
          if (taskProvider.error != null) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(taskProvider.error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
          if (taskProvider.tasks.isEmpty) const Padding(padding: EdgeInsets.only(top: 80), child: Column(children: [Icon(Icons.inbox_outlined, size: 64), SizedBox(height: 12), Text('No tasks yet'), SizedBox(height: 6), Text('Tap “Add Task” to create your first task.')]))
          else ...taskProvider.tasks.map((task) => Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(
            leading: Checkbox(value: task.isCompleted, onChanged: (_) => context.read<TaskProvider>().toggleTask(uid, task)),
            title: Text(task.title, style: TextStyle(decoration: task.isCompleted ? TextDecoration.lineThrough : null, fontWeight: FontWeight.w600)),
            subtitle: Text(task.description, maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: PopupMenuButton<String>(onSelected: (value) { if (value == 'edit') Navigator.push(context, MaterialPageRoute(builder: (_) => TaskFormScreen(uid: uid, task: task))); if (value == 'delete') _delete(uid, task.id); }, itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Edit')), PopupMenuItem(value: 'delete', child: Text('Delete'))]),
          )))
        ],),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label; final String value;
  const _Stat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(children: [Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 3), Text(label)]);
}
