
    option casemap:none
    option frame:auto
    option win64:3

	include gdi32.inc
	include user32.inc
	include kernel32.inc
	include comctl32.inc
	include comdlg32.inc
	include shell32.inc
	include oleaut32.inc
	include ole32.inc
	include msvcrt.inc
	include advapi32.inc
	include imagehlp.inc
	include winmm.inc
	include setupapi.inc
	include iphlpapi.inc
	include ntdll.inc
	include crypt32.inc
	include wintrust.inc
	include psapi.inc
	
	include windows64.inc
	include macros64.asm
	
	includelib gdi32.lib
	includelib user32.lib
	includelib kernel32.lib
	includelib comctl32.lib
	includelib comdlg32.lib
	includelib shell32.lib
	includelib oleaut32.lib
	includelib ole32.lib
	includelib msvcrt.lib
	includelib advapi32.lib
	includelib imagehlp.lib
	includelib winmm.lib
	includelib setupapi.lib
	includelib iphlpapi.lib
	includelib ntdll.lib
	includelib crypt32.lib
	includelib wintrust.lib
	includelib psapi.lib
