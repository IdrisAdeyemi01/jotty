import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_book/models/ContactsModel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:flutter_book/utilities/utils.dart' as utils;
import 'package:provider/provider.dart';

import '../services/ContactsDBWorker.dart';

class ContactsEntry extends StatelessWidget {
  ContactsEntry() {
    _nameEditingController.addListener(() {
      contactsModel.entityBeingEdited.name = _nameEditingController.text;
    });
    _emailEditingController.addListener(() {
      contactsModel.entityBeingEdited.email = _emailEditingController.text;
    });
    _phoneEditingController.addListener(() {
      contactsModel.entityBeingEdited.phone = _phoneEditingController.text;
    });
  }
  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController _phoneEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  _save(BuildContext inContext, ContactsModel inModel) async {
    inModel = Provider.of<ContactsModel>(inContext, listen: false);
    if (!_formKey.currentState!.validate()) {
      return;
    }
    var id = inModel.entityBeingEdited.id;
    File avatarFile = File(join(utils.docsDir!.path, "avatar"));
    if (inModel.entityBeingEdited.id == null) {
      id = await ContactsDBWorker.db.create(inModel.entityBeingEdited);
      if (avatarFile.existsSync()) {
        avatarFile.renameSync(
          join(
            utils.docsDir!.path,
            id.toString(),
          ),
        );
      }
    } else {
      await ContactsDBWorker.db.update(inModel.entityBeingEdited);
      if (avatarFile.existsSync()) {
        print(avatarFile.existsSync());
        avatarFile.renameSync(
          join(
            utils.docsDir!.path,
            id.toString(),
          ),
        );
      }
    }

    inModel.loadData("contacts", ContactsDBWorker.db);
    inModel.setStackIndex(0);
    ScaffoldMessenger.of(inContext).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        content: Text("Contact saved"),
      ),
    );
  }

  _selectAvatar(BuildContext inContext) {
    contactsModel = Provider.of<ContactsModel>(inContext, listen: false);
    return showDialog(
        context: inContext,
        builder: (inContext) {
          return AlertDialog(
              content: SingleChildScrollView(
                  child: ListBody(
            children: [
              GestureDetector(
                  child: Text("Take a picture"),
                  onTap: () async {
                    var cameraImagery = await ImagePicker()
                        .getImage(source: ImageSource.camera);
                    var cameraImage = File(cameraImagery!.path);

                    // ignore: unnecessary_null_comparison
                    if (cameraImage != null) {
                      cameraImage.copySync(
                        join(utils.docsDir!.path, 'avatar'),
                      );
                      contactsModel.triggerRebuild();
                    }
                    Navigator.of(inContext).pop();
                  }),
              SizedBox(height: 30),
              GestureDetector(
                  child: Text("Select from Gallery"),
                  onTap: () async {
                    print('Now uploading...');
                    var galleryImagery = await ImagePicker()
                        .getImage(source: ImageSource.gallery);
                    var galleryImage = File(galleryImagery!.path);
                    print(galleryImage.path);
                    // ignore: unnecessary_null_comparison
                    if (galleryImage != null) {
                      galleryImage.renameSync(
                        join(utils.docsDir!.path, 'avatar'),
                      );
                      print(galleryImage.path);
                      contactsModel.triggerRebuild();
                      print('Rebuilt triggered');
                    }
                    Navigator.of(inContext).pop();
                  }),
            ],
          )));
        });
  }

  @override
  Widget build(BuildContext context) {
    if (contactsModel.entityBeingEdited == null) {
      _nameEditingController.text = '';
      _emailEditingController.text = '';
      _phoneEditingController.text = '';
    } else {
      _nameEditingController.text = contactsModel.entityBeingEdited.name;
      _emailEditingController.text = contactsModel.entityBeingEdited.email;
      _phoneEditingController.text = contactsModel.entityBeingEdited.phone;
    }

    File avatarFile = File(join(utils.docsDir!.path, "avatar"));
    if (!avatarFile.existsSync()) {
      if (contactsModel.entityBeingEdited != null &&
          contactsModel.entityBeingEdited.id != null) {
        avatarFile = File(
          join(
            utils.docsDir!.path,
            contactsModel.entityBeingEdited.id.toString(),
          ),
        );
      }
    }

    return Scaffold(
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        child: Row(
          children: [
            TextButton(
                onPressed: () {
                  File avatarFile = File(
                    join(utils.docsDir!.path, 'avatar'),
                  );
                  if (avatarFile.existsSync()) {
                    avatarFile.deleteSync();
                  }
                  FocusScope.of(context).requestFocus(FocusNode());
                  contactsModel.setStackIndex(0);
                },
                child: Text("Cancel")),
            Spacer(),
            TextButton(
              onPressed: () {
                _save(context, contactsModel);
              },
              child: Text("Save"),
            )
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            ListTile(
              title: avatarFile.existsSync()
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height * 0.2,
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Image.file(avatarFile))
                  : Text('No avatar image for this contact'),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => _selectAvatar(context),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: TextFormField(
                decoration: InputDecoration(hintText: "Name"),
                controller: _nameEditingController,
                validator: (value) {
                  if (value!.length == 0) {
                    return "Please enter a name";
                  }
                  return null;
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: TextFormField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(hintText: "Phone number"),
                controller: _phoneEditingController,
                validator: (value) {
                  if (value!.length == 0) {
                    return "Please enter the phone number";
                  }
                  return null;
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.email),
              title: TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(hintText: "Email"),
                controller: _emailEditingController,
              ),
            ),
            ListTile(
              leading: Icon(Icons.today),
              title: Text("Birthday"),
              subtitle: Text(contactsModel.chosenDate == null
                  ? ''
                  : contactsModel.chosenDate!),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () async {
                  contactsModel =
                      Provider.of<ContactsModel>(context, listen: false);
                  print(contactsModel.entityBeingEdited.birthday);
                  String chosenDate = await utils.selectDate(
                    context,
                    contactsModel,
                    contactsModel.entityBeingEdited.birthday,
                  );

                  // ignore: unnecessary_null_comparison
                  if (chosenDate != null) {
                    contactsModel.entityBeingEdited.birthday = chosenDate;
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
