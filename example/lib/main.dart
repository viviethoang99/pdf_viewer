import 'package:flutter/material.dart';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  PDFDocument document;

  @override
  void initState() {
    super.initState();
    changePDF();
  }

  // void loadDocument() async {
  //   document = await PDFDocument.fromAsset('assets/sample.pdf');

  //   setState(() => _isLoading = false);
  // }

  void changePDF() async {
    setState(() => _isLoading = true);

    document = await PDFDocument.fromURL(
      'http://conorlastowka.com/book/CitationNeededBook-Sample.pdf',
      /* cacheManager: CacheManager(
          Config(
            "customCacheKey",
            stalePeriod: const Duration(days: 2),
            maxNrOfCacheObjects: 10,
          ),
        ), */
    );

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        // drawer: Drawer(
        //   child: Column(
        //     children: <Widget>[
        //       const SizedBox(height: 36),
        //       ListTile(
        //         title: const Text('Load from Assets'),
        //         onTap: () {
        //           changePDF(1);
        //         },
        //       ),
        //       ListTile(
        //         title: const Text('Load from URL'),
        //         onTap: () {
        //           changePDF(2);
        //         },
        //       ),
        //       ListTile(
        //         title: const Text('Restore default'),
        //         onTap: () {
        //           changePDF(3);
        //         },
        //       ),
        //     ],
        //   ),
        // ),
        appBar: AppBar(
          title: const Text('FlutterPluginPDFViewer'),
        ),
        body: Center(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : PDFViewer(
                  document: document,
                  zoomSteps: 1,
                  //uncomment below line to preload all pages
                  lazyLoad: false,
                  // uncomment below line to scroll vertically
                  scrollDirection: Axis.vertical,

                  //uncomment below code to replace bottom navigation with your own
                  /* navigationBuilder:
                      (context, page, totalPages, jumpToPage, animateToPage) {
                    return ButtonBar(
                      alignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.first_page),
                          onPressed: () {
                            jumpToPage()(page: 0);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            animateToPage(page: page - 2);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_forward),
                          onPressed: () {
                            animateToPage(page: page);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.last_page),
                          onPressed: () {
                            jumpToPage(page: totalPages - 1);
                          },
                        ),
                      ],
                    );
                  }, */
                ),
        ),
      ),
    );
  }
}
