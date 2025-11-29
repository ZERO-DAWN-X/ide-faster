#ifndef RUNNER_FILE_OPS_HANDLER_H_
#define RUNNER_FILE_OPS_HANDLER_H_

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <flutter/binary_messenger.h>
#include <windows.h>
#include <string>
#include <memory>

// Forward declaration
namespace flutter {
  class FlutterEngine;
}

class FileOpsHandler {
 public:
  FileOpsHandler(flutter::FlutterEngine* engine);
  ~FileOpsHandler();

 private:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  // Check if a path is a junction
  bool IsJunction(const std::string& path);

  // Move folder using robocopy and create junction
  bool MoveIdeFolder(const std::string& sourcePath,
                     const std::string& destinationPath,
                     const std::string& junctionPath,
                     std::string& errorMessage);

  // Helper: Convert std::string to std::wstring
  std::wstring StringToWString(const std::string& str);

  // Helper: Convert std::wstring to std::string
  std::string WStringToString(const std::wstring& wstr);

  // Helper: Execute command and get output
  bool ExecuteCommand(const std::wstring& command, std::string& output);

  flutter::BinaryMessenger* messenger_;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel_;
};

#endif  // RUNNER_FILE_OPS_HANDLER_H_

