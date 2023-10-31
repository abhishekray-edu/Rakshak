import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../model/emergency_contacts.dart';
import 'package:provider/provider.dart';
class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFFAFCFE),
        appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            title: Text(
              "SOS Contacts",
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.black),
            ),
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: Image.asset("assets/phone_red.png"),
              onPressed: () {},
            )),
        body: FutureBuilder(
            future:
                Provider.of<EmergencyContacts>(context).fetchSavedEmergency(), //now work from here
            builder: (context, AsyncSnapshot<List<Contact>> snap) {
              if (snap.hasData && snap.data!.isNotEmpty) {
                print(snap.data);

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              indent: 20,
                              endIndent: 20,
                            ),
                          ),
                          Text("Swipe left to delete Contact"),
                          Expanded(
                            child: Divider(
                              indent: 20,
                              endIndent: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: snap.data!.length,
                        itemBuilder: (context, index) {
                          final contact = snap.data![index];

                          return Slidable(
                            child: Container(
                              color: Colors.white,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage:
                                      AssetImage("assets/user.png"),
                                ),
                                title: Text(contact
                                    .displayName), // Display contact name
                                subtitle: Text(
                                  contact.phones.isNotEmpty
                                      ? contact.phones[0].number
                                      : "No Contact", // Display first phone number if available
                                ),
                              ),
                            ),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: <Widget>[
                                SlidableAction(
                                  label: 'Delete',
                                  backgroundColor: Color(0xFFFE4A49),
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  onPressed: (context) {
                                    // Handle delete action here
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                );
              } else {
                return Center(
                  child: Text("No Contacts found!"),
                );
              }
            }));
  }
}
