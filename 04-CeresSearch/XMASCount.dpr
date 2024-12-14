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

  function CheckBackwardsXMAS(const row, col: Integer): Boolean;
  begin
    Result := (col >= 4) and (Copy(InputLines[row], col - 3, 4) = 'SAMX');
  end;

  function CheckUpLeftXMAS(const row, col: Integer): Boolean;
  begin
    Result := (col >= 4) and (row >= 3) and (InputLines[row-3][col-3] = 'S') and
                                            (InputLines[row-2][col-2] = 'A') and
                                            (InputLines[row-1][col-1] = 'M');
  end;

  function CheckUpVertXMAS(const row, col: Integer): Boolean;
  begin
    Result := (row >= 3) and (InputLines[row-3][col] = 'S') and
                             (InputLines[row-2][col] = 'A') and
                             (InputLines[row-1][col] = 'M');
  end;

  function CheckUpRightXMAS(const row, col: Integer): Boolean;
  begin
    Result := (col <= Length(InputLines[0]) - 3) and (row >= 3) and
              (InputLines[row-3][col+3] = 'S') and
              (InputLines[row-2][col+2] = 'A') and
              (InputLines[row-1][col+1] = 'M');
  end;

  function CheckRightXMAS(const row, col: Integer): Boolean;
  begin
    Result := (col < Length(InputLines[0]) - 3) and (Copy(InputLines[row], col, 4) = 'XMAS');
  end;

  function CheckDownRightXMAS(const row, col: Integer): Boolean;
  begin
    Result := (col < Length(InputLines[0]) - 3) and (row < Length(InputLines) - 4) and
              (InputLines[row+1][col+1] = 'M') and
              (InputLines[row+2][col+2] = 'A') and
              (InputLines[row+3][col+3] = 'S');
  end;

  function CheckDownVertXMAS(const row, col: Integer): Boolean;
  begin
    Result := (row < Length(InputLines) - 4) and
              (InputLines[row+1][col] = 'M') and
              (InputLines[row+2][col] = 'A') and
              (InputLines[row+3][col] = 'S');
  end;

  function CheckDownLeftXMAS(const row, col: Integer): Boolean;
  begin
    Result := (row < Length(InputLines) - 4) and (col > 3) and
              (InputLines[row+1][col-1] = 'M') and
              (InputLines[row+2][col-2] = 'A') and
              (InputLines[row+3][col-3] = 'S');
  end;

  function CountXMAS(const InputLine: string): Integer;
  var
    p, start_p: Integer;
  begin
    Result := 0;

    start_p := 1;
    repeat
      p := Pos('XMAS', InputLine, start_p);
      if p > 0 then begin
        start_p := p + 4;
        Inc(Result);
      end;
    until p = 0;
  end;

  function CountSAMX(const InputLine: string): Integer;
  var
    p, start_p: Integer;
  begin
    Result := 0;

    start_p := 1;
    repeat
      p := Pos('SAMX', InputLine, start_p);
      if p > 0 then begin
        start_p := p + 4;
        Inc(Result);
      end;
    until p = 0;
  end;

var
  HorzXMASCount: Integer;
  VertXMASCount: Integer;
  RtDiagXMASCount: Integer;
  LfDiagXMASCount: Integer;

  VertLines: TArray<string>;   // strings built up of characters in a vertial line through the grid
  RtDiagLines: TArray<string>; // strings built up of characters in a diagonal line down to the right
  LfDiagLines: TArray<string>; // strings built up of characters in a diagonal line down to the left
