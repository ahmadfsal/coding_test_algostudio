import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:coding_test_algostudio/meme_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_share_plugin/social_share_plugin.dart';

class MemeDetailPage extends StatefulWidget {
  const MemeDetailPage(this.item, {Key? key}) : super(key: key);

  final MemeModel item;

  @override
  State<MemeDetailPage> createState() => _MemeDetailPageState();
}

class _MemeDetailPageState extends State<MemeDetailPage> {
  XFile? _logoAdded;
  String? _textAdded;
  bool _showShare = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MimGenerator'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.item.url!,
                    fit: BoxFit.fill,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_logoAdded != null)
                          CircleAvatar(
                            backgroundImage: FileImage(File(_logoAdded!.path)),
                            maxRadius: 56.0,
                          ),
                        if (_textAdded != null)
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 24.0,
                                left: 24.0,
                              ),
                              child: Text(
                                _textAdded!,
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            _checkStatuses(),
          ],
        ),
      ),
    );
  }

  Widget _checkStatuses() {
    if (_logoAdded != null && _textAdded != null) {
      if (!_showShare) {
        return _actionsSaveAndShare();
      } else {
        return _actionsShareSocial();
      }
    }
    return _actionsAddLogoAndText();
  }

  Widget _bottomAction(
      {required String title, required IconData icon, void Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          const SizedBox(height: 8.0),
          Icon(icon),
        ],
      ),
    );
  }

  void _showPopupAddText() {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text('Add Text'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _controller,
              decoration: const InputDecoration(
                fillColor: Color(0xFFF5F6F7),
                filled: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 14.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value == '') {
                  return 'Text cannot be empty';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _textAdded = _controller.text;
                  setState(() {});
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _actionsAddLogoAndText() {
    return Row(
      children: [
        _bottomAction(
          title: 'Add Logo',
          icon: Icons.image,
          onTap: () async {
            XFile? pickedFile = await ImagePicker().pickImage(
              source: ImageSource.gallery,
              maxHeight: 1000.0,
              maxWidth: 1000.0,
            );
            if (pickedFile != null) {
              _logoAdded = XFile(pickedFile.path);
              setState(() {});
            }
          },
        ),
        const SizedBox(width: 24.0),
        _bottomAction(
          title: 'Add Text',
          icon: Icons.text_fields,
          onTap: _showPopupAddText,
        ),
      ],
    );
  }

  Widget _actionsSaveAndShare() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            child: const Text('Simpan'),
            onPressed: () async {
              SharedPreferences preferences =
                  await SharedPreferences.getInstance();
              preferences.setString(
                "LOGO_IMAGE_PATH",
                _logoAdded!.path,
              );
              preferences.setString("TEXT_ADDED", _textAdded!);
            },
          ),
        ),
        const SizedBox(width: 24.0),
        Expanded(
          child: ElevatedButton(
            child: const Text('Share'),
            onPressed: () {
              _showShare = true;
              setState(() {});
            },
          ),
        ),
      ],
    );
  }

  Widget _actionsShareSocial() {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: ElevatedButton(
            child: const Text('Share to FB'),
            onPressed: () {
              SocialSharePlugin.shareToFeedFacebook(path: _logoAdded!.path);
            },
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: ElevatedButton(
            child: const Text('Share to Twitter'),
            onPressed: () {
              SocialSharePlugin.shareToTwitterLink(
                url: 'https://flutter.dev',
                text: '${_logoAdded!.name} ${_textAdded!}',
              );
            },
          ),
        ),
      ],
    );
  }
}
