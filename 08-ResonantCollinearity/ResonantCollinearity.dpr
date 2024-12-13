program ResonantCollinearity;
(* as: ResonantCollinearity.exe, a Windows console app
 * in: Delphi 12.2
 * on: December, 2024
 * by: David Cornelius
 * to: Solve Day 8a of Advent of Code, 2024 (https://adventofcode.com/2024/day/8)
 *)

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Math, System.StrUtils;

procedure GenerateAnswer(const InputLines: TArray<string>);
begin
  // process each line
  for var i := 0 to Length(InputLines) - 1 do begin
    var CurrLine := InputLines[i];

  end;

  Writeln(Format('No answer generated yet--but there are %d lines in the input file', [Length(InputLines)]));
end;

function ParentPath: string;
begin
  // executables are created in a .\$(Platform)\$(Config) folder, so look two parents up for files
  Result := '..' + TPath.DirectorySeparatorChar + '..';
end;

begin
  Writeln('Day 8a of Advent of Code, 2024 (https://adventofcode.com/2024/day/8)');
  GenerateAnswer(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input.txt')));
  Readln;
end.
