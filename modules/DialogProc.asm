MainDlgProc proto :HWND,:QWORD,:WPARAM,:LPARAM

OPTION NOKEYWORD:<CRC32>

MAIN_DLG = 1000
FILE_EDT = 1001

CRC32_EDT = 1002
MD5_1_EDT = 1003
MD5_2_EDT = 1004
MD5_3_EDT = 1005
MD5_4_EDT = 1006

CRC_BASE_EDT = 1010
MD5_BASE_EDT = 1011

ECDSA_EDT = 1012

INLINE_BTN = 1013
BACKUP_CHK = 1015

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

; Errors

SMALL_SIZE = -1
NOT_PE_FILE = -2
NOT_X64_FILE = -3
NOT_ARMADILLO = -4
ALREADY_PATCHED = -5
IS_EXE = 1
IS_DLL = 2

.data?

DynamicInfo DYNAMIC_INFO <>
TypePE BOOL ?
szInfo BYTE 9 dup(?)
FileName BYTE 260 dup(?)

.code

MainDlgProc proc hWnd:HWND,uMsg:QWORD,wParam:WPARAM,lParam:LPARAM

        switch uMsg
    
        case WM_INITDIALOG
            invoke SendMessage,hWnd,WM_SETICON,ICON_BIG,FUNC(LoadIcon,FUNC(GetModuleHandle,NULL),100)
            invoke SetWindowText,hWnd,chr$("Armadillo x64 Inline Patch ECDSA Verify v0.1")
            invoke ChangeWindowMessageFilter,WM_DROPFILES,MSGFLT_ALLOW
            invoke ChangeWindowMessageFilter,WM_COPYDATA,MSGFLT_ALLOW
            invoke ChangeWindowMessageFilter,049h,MSGFLT_ALLOW

            invoke SendMessage,FUNC(GetDlgItem,hWnd,BACKUP_CHK),BM_CLICK,0,0

        case WM_CLOSE
    		invoke EndDialog,hWnd,NULL

        case WM_DROPFILES
            invoke DragQueryFile,wParam,0,addr FileName,sizeof FileName
            invoke GetTypeFile,addr FileName
            .repeat
                .if eax == SMALL_SIZE
                    mov rbx,chr$("File Size Too Small!")
                .elseif eax == NOT_PE_FILE
                    mov rbx,chr$("Not PE-file!")
                .elseif eax == NOT_X64_FILE
                    mov rbx,chr$("Not x64 executable!")
                .elseif eax == NOT_ARMADILLO
                    mov rbx,chr$("Executable File Not Protected Armadillo!")
                .elseif eax == ALREADY_PATCHED
                    mov rbx,chr$("Executable File Already Patched!")
                .else
                    mov TypePE,eax
                    .break
                .endif
                invoke MessageBox,hWnd,rbx,chr$("[ERROR]"),MB_ICONERROR or MB_TOPMOST or MB_OK
                return NULL
            .until

                invoke SetWindowText,FUNC(GetDlgItem,hWnd,FILE_EDT),addr FileName
                invoke SendMessage,FUNC(GetDlgItem,hWnd,FILE_EDT),EM_SETSEL,eax,eax

            invoke GetDynamicInfo,TypePE,addr FileName,addr DynamicInfo,sizeof DynamicInfo
            .if eax
                invoke sprintf,addr szInfo,chr$("%08X"),DynamicInfo.CRC32
                invoke SetWindowText,FUNC(GetDlgItem,hWnd,CRC32_EDT),addr szInfo
                invoke sprintf,addr szInfo,chr$("%08X"),DynamicInfo.MD5_1
                invoke SetWindowText,FUNC(GetDlgItem,hWnd,MD5_1_EDT),addr szInfo
                invoke sprintf,addr szInfo,chr$("%08X"),DynamicInfo.MD5_2
                invoke SetWindowText,FUNC(GetDlgItem,hWnd,MD5_2_EDT),addr szInfo 
                invoke sprintf,addr szInfo,chr$("%08X"),DynamicInfo.MD5_3
                invoke SetWindowText,FUNC(GetDlgItem,hWnd,MD5_3_EDT),addr szInfo 
                invoke sprintf,addr szInfo,chr$("%08X"),DynamicInfo.MD5_4
                invoke SetWindowText,FUNC(GetDlgItem,hWnd,MD5_4_EDT),addr szInfo            
    
                invoke sprintf,addr szInfo,chr$("%08X"),DynamicInfo.CRCBase
                invoke SetWindowText,FUNC(GetDlgItem,hWnd,CRC_BASE_EDT),addr szInfo 
                invoke sprintf,addr szInfo,chr$("%08X"),DynamicInfo.MD5Base
                invoke SetWindowText,FUNC(GetDlgItem,hWnd,MD5_BASE_EDT),addr szInfo

                invoke sprintf,addr szInfo,chr$("%08X"),DynamicInfo.ECDSAVerify
                invoke SetWindowText,FUNC(GetDlgItem,hWnd,ECDSA_EDT),addr szInfo
            .else
                invoke MessageBox,hWnd,chr$("Error Receiving Dynamic Data!"),chr$("[ERROR]"),MB_ICONERROR or MB_TOPMOST or MB_OK
            .endif

        case WM_COMMAND
    
        switch wParam

          case INLINE_BTN
            invoke IsDlgButtonChecked,hWnd,BACKUP_CHK
            invoke InlinePatch,addr DynamicInfo,addr FileName,eax
            invoke MessageBox,hWnd,chr$("Inline Patch Successfully!"),chr$("[INFORMATION]"),MB_ICONINFORMATION or MB_TOPMOST or MB_OK
          endsw
        endsw
        return NULL

MainDlgProc endp