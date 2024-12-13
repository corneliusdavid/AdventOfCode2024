program XMASCount;
(* as: XMASCount.exe, a Windows console app
 * in: Delphi 12.2
 * on: December, 2024
 * by: David Cornelius
 * to: Solve Day 4a of Advent of Code, 2024 (https://adventofcode.com/2024/day/4)
 *)

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Math, System.StrUtils, RegularExpressions;

procedure GenerateAnswer(const InputLines: TArray<string>);
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

  Writeln(Format('The Input file has %d rows, each of which is %d characters long.', [Length(InputLines), Length(InputLines[0])]));

  // set the number of vertical lines
  SetLength(VertLines, Length(InputLines[0]));
  // initialize the vertical lines
  for var c := 0 to Length(InputLines[0]) - 1 do
    VertLines[c] := EmptyStr;

  // set the length of the diagonal lines to accomodate the one for each row and one for each column
  SetLength(RtDiagLines, Length(InputLines) - 4 + Length(InputLines[0]) - 3);
  SetLength(LfDiagLines, Length(InputLines) - 4 + Length(InputLines[0]) - 3);
  // initialize the diagonal lines
  for var i := 0 to Length(RtDiagLines) - 1 do begin
    RtDiagLines[i] := EmptyStr;
    LfDiagLines[i] := EmptyStr;
  end;

  // build downward-right diagonal lines
  for var row := 0 to Length(InputLines) - 4 do
    for var col := 1 to Length(InputLines[0]) - row do
      RtDiagLines[row] := RtDiagLines[row] + InputLines[row+(col-1)][col];
  // the downward-right diagonal lines to the right of the top-left corner
  for var col := 2 to Length(InputLines[0]) - 3 do
    for var row := 0 to Length(InputLines) - col do
      RtDiagLines[Length(InputLines) - 5 + col] :=
        RtDiagLines[Length(InputLines) - 5 + col] + InputLines[row][col+row];

  // build downard-left diagonal lines
  for var row := 0 to Length(InputLines) - 4 do
    for var col := Length(InputLines[0]) downto row + 1 do
      LfDiagLines[row] := LfDiagLines[row] + InputLines[row+(Length(InputLines[0])-col)][col];
  // the downward-left diagonal lines to the left of the top-right corner
  for var col := Length(InputLines[0]) - 1 downto 4 do
    for var row := 0 to Min(Length(InputLines), col-1) do
      LfDiagLines[Length(InputLines) - 4 + col - 3] :=
        LfDiagLines[Length(InputLines) - 4 + col - 3] + InputLines[row][col-row];

  // build vertical lines
  for var col := 1 to Length(InputLines[0]) do
    for var row := 0 to Length(InputLines) - 1 do
      VertLines[row] := VertLines[row] + InputLines[row][col];

  // search horizontal lines
  for var row := 0 to Length(InputLines) - 1 do begin
    var p := RegEx.Match(InputLines[row]);
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
                  [HorzXMASCount, Length(InputLines),
                   VertXMASCount, Length(VertLines),
                   RtDiagXMASCount, Length(RtDiagLines),
                   LfDiagXMASCount, Length(LfDiagLines),
                   HorzXMASCount + VertXMASCount + RtDiagXMASCount + LfDiagXMASCount]));
end;

function ParentPath: string;
begin
  // executables are created in a .\$(Platform)\$(Config) folder, so look two parents up for files
  Result := '..' + TPath.DirectorySeparatorChar + '..';
end;

begin
  Writeln('Day 4a of Advent of Code, 2024 (https://adventofcode.com/2024/day/4)');
  GenerateAnswer(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input.txt')));
  Readln;
end.
