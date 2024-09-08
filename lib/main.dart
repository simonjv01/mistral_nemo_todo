import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TodoScreen(),
    );
  }
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _controller = TextEditingController();
  List<TodoItem> _items = [];
  bool _savingState = false;

  @override
  void initState() {
    super.initState();
    loadItemsFromSharedPreferences().then((value) {
      setState(() {
        _items = value;
      });
    });
  }

  Future<List<TodoItem>> loadItemsFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return List<TodoItem>.from(
        prefs.getStringList('todo_items')!.map((e) => TodoItem.fromJson(e)));
  }

  void saveItemsToSharedPreferences(List<TodoItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('todo_items', items.map((item) => item.toJson()).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Todo List')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Add new item',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                setState(() {
                  _items.add(TodoItem(_controller.text, false));
                  _controller.clear();
                });
                saveItemsToSharedPreferences(_items);
              }
            },
            child: Text('Add'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Row(
                    children: [
                      Checkbox(
                        value: _items[index].completed,
                        onChanged: (value) {
                          setState(() {
                            _items[index].completed = value!;
                            saveItemsToSharedPreferences(_items);
                          });
                        },
                      ),
                      Text(_items[index].title),
                      if (_items[index].completed)
                        Text(
                          _items[index].title,
                          style: const TextStyle(decoration: TextDecoration.lineThrough),
                        )
                    ],
                  ),
                  onLongPress: () {
                    setState(() {
                      _items.removeAt(index);
                      saveItemsToSharedPreferences(_items);
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TodoItem {
  String title;
  bool completed;

  TodoItem(this.title, this.completed);

  factory TodoItem.fromJson(String json) {
    final Map<String, dynamic> map = jsonDecode(json);
    return TodoItem(map['title'], map['completed']);
  }

  String toJson() => jsonEncode({'title': title, 'completed': completed});
}
