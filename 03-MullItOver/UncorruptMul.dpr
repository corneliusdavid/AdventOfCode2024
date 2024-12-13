program UncorruptMul;
(* as: UncorruptMul.exe, a Windows console app
 * in: Delphi 12.2
 * on: December, 2024
 * by: David Cornelius
 * to: Solve Day 3a of Advent of Code, 2024 (https://adventofcode.com/2024/day/3)
 *)

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes, System.IOUtils, RegularExpressions;

procedure GenerateAnswer(const InputLines: TArray<string>);
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

  for var i := 0 to Length(InputLines) - 1 do begin
    var CurrLine := InputLines[i];

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

function ParentPath: string;
begin
  // executables are created in a .\$(Platform)\$(Config) folder, so look two parents up for files
  Result := '..' + TPath.DirectorySeparatorChar + '..';
end;

begin
  Writeln('Day 3a of Advent of Code, 2024 (https://adventofcode.com/2024/day/3)');
  GenerateAnswer(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input.txt')));
  Readln;
end.
