program XMASCount;
(* as: XMASCount.exe, a Windows console app
 * in: Delphi 12.2
 * on: December, 2024
 * by: David Cornelius
 * to: Solve Day 4 of Advent of Code, 2024 (https://adventofcode.com/2024/day/4)
 *)

{$APPTYPE CONSOLE}
{.$DEFINE Sample}

{$R *.res}

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Math, System.StrUtils, RegularExpressions;

type
  CharArray2D = array of array of Char;

function ConvertToArray2D(StringArray: TArray<string>): CharArray2D;
var
  RowCount, ColCount: Integer;
begin
  RowCount := Length(StringArray);
  ColCount := Length(StringArray[0]);

  SetLength(Result, ColCount, RowCount);

  for var r := 0 to RowCount - 1 do
    for var c := 1 to ColCount do
      Result[r,c-1] := StringArray[r][c];
end;

procedure GenerateAnswer(const XMASGrid: CharArray2D);
const
  MAS_STR = 'MAS';

  function StringFromCoords(y1, x1, y2, x2, y3, x3: Integer): string;
  begin
    Result := XMASGrid[y1, x1] + XMASGrid[y2, x2] + XMASGrid[y3, x3];
  end;

  function CheckBackwardsXMAS(const row, col: Integer): Boolean;
  begin
    Result := (col >= 2) and (StringFromCoords(row, col, row, col-1, row, col-2) = MAS_STR);
  end;

  function CheckUpLeftXMAS(const row, col: Integer): Boolean;
  begin
    Result := (col >= 2) and (row >= 2) and
       (StringFromCoords(row, col, row-1, col-1, row-2, col-2) = MAS_STR);
  end;

  function CheckUpVertXMAS(const row, col: Integer): Boolean;
  begin
    Result := (row >= 2) and (StringFromCoords(row, col, row-1, col, row-2, col) = MAS_STR);
  end;

  function CheckUpRightXMAS(const row, col: Integer): Boolean;
  begin
    Result := (row >= 2) and (col < Length(XMASGrid[0]) - 2) and
              (StringFromCoords(row, col, row-1, col+1, row-2, col+2) = MAS_STR);
  end;

  function CheckRightXMAS(const row, col: Integer): Boolean;
  begin
    Result := (col < Length(XMASGrid[0]) - 2) and
              (StringFromCoords(row, col, row, col+1, row, col+2) = MAS_STR);
  end;

  function CheckDownRightXMAS(const row, col: Integer): Boolean;
  begin
    Result := (col < Length(XMASGrid[0]) - 2) and (row < Length(XMASGrid) - 2) and
              (StringFromCoords(row, col, row+1, col+1, row+2, col+2) = MAS_STR);
  end;

  function CheckDownVertXMAS(const row, col: Integer): Boolean;
  begin
    Result := (row < Length(XMASGrid) - 2) and
              (StringFromCoords(row, col, row+1, col, row+2, col) = MAS_STR);
  end;

  function CheckDownLeftXMAS(const row, col: Integer): Boolean;
  begin
    Result := (row < Length(XMASGrid) - 2) and (col >= 2) and
              (StringFromCoords(row, col, row+1, col-1, row+2, col-2) = MAS_STR);
  end;

var
  HorzXMASCount: Integer;
  VertXMASCount: Integer;
  RtDiagXMASCount: Integer;
  LfDiagXMASCount: Integer;
begin
  HorzXMASCount := 0;
  VertXMASCount := 0;
  RtDiagXMASCount := 0;
  LfDiagXMASCount := 0;

  {$IFDEF DEBUG}
  Writeln(Format('The Input file has %d rows and %d columns.', [Length(XMASGrid), Length(XMASGrid[0])]));
  {$ENDIF}

  // look at each character in the original array of strings and compare the surrounding
  // characters to see if they form "XMAS" in any direction.
  for var row := 0 to Length(XMASGrid) - 1 do
    for var col := 0 to Length(XMASGrid[row]) - 1 do
      // if the current character is X...
      if XMASGrid[row][col] = 'X' then begin
        // .. check the characters in all directions to see if they spell "XMAS"
        if CheckBackwardsXMAS(row, col-1) then
          Inc(HorzXMASCount);
        if CheckUpLeftXMAS(row-1, col-1) then
          Inc(LfDiagXMASCount);
        if CheckUpVertXMAS(row-1, col) then
          Inc(VertXMASCount);
        if CheckUpRightXMAS(row-1, col+1) then
          Inc(RtDiagXMASCount);
        if CheckRightXMAS(row, col+1) then
          Inc(HorzXMASCount);
        if CheckDownRightXMAS(row+1, col+1) then
          Inc(LfDiagXMASCount);
        if CheckDownVertXMAS(row+1, col) then
          Inc(VertXMASCount);
        if CheckDownLeftXMAS(row+1, col-1) then
          Inc(RtDiagXMASCount);
      end;

  {$IFDEF DEBUG}
  Writeln('Part 1: search in all directions from each "X":');
  Writeln(Format('Found %d cases of XMAS in horizontal lines,' + sLineBreak +
                 '      %d cases of XMAS in vertial lines,' + sLineBreak +
                 '      %d cases of XMAS in right-diagonals,' + sLineBreak +
                 '      %d cases of XMAS in left-diagonal lines' + sLineBreak +
                 '  for a total of %d cases of XMAS!',
                  [HorzXMASCount, VertXMASCount, RtDiagXMASCount, LfDiagXMASCount,
                   HorzXMASCount + VertXMASCount + RtDiagXMASCount + LfDiagXMASCount]));
  {$ELSE}
  Writeln(Format('Part 1: Found a total of %d cases of XMAS!',
                  [HorzXMASCount + VertXMASCount + RtDiagXMASCount + LfDiagXMASCount]));
  {$ENDIF}

end;

function ParentPath: string;
begin
  // executables are created in a .\$(Platform)\$(Config) folder, so look two parents up for files
  Result := '..' + TPath.DirectorySeparatorChar + '..';
end;

begin
  Writeln('Day 4 of Advent of Code, 2024 (https://adventofcode.com/2024/day/4)');
  {$IFDEF Sample}
  GenerateAnswer(ConvertToArray2D(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input-sm.txt'))));
  {$ELSE}
  GenerateAnswer(ConvertToArray2D(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input.txt'))));
  {$ENDIF}
  Readln;
end.
