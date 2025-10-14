import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../providers/api_config_provider.dart';

class ChangeApiDialog extends StatefulWidget {
  const ChangeApiDialog({super.key});

  @override
  State<ChangeApiDialog> createState() => _ChangeApiDialogState();
}

class _ChangeApiDialogState extends State<ChangeApiDialog> {
  @override
  Widget build(BuildContext context) {
    final apiConfigProvider = Provider.of<ApiConfigProvider>(
      context,
      listen: false,
    );
    final TextEditingController controller = TextEditingController(
      text: apiConfigProvider.baseUrl,
    );
    return AlertDialog(
      title: Text("Alterar Servidor"),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: "URL"),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () {
            if (controller.text.isNotEmpty) {
              apiConfigProvider.updateBaseUrl(controller.text.trim());
              Navigator.of(context).pop();
            }
          },
          child: Text("Salvar"),
        ),
      ],
    );
  }
}
