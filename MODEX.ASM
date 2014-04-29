; Modex 360x240 set up routine
; (real mode adaptation of my pmode vmodex library)
; by...
; -ÄÄÄ Aragorn ÄÄ-- / þCONTROL UNiTþ

        o equ offset
        b equ byte ptr
        w equ word ptr
        d equ dword ptr

 ATTRCON_ADDR   = 3c0h
 MISC_ADDR      = 3c2h
 VGAENABLE_ADDR = 3c3h
 SEQ_ADDR       = 3c4h
 GRACON_ADDR    = 3ceh
 CRTC_ADDR      = 3d4h
 STATUS_ADDR    = 3dah

.386
jumps

Data Segment Word Use16
Data EndS

Code Segment DWord Use16
Assume CS: Code, DS: Data

public go360x240
go360x240 proc pascal near
        push    ds
        push    cs
        pop     ds
        mov     ax,0a000h
        mov     es,ax
        mov     si,o M360x240_data
        cld
        lodsb                   ; al = number of regs to change
        movzx   cx,al
        mov     dx,3D4h         ;Ä¿ ready vga regs
        mov     al,11h
        out     dx,al
        inc     dx
        in      al,dx
        and     al,7Fh
        mov     ah,al
        mov     al,11h
        dec     dx
        out     dx,ax           ;ÄÙ
vmxs:   lodsw                   ;Ä¿ dump the mode data to the VGA
        mov     dx,ax
        cmp     dx,ATTRCON_ADDR
        je      vmxAA
        cmp     dx,MISC_ADDR
        je      vmxMA
        cmp     dx,VGAENABLE_ADDR
        je      vmxMA
        lodsw                   ;default:
        out     dx,ax
        jmp     vmxR
vmxAA:  mov     bx,dx
        mov     dx,STATUS_ADDR
        in      al,dx
        mov     dx,bx
        lodsw
        or      al,20h
        out     dx,al
        mov     al,ah
        out     dx,al
        jmp     vmxR
vmxMA:  lodsw
        mov     al,ah
        out     dx,al
vmxR:   loop    vmxs            ;ÄÙ
        xor     al,al           ;Ä¿ Clear the palette: faster than clearing
        mov     dx,3C8h         ;   the whole VMEM
        out     dx,al
        inc     dx
        mov     ecx,256*3
vmxCP:  out     dx,al
        loop    vmxCP           ;ÄÙ
        mov     dx,SEQ_ADDR     ;Ä¿ Now clear the VMEM
        mov     ax,0F02h
        out     dx,ax
        xor     edi,edi
        xor     ax,ax
        mov     ecx,8000h
        rep     stosw           ;ÄÙ
        pop     ds
        ret
M360x240_data label word
 DB 25 ; <- number of records in data block
 DB 194,3,0,231,212,3,0,107,212,3,1,89,212,3,2,90,212,3,3,142
 DB 212,3,4,94,212,3,5,138,212,3,6,13,212,3,7,62,212,3,8,0
 DB 212,3,9,65,212,3,16,234,212,3,17,172,212,3,18,223,212,3,19,45
 DB 212,3,20,0,212,3,21,231,212,3,22,6,212,3,23,227,196,3,1,1
 DB 196,3,4,6,206,3,5,64,206,3,6,5,192,3,16,65,192,3,19,0
go360x240 endp

code ends
end
