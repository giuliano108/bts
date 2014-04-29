const cursword : word = 0;

function tohex(value : word):string;
const hexch : array[0..15] of char = ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');
begin
tohex := hexch[hi(value) shr  4]+
         hexch[hi(value) and 15]+
         hexch[lo(value) shr  4]+
         hexch[lo(value) and 15]+'h';
end;

function FileExists(FileName: String): Boolean;
var
 F: file;
begin
 {$I-}
 Assign(F, FileName);
 FileMode := 0;
 Reset(F);
 Close(F);
 {$I+}
 FileExists := (IOResult = 0) and (FileName <> '');
end;

procedure swdumper;
var f : text;
begin
  assign(f,'swords');
  if fileexists('swords') then append(f) else rewrite(f);
  writeln(f,cursword:6,': ',tohex(getsyncword));
  close(f);
  inc(cursword);
end;

