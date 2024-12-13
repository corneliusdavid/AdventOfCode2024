program PrintQueue;
(* as: PrintQueue.exe, a Windows console app
 * in: Delphi 12.2
 * on: December, 2024
 * by: David Cornelius
 * to: Solve Day 5a of Advent of Code, 2024 (https://adventofcode.com/2024/day/5)
 *)

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Math, System.StrUtils, System.Generics.Collections;

procedure GenerateAnswer(const InputLines: TArray<string>);
var
  PageOrderRules: TDictionary<Integer, Integer>;
  PageQueues: TArray<Integer>;
begin
  PageOrderRules := TDictionary<Integer, Integer>.Create;

  try
    // process each line
    for var i := 0 to Length(InputLines) - 1 do begin
      var CurrLine := Trim(InputLines[i]);

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

function ParentPath: string;
begin
  // executables are created in a .\$(Platform)\$(Config) folder, so look two parents up for files
  Result := '..' + TPath.DirectorySeparatorChar + '..';
end;

begin
  Writeln('Day 5a of Advent of Code, 2024 (https://adventofcode.com/2024/day/5)');
  GenerateAnswer(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input.txt')));
  Readln;
end.
