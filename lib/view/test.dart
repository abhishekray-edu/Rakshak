import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fast_contacts/fast_contacts.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PhoneMobile(),
    );
  }
}

class PhoneMobile extends StatefulWidget {
  @override
  _PhoneMobileState createState() => _PhoneMobileState();
}

class _PhoneMobileState extends State<PhoneMobile> {
  List<Contact>? _contacts;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.contacts.request();
    if (status.isGranted) {
      _fetchContacts();
    } else {}
  }

  Future<void> _fetchContacts() async {
    final contacts = await FastContacts.getAllContacts();

    setState(() {
      _contacts = contacts;
    });
    print(contacts);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Contacts')),
        body: _body(),
      );

  Widget _body() {
    if (_contacts == null) {
      return Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      itemCount: _contacts!.length,
      itemBuilder: (context, i) => ListTile(
        title: Text(_contacts![i].displayName),

        // Add more contact details or actions here if needed.
      ),
    );
  }
}
