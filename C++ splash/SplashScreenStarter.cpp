// SplashScreenStarter.cpp : Defines the entry point for the application.
// http://www.catch22.net/tuts/win32/reducing-executable-size#
// https://stackoverflow.com/questions/37398/how-do-i-make-a-fully-statically-linked-exe-with-visual-studio-express-2005

#include "stdafx.h"
#include "SplashScreenStarter.h"

#include "SplashScreen.h"
//#include "Objidl.h"
//#include <iostream>
#include <fstream>
//#include <string>
//#include "FileImageLoader.h"
//#include "ResourceImageLoader.h"
#include "shlwapi.h"

// For memory leak report https://docs.microsoft.com/es-es/visualstudio/debugger/finding-memory-leaks-using-the-crt-library?view=vs-2019
#define _CRTDBG_MAP_ALLOC
#include <stdlib.h>
#include <crtdbg.h>

int APIENTRY _tWinMain(_In_ HINSTANCE hInstance, _In_opt_ HINSTANCE hPrevInstance, _In_ LPTSTR lpCmdLine, _In_ int nCmdShow)
{
	// Local variables to store the settings
	std::basic_string <TCHAR> strImagePath;
	std::basic_string <TCHAR> strExecutable = _T("");
	std::basic_string <TCHAR> strFadeoutTime = _T("0");
	std::basic_string <TCHAR> strSuffix = _T("");
	std::basic_ifstream <TCHAR> fin(_T("settings.splash"));	// https://stackoverflow.com/questions/19697296/what-is-stdwifstreamgetline-doing-to-my-wchar-t-array-its-treated-like-a-b
	//std::basic_ifstream <TCHAR> fin(_T("C:\\Users\\Arthurit\\Documents\\Visual Studio 2017\\Projects\\SplashScreen\\C++ splash\\x64\\Debug\\settings.txt"));
	//std::wifstream fin(L"C:\\Users\\Arthurit\\Documents\\Visual Studio 2017\\Projects\\SplashScreen\\C++ splash\\x64\\Debug\\settings.txt");
	//std::basic_ifstream <TCHAR> fin(_T("C:\\Users\\alfredoa\\source\\repos\\SplashScreen\\C++ splash\\x64\\Debug\\settings.txt"));
	ULONGLONG nFadeoutTime = 0;
	 
	// If the file couldn't be opened
	if (!fin)
	{
		fin.close();
		::MessageBox(NULL,
			_T("An unexpected error ocurred while reading 'settings.splash'.\nPlease make sure the file and format are correct."),
			_T("Error opening/reading file"),
			MB_ICONERROR);
		return 0;
	}

	// Read the settings from the file
	if (!fin.eof()) std::getline(fin, strImagePath);
	if (!fin.eof()) std::getline(fin, strExecutable);
	if (!fin.eof()) std::getline(fin, strFadeoutTime);
	// https://stackoverflow.com/questions/32006796/how-to-convert-wchar-t-to-long-c
	//nFadeoutTime = std::stoi(strFadeoutTime);
	nFadeoutTime = StrToInt(strFadeoutTime.c_str());
	if (!fin.eof()) std::getline(fin, strSuffix);

	fin.close();

	// Check whether the App to be executed does not exist
	DWORD dwAttrib = GetFileAttributes(strExecutable.c_str());
	if (!(dwAttrib != INVALID_FILE_ATTRIBUTES && !(dwAttrib & FILE_ATTRIBUTE_DIRECTORY)))
	{
		std::basic_string <TCHAR> message = _T("Could not find the file in the following path:\n");
		message += strExecutable;
		MessageBox(NULL, message.c_str(), _T("File does not exist"), MB_ICONERROR);
		return 0;
	}

	// Set the splash screen instance and set up the values read from the settings file
	CSplashScreen splash(hInstance, nFadeoutTime, strImagePath.c_str(), strSuffix.c_str(), strExecutable.c_str());
	splash.Show();
	
	#ifdef _DEBUG
		_CrtDumpMemoryLeaks();
	#endif
	
	// Exit
	return 0;
}