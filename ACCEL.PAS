{$N+}
uses crt;

PROCEDURE SetPix13(X,Y:Word; C:Byte);
BEGIN
     if (x < 320) and (y < 200) then
     ASM
        mov ax,$a000
        mov es,ax
        mov bx,x
        mov dx,y
        xchg dh,dl
        mov al,c
        mov di,dx
        shr di,1
        shr di,1
        add di,dx
        add di,bx
        stosb
     END
{$ifndef outinfo}
;
{$else}
     else
     begin
     directvideo := false;
     writeln(#13#10'fuoRi !!! ',x,',',y);
     end;
{$endif}
END;

function tunx(frame : longint):longint;
begin
  if frame < 200 then tunx := 0
      else if frame < 250 then tunx := trunc(-cos((frame-200)*((pi/2)/50))*25+25)
        else tunx := trunc((frame-250)*(0.8))+25;
end;

var frame : longint;
begin
asm  mov   ax,13h; int   10h; end;
for frame := 0 to 319 do
  setpix13(frame,199-tunx(frame),10);
readkey;
asm  mov   ax, 3h; int   10h; end;
end.