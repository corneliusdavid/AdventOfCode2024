program PrintQueue;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Math, System.StrUtils, System.Generics.Collections;

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
  Writeln('Advent of Code 2024 - Day 05: Print Queue');
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
var
  PageOrderRules: TList<
  PageQueues: TArray<Integer>;
begin
  PageOrderRules := TDictionary<Integer, Integer>.Create;

  try
    // read input
    var InputFile := TFile.ReadAllLines(TPath.Combine(ParentPath, 'input.txt'));
    // process each line
    for var i := 0 to Length(InputFile) - 1 do begin
      var CurrLine := Trim(InputFile[i]);

      if Pos('|', CurrLine) > -1 then
        // read rules
        PageOrderRules.Add(StrToInt(LeftStr(CurrLine, 2)), StrToInt(RightStr(CurrLine, 2)))
      else
        // read page updates
    end;

    Writeln(Format('No answer generated yet--but there are %d rules and %d page updates to analyize.', [PageOrderRules.Count, Length(PageQueues)]));
  finally
    PageOrderRules.Free;
  end;
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
