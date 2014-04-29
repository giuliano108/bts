; -ÄÄÄ Aragorn ÄÄ-- / þCONTROL UNiTþ

        o equ offset
        b equ byte ptr
        w equ word ptr
        d equ dword ptr

.386
jumps

Data Segment Word Use16
Data EndS

Code Segment DWord Use16

Assume CS: Code, DS: Data

public fireline
fireline proc pascal near
arg src:word,srcoff:word,dst:word,dstoff:word,numba:word,carr:dword

push bp
push ds
    mov es,dst
    mov cx,numba
    mov ebx,carr
    mov ax,src
    mov si,srcoff
    mov di,dstoff
    mov ds,ax
@@lp:
    i=0
    rept 2
      mov eax,ebx
      add eax,ds:[si+i+320]
      add eax,ds:[si+i-1]
      add eax,ds:[si+i-320]
      add eax,ds:[si+i+1]
      mov ebx,eax
      and ebx,03030303h
      and eax,not 03030303h
      shr eax,2
      mov ds:[di+i],eax
      i=i+4
    endm
    add si,i
    add di,i
  dec cx
  jnz @@lp
pop ds
pop bp
  mov ax,bx
  shr ebx,16
  mov dx,bx
  ret
endp
ø
code ends

end
