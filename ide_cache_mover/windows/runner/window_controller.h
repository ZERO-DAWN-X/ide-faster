#ifndef RUNNER_WINDOW_CONTROLLER_H_
#define RUNNER_WINDOW_CONTROLLER_H_

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <flutter/binary_messenger.h>
#include <windows.h>
#include <memory>

// Forward declaration
namespace flutter {
  class FlutterEngine;
}

class WindowController {
 public:
  WindowController(flutter::FlutterEngine* engine, HWND window_handle);
  ~WindowController();

 private:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  flutter::BinaryMessenger* messenger_;
  HWND window_handle_;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel_;
};

#endif  // RUNNER_WINDOW_CONTROLLER_H_

