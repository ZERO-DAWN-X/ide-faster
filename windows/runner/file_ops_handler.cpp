#include "file_ops_handler.h"
#include <flutter/flutter_engine.h>
#include <shlwapi.h>
#include <io.h>
#include <fcntl.h>
#include <iostream>
#include <sstream>

#pragma comment(lib, "shlwapi.lib")

FileOpsHandler::FileOpsHandler(flutter::FlutterEngine* engine) 
    : messenger_(engine->messenger()) {
  channel_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      messenger_, "ide_cache_mover/file_ops",
      &flutter::StandardMethodCodec::GetInstance());

  channel_->SetMethodCallHandler(
      [this](const auto& call, auto result) {
        this->HandleMethodCall(call, std::move(result));
      });
}

FileOpsHandler::~FileOpsHandler() {}

void FileOpsHandler::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  const std::string& method_name = method_call.method_name();

  if (method_name == "isJunction") {
    const auto* args = std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (!args) {
      result->Error("InvalidArguments", "Arguments must be a map");
      return;
    }

    auto path_it = args->find(flutter::EncodableValue("path"));
    if (path_it == args->end()) {
      result->Error("InvalidArguments", "Missing 'path' argument");
      return;
    }

    const std::string* path = std::get_if<std::string>(&path_it->second);
    if (!path) {
      result->Error("InvalidArguments", "Path must be a string");
      return;
    }

    bool isJunction = IsJunction(*path);
    result->Success(flutter::EncodableValue(isJunction));
  } else if (method_name == "moveIdeFolder") {
    const auto* args = std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (!args) {
      result->Error("InvalidArguments", "Arguments must be a map");
      return;
    }

    auto source_it = args->find(flutter::EncodableValue("sourcePath"));
    auto dest_it = args->find(flutter::EncodableValue("destinationPath"));
    auto junction_it = args->find(flutter::EncodableValue("junctionPath"));

    if (source_it == args->end() || dest_it == args->end() ||
        junction_it == args->end()) {
      result->Error("InvalidArguments", "Missing required arguments");
      return;
    }

    const std::string* sourcePath = std::get_if<std::string>(&source_it->second);
    const std::string* destPath = std::get_if<std::string>(&dest_it->second);
    const std::string* junctionPath = std::get_if<std::string>(&junction_it->second);

    if (!sourcePath || !destPath || !junctionPath) {
      result->Error("InvalidArguments", "All paths must be strings");
      return;
    }

    std::string errorMessage;
    bool success = MoveIdeFolder(*sourcePath, *destPath, *junctionPath, errorMessage);

    flutter::EncodableMap response;
    response[flutter::EncodableValue("success")] = flutter::EncodableValue(success);
    response[flutter::EncodableValue("message")] = flutter::EncodableValue(errorMessage);
    result->Success(flutter::EncodableValue(response));
  } else if (method_name == "revertIdeFolder") {
    const auto* args = std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (!args) {
      result->Error("InvalidArguments", "Arguments must be a map");
      return;
    }

    auto junction_it = args->find(flutter::EncodableValue("junctionPath"));
    auto source_it = args->find(flutter::EncodableValue("sourcePath"));
    auto dest_it = args->find(flutter::EncodableValue("destinationPath"));

    if (junction_it == args->end() || source_it == args->end() ||
        dest_it == args->end()) {
      result->Error("InvalidArguments", "Missing required arguments");
      return;
    }

    const std::string* junctionPath = std::get_if<std::string>(&junction_it->second);
    const std::string* sourcePath = std::get_if<std::string>(&source_it->second);
    const std::string* destPath = std::get_if<std::string>(&dest_it->second);

    if (!junctionPath || !sourcePath || !destPath) {
      result->Error("InvalidArguments", "All paths must be strings");
      return;
    }

    std::string errorMessage;
    bool success = RevertIdeFolder(*junctionPath, *sourcePath, *destPath, errorMessage);

    flutter::EncodableMap response;
    response[flutter::EncodableValue("success")] = flutter::EncodableValue(success);
    response[flutter::EncodableValue("message")] = flutter::EncodableValue(errorMessage);
    result->Success(flutter::EncodableValue(response));
  } else {
    result->NotImplemented();
  }
}

