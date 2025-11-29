#include "window_controller.h"
#include <flutter/flutter_engine.h>

WindowController::WindowController(flutter::FlutterEngine* engine, HWND window_handle)
    : messenger_(engine->messenger()), window_handle_(window_handle) {
  channel_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      messenger_, "ide_cache_mover/window",
      &flutter::StandardMethodCodec::GetInstance());

  channel_->SetMethodCallHandler(
      [this](const auto& call, auto result) {
        this->HandleMethodCall(call, std::move(result));
      });
}

WindowController::~WindowController() {}

void WindowController::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  const std::string& method_name = method_call.method_name();

  if (method_name == "minimize") {
    ShowWindow(window_handle_, SW_MINIMIZE);
    result->Success(flutter::EncodableValue(true));
  } else if (method_name == "maximize") {
    WINDOWPLACEMENT wp;
    wp.length = sizeof(WINDOWPLACEMENT);
    GetWindowPlacement(window_handle_, &wp);
    if (wp.showCmd == SW_SHOWMAXIMIZED) {
      ShowWindow(window_handle_, SW_RESTORE);
    } else {
      ShowWindow(window_handle_, SW_MAXIMIZE);
    }
    result->Success(flutter::EncodableValue(true));
  } else if (method_name == "close") {
    PostMessage(window_handle_, WM_CLOSE, 0, 0);
    result->Success(flutter::EncodableValue(true));
  } else {
    result->NotImplemented();
  }
}

