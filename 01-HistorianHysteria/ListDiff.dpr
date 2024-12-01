program ListDiff;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Generics.Collections;

var
  Done: Boolean;

function ParentPath: string;
begin
  // executables are created in a .\$(Platform)\$(Config) folder, so look two parents up for files
  Result := '..' + TPath.DirectorySeparatorChar + '..';
end;

procedure ShowAbout;
begin
  var AboutText := TFile.ReadAllLines(TPath.Combine(ParentPath, 'about.txt'));
  for var i := 0 to Length(AboutText) - 1 do
    Writeln(AboutText[i]);
end;

function MenuPrompt: Char;
var
  Cmd: string;
begin
  Result := ' ';

  Writeln;
  Writeln('Advent of Code 2024 - Day 01: Historian Hysteria');
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
  LeftLoc, RightLoc, DiffLocs: Integer;
  LeftLocs, RightLocs: TList<Integer>;
begin
  DiffLocs := 0;

  LeftLocs := TList<Integer>.Create;
  RightLocs := TList<Integer>.Create;
  try
    // read all locations
    var InputFile := TFile.ReadAllLines(TPath.Combine(ParentPath, 'input.txt'));
    for var i := 0 to Length(InputFile) - 1 do begin
      var FirstSpace := Pos(' ', Trim(InputFile[i]));
      var LeftLocStr := Trim(Copy(Trim(InputFile[i]), 1, FirstSpace));
      var RightLocStr := Trim(Copy(Trim(InputFile[i]), FirstSpace, 100));

      if TryStrToInt(LeftLocStr, LeftLoc) and TryStrToInt(RightLocStr, RightLoc) then begin
        LeftLocs.Add(LeftLoc);
        RightLocs.Add(RightLoc);
      end;
    end;

    // sort and sum the lists
    LeftLocs.Sort;
    RightLocs.Sort;
    for var i := 0 to LeftLocs.Count - 1 do begin
      Writeln(Format('%d - %d = %d', [RightLocs.Items[i], LeftLocs.Items[i], Abs(RightLocs.Items[i] - LeftLocs.Items[i])]));
      DiffLocs := DiffLocs + Abs(RightLocs.Items[i] - LeftLocs.Items[i]);
    end;
  finally
    LeftLocs.Free;
    RightLocs.Free;
  end;

  Writeln('Total Difference: ', DiffLocs);
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