bool FileOpsHandler::IsJunction(const std::string& path) {
  std::wstring wpath = StringToWString(path);
  
  DWORD attributes = GetFileAttributesW(wpath.c_str());
  if (attributes == INVALID_FILE_ATTRIBUTES) {
    return false;
  }

  // Check if it's a directory and has reparse point attribute
  if ((attributes & FILE_ATTRIBUTE_DIRECTORY) &&
      (attributes & FILE_ATTRIBUTE_REPARSE_POINT)) {
    // Additional check: try to read reparse point
    HANDLE hFile = CreateFileW(
        wpath.c_str(),
        GENERIC_READ,
        FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE,
        NULL,
        OPEN_EXISTING,
        FILE_FLAG_BACKUP_SEMANTICS | FILE_FLAG_OPEN_REPARSE_POINT,
        NULL);

    if (hFile != INVALID_HANDLE_VALUE) {
      CloseHandle(hFile);
      return true;
    }
  }

  return false;
}

bool FileOpsHandler::MoveIdeFolder(const std::string& sourcePath,
                                    const std::string& destinationPath,
                                    const std::string& junctionPath,
                                    std::string& errorMessage) {
  std::wstring wSourcePath = StringToWString(sourcePath);
  std::wstring wDestPath = StringToWString(destinationPath);
  std::wstring wJunctionPath = StringToWString(junctionPath);

  // Check if source exists
  DWORD sourceAttrib = GetFileAttributesW(wSourcePath.c_str());
  if (sourceAttrib == INVALID_FILE_ATTRIBUTES ||
      !(sourceAttrib & FILE_ATTRIBUTE_DIRECTORY)) {
    errorMessage = "Source folder does not exist";
    return false;
  }

  // Check if already a junction
  if (IsJunction(sourcePath)) {
    errorMessage = "Folder is already a junction";
    return false;
  }

  // Create destination directory if it doesn't exist
  std::wstring destParent = wDestPath;
  size_t lastSlash = destParent.find_last_of(L"\\/");
  if (lastSlash != std::wstring::npos) {
    destParent = destParent.substr(0, lastSlash);
    CreateDirectoryW(destParent.c_str(), NULL);
  }

  // Use robocopy to move files
  // robocopy source dest /E /MOVE /NFL /NDL /NJH /NJS
  std::wstring robocopyCmd = L"robocopy \"" + wSourcePath + L"\" \"" +
                             wDestPath + L"\" /E /MOVE /NFL /NDL /NJH /NJS /R:3 /W:1";

  std::string output;
  if (!ExecuteCommand(robocopyCmd, output)) {
    errorMessage = "Robocopy failed: " + output;
    return false;
  }

  // Remove empty source directory
  RemoveDirectoryW(wSourcePath.c_str());

  // Create junction link
  // mklink /J junctionPath destinationPath
  std::wstring mklinkCmd = L"cmd /c mklink /J \"" + wJunctionPath + L"\" \"" +
                          wDestPath + L"\"";

  std::string mklinkOutput;
  if (!ExecuteCommand(mklinkCmd, mklinkOutput)) {
    errorMessage = "Failed to create junction: " + mklinkOutput;
    return false;
  }

  return true;
}

bool FileOpsHandler::RevertIdeFolder(const std::string& junctionPath,
                                      const std::string& sourcePath,
                                      const std::string& destinationPath,
                                      std::string& errorMessage) {
  std::wstring wJunctionPath = StringToWString(junctionPath);
  std::wstring wSourcePath = StringToWString(sourcePath);
  std::wstring wDestPath = StringToWString(destinationPath);

  // Check if junction exists
  if (!IsJunction(junctionPath)) {
    errorMessage = "Folder is not a junction";
    return false;
  }

  // Check if source (D: drive) exists
  DWORD sourceAttrib = GetFileAttributesW(wSourcePath.c_str());
  if (sourceAttrib == INVALID_FILE_ATTRIBUTES ||
      !(sourceAttrib & FILE_ATTRIBUTE_DIRECTORY)) {
    errorMessage = "Source folder does not exist on D: drive";
    return false;
  }

  // Remove the junction
  if (!RemoveDirectoryW(wJunctionPath.c_str())) {
    errorMessage = "Failed to remove junction";
    return false;
  }

  // Use robocopy to move files back
  std::wstring robocopyCmd = L"robocopy \"" + wSourcePath + L"\" \"" +
                             wDestPath + L"\" /E /MOVE /NFL /NDL /NJH /NJS /R:3 /W:1";

  std::string output;
  if (!ExecuteCommand(robocopyCmd, output)) {
    errorMessage = "Robocopy failed: " + output;
    return false;
  }

  // Remove empty source directory from D: drive
  RemoveDirectoryW(wSourcePath.c_str());

  return true;
}

