# WebviewComponent

[![CI Status](https://img.shields.io/travis/howoften/WebviewComponent.svg?style=flat)](https://travis-ci.org/howoften/WebviewComponent)
[![Version](https://img.shields.io/cocoapods/v/WebviewComponent.svg?style=flat)](https://cocoapods.org/pods/WebviewComponent)
[![License](https://img.shields.io/cocoapods/l/WebviewComponent.svg?style=flat)](https://cocoapods.org/pods/WebviewComponent)
[![Platform](https://img.shields.io/cocoapods/p/WebviewComponent.svg?style=flat)](https://cocoapods.org/pods/WebviewComponent)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

WebviewComponent is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile, and keep latest tag:

```ruby
pod ‘WebviewComponent’, :tag => '0.3.7', :git => "https://git.brightcns.cn/iOS/webviewcomponent.git"
```

## Usage

WebviewComponent is using WKWebView  to load a webPage, so deployment system must be greater than iOS 8.0. You also need to set 'View controller-based status bar appearance' key in info.plist to NO, because of the status-bar-style's JSHandler is based on this.

#### Load a webview

want webview to get more support
```objective-c
[LLWebviewLoader loadWebViewByURL:[NSURL URLWithString:@"https://www.baidu.com"] fromSourceViewController:self.navigationController title:@"Baidu" shouleShare:YES];
```
just load, like load a simple privacy web

```objective-c
[LLWebViewSimplifyLoader loadWebViewByURL:[NSURL URLWithString:@"https://www.baidu.com"] webViewTitle:@"Baidu" fromSourceViewController:self.navigationController];
```
load a local HTML file

```objective-c
[LLWebviewLoader loadWebViewByLocalFile:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"] fromSourceViewController:self.navigationController title:@"Example" shouleShare:YES];
```
------
```objective-c
[LLWebViewSimplifyLoader loadWebViewByFile:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"] webViewTitle:@"hello" fromSourceViewController:self.navigationController]
```

#### Add your JS Handler

register by a plist file, you can loop up the example js handler file in the demo project

```objective-c
[LLWebJSBridgeManage registerJSBridgeHandlerWithHandlerFile:[[NSBundle mainBundle] pathForResource:@"mainJSHandler" ofType:@"plist"]];
```
you can also register a special handler
```objective-c
[LLWebJSBridgeManage registerJSBridgeHandler:@"myHandler" callback:^(id data, void (^responseCallback)(id response)) {///statement }];
```
you can also response an exist js handler, the old response block will be abandoned
```objective-c
[LLWebJSBridgeManage responseForJSBridgeHandler:@"previousHandler" callback:^(id data, void (^responseCallback)(id response)) {//statement }];
```

## Author

howoften, forliujiang@126.com

## License

WebviewComponent is available under the MIT license. See the LICENSE file for more info.
