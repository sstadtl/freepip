import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.orange, primaryTextTheme: TextTheme(headline6: TextStyle(color: Colors.white))),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _editingController = TextEditingController();

  InAppWebViewController webView;
  // String url = "";
  double progress = 0;
  String leerHtml = """<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Page Title</title>
<style>
</style>
</head>
<body></body></html>""";

  String parseInputToUrl(String input) {
    debugPrint('input:$input');
    String ret = '';

    if (input.indexOf('embed') > 0) {
      debugPrint('url ist schon richtig');
      ret = input;
    } else if (input.indexOf('/playlist?list') > 0) {
      var uri = Uri.parse(input);
      uri.queryParameters.forEach((k, v) {
        print('key: $k - value: $v');
        if (k == 'list') {
          ret = 'https://www.youtube.com/embed/videoseries?list=$v';
        }
      });
    } else if (input.indexOf('/watch?') > 0) {
      var uri = Uri.parse(input);
      uri.queryParameters.forEach((k, v) {
        print('key: $k - value: $v');
        if (k == 'v') {
          String vidid = v;
          ret = 'https://www.youtube.com/embed/$vidid';
        }
      });
    } else if (input.indexOf('/youtu.be/') > 0) {
      var arr = input.split('/');
      debugPrint('$arr');
      // IyFZznAk69U
      String vidid = arr.last;
      ret = 'https://www.youtube.com/embed/$vidid';
    }

    return ret;
  }

  String buildHTML(String url) {
    int width = MediaQuery.of(context).size.width.toInt() - 15;
    int height = (width / 4.0 * 3.0).floor();
    debugPrint('width:$width height:$height');
    String ret = """<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Page Title</title>
<style>
</style>
</head>
<body><iframe width="$width" height="$height" src="$url" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe></body>
</html>""";
    debugPrint('$ret');
    return ret;
  }

  void sendAction() {
    String vidurl = parseInputToUrl(_editingController.text);
    debugPrint(' sendActionvidurl:$vidurl');
    if (vidurl == '') {
      webView.loadData(data: leerHtml);
    } else {
      webView.loadData(data: buildHTML(vidurl));
    }

    FocusScope.of(context).unfocus();
  }

  void clearAction() {
    _editingController.text = '';
    sendAction();
  }

  Widget buildEditBar() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _editingController,
              decoration: InputDecoration(
                labelText: 'paste url here',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                prefixIcon: IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Theme.of(context).primaryColor,
                    size: 30.0,
                  ),
                  onPressed: clearAction,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Theme.of(context).primaryColor,
                    size: 30.0,
                  ),
                  onPressed: sendAction,
                ),
              ),
              onFieldSubmitted: (_) {
                sendAction();
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Free PiP'),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            // debugPrint('tap');
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Column(
            children: [
              buildEditBar(),
              Container(padding: EdgeInsets.all(10.0), child: progress < 1.0 ? LinearProgressIndicator(value: progress) : Container()),
              Expanded(
                child: Container(
                  child: InAppWebView(
                    initialHeaders: {},
                    initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                      debuggingEnabled: true,
                    )),
                    onWebViewCreated: (InAppWebViewController controller) {
                      webView = controller;
                    },
                    onProgressChanged: (InAppWebViewController controller, int progress) {
                      setState(() {
                        this.progress = progress / 100;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
