{
-ÄÄÄ Aragorn ÄÄ-- / şCONTROL UNiTş

 BeyOnd the Sea 64kb intro

 substitution for BP's crt
}
unit crta;
interface
function keypressed:boolean;
function readkey:byte;

implementation
function keypressed:boolean; assembler;
asm
mov ah,1
int 16h
mov al,1
jnz @skip
mov al,0
@skip:
end;

function readkey:byte; assembler;
asm
mov ah,0
int 16h
end;

begin
end.