import 'package:flutter/material.dart';

import '../services/image_sources.dart';

class ImageUrlDialog extends StatefulWidget {
  const ImageUrlDialog({super.key});
  @override
  State<ImageUrlDialog> createState() => _ImageUrlDialogState();
}

class _ImageUrlDialogState extends State<ImageUrlDialog> {
  final _controller = TextEditingController();
  final _form = GlobalKey<FormState>();

  void _submit() {
    if (_form.currentState!.validate()) {
      Navigator.of(context).pop(_controller.text.trim());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Download an image'),
      content: SingleChildScrollView(
        child: Form(
          key: _form,
          child: TextFormField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.url,
            autocorrect: false,
            textInputAction: TextInputAction.go,
            decoration: const InputDecoration(
              labelText: 'Image URL',
              hintText: 'https://example.com/photo.jpg',
              helperText: 'Paste a direct image link, not a web page.',
            ),
            validator: (value) {
              try {
                ImageSources.parseUrl(value ?? '');
                return null;
              } on ImageSourceException catch (error) {
                return error.message;
              }
            },
            onFieldSubmitted: (_) => _submit(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Download')),
      ],
    );
  }
}
