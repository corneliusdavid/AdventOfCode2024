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
  System.SysUtils, System.Classes, System.IOUtils, System.Math, System.StrUtils;

procedure GenerateAnswer(const InputLines: TArray<string>);
const
  MAX_BLINKS = 25;  // Part 1
  //MAX_BLINKS = 75; // Part 2
var
  OrigStones: TStringList;
  NewStones: TStringList;
begin
  OrigStones := TStringList.Create;
  NewStones := TStringList.Create;
  try
    OrigStones.CommaText := InputLines[0];

    for var BlinkCount := 1 to MAX_BLINKS do begin
      NewStones.Clear;

      // use rules to create new list of stones
      for var i := 0 to OrigStones.Count - 1 do begin
        // rule 1 - is it zero?
        if OrigStones[i] = '0' then
          NewStones.Add('1')
        else begin
          // rule 2 - is the length even?
          var StoneLen := OrigStones[i].Length;
          if not Odd(StoneLen) then begin
            NewStones.Add(LeftStr(OrigStones[i], StoneLen div 2));
            NewStones.Add(RightStr(OrigStones[i], StoneLen div 2));
          end else begin
            // rule three - multiply by 2024
            var StoneVal := StrToInt64(OrigStones[i]) * 2024;
            NewStones.Add(UIntToStr(StoneVal));
          end;
        end;
      end;

      // now, the new stone list gets moved to the "orig stones" list
      OrigStones.Clear;
      for var i := 0 to NewStones.Count - 1 do
        OrigStones.Add(IntToStr(StrToInt64(NewStones[i])));

      if BlinkCount < 10 then begin
        // write out what we have so far
        for var i := 0 to OrigStones.Count - 1 do
          Write(OrigStones[i], ' ');
        Writeln;
      end;
    end;

    Writeln(Format('After blinking %d times, there are %d stones.',
                   [MAX_BLINKS, OrigStones.Count]));
  finally
    NewStones.Free;
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
