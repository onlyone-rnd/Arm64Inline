    include include\masm64rt.inc

OPTION NOKEYWORD:<CRC32>

GetModuleHandle64 PROTO :LPCSTR
GetProcAddress64  PROTO :HMODULE,:LPCSTR
SetProtect PROTO :HMODULE,:LPVOID
SetHookOutputDebugStringA PROTO :LPVOID,:LPVOID,:DWORD
SetHookVirtualProtect PROTO :HMODULE,:LPVOID,:LPVOID,:DWORD

MyOutputDebugStringA PROTO
MyVirtualProtect PROTO

.code

OPTION PROLOGUE:NONE
OPTION EPILOGUE:NONE

OEP dd 0
CRCBase dd 0
MD5Base dd 0
ECDSAVerify dd 0
CRC32 dd 0
MD5_1 dd 0
MD5_2 dd 0
MD5_3 dd 0
MD5_4 dd 0
szBaseDllName db 32 dup(0) 

OldBytesNtProtectVirtualMemory db 5 dup(0)
OldBytesOutputDebugStringA     db 12 dup(0)
KERNEL32                       db "kernel32.dll",0
szOutputDebugStringA           db "OutputDebugStringA",0
szK32GetMappedFileNameA        db "K32GetMappedFileNameA",0
NTDLL                          db "ntdll.dll",0
szNtProtectVirtualMemory       db "NtProtectVirtualMemory",0

lpOutputDebugStringA   dq 0
lpProtectVirtualMemory dq 0
lpK32GetMappedFileNameA dq 0
InBuffer db 260 dup(0)
db "[******]"
start:

    push -1
    push rax
    push rbx
    push rcx
    push rdx
    push rbp
    push rsi
    push rdi
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15
    mov rsi,FUNC(GetModuleHandle64,addr KERNEL32)
    mov rdi,FUNC(GetModuleHandle64,addr NTDLL)
    mov r13,FUNC(GetProcAddress64,rsi,addr szK32GetMappedFileNameA)
    lea rax,lpK32GetMappedFileNameA
    mov [rax],r13
    mov r13,FUNC(GetProcAddress64,rsi,addr szOutputDebugStringA)
    lea rax,lpOutputDebugStringA
    mov [rax],r13
    mov r12,FUNC(GetProcAddress64,rdi,addr szNtProtectVirtualMemory)
    lea rax,lpProtectVirtualMemory
    mov [rax],r12
    ; kernel32.dll set protect section
    invoke SetProtect,rsi,r12
    ; ntdll.dll set protect section
    invoke SetProtect,rdi,r12 
    ; ----------------------------
    invoke SetHookOutputDebugStringA,r13,addr OldBytesOutputDebugStringA,TRUE
    invoke SetHookVirtualProtect,rdi,r12,addr OldBytesNtProtectVirtualMemory,TRUE
    invoke GetModuleHandle64,addr szBaseDllName
    lea rcx,OEP
    mov ecx,dword ptr[rcx]
    add rax,rcx
    mov qword ptr[rsp+15*8],rax
    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rbp
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

OPTION PROLOGUE:PROLOGUEDEF
OPTION EPILOGUE:EPILOGUEDEF

MyVirtualProtect proc uses rbx rcx rdx rsi rdi r8 r9 r10 r11 r12 r13 r14 r15

    mov rbx,qword ptr[rdx]
    lea rax,lpK32GetMappedFileNameA
    mov r9d,sizeof InBuffer
    lea r8,InBuffer
    mov rdx,rbx
    mov rcx,-1
    call qword ptr[rax]
    .if !eax
        lea rax,ECDSAVerify
        mov eax,dword ptr[rax]
        lea rbx,qword ptr[rax+rbx]
        .if dword ptr[rbx] == 44C70A75h
            xor byte ptr[rbx],1
            lea rax,lpProtectVirtualMemory
            mov rax,[rax]
            invoke SetHookVirtualProtect,0,rax,addr OldBytesNtProtectVirtualMemory,FALSE
        .endif
    .endif
    ret
MyVirtualProtect endp

