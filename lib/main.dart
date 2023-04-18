import 'package:cached_network_image/cached_network_image.dart';
import 'package:coding_test_algostudio/meme_detail.dart';
import 'package:coding_test_algostudio/meme_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MimGenerator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<MemeModel>?> _fetchListMeme() async {
    try {
      Response response = await Dio().get('https://api.imgflip.com/get_memes');

      if (response.data['success']) {
        if (response.data['data'] != null) {
          if (response.data['data']['memes'] != null) {
            return (response.data['data']['memes'] as List)
                .map((e) => MemeModel.fromJson(e))
                .toList();
          }
          return null;
        }
        return null;
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MimGenerator'), centerTitle: true),
      body: FutureBuilder(
        future: _fetchListMeme(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              if (snapshot.hasData) {
                List<MemeModel> listMeme = snapshot.data as List<MemeModel>;
                return _gridItem(listMeme);
              } else {
                return Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Data tidak ditemukan'),
                      const SizedBox(height: 8.0),
                      OutlinedButton.icon(
                        onPressed: () {
                          _fetchListMeme();
                          setState(() {});
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      )
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }

  Widget _gridItem(List<MemeModel> listMeme) {
    return RefreshIndicator(
      onRefresh: () async {
        _fetchListMeme();
        setState(() {});
      },
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
        ),
        itemBuilder: (context, index) {
          MemeModel item = listMeme[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return MemeDetailPage(item);
              }));
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CachedNetworkImage(
                imageUrl: item.url!,
                fit: BoxFit.fill,
              ),
            ),
          );
        },
      ),
    );
  }
}