std::wstring FileOpsHandler::StringToWString(const std::string& str) {
  if (str.empty()) return std::wstring();
  int size_needed = MultiByteToWideChar(CP_UTF8, 0, &str[0], (int)str.size(), NULL, 0);
  std::wstring wstrTo(size_needed, 0);
  MultiByteToWideChar(CP_UTF8, 0, &str[0], (int)str.size(), &wstrTo[0], size_needed);
  return wstrTo;
}

std::string FileOpsHandler::WStringToString(const std::wstring& wstr) {
  if (wstr.empty()) return std::string();
  int size_needed = WideCharToMultiByte(CP_UTF8, 0, &wstr[0], (int)wstr.size(), NULL, 0, NULL, NULL);
  std::string strTo(size_needed, 0);
  WideCharToMultiByte(CP_UTF8, 0, &wstr[0], (int)wstr.size(), &strTo[0], size_needed, NULL, NULL);
  return strTo;
}

bool FileOpsHandler::ExecuteCommand(const std::wstring& command, std::string& output) {
  SECURITY_ATTRIBUTES sa;
  sa.nLength = sizeof(SECURITY_ATTRIBUTES);
  sa.bInheritHandle = TRUE;
  sa.lpSecurityDescriptor = NULL;

  HANDLE hChildStd_OUT_Rd = NULL;
  HANDLE hChildStd_OUT_Wr = NULL;

  // Create pipe for stdout
  if (!CreatePipe(&hChildStd_OUT_Rd, &hChildStd_OUT_Wr, &sa, 0)) {
    output = "Failed to create pipe";
    return false;
  }

  // Ensure read handle is not inherited
  SetHandleInformation(hChildStd_OUT_Rd, HANDLE_FLAG_INHERIT, 0);

  PROCESS_INFORMATION piProcInfo;
  STARTUPINFOW siStartInfo;

  ZeroMemory(&piProcInfo, sizeof(PROCESS_INFORMATION));
  ZeroMemory(&siStartInfo, sizeof(STARTUPINFOW));

  siStartInfo.cb = sizeof(STARTUPINFOW);
  siStartInfo.hStdError = hChildStd_OUT_Wr;
  siStartInfo.hStdOutput = hChildStd_OUT_Wr;
  siStartInfo.dwFlags |= STARTF_USESTDHANDLES;

  // Create process
  BOOL bSuccess = CreateProcessW(
      NULL,
      const_cast<LPWSTR>(command.c_str()),
      NULL,
      NULL,
      TRUE,
      CREATE_NO_WINDOW,
      NULL,
      NULL,
      &siStartInfo,
      &piProcInfo);

  if (!bSuccess) {
    CloseHandle(hChildStd_OUT_Wr);
    CloseHandle(hChildStd_OUT_Rd);
    output = "Failed to create process";
    return false;
  }

  // Close write handle
  CloseHandle(hChildStd_OUT_Wr);

  // Read output
  DWORD dwRead;
  CHAR chBuf[4096];
  std::string result;

  while (true) {
    bSuccess = ReadFile(hChildStd_OUT_Rd, chBuf, 4096, &dwRead, NULL);
    if (!bSuccess || dwRead == 0) break;
    result.append(chBuf, dwRead);
  }

  // Wait for process to complete
  WaitForSingleObject(piProcInfo.hProcess, INFINITE);

  DWORD exitCode;
  GetExitCodeProcess(piProcInfo.hProcess, &exitCode);

  CloseHandle(piProcInfo.hProcess);
  CloseHandle(piProcInfo.hThread);
  CloseHandle(hChildStd_OUT_Rd);

  output = result;

  // For robocopy, exit codes 0-7 are success
  // For mklink, exit code 0 is success
  return exitCode == 0 || (exitCode >= 0 && exitCode <= 7);
}

