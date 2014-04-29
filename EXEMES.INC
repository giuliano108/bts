type tXmovestruct =
       record
       Length       : longint;
       SourceHandle : word;
       SourceOffset : longint;
       DestHandle   : word;
       DestOffset   : longint;
       end;

var Xapi        : pointer;
    Xmovestruct : tXmovestruct;

function Xinit:boolean; assembler;
asm
   mov     ax,4300h
   int     2Fh
   cmp     al,80h
   mov     al,0
   jne     @NoXMSDriver
   mov     al,1
   push    ax

   mov     ax,4310h
   int     2Fh
   mov     word ptr [Xapi],bx
   mov     word ptr [Xapi+2],es

   pop     ax
@NoXMSDriver:
end;

function Xmaxavail:word; assembler; {biggest block size}
asm
   mov     ah,08h
   call    dword ptr Xapi
end;

function Xallocate(kbytes:word):word; assembler;
asm
   mov     ah,09h
   mov     dx,kbytes
   call    dword ptr Xapi
   xchg    ax,dx
   cmp     dx,1
   je      @allright
   mov     ax,0
@allright:
end;

function Xfree(block_handle:word):boolean; assembler;
asm
   mov     ah,0Ah
   mov     dx,block_handle
   call    dword ptr Xapi
end;

procedure Xlowtohigh(source : pointer;handle : word;destoffs,len : longint); assembler;
asm
   db 66h; mov ax,word ptr len
   db 66h; mov word ptr Xmovestruct.length,ax
           mov dx,handle
           mov          Xmovestruct.desthandle,dx
   db 66h; mov ax,word ptr destoffs
   db 66h; mov word ptr Xmovestruct.destoffset,ax
           mov          Xmovestruct.sourcehandle,0
   db 66h; mov ax,word ptr source
   db 66h; mov word ptr Xmovestruct.sourceoffset,ax
           mov si,offset Xmovestruct
           push ds
           push seg Xmovestruct
           pop  ds
           pop  ds
           mov  ah,0Bh
           call dword ptr Xapi
end;

procedure Xhightolow(handle : word;sourceoffs : longint;dest : pointer; len : longint); assembler;
asm
   db 66h; mov ax,word ptr len
   db 66h; mov word ptr Xmovestruct.length,ax
           mov dx,handle
           mov          Xmovestruct.sourcehandle,dx
   db 66h; mov ax,word ptr sourceoffs
   db 66h; mov word ptr Xmovestruct.sourceoffset,ax
           mov          Xmovestruct.desthandle,0
   db 66h; mov ax,word ptr dest
   db 66h; mov word ptr Xmovestruct.destoffset,ax
           mov si,offset Xmovestruct
           push ds
           push seg Xmovestruct
           pop  ds
           pop  ds
           mov  ah,0Bh
           call dword ptr Xapi
end;
