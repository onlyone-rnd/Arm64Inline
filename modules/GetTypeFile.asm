GetTypeFile PROTO :LPSTR

.code

GetTypeFile proc uses rbx rcx rdx rsi rdi r8 r9 r10 r11 r12 r13 r14 r15 lpFileName:LPSTR

    local hFile:HANDLE
    local hMap:HANDLE
    local dwSize:QWORD
    local pMap:LPVOID
    local Result:QWORD

    memalign rsp,16

    mov hFile,NULL
    mov hMap,NULL
    mov pMap,NULL

    mov hFile,FUNC(CreateFile,lpFileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0)
    .if hFile == INVALID_HANDLE_VALUE
        invoke LastError
    .endif
    mov dwSize,FUNC(GetFileSize,hFile,NULL)
    .if dwSize < 4096
        mov Result,SMALL_SIZE
    .else
        mov hMap,FUNC(CreateFileMapping,hFile,0,PAGE_READONLY,0,dwSize,0)
        .if !hMap
            invoke LastError
        .endif
        mov pMap,FUNC(MapViewOfFile,hMap,FILE_MAP_READ,0,0,0)
        .if !pMap
            invoke LastError
        .endif        
        mov rbx,FUNC(RtlImageNtHeader,pMap)
        .if !rbx
            mov Result,NOT_PE_FILE
        .else
            .if [rbx].IMAGE_NT_HEADERS.OptionalHeader.Magic != IMAGE_NT_OPTIONAL_HDR64_MAGIC
                mov Result,NOT_X64_FILE
            .else
                .if ([rbx].IMAGE_NT_HEADERS.OptionalHeader.MajorLinkerVersion == 'O') && ([rbx].IMAGE_NT_HEADERS.OptionalHeader.MinorLinkerVersion == 'N')
                    mov Result,ALREADY_PATCHED
                .elseif ([rbx].IMAGE_NT_HEADERS.OptionalHeader.MajorLinkerVersion != 'S') || ([rbx].IMAGE_NT_HEADERS.OptionalHeader.MinorLinkerVersion != 'R')
                    mov Result,NOT_ARMADILLO
                .else
                    .if [rbx].IMAGE_NT_HEADERS.FileHeader.Characteristics & IMAGE_FILE_DLL
                        mov Result,IS_DLL
                    .else
                        mov Result,IS_EXE
                    .endif
                .endif
            .endif
        .endif
    .endif
    .if hFile
        invoke CloseHandle,hFile
    .endif
    .if hMap
        invoke CloseHandle,hMap
    .endif
    .if pMap
        invoke UnmapViewOfFile,pMap
    .endif
    return Result    

GetTypeFile endp

