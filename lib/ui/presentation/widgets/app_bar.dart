import 'package:flutter/material.dart';

class AppBarCustomized extends StatefulWidget implements PreferredSizeWidget {
  final double height;

  const AppBarCustomized({super.key, this.height = kToolbarHeight + 20});

  @override
  State<AppBarCustomized> createState() => _AppBarCustomizedState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(height);
}

class _AppBarCustomizedState extends State<AppBarCustomized> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.amber,
      //toolbarTextStyle: too
      leading: const Padding(
        padding: EdgeInsets.all(1.0),
        child: CircleAvatar(
            //backgroundImage: NetworkImage(),
            ),
      ),
      title: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'Buenos Dias \n Julian',
          textAlign: TextAlign.left,
          style: TextStyle(fontSize: 25),
        ),
      ),
      titleSpacing: 5.0,
    );
  }
}
