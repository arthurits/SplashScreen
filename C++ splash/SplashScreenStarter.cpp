// SplashScreenStarter.cpp : Defines the entry point for the application.
// http://www.catch22.net/tuts/win32/reducing-executable-size#
//

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

int APIENTRY _tWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPTSTR lpCmdLine, int nCmdShow)
{
	// Local variables to store the settings
	std::basic_string <WCHAR> strImagePath;
	std::basic_string <WCHAR> strExecutable = L"";
	//const wchar_t* lpszExecutable;
	std::basic_string <WCHAR> strFadeoutTime = L"0";
	std::basic_string <WCHAR> strSuffix = L"";
	//std::wifstream fin(L"C:\\Users\\Arthurit\\Documents\\Visual Studio 2019\\Projects\\SplashScreen\\SplashScreenStarter\\x64\\Debug\\settings.txt");
	std::wifstream fin(L"settings.txt");	// https://stackoverflow.com/questions/19697296/what-is-stdwifstreamgetline-doing-to-my-wchar-t-array-its-treated-like-a-b
	int nFadeoutTime = 0;

	// If the file couldn't be opened
	if (!fin)
	{
		fin.close();
		MessageBox(NULL, L"An unexpected error ocurred while reading 'settings.txt'.\nPlease make sure the file and format are correct.", L"Error opening/reading file", MB_ICONERROR);
		return 0;
	}

	// Read the settings from the file
	if (!fin.eof()) std::getline(fin, strImagePath);
	if (!fin.eof()) std::getline(fin, strExecutable);
	//lpszExecutable = strExecutable.c_str();
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
		std::basic_string <WCHAR> message = L"Could not find the file in the following path:\n";
		message += strExecutable;
		MessageBox(NULL, message.c_str(), L"File does not exist", MB_ICONERROR);
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


// in WPF code
//private void CloseSplashScreen()
//{
//    // signal the native process (that launched us) to close the splash screen
//    using (var closeSplashEvent = new EventWaitHandle(false,
//        EventResetMode.ManualReset, "CloseSplashScreenEvent"+Prefix))
//    {
//        closeSplashEvent.Set();
//    }
//}


