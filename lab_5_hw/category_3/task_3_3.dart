
import 'package:flutter/material.dart';

class Contact {
  final String name;
  final String phone;
  final String email;

  const Contact(this.name, this.phone, this.email);
}

const contacts = [
  Contact('Ali', '111111', 'ali@gmail.com'),
  Contact('Bob', '222222', 'bob@gmail.com'),
  Contact('John', '333333', 'john@gmail.com'),
  Contact('Anna', '444444', 'anna@gmail.com'),
  Contact('Sara', '555555', 'sara@gmail.com'),
];

void main() => runApp(const MaterialApp(home: ContactListScreen()));

class ContactListScreen extends StatelessWidget {
  const ContactListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contacts')),
      body: ListView(
        children: [
          for (final contact in contacts)
            ListTile(
              title: Text(contact.name),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ContactScreen(contact: contact),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class ContactScreen extends StatelessWidget {
  final Contact contact;

  const ContactScreen({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(contact.name)),
      body: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(contact.name),
                Text(contact.phone),
                Text(contact.email),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
