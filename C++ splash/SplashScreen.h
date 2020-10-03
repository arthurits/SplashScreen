#pragma once
//#include "imageloader.h"
#include <iostream>
#include <string>

#ifndef SPLASHSCREEN_H
#define SPLASHSCREEN_H

class CSplashScreen
{
	private:
		HINSTANCE m_hInstance;
		BLENDFUNCTION m_blend;
		DWORD m_nFadeoutEnd;
		DWORD m_nFadeoutTime;
		std::basic_string <WCHAR> m_strSplashClass;	// Window Class name
		std::basic_string <WCHAR> m_strFullPath;	//
		std::basic_string <WCHAR> m_strPrefix;		// Prefix
		std::basic_string <WCHAR> m_strAppFileName;	// Path of the executable to launch
		std::basic_string <WCHAR> m_strImagePath;	// Path of the image used as splash
		bool m_boolFileExists;
		//CImageLoader *m_pImgLoader;
	private:
		const int m_nSplashWidth = 800;
		const int m_nSplashHeight = 500;
		const DWORD m_SplashBackgroundColor = 0xFF000000;
		const DWORD m_SplashColor = 0xFF000000;
		void SetSplashImage(HWND hwndSplash, HBITMAP hbmpSplash);
		void RegisterWindowClass();
		void UnregisterWindowClass();
		HBITMAP CreateBitmapImage();
		HWND CreateSplashWindow();
		HANDLE LaunchApplication();
		bool FadeWindowOut(HWND hwnd, HDC hdcScreen);
		bool FileExists(LPCTSTR szPath);
		inline DWORD PumpMsgWaitForMultipleObjects(HWND hWnd, DWORD nCount, LPHANDLE pHandles, DWORD dwMilliseconds);
	public:
		//CSplashScreen(HINSTANCE hInstance, DWORD nFadeoutTime, CImageLoader *pImgLoader, LPCTSTR lpszImagePath, LPCTSTR lpszPrefix, LPCTSTR lpszAppFileName);
		CSplashScreen(HINSTANCE hInstance, DWORD nFadeoutTime, LPCTSTR lpszImagePath, LPCTSTR lpszPrefix, LPCTSTR lpszAppFileName);
		~CSplashScreen(void);

		void SetFullPath(LPCTSTR lpszPath);
		void Show();
};

#endif // !SPLASHSCREEN_H