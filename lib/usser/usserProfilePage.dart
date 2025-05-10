import 'package:flutter/material.dart';
import 'package:sevenc_iteration_two/usser/usserObject.dart';

/*
class UsserProfile extends StatelessWidget {
  final Usser usser;

  const UsserProfile({Key? key, required this.usser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Row on Top of Column')),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              profilePhoto(imageUrl: usser.profilePic!, name: usser.usserName),

              // Use FutureBuilder for async task retrieval
              FutureBuilder<List<task>>(
                future: usser.getTasksAsync(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return SizedBox(
                      width: 200,
                      child: taskList(snapshot.data ?? []),
                    );
                  }
                },
              ),
            ],
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Column Item 1'),
                Text('Column Item 2'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class profilePhoto extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double imageSize;
  final TextStyle? textStyle;

  const profilePhoto({
    Key? key,
    required this.imageUrl,
    required this.name,
    this.imageSize = 100.0,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(imageSize / 2),
          child: Image.network(
            imageUrl,
            width: imageSize,
            height: imageSize,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.person,
              size: imageSize,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          name,
          style: textStyle ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

Widget taskList(List<task> tasks) {
  return Container(
    height: 300, // Adjust height as needed
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Scrollbar(
      child: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(tasks[index].name!),
          );
        },
      ),
    ),
  );
}

 */



