program ListDiff;
(* as: ListDiff.exe, a Windows console app
 * in: Delphi 12.2
 * on: December, 2024
 * by: David Cornelius
 * to: Solve Day 1a of Advent of Code, 2024 (https://adventofcode.com/2024/day/1)
 *)

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Generics.Collections;

procedure GenerateAnswer(const InputLines: TArray<string>);
var
  LeftLoc, RightLoc, DiffLocs: Integer;
  LeftLocs, RightLocs: TList<Integer>;
begin
  DiffLocs := 0;

  LeftLocs := TList<Integer>.Create;
  RightLocs := TList<Integer>.Create;
  try
    for var i := 0 to Length(InputLines) - 1 do begin
      var FirstSpace := Pos(' ', Trim(InputLines[i]));
      var LeftLocStr := Trim(Copy(Trim(InputLines[i]), 1, FirstSpace));
      var RightLocStr := Trim(Copy(Trim(InputLines[i]), FirstSpace, 100));

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

function ParentPath: string;
begin
  // executables are created in a .\$(Platform)\$(Config) folder, so look two parents up for files
  Result := '..' + TPath.DirectorySeparatorChar + '..';
end;

begin
  Writeln('Day 1a of Advent of Code, 2024 (https://adventofcode.com/2024/day/1)');
  GenerateAnswer(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input.txt')));
  Readln;
end.
