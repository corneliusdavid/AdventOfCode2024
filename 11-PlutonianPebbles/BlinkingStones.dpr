program BlinkingStones;
(* as: BlinkingStones.exe, a Windows console app
 * in: Delphi 12.2
 * on: December, 2024
 * by: David Cornelius
 * to: Solve Day 11a of Advent of Code, 2024 (https://adventofcode.com/2024/day/11)
 *)

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Math, System.StrUtils, System.Threading;

procedure GenerateAnswer(const InputLines: TArray<string>);

  function StoneCount(const Iteration: Integer; const Number: UInt64): UInt64;
  begin
    if Iteration = 0 then
      Result := 1
    else
      if Number = 0 then
        Result := StoneCount(Iteration - 1, 1)
      else begin
        var NumLen := Number.ToString.Length;
        if not Odd(NumLen) then
          Result := StoneCount(Iteration - 1, StrToUInt64(LeftStr(Number.ToString, NumLen div 2))) +
                    StoneCount(Iteration - 1, StrToUInt64(RightStr(Number.ToString, NumLen div 2)))
        else
          Result := StoneCount(Iteration - 1, Number * 2024);
      end;
  end;

const
  //MAX_BLINKS = 25;  // Part 1
  //MAX_BLINKS = 50;   // just a test
  MAX_BLINKS = 75; // Part 2
var
  OrigStones: TStringList;
  TotalStoneCount: UInt64;
begin
  TotalStoneCount := 0;
  OrigStones := TStringList.Create;
  try
    OrigStones.CommaText := InputLines[0];

    for var i := 0 to OrigStones.Count - 1 do begin
      Writeln('Processing ', OrigStones[i], ' ... ');
      TotalStoneCount := TotalStoneCount + StoneCount(MAX_BLINKS, StrToUInt64(OrigStones[i]));
    end;

    Writeln(Format('After blinking %d times, there are %d stones.',
                   [MAX_BLINKS, TotalStoneCount]));
  finally
    OrigStones.Free;
  end;


end;

function ParentPath: string;
begin
  // executables are created in a .\$(Platform)\$(Config) folder, so look two parents up for files
  Result := '..' + TPath.DirectorySeparatorChar + '..';
end;

begin
  Writeln('Day 11a of Advent of Code, 2024 (https://adventofcode.com/2024/day/11)');
  GenerateAnswer(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input.txt')));
  Readln;
end.