begin
  HorzXMASCount := 0;
  VertXMASCount := 0;
  RtDiagXMASCount := 0;
  LfDiagXMASCount := 0;

  Writeln(Format('The Input file has %d rows, each of which is %d characters long.', [Length(InputLines), Length(InputLines[0])]));

  // This problem is attempted using two very different methods:
  // 1. The first method looks at each character in the original array of strings and then compares the surrounding
  // characters to see if they form "XMAS" in any direction. This is the most popular approach seen in posted answers.
  for var row := 0 to Length(InputLines) - 1 do
    for var col := 1 to Length(InputLines[0]) do
      // if the current character is X...
      if InputLines[row][col] = 'X' then begin
        // .. check the characters in all directions to see if they spell "XMAS"
        if CheckBackwardsXMAS(row, col) then
          Inc(HorzXMASCount);
        if CheckUpLeftXMAS(row, col) then
          Inc(LfDiagXMASCount);
        if CheckUpVertXMAS(row, col) then
          Inc(VertXMASCount);
        if CheckUpRightXMAS(row, col) then
          Inc(RtDiagXMASCount);
        if CheckRightXMAS(row, col) then
          Inc(HorzXMASCount);
        if CheckDownRightXMAS(row, col) then
          Inc(LfDiagXMASCount);
        if CheckDownVertXMAS(row, col) then
          Inc(VertXMASCount);
        if CheckDownLeftXMAS(row, col) then
          Inc(RtDiagXMASCount);
      end;

  Writeln('METHOD ONE: search in all directions from each "X":');
  Writeln(Format('Found %d cases of XMAS in horizontal lines,' + sLineBreak +
                 '      %d cases of XMAS in vertial lines,' + sLineBreak +
                 '      %d cases of XMAS in right-diagonals,' + sLineBreak +
                 '      %d cases of XMAS in left-diagonal lines' + sLineBreak +
                 '  for a total of %d cases of XMAS! (correct for small 10x10 grid)',
                  [HorzXMASCount, VertXMASCount, RtDiagXMASCount, LfDiagXMASCount,
                   HorzXMASCount + VertXMASCount + RtDiagXMASCount + LfDiagXMASCount]));


  // Here's my original method, creating strings of all the vertical and diagonal lines,
  // then using standard search through all these extracted strings to find "XMAS"
  HorzXMASCount := 0;
  VertXMASCount := 0;
  RtDiagXMASCount := 0;
  LfDiagXMASCount := 0;

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
      VertLines[col-1] := VertLines[col-1] + InputLines[row][col];

  // now that all the vertical and diagonal lines have been extracted, it's simple to find XMAS in them...

  // search horizontal lines
  for var row := 0 to Length(InputLines) - 1 do
    HorzXMASCount := HorzXMASCount + CountXMAS(InputLines[row]) + CountSAMX(InputLines[row]);

  // search vertical lines
  for var i := 0 to Length(VertLines) - 1 do
    VertXMASCount := VertXMASCount + CountXMAS(VertLines[i]) + CountSAMX(VertLines[i]);

  // search downward-right diagonal lines
  for var i := 0 to Length(RtDiagLines) - 1 do
    RtDiagXMASCount := RtDiagXMASCount + CountXMAS(RtDiagLines[i]) + CountSAMX(RtDiagLines[i]);

  // search downward-left diagonal lines
  for var i := 0 to Length(LfDiagLines) - 1 do
    LfDiagXMASCount := LfDiagXMASCount + CountXMAS(LfDiagLines[i]) + CountSAMX(LfDiagLines[i]);

  Writeln('METHOD TWO: extract vertical and diagonal lines and then simply search through them all:');
  Writeln(Format('Found %d cases of XMAS in horizontal lines,' + sLineBreak +
                 '      %d cases of XMAS in vertial lines,' + sLineBreak +
                 '      %d cases of XMAS in right-diagonals,' + sLineBreak +
                 '      %d cases of XMAS in left-diagonal lines' + sLineBreak +
                 '  for a total of %d cases of XMAS!',
                  [HorzXMASCount, VertXMASCount, RtDiagXMASCount, LfDiagXMASCount,
                   HorzXMASCount + VertXMASCount + RtDiagXMASCount + LfDiagXMASCount]));

  (* NOTE: The only way this got the right answer was to add a layer of characters (e.g. "Q") around the
   * entire input, a new row at the top and bottom, and an additional letter at the start and end of each
   * row. This is the only way both answers agree and I finally got a right answer. After trying the original
   * input, I discovered Method Two got the right answer--method one was quite short!
   * This means my algorithms are off by one (or more) somewhere in Method One.  :-(
   * However, I've spent a LOT of time on this puzzle; I'm not going to attempt part 2 or to fix this one.
   *)
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
