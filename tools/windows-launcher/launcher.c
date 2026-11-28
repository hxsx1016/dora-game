#define UNICODE
#define _UNICODE
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <wchar.h>
#include <stdbool.h>

#define APP_TITLE_W L"\x5411\x897F\x5B88\x671B"
#define RUNTIME_DIR_W L"runtime"
#define RUNTIME_EXE_W L"WestwardWatchRuntime.exe"
#define CHECK_INIT_W L"Script\\init.lua"
#define CHECK_ART_W L"assets\\art\\title.png"

typedef struct {
    DWORD pid;
    bool found;
    bool visibleRenamed;
} RetitleCtx;

static bool file_exists_w(const wchar_t *path) {
    DWORD attrs = GetFileAttributesW(path);
    return attrs != INVALID_FILE_ATTRIBUTES && (attrs & FILE_ATTRIBUTE_DIRECTORY) == 0;
}

static bool dir_exists_w(const wchar_t *path) {
    DWORD attrs = GetFileAttributesW(path);
    return attrs != INVALID_FILE_ATTRIBUTES && (attrs & FILE_ATTRIBUTE_DIRECTORY) != 0;
}

static BOOL CALLBACK enum_windows_retitle(HWND hwnd, LPARAM lparam) {
    RetitleCtx *ctx = (RetitleCtx *)lparam;
    DWORD pid = 0;
    GetWindowThreadProcessId(hwnd, &pid);
    if (pid != ctx->pid) {
        return TRUE;
    }
    if (GetWindow(hwnd, GW_OWNER) != NULL) {
        return TRUE;
    }
    wchar_t title[256];
    title[0] = L'\0';
    int len = GetWindowTextW(hwnd, title, 256);
    if (len > 0 && (wcsncmp(title, L"Dora", 4) == 0 || wcscmp(title, APP_TITLE_W) == 0)) {
        if (wcscmp(title, APP_TITLE_W) != 0) {
            SetWindowTextW(hwnd, APP_TITLE_W);
        }
        ctx->found = true;
        if (IsWindowVisible(hwnd)) {
            ctx->visibleRenamed = true;
        }
    }
    return TRUE;
}

static const wchar_t *skip_first_arg(const wchar_t *cmdline) {
    if (!cmdline) return L"";
    const wchar_t *p = cmdline;
    while (*p == L' ' || *p == L'\t') p++;
    if (*p == L'"') {
        p++;
        while (*p && *p != L'"') p++;
        if (*p == L'"') p++;
    } else {
        while (*p && *p != L' ' && *p != L'\t') p++;
    }
    while (*p == L' ' || *p == L'\t') p++;
    return p;
}

