program UncorruptMul;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes, System.IOUtils, RegularExpressions;

var
  Done: Boolean;

function ParentPath: string;
begin
  // executables are created in a .\$(Platform)\$(Config) folder, so look two parents up for files
  Result := '..' + TPath.DirectorySeparatorChar + '..';
end;

procedure ShowAbout;
begin
  var AboutText := TFile.ReadAllLines(TPath.Combine(ParentPath, ChangeFileExt(ExtractFileName(ParamStr(0)), '.txt')));
  for var i := 0 to Length(AboutText) - 1 do
    Writeln(AboutText[i]);
end;

function MenuPrompt: Char;
var
  Cmd: string;
begin
  Result := ' ';

  Writeln;
  Writeln('Advent of Code 2024 - Day 03: Mull it Over');
  Writeln;
  Writeln(' ? - Information About this Puzzle');
  Writeln(' A - Generate the Answer for this Puzzle');
  Writeln(' X - Exit this program');
  Writeln;
  Write  ('> ');

  Readln(cmd);
  cmd := UpperCase(Trim(cmd));
  if cmd.IsEmpty then
    Writeln('Please enter a command.')
  else if cmd.Length > 1 then
    Writeln('Please only enter one character.')
  else if not CharInSet(cmd[1], ['?','A','X']) then
    Writeln('Please enter one of the valid characters.')
  else
    Result := cmd[1];
end;

procedure GenerateAnswer;
const
  MulPattern = 'mul\([0-9]+\,[0-9]+\)';
var
  MulCount: Integer;
  MulTotal: Longint;
  RegEx: TRegEx;
  Num1: Integer;
  Num2: Integer;
begin
  MulCount := 0;
  MulTotal := 0;

  RegEx := TRegEx.Create(MulPattern);

  // read input
  var InputFile := TFile.ReadAllLines(TPath.Combine(ParentPath, 'input.txt'));
  for var i := 0 to Length(InputFile) - 1 do begin
    var CurrLine := InputFile[i];

    var p := RegEx.Match(CurrLine);
    while p.Success do begin
      var p1 := TRegEx.Match(p.Value, '[0-9]+').Value;
      var p2 := TRegEx.Match(Copy(p.Value, Pos(',', p.Value) + 1), '[0-9]+').Value;

      if TryStrToInt(p1, Num1) and
         TryStrToInt(p2, Num2) then begin
        Inc(MulCount);
        var TempTotal := Num1 * Num2;
        Writeln(Format('found: %s: %d * %d = %d', [p.Value, Num1, Num2, TempTotal]));
        Inc(MulTotal, TempTotal);
      end;

      p := p.NextMatch;
    end;
  end;

  Writeln(Format('Found Mul Matches: %d for a grand total of %d', [MulCount, MulTotal]));
end;

procedure MenuAction(const Cmd: Char);
begin
  case Cmd of
    '?': ShowAbout;
    'A': GenerateAnswer;
    'X': Done := True;
  end;
end;

begin
  try
    Done := False;
    repeat
      MenuAction(MenuPrompt);
    until Done;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
