{
-ÄÄÄ Aragorn ÄÄ-- / þCONTROL UNiTþ

bitbybit (2 colors) packed pictures - decoding routine
}
unit bpp;
interface
uses globals;
procedure bppdecode(source,dest:ptarr;size:word;mul:byte);
procedure openpic;
procedure bmpdrop;

implementation

procedure bppdecode(source,dest:ptarr;size:word;mul:byte); assembler;
asm
  push  ds
  mov   dx,size
  xor   cx,cx
  mov   bl,mul
  les   di,dest
  lds   si,source
@lup:
  lodsb
  dec   si
  shr   al,cl
  and   al,1
  mul   bl
  inc   cl
  cmp   cl,8
  jne   @skip
  inc   si
  xor   cx,cx
@skip:
  stosb
  dec   dx
  jnz   @lup
  pop   ds
end;

procedure openpic; external; {$L openpic.obj}
procedure bmpdrop; external; {$L droppic.obj}

begin
end.