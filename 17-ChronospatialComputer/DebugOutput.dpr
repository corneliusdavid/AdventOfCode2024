program DebugOutput;
(* as: DebugOutput.exe, a Windows console app
 * in: Delphi 12.2
 * on: December, 2024
 * by: David Cornelius
 * to: Solve Day 17a of Advent of Code, 2024 (https://adventofcode.com/2024/day/17)
 *)

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Math, System.StrUtils;

procedure GenerateAnswer(const InputLines: TArray<string>);
begin
  var CurrLine := InputLines[0];

  Writeln(Format('No answer yet; there are %d lines in the input file.',
                 [Length(InputLines)]));
end;

function ParentPath: string;
begin
  // executables are created in a .\$(Platform)\$(Config) folder, so look two parents up for files
  Result := '..' + TPath.DirectorySeparatorChar + '..';
end;

begin
  Writeln('Day 17a of Advent of Code, 2024 (https://adventofcode.com/2024/day/17)');
  GenerateAnswer(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input.txt')));
  Readln;
end.