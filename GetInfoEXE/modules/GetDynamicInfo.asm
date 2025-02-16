GetDynamicInfo PROTO :LPSTR
SetHookToOutputDebugStringA PROTO
SetHookVirtualProtect PROTO
MyOutputDebugStringA PROTO
MyVirtualProtect PROTO
SendDynamicInfo PROTO

OPTION NOKEYWORD:<CRC32>

DYNAMIC_INFO STRUCT
CRCBase            DWORD ?
MD5Base            DWORD ?
ECDSAVerify        DWORD ?
CRC32              DWORD ?
MD5_1              DWORD ?
MD5_2              DWORD ?
MD5_3              DWORD ?
MD5_4              DWORD ?
DYNAMIC_INFO ENDS

.data?

DynamicInfo DYNAMIC_INFO <>

.code

GetDynamicInfo proc lpModule:LPSTR

    invoke SetHookToOutputDebugStringA
    invoke SetHookVirtualProtect
    invoke LoadLibraryW,lpModule
    ret

GetDynamicInfo endp

SIZEOFHOOK equ sizeof WORD + sizeof QWORD + sizeof WORD

SetHookToOutputDebugStringA proc uses rbx rcx rdx rsi rdi r8 r9 r10 r11 r12 r13 r14 r15

    local OldProtect:DWORD

    memalign rsp,16

    mov rbx,FUNC(GetProcAddress,FUNC(GetModuleHandle,chr$("kernel32.dll")),chr$("OutputDebugStringA"))
    invoke VirtualProtect,rbx,SIZEOFHOOK,PAGE_EXECUTE_READWRITE,addr OldProtect
    mov word ptr[rbx],0B848h
    lea rax,MyOutputDebugStringA
    mov qword ptr[rbx+sizeof WORD],rax
    mov word ptr[rbx+sizeof WORD+sizeof QWORD],0E0FFh
    invoke VirtualProtect,rbx,SIZEOFHOOK,OldProtect,addr OldProtect
    ret

SetHookToOutputDebugStringA endp

MyVirtualProtect proc uses rbx rcx rdx rsi rdi r8 r9 r10 r11 r12 r13 r14 r15

    local mbi:MEMORY_BASIC_INFORMATION
    local FileName[260]:BYTE

    mov rbx,qword ptr[rdx]
    invoke GetMappedFileName,-1,rbx,addr FileName,sizeof FileName
    .if !eax
        invoke VirtualQuery,rbx,addr mbi,sizeof mbi
        .if eax
            .if mbi.AllocationProtect == PAGE_EXECUTE_READWRITE || mbi.AllocationProtect == PAGE_READWRITE
                mov rcx,mbi.RegionSize
                sub rcx,1000h
                mov rax,rbx
                .repeat
                    .if dword ptr[rax] == 24548948h && dword ptr[rax+4] == 4C894810h && dword ptr[rax+4+4] == 83480824h && \
                        dword ptr[rax+4+4+4] == 334538ECh && dword ptr[rax+4+4+4+4] == 548B48C0h && dword ptr[rax+4+4+4+4+4] == 8B484824h &&\
                        dword ptr[rax+4+4+4+4+4+4] == 0E840244Ch && dword ptr[rax+4+4+4+4+4+4+4+4] == 0A75C085h
                        lea rax,qword ptr[rax+4+4+4+4+4+4+4+4+2]
                        sub rax,rbx
                        mov DynamicInfo.ECDSAVerify,eax
                        .break
                    .endif
                    inc rax
                    dec rcx
                .until !rcx
            .endif
        .endif
    .endif
    ret

MyVirtualProtect endp

