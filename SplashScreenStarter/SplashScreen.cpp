#include "StdAfx.h"
#include "resource.h"
#include "shlwapi.h"
#include <gdiplus.h>
#pragma comment (lib,"Gdiplus.lib")
#include "SplashScreen.h"

/*
CSplashScreen::CSplashScreen(HINSTANCE hInstance, DWORD nFadeoutTime, CImageLoader *pImgLoader, LPCTSTR lpszImagePath, LPCTSTR lpszPrefix, LPCTSTR lpszAppFileName)
{
	m_strSplashClass =  _T("SplashWindow") ;
	m_strSplashClass += lpszPrefix;
	m_hInstance = hInstance;
	m_nFadeoutTime = nFadeoutTime;
	m_strImagePath = lpszImagePath;
	m_strPrefix = lpszPrefix;
	m_strAppFileName = lpszAppFileName;
	m_pImgLoader = pImgLoader;

	memset(&m_blend, 0, sizeof(m_blend));
	m_nFadeoutEnd=0;
}
*/

CSplashScreen::CSplashScreen(HINSTANCE hInstance, DWORD nFadeoutTime, LPCTSTR lpszImagePath, LPCTSTR lpszPrefix, LPCTSTR lpszAppFileName)
{
	m_strSplashClass = L"SplashWindow";
	m_strSplashClass += lpszPrefix;
	m_hInstance = hInstance;
	m_nFadeoutTime = nFadeoutTime;
	m_strImagePath = lpszImagePath;
	m_strPrefix = lpszPrefix;
	m_strAppFileName = lpszAppFileName;
	//m_boolFileExists = FileExists(lpszAppFileName);
	m_boolFileExists = true;

	memset(&m_blend, 0, sizeof(m_blend));
	m_nFadeoutEnd = 0;
}

CSplashScreen::~CSplashScreen(void)
{
}

void CSplashScreen::SetFullPath(LPCTSTR lpszPath)
{
	m_strFullPath = lpszPath;
}

// Returns true if the file exists. False otherwise
// https://stackoverflow.com/questions/3828835/how-can-we-check-if-a-file-exists-or-not-using-win32-program
bool CSplashScreen::FileExists(LPCTSTR lpszAppFileName)
{
	/*
	DWORD dwAttrib = GetFileAttributes(lpszAppFileName);

	return (dwAttrib != INVALID_FILE_ATTRIBUTES &&
		!(dwAttrib & FILE_ATTRIBUTE_DIRECTORY));
	*/
	return true;
}

// Calls UpdateLayeredWindow to set a bitmap (with alpha) as the content of the splash window.
void CSplashScreen::SetSplashImage(HWND hwndSplash, HBITMAP hbmpSplash)
{
	// get the size of the bitmap
	BITMAP bm;
	POINT ptZero = { 0 };

	GetObject(hbmpSplash, sizeof(bm), &bm);

	SIZE sizeSplash = { bm.bmWidth, bm.bmHeight };

	// get the primary monitor's info
	HMONITOR hmonPrimary = MonitorFromPoint(ptZero, MONITOR_DEFAULTTOPRIMARY);
	MONITORINFO monitorinfo = { 0 };
	monitorinfo.cbSize = sizeof(monitorinfo);
	GetMonitorInfo(hmonPrimary, &monitorinfo);

	// center the splash screen in the middle of the primary work area
	const RECT & rcWork = monitorinfo.rcWork;
	POINT ptOrigin;

	ptOrigin.x = rcWork.left + (rcWork.right - rcWork.left - sizeSplash.cx) / 2;
	ptOrigin.y = rcWork.top + (rcWork.bottom - rcWork.top - sizeSplash.cy) / 2;

	// create a memory DC holding the splash bitmap
	HDC hdcScreen = GetDC(NULL);
	HDC hdcMem = CreateCompatibleDC(hdcScreen);
	HBITMAP hbmpOld = (HBITMAP) SelectObject(hdcMem, hbmpSplash);

	// use the source image's alpha channel for blending
	m_blend.BlendOp = AC_SRC_OVER;
	m_blend.SourceConstantAlpha = 0xff;
	m_blend.AlphaFormat = AC_SRC_ALPHA;

	// paint the window (in the right location) with the alpha-blended bitmap
	UpdateLayeredWindow(hwndSplash, hdcScreen, &ptOrigin, &sizeSplash, hdcMem, &ptZero, RGB(0, 0, 0), &m_blend, ULW_ALPHA);

	// delete temporary objects
	SelectObject(hdcMem, hbmpOld);
	DeleteDC(hdcMem);
	ReleaseDC(NULL, hdcScreen);

	::SetWindowPos(hwndSplash ,       // handle to window
				HWND_TOPMOST,  // placement-order handle
				ptOrigin.x,     // horizontal position
				ptOrigin.y,      // vertical position
				sizeSplash.cx,  // width
				sizeSplash.cy, // height
				SWP_SHOWWINDOW); // window-positioning options);
}


