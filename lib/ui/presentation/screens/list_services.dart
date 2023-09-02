import 'package:flutter/material.dart';

class ListService extends StatefulWidget {
  const ListService({super.key});

  @override
  State<ListService> createState() => _ListServiceState();
}

class _ListServiceState extends State<ListService> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text("Services"),
    );
  }
}