MyOutputDebugStringA proc uses rbx rcx rdx rsi rdi r8 r9 r10 r11 r12 r13 r14 r15

    mov rbx,qword ptr[rsp+8*19]
    mov rdi,rbx
    mov ecx,32
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

    lea rax,CRCBase
    mov eax,dword ptr[rax]
    lea rcx,CRC32
    mov ecx,dword ptr[rcx]
    mov dword ptr[rsp+8*20+rax],ecx
    
    lea rax,MD5Base
    mov eax,dword ptr[rax]
    .if eax > 0FFh
        lea rdi,qword ptr[rdi+rax]
    .else
        lea rdi,qword ptr[rsp+8*20+rax]
    .endif
    lea rax,MD5_1
    mov eax,dword ptr[rax]
    mov dword ptr[rdi],eax
    lea rax,MD5_2
    mov eax,dword ptr[rax]
    mov dword ptr[rdi+4],eax        
    lea rax,MD5_3
    mov eax,dword ptr[rax]
    mov dword ptr[rdi+4+4],eax
    lea rax,MD5_4
    mov eax,dword ptr[rax]
    mov dword ptr[rdi+4+4+4],eax
    lea rax,lpOutputDebugStringA
    mov rax,[rax]
    invoke SetHookOutputDebugStringA,rax,addr OldBytesOutputDebugStringA,FALSE
    ret
MyOutputDebugStringA endp

SetProtect proc uses rbx rcx rdx rsi rdi r8 r9 r10 r11 r12 r13 r14 r15 hModule:HMODULE,lpNtProtectVirtualMemory:LPVOID

    local OldProtect:PULONG

    memalign rsp,16

    mov r10,hModule
    mov r11d,dword ptr[r10+3Ch]
    lea r11,qword ptr[r11+r10+sizeof IMAGE_NT_HEADERS]
    mov ecx,[r11].IMAGE_SECTION_HEADER.VirtualAddress
    add rcx,r10
    mov edx,[r11].IMAGE_SECTION_HEADER.Misc.VirtualSize
    memalign rdx,1000h
    mov r8,PAGE_EXECUTE_READWRITE
    lea r9,OldProtect
    mov rax,rsp
    sub rsp,48h
    mov rdi,r9
    mov qword ptr[rax-28h],r9
    mov esi,r8d
    mov qword ptr[rax-18h],rdx
    mov r9d,r8d
    mov qword ptr[rax-10h],rcx
    lea r8,[rax-18h]
    lea rdx,[rax-10h]
    mov rcx,-1
    call lpNtProtectVirtualMemory
    ret

SetProtect endp

SIZEOFHOOK equ sizeof WORD + sizeof QWORD + sizeof WORD

SetHookOutputDebugStringA proc uses rsi rdi lpHookAddress:LPVOID,lpOldBytes:LPVOID,Install:DWORD

    .if !Install
        mov ecx,SIZEOFHOOK
        mov rsi,lpOldBytes
        mov rdi,lpHookAddress
        rep movsb
    .else
        mov ecx,SIZEOFHOOK
        mov rsi,lpHookAddress
        mov rdi,lpOldBytes
        rep movsb
        mov rdi,lpHookAddress
        mov word ptr[rdi],0B848h
        lea rax,MyOutputDebugStringA
        mov qword ptr[rdi+sizeof WORD],rax
        mov word ptr[rdi+sizeof WORD+sizeof QWORD],0E0FFh
    .endif
    ret

SetHookOutputDebugStringA endp

SetHookVirtualProtect proc uses rcx rsi rdi r10 r11 r12 r13 hModule:HMODULE,lpHookAddress:LPVOID,lpOldBytes:LPVOID,Install:DWORD

    .if !Install
        mov ecx,5
        mov rsi,lpOldBytes
        mov rdi,lpHookAddress
        add rdi,3
        rep movsb
    .else
        mov ecx,5
        mov rsi,lpHookAddress
        add rsi,3
        mov rdi,lpOldBytes
        rep movsb
        mov r10,hModule
        mov r11d,dword ptr[r10+3Ch]
        lea r11,qword ptr[r11+r10+sizeof IMAGE_NT_HEADERS]
        mov ecx,[r11].IMAGE_SECTION_HEADER.VirtualAddress
        add rcx,r10
        mov edx,[r11].IMAGE_SECTION_HEADER.Misc.VirtualSize
        memalign rdx,1000h
        lea rdi,qword ptr[rcx+rdx-64]
        mov r12,rdi
        mov word ptr[rdi],0B848h
        lea rax,MyVirtualProtect
        mov qword ptr[rdi+sizeof WORD],rax
        mov word ptr[rdi+sizeof WORD+sizeof QWORD],0D0FFh
        add rdi,SIZEOFHOOK
        mov r13,lpHookAddress
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
    .endif
    ret

SetHookVirtualProtect endp

    include GetModuleHandle64.asm
    include GetProcAddress64.asm

end start