ExtractModule PROTO :BOOL,:LPSTR,:LPSTR

DLLx64 = 101
EXEx64 = 102

.data

ENCRYPTED_KEY dd 0C3919A62h

.code

ExtractModule proc uses rbx rcx rdx rsi rdi r8 r9 r10 r11 r12 r13 r14 r15 dwTypePE:BOOL,lpFileName:LPSTR,lpModuleName:LPSTR

    local hInstance:HINSTANCE
    local Buffer:LPVOID

    memalign rsp,16

    mov hInstance,FUNC(GetModuleHandle,NULL)
    .if dwTypePE == IS_EXE
        mov eax,DLLx64
    .else
        mov eax,EXEx64
    .endif        
    mov rdi,FUNC(FindResource,hInstance,eax,RT_RCDATA)
    mov rsi,FUNC(LockResource,FUNC(LoadResource,hInstance,rdi))
    mov rbx,FUNC(SizeofResource,hInstance,rdi)
    sub ebx,49
    add rsi,49
    mov Buffer,FUNC(LocalAlloc,LPTR,ebx)
    mov ecx,ebx
    mov rdi,Buffer
    rep movsb
    mov ecx,ebx
    shr ecx,2
    mov rsi,Buffer
    mov rdi,rsi
    @@:
    lodsd
    xor eax,ENCRYPTED_KEY
    bswap eax
    stosd
    loop @B
    invoke strcpy,lpModuleName,lpFileName
    mov rsi,FUNC(strrchr,lpModuleName,'\')
    .if dwTypePE == IS_EXE
        mov rdi,chr$("\%X.dll")
    .else
        mov rdi,chr$("\%X.exe")
    .endif
    invoke sprintf,rsi,rdi,FUNC(GetProcessId,-1)
    invoke SaveToFile,lpModuleName,Buffer,ebx
    invoke LocalFree,Buffer
    ret

ExtractModule endp