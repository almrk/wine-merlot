#include <windows.h>
#include <shellapi.h>

#define WM_TRAYICON (WM_USER + 1)

static NOTIFYICONDATAW nid;

static LRESULT CALLBACK wndproc( HWND hwnd, UINT msg, WPARAM wparam, LPARAM lparam )
{
    if (msg == WM_DESTROY)
    {
        Shell_NotifyIconW( NIM_DELETE, &nid );
        PostQuitMessage( 0 );
    }
    return DefWindowProcW( hwnd, msg, wparam, lparam );
}

int WINAPI WinMain( HINSTANCE hinstance, HINSTANCE prev, LPSTR cmdline, int show )
{
    WNDCLASSW wc = { 0 };
    HWND hwnd;
    MSG msg;

    wc.lpfnWndProc   = wndproc;
    wc.hInstance     = hinstance;
    wc.lpszClassName = L"TrayTest";
    RegisterClassW( &wc );

    hwnd = CreateWindowW( L"TrayTest", L"TrayTest", 0,
                          CW_USEDEFAULT, CW_USEDEFAULT, 0, 0,
                          HWND_MESSAGE, NULL, hinstance, NULL );

    nid.cbSize           = sizeof(nid);
    nid.hWnd             = hwnd;
    nid.uID              = 1;
    nid.uFlags           = NIF_ICON | NIF_TIP | NIF_MESSAGE;
    nid.uCallbackMessage = WM_TRAYICON;
    nid.hIcon            = LoadIconW( NULL, (LPCWSTR)IDI_WARNING );
    lstrcpyW( nid.szTip, L"Tray test icon" );
    Shell_NotifyIconW( NIM_ADD, &nid );

    while (GetMessageW( &msg, NULL, 0, 0 ))
    {
        TranslateMessage( &msg );
        DispatchMessageW( &msg );
    }
    return 0;
}