HBITMAP CSplashScreen::CreateBitmapImage()
{
	Gdiplus::GdiplusStartupInput gdiplusStartupInput;
		gdiplusStartupInput.GdiplusVersion = 1;
		gdiplusStartupInput.SuppressBackgroundThread = FALSE;
	ULONG_PTR gdiplusToken;
	Gdiplus::Bitmap* pBitmap;
	HBITMAP hImage = NULL;

	Gdiplus::GdiplusStartup(&gdiplusToken, &gdiplusStartupInput, NULL);
	
	if (gdiplusToken != 0)
	{
		// First convert it to std::wstring:
		// std::wstring widestr = std::wstring(str.begin(), str.end());
		// Then get the C string :
		// const wchar_t* widecstr = widestr.c_str();

		pBitmap = Gdiplus::Bitmap::FromFile(m_strImagePath.c_str(), false);
		
		if (pBitmap)
		{
			pBitmap->GetHBITMAP(Gdiplus::Color::Color(m_SplashBackgroundColor), &hImage);
			Gdiplus::GdiplusBase::operator delete (pBitmap);
		}
		
		// If we didn't get any HBITMAP, then create a default one
		// https://stackoverflow.com/questions/48193891/initialize-gdiplus-bitmap-with-color?rq=1
		if (!hImage)
		{
			pBitmap = new Gdiplus::Bitmap(m_nSplashWidth, m_nSplashHeight, PixelFormat32bppARGB);
			Gdiplus::Graphics* mem = Gdiplus::Graphics::FromImage(pBitmap);
			//Gdiplus::SolidBrush* brush = new Gdiplus::SolidBrush(Gdiplus::Color::Black);
			Gdiplus::SolidBrush* brush = new Gdiplus::SolidBrush(Gdiplus::Color::Color(m_SplashColor));
			mem->FillRectangle(brush, 0, 0, m_nSplashWidth, m_nSplashHeight);

			//pBitmap->GetHBITMAP(Gdiplus::Color::Color(255, 255, 255), &hImage);
			pBitmap->GetHBITMAP(Gdiplus::Color::Color(m_SplashBackgroundColor), &hImage);

			Gdiplus::GdiplusBase::operator delete(brush);
			Gdiplus::GdiplusBase::operator delete(mem);
			Gdiplus::GdiplusBase::operator delete (pBitmap);
		}
	}

	Gdiplus::GdiplusShutdown(gdiplusToken);
	
	return hImage;
	// https://www.dreamincode.net/forums/topic/401951-gaussian-blur-in-c/page__st__30
	// https://stackoverflow.com/questions/36689559/visual-c-gdi-questions-gdiplusstartup-always-returns-2invalid-paramters
	// https://docs.microsoft.com/en-us/windows/win32/api/gdiplusinit/nf-gdiplusinit-gdiplusstartup
	// https://social.msdn.microsoft.com/Forums/vstudio/en-US/f53660f5-4e6b-4bff-9849-61170c789caa/gdiplus-problem?forum=vcgeneral
}

