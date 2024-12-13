program Similarity;
(* as: Similarity.exe, a Windows console app
 * in: Delphi 12.2
 * on: December, 2024
 * by: David Cornelius
 * to: Solve Day 1b of Advent of Code, 2024 (https://adventofcode.com/2024/day/1)
 *)

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Generics.Collections;

procedure GenerateAnswer(const InputLines: TArray<string>);
var
  LeftLoc, RightLoc, SimScore: Integer;
  LeftLocs, RightLocs: TList<Integer>;
begin
  SimScore := 0;

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

    // sort and calculate similarity
    LeftLocs.Sort;
    RightLocs.Sort;
    for var i := 0 to LeftLocs.Count - 1 do begin
      LeftLoc := LeftLocs.Items[i];
      var SameLocCount := 0;
      // find same location in right list
      for var j := 0 to RightLocs.Count - 1 do
        if RightLocs.Items[j] = LeftLoc then
          Inc(SameLocCount);
      Inc(SimScore, LeftLoc * SameLocCount);

      Writeln(Format('Right list [%d] found %d times in left list', [RightLocs.Items[i], SameLocCount]));
    end;
  finally
    LeftLocs.Free;
    RightLocs.Free;
  end;

  Writeln('Similarity Score: ', SimScore);
end;

function ParentPath: string;
begin
  // executables are created in a .\$(Platform)\$(Config) folder, so look two parents up for files
  Result := '..' + TPath.DirectorySeparatorChar + '..';
end;

begin
  Writeln('Day 1b of Advent of Code, 2024 (https://adventofcode.com/2024/day/1)');
  GenerateAnswer(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input.txt')));
  Readln;
end.
