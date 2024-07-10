import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import 'main.dart';

class InAppWebViewExampleScreen extends StatefulWidget {
  @override
  _InAppWebViewExampleScreenState createState() =>
      _InAppWebViewExampleScreenState();
}

class _InAppWebViewExampleScreenState extends State<InAppWebViewExampleScreen> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
      isInspectable: kDebugMode,
      mediaPlaybackRequiresUserGesture: true,
      allowsInlineMediaPlayback: false,
      useShouldInterceptAjaxRequest: true,
      interceptOnlyAsyncAjaxRequests: false,
      iframeAllow: "camera; microphone",
      iframeAllowFullscreen: true);

  PullToRefreshController? pullToRefreshController;

  late ContextMenu contextMenu;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();


  String htmlString = """
  <html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=10.0, user-scalable=yes" />
    <link rel="shortcut icon" href="#" />
    <link rel="stylesheet" href="https://unpkg.com/formiojs@4.14.12/dist/formio.full.min.css">
    <link rel="stylesheet" href="https://form.carecloud.io/prod/manage/view/styles.css">
    <link rel="stylesheet" href="https://form.carecloud.io/prod/manage/view/assets/lib/bootswatch/dist/cosmo/bootstrap.min.css">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2/?family=Source+Sans+Pro:wght@300;400;700&display=swap">
    <script src="https://unpkg.com/formiojs@4.14.12/dist/formio.full.min.js"></script>
    <script src="https://cdn.staticfile.org/jquery/1.10.2/jquery.min.js"></script>
    <script type="text/javascript">
      var formio;
      var submitData = {};
      var initFormioJson = {};
      var objectData = {}
      var formURL = '';
      var isReadOnly = false;
      var isViewOnly = false;
      var zoom = 0;
      var role = '';
      var service
      var controlIsChanging = false
      var _currentComponent
      var defaultRenderOptions = {
        sanitizeConfig: {
          addTags: ['iframe']
        }
      };
      var renderOptions = {}
      var isFlutterInAppWebViewReady = false;
      window.addEventListener("flutterInAppWebViewPlatformReady", function(event) {
        isFlutterInAppWebViewReady = true;
      });
      window.onload = function() {
        Load.postMessage('window onload...');
      };

      function refresh() {
        formio.refresh();
      }

      function initData(data) {
        if (data) {
          objectData = data.objectData // { readOnly: isReadOnly, viewOnly: isViewOnly, zoom: zoom, noAlerts: true }
          initFormioJson = data.initFormioJson
          submitData = data.submitData
          role = data.role
          formURL = data.url
          renderOptions = data.renderOptions || defaultRenderOptions
          createForm()
        }
      }

      function initSubmitData(data) {
        submitData = data
        Object.keys(submitData.data).map((item) => {
          if (submitData.data[item] == '') {
            delete submitData.data[item]
          }
        })
        formio.submission = submitData
      }

      function initRole(data) {
        role = data
        if (formio && formio.form) {
          resetComponents(formio.form.components);
        }
      }

      function createForm() {
        var initFormData = initFormioJson ? JSON.parse(initFormioJson) : formURL
        Formio.createForm(document.getElementById('formio'), initFormData, objectData).then(function(form) {
          form.submission = submitData
          formio = form
          form.on('error', function(e) {
            if (e && e.length) {
              const error = e.map((x) => x.message)
              callApp('error', error)
            }
          })
          form.on('change', function(e) {
            callApp('change')
          })
          form.on('formLoad', function(e) {
            updateControlForm()
            callApp('formLoad')
          })
          form.on('submit', function(e) {
            callApp('submit')
          })
          form.on('submitDone', function(e) {
            callApp('submitDone')
          })
          form.on('submitError', function(e) {
            callApp('submitError')
          })
          form.on('render', function(e) {
            callApp('render')
          })
          form.on('initialized', function(e) {
            callApp('initialized')
          })
          form.on('requestDone', function(e) {
            callApp('requestDone')
          })
          form.on('languageChanged', function(e) {
            callApp('languageChanged', e)
          })
          form.on('saveDraftBegin', function(e) {
            callApp('saveDraftBegin')
          })
          form.on('saveDraft', function(e) {
            callApp('saveDraft')
          })
          form.on('restoreDraft', function(e) {
            callApp('restoreDraft')
          })
          form.on('submissionDeleted', function(e) {
            callApp('submissionDeleted')
          })
          form.on('redraw', function(e) {
            callApp('redraw')
          })
          form.on('focus', function(e) {
            callApp('focus')
          })
          form.on('blur', function(e) {
            callApp('blur')
          })
          form.on('componentChanged', function(e) {
            callApp('componentChanged')
          })
          form.on('componentError', function(e) {
            callApp('componentError')
          })
          form.on('nextPage', function(e) {
            callApp('nextPage')
          })
          form.on('prevPage', function(e) {
            callApp('prevPage')
          })
          form.on('wizardPageClicked', function(e) {
            callApp('wizardPageClicked')
          })
          form.on('wizardPageSelected', function(e) {
            callApp('wizardPageSelected')
          })
          callApp('oninit')
          setTimeout(() => {
            resetComponents(formio.form.components);
            if (form.form && form.form.display == 'form') {
              updateControlForm();
            }
          });
        })
      }
      async function updateControlForm() {
        if (controlIsChanging || !formio.form || _currentComponent === formio.form.components) {
          return;
        }
        controlIsChanging = true;
        _currentComponent = _.cloneDeep(formio.form.components || []);
        // console.warn('formio', formio)
        const hasChange = resetComponents(_currentComponent);
        await formio.setForm({
          components: _currentComponent
        });
        controlIsChanging = false;
      };

      function resetComponents(components) {
        let hasChange = false;
        FormioUtils.eachComponent(components, component => {
          let visible = _.get(component, 'properties.visible');
          let required = _.get(component, 'properties.required');
          // console.info(visible, required)
          if (visible) {
            visible = visible.split(',');
            const hidden = visible.indexOf(role) <= -1;
            if (component.hidden !== hidden) {
              component.hidden = hidden;
              hasChange = true;
            }
          }
          if (required) {
            required = required.split(',');
            const oldRequired = _.get(component, 'validate.required');
            const newRequired = required.indexOf(role) > -1;
            // console.info(oldRequired, newRequired)
            if (oldRequired !== newRequired) {
              _.set(component, 'validate.required', newRequired);
              hasChange = true;
            }
          }
        });
        return hasChange;
      };

      function callApp(func, e = '') {
        if (func) {
          const data = {
            Name: func,
            Data: e
          }
          if (isFlutterInAppWebViewReady) {
            window.flutter_inappwebview.callHandler('formIoCall', data);
          }
        }
      }

      function submit() {
        if (formio) {
          if (!formio.checkValidity()) {
            formio.executeSubmit();
          } else {
            var params = formio._data; // _submission
            if (isFlutterInAppWebViewReady) {
              window.flutter_inappwebview.callHandler('submitCall', params);
            }
          }
        }
      }
    </script>
    <style type="text/css">
      html {
        height: 100%;
        width: 100%;
      }

      #formio {
        height: 100%;
        overflow: auto;
      }

      #formio .formio-form-pdf {
        height: 100%;
      }

      #formio .formio-component-button {
        display: none;
      }

      #formio .formio-iframe {
        height: 100%;
        overflow: hidden;
      }

      .height100 {
        height: 100%;
        width: auto;
      }

      /*隐藏 submit 按钮*/
      #formio .formio-component-button {
        display: none;
      }
    </style>
</head>
<body style="background-color: rgb(250,250,250);height: 100%;width: 100%;">
<div id='formio'></div>
</body>
</html>
  """;

  @override
  void initState() {
    super.initState();

    contextMenu = ContextMenu(
        menuItems: [
          ContextMenuItem(
              id: 1,
              title: "Special",
              action: () async {
                print("Menu item Special clicked!");
                print(await webViewController?.getSelectedText());
                await webViewController?.clearFocus();
              })
        ],
        settings: ContextMenuSettings(hideDefaultSystemContextMenuItems: false),
        onCreateContextMenu: (hitTestResult) async {
          print("onCreateContextMenu");
          print(hitTestResult.extra);
          print(await webViewController?.getSelectedText());
        },
        onHideContextMenu: () {
          print("onHideContextMenu");
        },
        onContextMenuActionItemClicked: (contextMenuItemClicked) async {
          var id = contextMenuItemClicked.id;
          print("onContextMenuActionItemClicked: " +
              id.toString() +
              " " +
              contextMenuItemClicked.title);
        });

    pullToRefreshController = kIsWeb ||
            ![TargetPlatform.iOS, TargetPlatform.android]
                .contains(defaultTargetPlatform)
        ? null
        : PullToRefreshController(
            settings: PullToRefreshSettings(
              color: Colors.blue,
            ),
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS) {
                webViewController?.loadUrl(
                    urlRequest:
                        URLRequest(url: await webViewController?.getUrl()));
              }
            },
          );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("InAppWebView")),
        drawer: myDrawer(context: context),
        body: SafeArea(
            child: Column(children: <Widget>[
          TextField(
            decoration: InputDecoration(prefixIcon: Icon(Icons.search)),
            controller: urlController,
            keyboardType: TextInputType.text,
            onSubmitted: (value) {
              var url = WebUri(value);
              if (url.scheme.isEmpty) {
                url = WebUri((!kIsWeb
                        ? "https://www.google.com/search?q="
                        : "https://www.bing.com/search?q=") +
                    value);
              }
              webViewController?.loadUrl(urlRequest: URLRequest(url: url));
            },
          ),
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  key: webViewKey,
                  webViewEnvironment: webViewEnvironment,
                  initialData: InAppWebViewInitialData(
                      data: htmlString, baseUrl: WebUri('http://localhost')),
                  initialUserScripts: UnmodifiableListView<UserScript>([]),
                  initialSettings: settings,
                  contextMenu: contextMenu,
                  pullToRefreshController: pullToRefreshController,
                  onWebViewCreated: (controller) async {
                    webViewController = controller;
                  },
                  onLoadStart: (controller, url) async {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onPermissionRequest: (controller, request) async {
                    return PermissionResponse(
                        resources: request.resources,
                        action: PermissionResponseAction.GRANT);
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                    var uri = navigationAction.request.url!;

                    if (![
                      "http",
                      "https",
                      "file",
                      "chrome",
                      "data",
                      "javascript",
                      "about"
                    ].contains(uri.scheme)) {
                      if (await canLaunchUrl(uri)) {
                        // Launch the App
                        await launchUrl(
                          uri,
                        );
                        // and cancel the request
                        return NavigationActionPolicy.CANCEL;
                      }
                    }

                    return NavigationActionPolicy.ALLOW;
                  },
                  onLoadStop: (controller, url) async {
                    pullToRefreshController?.endRefreshing();
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                    dynamic initDataParams = {
                      "url": 'https://form.mcttechnology.cn/shtest-prod/shtest-0-ccn-uploadfiles-en',
                      "objectData": {
                        "sanitizeConfig": {
                          "addTags": ["iframe"]
                        }
                      },
                    };
                    String jsonString = json.encode(initDataParams);
                    controller.evaluateJavascript(source: 'initData($jsonString)');
                  },
                  onReceivedError: (controller, request, error) {
                    pullToRefreshController?.endRefreshing();
                  },
                  onProgressChanged: (controller, progress) {
                    if (progress == 100) {
                      pullToRefreshController?.endRefreshing();
                    }
                    setState(() {
                      this.progress = progress / 100;
                      urlController.text = this.url;
                    });
                  },
                  onUpdateVisitedHistory: (controller, url, isReload) {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  shouldInterceptAjaxRequest: (controller, ajaxRequest) async {
                    print('ajaxRequest ---------- ${ajaxRequest.toString()}');

                    /// change https://form.mcttechnology.cn/shtest-prod/shtest-0-ccn-uploadfiles-en/storage/s3
                    if (ajaxRequest.url.toString().contains('storage/s3')) {
                      ajaxRequest.url = WebUri.uri(Uri.parse(
                          'https://shtest-app-v2.mcttechnology.cn/api/platform/formio/shtest-0-ccn-uploadfiles-en/storage/s3'));

                      ajaxRequest.headers?.setRequestHeader('authorization',
                          'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsImtpZCI6Ikl2VyJ9.eyJpc3MiOm51bGwsInN1YiI6MTExMTY1MjQxLCJpYXQiOjE3MjA1ODE3MTMsImV4cCI6MTcyMDYyNDkxMywiZW1haWwiOiIzMjY1NjQ0NTYxQHFxLmNvbSIsImdpdmVuX25hbWUiOiJzaHRlc3QiLCJmYW1pbHlfbmFtZSI6ImNqanl5IiwibmFtZSI6IjMyNjU2NDQ1NjFAcXEuY29tIiwicHJlZmVycmVkX3VzZXJuYW1lIjoiMzI2NTY0NDU2MUBxcS5jb20iLCJqdGkiOjQsInVzZXJJZCI6bnVsbH0.uU0WVtEJoa3v17_UHKzaee1y2cFXdArvKQidylPa-YY');
                    }

                    return ajaxRequest;
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    print(consoleMessage);
                  },
                ),
                progress < 1.0
                    ? LinearProgressIndicator(value: progress)
                    : Container(),
              ],
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                child: Icon(Icons.arrow_back),
                onPressed: () {
                  webViewController?.goBack();
                },
              ),
              ElevatedButton(
                child: Icon(Icons.arrow_forward),
                onPressed: () {
                  webViewController?.goForward();
                },
              ),
              ElevatedButton(
                child: Icon(Icons.refresh),
                onPressed: () {
                  webViewController?.reload();
                },
              ),
            ],
          ),
        ])));
  }
}