// Creates the splash owner window and the splash window.
HWND CSplashScreen::CreateSplashWindow()
{
	// https://stackoverflow.com/questions/42351633/show-taskbar-button-when-using-ws-ex-toolwindow
	//HWND hwndOwner = CreateWindow(m_strSplashClass.c_str(), NULL, WS_POPUP,0, 0, 0, 0, NULL, NULL, m_hInstance, NULL);
	//return CreateWindowEx(WS_EX_LAYERED, m_strSplashClass.c_str(), NULL, WS_POPUP | WS_VISIBLE, 0, 0, 0, 0, hwndOwner, NULL, m_hInstance, NULL);
	return CreateWindowEx(WS_EX_LAYERED | WS_EX_TOOLWINDOW | WS_EX_TOPMOST, m_strSplashClass.c_str(), NULL, WS_POPUP | WS_VISIBLE, 0, 0, 0, 0, NULL, NULL, m_hInstance, NULL);
}

// Registers a window class for the splash and splash owner windows.
void CSplashScreen::RegisterWindowClass()
{
	WNDCLASS wc = { 0 };
	wc.lpfnWndProc = DefWindowProc;
	wc.hInstance = m_hInstance;
	wc.hIcon = LoadIcon(m_hInstance, MAKEINTRESOURCE(IDI_SPLASHICON));
	wc.hCursor = LoadCursor(NULL, IDC_ARROW); 
	wc.lpszClassName = m_strSplashClass.c_str();

	RegisterClass(&wc);
}
// Registers a window class for the splash and splash owner windows.
void CSplashScreen::UnregisterWindowClass() {
	UnregisterClass(m_strSplashClass.c_str(), m_hInstance);
}

HANDLE CSplashScreen::LaunchApplication()
{
	// get folder of the current process
	TCHAR szCurrentFolder[MAX_PATH] = { 0 };

	GetModuleFileName(NULL, szCurrentFolder, MAX_PATH);

	PathRemoveFileSpec(szCurrentFolder);

	// add the application name to the path
	TCHAR szApplicationPath[MAX_PATH];
	if (m_strFullPath.length()>0) {
		lstrcpy(szApplicationPath, m_strFullPath.c_str());
	}
	else {
		PathCombine(szApplicationPath, szCurrentFolder, m_strAppFileName.c_str());
	}

	// start the application
	STARTUPINFO si = { 0 };
	ZeroMemory(&si, sizeof(si));
	si.cb = sizeof(si);
	PROCESS_INFORMATION pi = { 0 };
	ZeroMemory(&pi, sizeof(pi));

	CreateProcess(szApplicationPath, GetCommandLine(), NULL, NULL, FALSE, CREATE_UNICODE_ENVIRONMENT, NULL, szCurrentFolder, &si, &pi);
	//CreateProcess(szApplicationPath, GetCommandLine(), NULL, NULL, FALSE, 0, NULL, NULL, &si, &pi);

	// Normally we should close both process and thread handles in order to avoid memory leaks: CloseHandle(pi.hProcess) CloseHandle(pi.hThread)
	// but here the variable pi goes out of scope
	//CloseHandle(pi.hProcess);
	CloseHandle(pi.hThread);

	return pi.hProcess; 
}

bool CSplashScreen::FadeWindowOut(HWND hWnd, HDC hdcScreen) {
	
	DWORD dtNow = ::GetTickCount();
	if (dtNow >= m_nFadeoutEnd) 
	{
		return true;
	} 
	else
	{ 
		double fade = ((double)m_nFadeoutEnd - (double)dtNow) / (double)m_nFadeoutTime;
		m_blend.SourceConstantAlpha = (byte)(255 * fade);
		
		UpdateLayeredWindow(hWnd, hdcScreen, NULL, NULL, NULL, NULL, RGB(0, 0, 0), &m_blend, ULW_ALPHA);
		return false;
	} 

}

