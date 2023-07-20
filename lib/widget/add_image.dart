import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class InputImage extends StatefulWidget {
  const InputImage({super.key, required this.tackImage});
final void Function(File selectedImage) tackImage;
  @override
  State<InputImage> createState() => _InputImageState();
}

class _InputImageState extends State<InputImage> {
  File? pickedImage;

  void getImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 150,
    );
    if (image == null) {
      return;
    }
    setState(() {
      pickedImage = File(image.path);
    });
    widget.tackImage(pickedImage!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 45,
          backgroundColor: Colors.grey,
          foregroundImage:
              pickedImage != null ? FileImage(pickedImage!) :null,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: getImage,
              icon: const Icon(Icons.photo),
              label: Text(
                'Add Image',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  pickedImage = null;
                });
              },
              child: const Text('Reset'),
            )
          ],
        ),
      ],
    );
  }
}
