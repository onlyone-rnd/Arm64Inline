GetDynamicInfo PROTO :BOOL,:LPSTR,:LPVOID,:DWORD

.code

GetDynamicInfo proc uses rbx rcx rdx rsi rdi r8 r9 r10 r11 r12 r13 r14 r15 dwTypePE:BOOL,lpFileName:LPSTR,lpDynamicInfo:LPVOID,dwSizeDynamicInfo:DWORD

    local InjectMemory:PTR
    local hNamedPipe:HANDLE
    local nBytesRead:DWORD
    local ExitCode:QWORD
    local sinfo:STARTUPINFOW
    local pinfo:PROCESS_INFORMATION
    local ModuleName[260]:BYTE
    local CmdProcess[260*2]:BYTE
    
    memalign rsp,16
    
    mov hNamedPipe,FUNC(CreateNamedPipe,chr$("\\.\pipe\GetInfoCB654C9189FFCA7D7A2C1A8AE1EA0757"),PIPE_ACCESS_DUPLEX,PIPE_TYPE_MESSAGE,PIPE_UNLIMITED_INSTANCES,500,500,5000,NULL)
    .if hNamedPipe == INVALID_HANDLE_VALUE
        invoke LastError
    .endif
    .if dwTypePE == IS_EXE
        invoke memset,addr sinfo,0,sizeof sinfo
        mov sinfo.cb,sizeof sinfo
        invoke CreateProcess,NULL,lpFileName,NULL,NULL,NULL,NORMAL_PRIORITY_CLASS or CREATE_NEW_CONSOLE or CREATE_SUSPENDED,NULL,NULL,addr sinfo,addr pinfo
        .if !eax
            invoke LastError
        .endif
        invoke ExtractModule,dwTypePE,lpFileName,addr ModuleName
        mov rbx,FUNC(strlen,addr ModuleName)
        mov InjectMemory,FUNC(VirtualAllocEx,pinfo.hProcess,0,ebx,MEM_COMMIT,PAGE_EXECUTE_READWRITE)
        .if !InjectMemory
            invoke LastError
        .endif
        invoke WriteProcessMemory,pinfo.hProcess,InjectMemory,addr ModuleName,ebx,0
        .if !eax
            invoke LastError
        .endif
        mov rbx,FUNC(GetProcAddress,FUNC(GetModuleHandle,chr$("kernel32.dll")),chr$("LoadLibraryA"))
        .if !rbx
            invoke LastError
        .endif
        invoke CloseHandle,FUNC(CreateRemoteThread,pinfo.hProcess,NULL,0,rbx,InjectMemory,0,NULL)
        .if !rax
            invoke LastError
        .endif
        invoke ResumeThread,pinfo.hThread
        .if eax == -1
            invoke LastError
        .endif
        invoke ConnectNamedPipe,hNamedPipe,NULL
        invoke ReadFile,hNamedPipe,lpDynamicInfo,dwSizeDynamicInfo,addr nBytesRead,0
        .if !eax
            invoke LastError
        .endif
        invoke DisconnectNamedPipe,hNamedPipe
        invoke CloseHandle,hNamedPipe
        .if !eax
            invoke LastError
        .endif
        invoke WaitForSingleObject,pinfo.hProcess,INFINITE
        invoke GetExitCodeProcess,pinfo.hProcess,addr ExitCode
        .if !eax
            invoke LastError
        .endif
        invoke CloseHandle,pinfo.hThread
        .if !eax
            invoke LastError
        .endif
        invoke CloseHandle,pinfo.hProcess
        .if !eax
            invoke LastError
        .endif
        invoke DeleteFile,addr ModuleName
        .if !eax
            invoke LastError
        .endif
     .else
        invoke ExtractModule,dwTypePE,lpFileName,addr ModuleName
        invoke memset,addr CmdProcess,0,sizeof CmdProcess
        invoke strcat,addr CmdProcess,chr$('"')
        invoke strcat,addr CmdProcess,addr ModuleName
        invoke strcat,addr CmdProcess,chr$('" "')
        invoke strcat,addr CmdProcess,lpFileName
        invoke strcat,addr CmdProcess,chr$('"')
       invoke memset,addr sinfo,0,sizeof sinfo
        mov sinfo.cb,sizeof sinfo
        invoke CreateProcess,NULL,addr CmdProcess,NULL,NULL,NULL,NORMAL_PRIORITY_CLASS or CREATE_NEW_CONSOLE or CREATE_SUSPENDED,NULL,NULL,addr sinfo,addr pinfo
        .if !eax
            invoke LastError
        .endif
        invoke ResumeThread,pinfo.hThread
        .if eax == -1
            invoke LastError
        .endif
        invoke ConnectNamedPipe,hNamedPipe,NULL
        invoke ReadFile,hNamedPipe,lpDynamicInfo,dwSizeDynamicInfo,addr nBytesRead,0
        .if !eax
            invoke LastError
        .endif
        invoke DisconnectNamedPipe,hNamedPipe
        invoke CloseHandle,hNamedPipe
        .if !eax
            invoke LastError
        .endif
        invoke WaitForSingleObject,pinfo.hProcess,INFINITE
        invoke GetExitCodeProcess,pinfo.hProcess,addr ExitCode
        .if !eax
            invoke LastError
        .endif
        invoke CloseHandle,pinfo.hThread
        .if !eax
            invoke LastError
        .endif
        invoke CloseHandle,pinfo.hProcess
        .if !eax
            invoke LastError
        .endif
        invoke DeleteFile,addr ModuleName
        .if !eax
            invoke LastError
        .endif
    .endif
    return ExitCode

GetDynamicInfo endp