MyOutputDebugStringA proc uses rbx rcx rdx rsi rdi r8 r9 r10 r11 r12 r13 r14 r15

    mov ecx,32
    mov rbx,qword ptr[rsp+8*15]
    .while TRUE
        .if dword ptr[rbx] == 668h && dword ptr[rbx+14] == 668h && dword ptr[rbx+28] == 668h
            .break
        .endif
        inc rbx
        dec ecx
        .if !ecx
            return NULL
        .endif
    .endw
    lea rbx,qword ptr[rbx+28]
    mov ecx,32
    .while TRUE
        .if dword ptr[rbx] == 244C8BC1h ; mov ecx,dword ptr ss:[rsp+XXX]
            .break
        .endif
        inc rbx
        dec ecx
        .if !ecx
            return NULL
        .endif
    .endw
    add rbx,sizeof DWORD
    movzx eax,byte ptr[rbx]
    mov DynamicInfo.CRCBase,eax
    mov ecx,dword ptr[rsp+rax+8*16]
    mov DynamicInfo.CRC32,ecx
    nop
    mov ecx,186
    .while TRUE
        .if dword ptr[rbx] == 0C93345B6h ; xor r9d,r9d
            .break
        .endif
        inc rbx
        dec ecx
        .if !ecx
            return NULL
        .endif
    .endw
    mov ecx,22
    .while TRUE
        .if word ptr[rbx] == 8D48h ; lea rcx,
            .break
        .endif
        inc rbx
        dec ecx
        .if !ecx
            return NULL
        .endif
    .endw    
    add rbx,sizeof WORD
    .if word ptr[rbx] == 244Ch ; [rsp+
        add rbx,sizeof WORD
        movzx eax,byte ptr[rbx]
        mov DynamicInfo.MD5Base,eax
        lea rbx,qword ptr[rsp+rax+8*16]
        mov eax,dword ptr[rbx]
        mov DynamicInfo.MD5_1,eax
        mov eax,dword ptr[rbx+4]
        mov DynamicInfo.MD5_2,eax
        mov eax,dword ptr[rbx+4+4]
        mov DynamicInfo.MD5_3,eax
        mov eax,dword ptr[rbx+4+4+4]
        mov DynamicInfo.MD5_4,eax        
    .else
        inc rbx
        mov ecx,dword ptr[rbx]
        add rbx,sizeof DWORD
        add rbx,rcx
        mov eax,dword ptr[rbx]
        mov DynamicInfo.MD5_1,eax
        mov eax,dword ptr[rbx+4]
        mov DynamicInfo.MD5_2,eax
        mov eax,dword ptr[rbx+4+4]
        mov DynamicInfo.MD5_3,eax
        mov eax,dword ptr[rbx+4+4+4]
        mov DynamicInfo.MD5_4,eax
        sub rbx,qword ptr[rsp+8*15]
        mov DynamicInfo.MD5Base,ebx
    .endif
    nop
    jmp SendDynamicInfo

MyOutputDebugStringA endp

SetHookVirtualProtect proc uses rbx rcx rdx rsi rdi r8 r9 r10 r11 r12 r13 r14 r15

    local OldProtect:DWORD

    memalign rsp,16

    mov rbx,FUNC(GetModuleHandle,chr$("ntdll.dll"))
    mov rsi,FUNC(RtlImageNtHeader,rbx)
    lea rsi,qword ptr[rsi+sizeof IMAGE_NT_HEADERS]
    mov edi,[rsi].IMAGE_SECTION_HEADER.VirtualAddress
    mov r14d,[rsi].IMAGE_SECTION_HEADER.Misc.VirtualSize
    memalign r14d,1000h
    lea r15,qword ptr[rdi+rbx]
    invoke VirtualProtect,r15,r14d,PAGE_EXECUTE_READWRITE,addr OldProtect
    lea rdi,qword ptr[rdi+r14-64]
    add rdi,rbx
    mov r12,rdi
    mov word ptr[rdi],0B848h
    lea rax,MyVirtualProtect
    mov qword ptr[rdi+sizeof WORD],rax
    mov word ptr[rdi+sizeof WORD+sizeof QWORD],0D0FFh
    add rdi,SIZEOFHOOK

    mov r13,FUNC(GetProcAddress,rbx,chr$("NtProtectVirtualMemory"))
    add r13,3
    mov rsi,r13
    mov ecx,5
    rep movsb
    mov al,0C3h
    stosb
    mov rdi,r13
    mov al,0E8h
    stosb
    mov rax,r12
    sub rax,rsi
    stosd
    invoke VirtualProtect,r15,r14d,OldProtect,addr OldProtect
    ret

SetHookVirtualProtect endp

SendDynamicInfo proc

    local WriteBytes:DWORD

    memalign rsp,16

    mov rbx,FALSE
    xor rsi,rsi
    mov rsi,FUNC(CreateFile,chr$("\\.\pipe\GetInfoCB654C9189FFCA7D7A2C1A8AE1EA0757"),GENERIC_WRITE,NULL,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL)
    .if esi != INVALID_HANDLE_VALUE
        invoke WriteFile,rsi,addr DynamicInfo,sizeof DynamicInfo,addr WriteBytes,0
        .if eax
            mov rbx,TRUE
        .endif
    .endif
    .if rsi
        invoke CloseHandle,rsi
    .endif
    invoke ExitProcess,rbx

SendDynamicInfo endp