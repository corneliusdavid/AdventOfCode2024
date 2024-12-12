program XMASCount;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Math, System.StrUtils, RegularExpressions;

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
  Writeln('Advent of Code 2024 - Day 04: Ceres Search - "XMAS" Count');
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
  HorzXMASCount: Integer;
  VertXMASCount: Integer;
  RtDiagXMASCount: Integer;
  LfDiagXMASCount: Integer;
  VertLines: TArray<string>;   // strings built up of characters in a vertial line through the grid
  RtDiagLines: TArray<string>; // strings built up of characters in a diagonal line down to the right
  LfDiagLines: TArray<string>; // strings built up of characters in a diagonal line down to the left
  RegEx: TRegEx;
begin
  HorzXMASCount := 0;
  VertXMASCount := 0;
  RtDiagXMASCount := 0;
  LfDiagXMASCount := 0;

  RegEx := TRegEx.Create('(XMAS)|(SAMX)');

  // read input
  var InputFile := TFile.ReadAllLines(TPath.Combine(ParentPath, 'input.txt'));

  Writeln(Format('The Input file has %d rows, each of which is %d characters long.', [Length(Inputfile), Length(InputFile[0])]));

  // set the number of vertical lines
  SetLength(VertLines, Length(InputFile[0]));
  // initialize the vertical lines
  for var c := 0 to Length(InputFile[0]) - 1 do
    VertLines[c] := EmptyStr;

  // set the length of the diagonal lines to accomodate the one for each row and one for each column
  SetLength(RtDiagLines, Length(InputFile) - 4 + Length(InputFile[0]) - 3);
  SetLength(LfDiagLines, Length(InputFile) - 4 + Length(InputFile[0]) - 3);
  // initialize the diagonal lines
  for var i := 0 to Length(RtDiagLines) - 1 do begin
    RtDiagLines[i] := EmptyStr;
    LfDiagLines[i] := EmptyStr;
  end;

  // build downward-right diagonal lines
  for var row := 0 to Length(InputFile) - 4 do
    for var col := 1 to Length(InputFile[0]) - row do
      RtDiagLines[row] := RtDiagLines[row] + InputFile[row+(col-1)][col];
  // the downward-right diagonal lines to the right of the top-left corner
  for var col := 2 to Length(InputFile[0]) - 3 do
    for var row := 0 to Length(InputFile) - col do
      RtDiagLines[Length(InputFile) - 5 + col] :=
        RtDiagLines[Length(InputFile) - 5 + col] + InputFile[row][col+row];

  // build downard-left diagonal lines
  for var row := 0 to Length(InputFile) - 4 do
    for var col := Length(InputFile[0]) downto row + 1 do
      LfDiagLines[row] := LfDiagLines[row] + InputFile[row+(Length(InputFile[0])-col)][col];
  // the downward-left diagonal lines to the left of the top-right corner
  for var col := Length(InputFile[0]) - 1 downto 4 do
    for var row := 0 to Min(Length(InputFile), col-1) do
      LfDiagLines[Length(InputFile) - 4 + col - 3] :=
        LfDiagLines[Length(InputFile) - 4 + col - 3] + InputFile[row][col-row];

  // build vertical lines
  for var col := 1 to Length(InputFile[0]) do
    for var row := 0 to Length(InputFile) - 1 do
      VertLines[row] := VertLines[row] + InputFile[row][col];

  // search horizontal lines
  for var row := 0 to Length(InputFile) - 1 do begin
    var p := RegEx.Match(InputFile[row]);
    while p.Success do begin
      Inc(HorzXMASCount);
      p := p.NextMatch;
    end;
  end;

  // search vertical lines
  for var i := 0 to Length(VertLines) - 1 do begin
    var p := RegEx.Match(VertLines[i]);
    while p.Success do begin
      Inc(VertXMASCount);
      p := p.NextMatch;
    end;
  end;

  // search downward-right diagonal lines
  for var i := 0 to Length(RtDiagLines) - 1 do begin
    var p := RegEx.Match(RtDiagLines[i]);
    while p.Success do begin
      Inc(RtDiagXMASCount);
      p := p.NextMatch;
    end;
  end;

  // search downward-left diagonal lines
  for var i := 0 to Length(LfDiagLines) - 1 do begin
    var p := RegEx.Match(LfDiagLines[i]);
    while p.Success do begin
      Inc(LfDiagXMASCount);
      p := p.NextMatch;
    end;
  end;

  Writeln(Format('Found %d cases of XMAS in %d horizontal lines,' + sLineBreak +
                 '      %d cases of XMAS in %d vertial lines,' + sLineBreak +
                 '      %d cases of XMAS in %d right-diagonals,' + sLineBreak +
                 '      %d cases of XMAS in %d left-diagonal lines' + sLineBreak +
                 '  for a total of %d cases of XMAS!',
                  [HorzXMASCount, Length(InputFile),
                   VertXMASCount, Length(VertLines),
                   RtDiagXMASCount, Length(RtDiagLines),
                   LfDiagXMASCount, Length(LfDiagLines),
                   HorzXMASCount + VertXMASCount + RtDiagXMASCount + LfDiagXMASCount]));
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
