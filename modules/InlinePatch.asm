InlinePatch PROTO :LPVOID,:LPSTR,:BOOL

OPTION NOKEYWORD:<CRC32>

INLINEx64 = 103

INLINE_DATA STRUCT
OEP         DWORD ?
CRCBase     DWORD ?
MD5Base     DWORD ?
ECDSAVerify DWORD ?
CRC32       DWORD ?
MD5_1       DWORD ?
MD5_2       DWORD ?
MD5_3       DWORD ?
MD5_4       DWORD ?
BaseDllName BYTE 32 dup(?)
INLINE_DATA ENDS

.code

    include modules\BackUp.asm
    include modules\AddSection.asm

InlinePatch proc uses rbx rcx rdx rsi rdi r8 r9 r10 r11 r12 r13 r14 r15 lpDynamicInfo:LPVOID,lpFileName:LPSTR,IsBackUp:BOOL

    .if IsBackUp
        invoke BackUp,lpFileName
    .endif

    mov rbx,FUNC(GetModuleHandle,NULL)
    mov rdi,FUNC(FindResource,rbx,INLINEx64,RT_RCDATA)
    mov rsi,FUNC(LockResource,FUNC(LoadResource,rbx,rdi))
    mov rbx,FUNC(SizeofResource,rbx,rdi)
    mov rdi,FUNC(GlobalAlloc,GMEM_FIXED,ebx)
    invoke memcpy,rdi,rsi,ebx
    mov rsi,lpDynamicInfo
    mov eax,[rsi].DYNAMIC_INFO.CRCBase
    mov [rdi].INLINE_DATA.CRCBase,eax
    mov eax,[rsi].DYNAMIC_INFO.MD5Base
    mov [rdi].INLINE_DATA.MD5Base,eax
    mov eax,[rsi].DYNAMIC_INFO.ECDSAVerify
    mov [rdi].INLINE_DATA.ECDSAVerify,eax
    mov eax,[rsi].DYNAMIC_INFO.CRC32
    mov [rdi].INLINE_DATA.CRC32,eax
    mov eax,[rsi].DYNAMIC_INFO.MD5_1
    mov [rdi].INLINE_DATA.MD5_1,eax
    mov eax,[rsi].DYNAMIC_INFO.MD5_2
    mov [rdi].INLINE_DATA.MD5_2,eax
    mov eax,[rsi].DYNAMIC_INFO.MD5_3
    mov [rdi].INLINE_DATA.MD5_3,eax
    mov eax,[rsi].DYNAMIC_INFO.MD5_4
    mov [rdi].INLINE_DATA.MD5_4,eax
    invoke strrchr,lpFileName,'\'
    inc rax
    lea rcx,[rdi].INLINE_DATA.BaseDllName
    invoke strcpy,rcx,rax
    invoke AddSection,lpFileName,rdi,ebx
    invoke GlobalFree,rdi
    ret

InlinePatch endp