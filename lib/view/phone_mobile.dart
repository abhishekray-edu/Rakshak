import 'dart:async';
import 'dart:typed_data' as td;

import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rakhshak/constant.dart';
import '../model/emergency_contacts.dart';
import 'package:provider/provider.dart';

List<Contact> _selectedContacts = [];

List<Contact> _tappedContacts = [];

class PhoneMobile extends StatefulWidget {
  @override
  _PhoneMobileState createState() => _PhoneMobileState();
}

class _PhoneMobileState extends State<PhoneMobile> {
  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  List<Contact> _contacts = const [];
  String? _text;

  bool _isLoading = false;

  final _ctrl = ScrollController();

  Future<void> loadContacts() async {
    try {
      await Permission.contacts.request();
      _isLoading = true;
      if (mounted) setState(() {});
      final contacts = await FastContacts.getAllContacts();

      setState(() {
        _contacts = contacts;
      });
    } on PlatformException catch (e) {
      _text = 'Failed to get contacts:\n${e.details}';
    } finally {
      _isLoading = false;
    }
    if (!mounted) return;
    setState(() {});
  }

  void saveEmergencyContacts() async {
    Provider.of<EmergencyContacts>(context, listen: false)
        .saveEmergencyContacts(_selectedContacts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            saveEmergencyContacts();
            Navigator.pop(context);
          },
          label: Icon(Icons.save)),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (_selectedContacts != _tappedContacts) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Save changes?'),
                    content: SingleChildScrollView(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: Text('Discard'),
                          ),
                          TextButton(
                            onPressed: () {
                              saveEmergencyContacts();
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: Text('Save'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
        centerTitle: true,
        title: const Text('Contacts'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextButton(
            onPressed: loadContacts,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 24,
                  width: 24,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isLoading
                        ? CircularProgressIndicator()
                        : Icon(Icons.refresh),
                  ),
                ),
                const SizedBox(width: 8),
                Text('Load contacts'),
              ],
            ),
          ),
          Expanded(
            child: Scrollbar(
              controller: _ctrl,
              interactive: true,
              thickness: 24,
              child: ListView.builder(
                controller: _ctrl,
                itemCount: _contacts.length,
                itemExtent: _ContactItem.height,
                itemBuilder: (_, index) =>
                    _ContactItem(contact: _contacts[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  _ContactItem({
    Key? key,
    required this.contact,
  }) : super(key: key);

  static const height = 86.0;

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final phones = contact.phones.map((e) => e.number).join(', ');
    final emails = contact.emails.map((e) => e.address).join(', ');
    final name = contact.structuredName;
    final nameStr = name != null
        ? [
            if (name.namePrefix.isNotEmpty) name.namePrefix,
            if (name.givenName.isNotEmpty) name.givenName,
            if (name.middleName.isNotEmpty) name.middleName,
            if (name.familyName.isNotEmpty) name.familyName,
            if (name.nameSuffix.isNotEmpty) name.nameSuffix,
          ].join(', ')
        : '';
    final organization = contact.organization;
    final organizationStr = organization != null
        ? [
            if (organization.company.isNotEmpty) organization.company,
            if (organization.department.isNotEmpty) organization.department,
            if (organization.jobDescription.isNotEmpty)
              organization.jobDescription,
          ].join(', ')
        : '';

    return SizedBox(
      height: height,
      child: ListTile(
        onTap: () {
          _selectedContacts.add(contact);
        },
        leading: _ContactImage(contact: contact),
        title: Text(
          contact.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: backgroundColor),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (phones.isNotEmpty)
              Text(
                phones,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (emails.isNotEmpty)
              Text(
                emails,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (nameStr.isNotEmpty)
              Text(
                nameStr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (organizationStr.isNotEmpty)
              Text(
                organizationStr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Text(
          'Tap and click save',
          style: TextStyle(fontSize: 13),
        ),
      ),
    );
  }
}

class _ContactImage extends StatefulWidget {
  const _ContactImage({
    Key? key,
    required this.contact,
  }) : super(key: key);

  final Contact contact;

  @override
  __ContactImageState createState() => __ContactImageState();
}

class __ContactImageState extends State<_ContactImage> {
  late Future<td.Uint8List?> _imageFuture;

  @override
  void initState() {
    super.initState();
    _imageFuture = FastContacts.getContactImage(widget.contact.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<td.Uint8List?>(
      future: _imageFuture,
      builder: (context, snapshot) => CircleAvatar(
        child: Container(
          width: 56,
          height: 56,
          child: snapshot.hasData
              ? Image.memory(snapshot.data!, gaplessPlayback: true)
              : Icon(Icons.account_box_rounded),
        ),
      ),
    );
  }
}
