LastError proto

.code

LastError proc
		
		local ExitCode:qword
		local Message:PTR

		pushaq 
		pushfq
		mov ExitCode,FUNC(GetLastError)
		lea rbx,[Message]
		invoke FormatMessage,FORMAT_MESSAGE_FROM_SYSTEM or FORMAT_MESSAGE_ALLOCATE_BUFFER or FORMAT_MESSAGE_IGNORE_INSERTS,NULL,ExitCode,0,addr Message,MAX_PATH,0
		invoke MessageBoxEx,NULL,Message,chr$("[ERROR!!!]"),MB_ICONERROR or MB_TOPMOST,0
		popfq
		popaq
		invoke ExitProcess,ExitCode
		ret

LastError endp