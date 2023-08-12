## 0.0.3

New methods:
* setAsLauncher
* startApp
* handleBootCompleted
* isScreenAwake

Methods to manage storing simple data in the device preferences:
```dart
Future<String?> get(String contentKey, {String? defaultContent});
Future<void> put(String contentKey, {String? content});
Future<void> remove(String contentKey);
Future<void> clear();
```

## 0.0.2

Add methods:
* clearDeviceOwnerApp({String? packageName})
* setCameraDisabled({required bool disabled})
* setKeyguardDisabled({required bool disabled})
* setScreenCaptureDisabled({required bool disabled})


## 0.0.1

* Initial version.