int WINAPI wWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, PWSTR pCmdLine, int nCmdShow) {
    (void)hInstance;
    (void)hPrevInstance;
    (void)pCmdLine;
    (void)nCmdShow;

    wchar_t selfPath[32768];
    DWORD selfLen = GetModuleFileNameW(NULL, selfPath, 32768);
    if (selfLen == 0 || selfLen >= 32768) {
        MessageBoxW(
            NULL,
            L"\x65E0\x6CD5\x83B7\x53D6\x6E38\x620F\x7A0B\x5E8F\x8DEF\x5F84\x3002",
            APP_TITLE_W,
            MB_OK | MB_ICONERROR
        );
        return 1;
    }

    wchar_t *lastSlash = wcsrchr(selfPath, L'\\');
    if (!lastSlash) {
        lastSlash = wcsrchr(selfPath, L'/');
    }
    if (!lastSlash) {
        return 1;
    }
    *lastSlash = L'\0';

    wchar_t runtimeDir[32768];
    wchar_t runtimeExe[32768];
    wchar_t checkInit[32768];
    wchar_t checkArt[32768];

    _snwprintf(runtimeDir, 32768, L"%s\\%s", selfPath, RUNTIME_DIR_W);
    runtimeDir[32767] = L'\0';
    _snwprintf(runtimeExe, 32768, L"%s\\%s", runtimeDir, RUNTIME_EXE_W);
    runtimeExe[32767] = L'\0';
    _snwprintf(checkInit, 32768, L"%s\\%s", runtimeDir, CHECK_INIT_W);
    checkInit[32767] = L'\0';
    _snwprintf(checkArt, 32768, L"%s\\%s", runtimeDir, CHECK_ART_W);
    checkArt[32767] = L'\0';

    if (!dir_exists_w(runtimeDir) || !file_exists_w(runtimeExe) || !file_exists_w(checkInit) || !file_exists_w(checkArt)) {
        MessageBoxW(
            NULL,
            L"\x672A\x627E\x5230\x5B8C\x6574\x7684\x6E38\x620F\x8FD0\x884C\x6587\x4EF6\xFF08runtime \x76EE\x5F55\x7F3A\x5931\x6216\x4E0D\x5B8C\x6574\xFF09\x3002\n\n"
            L"\x8BF7\x5148\x5C06\x538B\x7F29\x5305\x5B8C\x6574\x89E3\x538B\x5230\x672C\x5730\x6587\x4EF6\x5939\xFF0C\x518D\x53CC\x51FB WestwardWatch.exe \x542F\x52A8\x6E38\x620F\x3002",
            APP_TITLE_W,
            MB_OK | MB_ICONWARNING
        );
        return 2;
    }

    SetEnvironmentVariableW(L"WESTWARD_WATCH_ROOT", selfPath);

    const wchar_t *extraArgs = skip_first_arg(GetCommandLineW());
    size_t cmdCap = wcslen(runtimeExe) + wcslen(extraArgs) + 8;
    wchar_t *childCmd = (wchar_t *)HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, cmdCap * sizeof(wchar_t));
    if (!childCmd) {
        return 1;
    }
    if (extraArgs[0] != L'\0') {
        _snwprintf(childCmd, cmdCap, L"\"%s\" %s", runtimeExe, extraArgs);
    } else {
        _snwprintf(childCmd, cmdCap, L"\"%s\"", runtimeExe);
    }
    childCmd[cmdCap - 1] = L'\0';

    STARTUPINFOW si;
    PROCESS_INFORMATION pi;
    ZeroMemory(&si, sizeof(si));
    ZeroMemory(&pi, sizeof(pi));
    si.cb = sizeof(si);

    BOOL ok = CreateProcessW(
        runtimeExe,
        childCmd,
        NULL,
        NULL,
        FALSE,
        0,
        NULL,
        runtimeDir,
        &si,
        &pi
    );
    HeapFree(GetProcessHeap(), 0, childCmd);

    if (!ok) {
        DWORD err = GetLastError();
        wchar_t msg[512];
        _snwprintf(
            msg,
            512,
            L"\x542F\x52A8\x6E38\x620F\x8FD0\x884C\x65F6\x5931\x8D25\xFF08\x9519\x8BEF\x7801 %lu\xFF09\x3002\n\n"
            L"\x8BF7\x786E\x8BA4\x6740\x6BD2\x8F6F\x4EF6\x672A\x62E6\x622A runtime\\WestwardWatchRuntime.exe\xFF0C\x6216\x5C1D\x8BD5\x4F7F\x7528 OpenGL \x517C\x5BB9\x7248\x3002",
            (unsigned long)err
        );
        msg[511] = L'\0';
        MessageBoxW(NULL, msg, APP_TITLE_W, MB_OK | MB_ICONERROR);
        return 3;
    }

    // Poll briefly until the child window becomes visible and update its title from "Dora SSR" to "向西守望".
    RetitleCtx ctx;
    ctx.pid = pi.dwProcessId;
    ctx.found = false;
    ctx.visibleRenamed = false;

    for (int step = 0; step < 180; ++step) {
        DWORD waitRes = WaitForSingleObject(pi.hProcess, 80);
        if (waitRes == WAIT_OBJECT_0) {
            break;
        }
        EnumWindows(enum_windows_retitle, (LPARAM)&ctx);
        if (ctx.visibleRenamed) {
            // Confirm once more after a short delay in case SDL re-applies window title on show.
            if (WaitForSingleObject(pi.hProcess, 350) == WAIT_OBJECT_0) {
                break;
            }
            EnumWindows(enum_windows_retitle, (LPARAM)&ctx);
            break;
        }
    }

    WaitForSingleObject(pi.hProcess, INFINITE);
    DWORD exitCode = 0;
    GetExitCodeProcess(pi.hProcess, &exitCode);

    CloseHandle(pi.hThread);
    CloseHandle(pi.hProcess);
    return (int)exitCode;
}
