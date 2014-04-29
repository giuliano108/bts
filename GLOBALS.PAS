{
-ÄÄÄ Aragorn ÄÄ-- / þCONTROL UNiTþ

vars and types shared by all modules
}
unit globals;
interface
uses palette;

type tarro = Array[0..128*128-1] of byte;
     tarr  = array[0..65520] of byte;
     ptarr = ^tarr;
var
     m13 : array[0..63999] of byte absolute $a000:0000;
     i,j,
     _di,_si,
     pdi,psi,pcx                    : word;
     buf1,buf2,buf3,buf4,
     tun1,tun2,tunt                 : word;
     pbuf1,pbuf2,pbuf3,pbuf4,p      : pointer;
     pal,pal1,pal2,pal3     : paltype;
     palf,palf1             : palfixedtype;
     pala,pala1,pala2       : paladdtype;


procedure flip(ins,outs: word);
procedure bufreset(ins: word);
procedure bufresetv(ins: word);
procedure bmpdrop;
procedure openpic;
procedure music;

implementation
procedure flip(ins,outs: word); assembler;
asm
  push  ds
  mov   di,0
  mov   si,0
  mov   ds,ins
  mov   es,outs
  mov   cx,16000
  db 66h; repnz movsw;
  pop   ds
end;

procedure bufreset(ins: word); assembler;
asm
mov ax,ins
mov es,ax
mov cx,16384
xor di,di
db 66h; xor ax,ax
db 66h; repnz stosw
end;

procedure bufresetv(ins: word); assembler;
asm
mov ax,ins
mov es,ax
mov cx,16000
xor di,di
db 66h; xor ax,ax
db 66h; repnz stosw
end;

procedure bmpdrop; external; {$L droppic.obj}
procedure openpic; external; {$L openpic.obj}
procedure music;external;  {$L aryx.obj} {{$L ventil.obj}

begin
end.