inline DWORD CSplashScreen::PumpMsgWaitForMultipleObjects(HWND hWnd, DWORD nCount, LPHANDLE pHandles, DWORD dwMilliseconds)
{
	// useful variables
	const DWORD dwStartTickCount = ::GetTickCount();

	// loop until done
	for (;;)
	{
		// calculate timeout
		const DWORD dwElapsed = GetTickCount() - dwStartTickCount;
		const DWORD dwTimeout = dwMilliseconds == INFINITE ? INFINITE :dwElapsed < dwMilliseconds ? dwMilliseconds - dwElapsed : 0;

		// wait for a handle to be signaled or a message
		const DWORD dwWaitResult = MsgWaitForMultipleObjects(nCount, pHandles, FALSE, dwTimeout, QS_ALLINPUT);

		if (dwWaitResult == WAIT_OBJECT_0 + nCount)
		{
			// pump messages
			MSG msg;

			while (PeekMessage(&msg, NULL, 0, 0, PM_REMOVE) != FALSE)
			{
				// check for WM_QUIT
				if (msg.message == WM_QUIT)
				{
					// repost quit message and return
					PostQuitMessage((int) msg.wParam);
					return WAIT_OBJECT_0 + nCount;
				}

				// dispatch thread message
				TranslateMessage(&msg);
				DispatchMessage(&msg);
			}
		}
		else
		{
			HDC hdcScreen = GetDC(NULL);
			// check fade event (pHandles[1]).  If the fade event is not set then we simply need to exit.  
			// if the fade event is set then we need to fade out  
			const DWORD dwWaitResult = MsgWaitForMultipleObjects(1, &pHandles[1], FALSE, 0, QS_ALLINPUT);
			if (dwWaitResult == WAIT_OBJECT_0) {
				MSG msg;
				// timeout on actual wait or any other object
				SetTimer(hWnd, 1, 30, NULL);
				m_nFadeoutEnd = GetTickCount() + m_nFadeoutTime;
				BOOL bRet;

				while( (bRet = GetMessage( &msg, hWnd, 0, 0 )) != 0)
				{ 
					if (bRet == -1)
					{
						// handle the error and possibly exit
					}
					else
					{
						if (msg.message == WM_TIMER) {
							if (FadeWindowOut(hWnd, hdcScreen)) { // finished
								ReleaseDC(NULL, hdcScreen);
								return dwWaitResult;
							}
						}
						TranslateMessage(&msg);
						DispatchMessage(&msg);
					}
				}
			}
			ReleaseDC(NULL, hdcScreen);
			return dwWaitResult;
		}
	}
}

void CSplashScreen::Show() {
	
	// If the App file does not exist, then exit
	if (!m_boolFileExists) return;

	// Open the COM library
	CoInitializeEx(0, COINIT::COINIT_APARTMENTTHREADED);

	// create the named close splash screen event, making sure we're the first process to create it
	SetLastError(ERROR_SUCCESS);

	std::basic_string <WCHAR> strEvent1 = L"CloseSplashScreenEvent" + m_strPrefix;
	HANDLE hCloseSplashEvent = CreateEvent(NULL, TRUE, FALSE, strEvent1.c_str());
	
	if (GetLastError() == ERROR_ALREADY_EXISTS) {
		ExitProcess(0);
	}

	// std::basic_string <TCHAR> strEvent2 = _T("CloseSplashScreenWithoutFadeEvent") + m_strPrefix;
	std::basic_string <WCHAR> strEvent2 = L"CloseSplashScreenWithoutFadeEvent" + m_strPrefix;
	HANDLE hCloseSplashWithoutFadeEvent = CreateEvent(NULL, TRUE, FALSE, strEvent2.c_str());
	if (GetLastError() == ERROR_ALREADY_EXISTS) {
		ExitProcess(0);
	}

	// Create and display the splash window
	HBITMAP hb;
	//hb = m_pImgLoader->LoadSplashImage();
	hb = CreateBitmapImage();
	HWND wnd= NULL;
	RegisterWindowClass();

	if (hb != NULL) {
		wnd = CreateSplashWindow();
		SetSplashImage(wnd, hb);
	}

	// Launch the application
	HANDLE hProcess = LaunchApplication();
	AllowSetForegroundWindow(GetProcessId(hProcess));
		
	// Display the splash screen for as long as it's needed
	if (wnd != NULL) {
		HANDLE aHandles[3] = { hProcess, hCloseSplashEvent, hCloseSplashWithoutFadeEvent };
		PumpMsgWaitForMultipleObjects(wnd, 3, &aHandles[0], INFINITE);
	}

	// Deallocate the hbitmap
	DeleteObject(hb);

	CloseHandle(hProcess);

	// Close the events
	CloseHandle(hCloseSplashEvent);
	CloseHandle(hCloseSplashWithoutFadeEvent);
	
	// Destroy the window
	DestroyWindow(wnd);
	UnregisterWindowClass();

	// Close the COM library
	CoUninitialize();

	return;
}
