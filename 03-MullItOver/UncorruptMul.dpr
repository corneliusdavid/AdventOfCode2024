program UncorruptMul;
(* as: UncorruptMul.exe, a Windows console app
 * in: Delphi 12.2
 * on: December, 2024
 * by: David Cornelius
 * to: Solve Day 3 of Advent of Code, 2024 (https://adventofcode.com/2024/day/3)
 *)

{$APPTYPE CONSOLE}
{.$DEFINE Sample}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  RegularExpressions,
  uAoCCommon in '..\uAoCCommon.pas';

procedure GenerateAnswer(const InputLines: TArray<string>; const DoPart2: Boolean = False);
const
  MulPattern = 'mul\([0-9]+\,[0-9]+\)';
  DoDontMulPattern = '(do\(\))|(don\''t\(\))|(mul\([0-9]+\,[0-9]+\))';
  DoInstruction = 'do()';
  DontInstruction = 'don''t()';
var
  MulCount: Integer;
  MulTotal: Longint;
  RegEx: TRegEx;
  DoMul: Boolean;
  Num1: Integer;
  Num2: Integer;
begin
  MulCount := 0;
  MulTotal := 0;
  DoMul := True;

  if DoPart2 then
    RegEx := TRegEx.Create(DoDontMulPattern)
  else
    RegEx := TRegEx.Create(MulPattern);

  // process each line
  for var i := 0 to Length(InputLines) - 1 do begin
    var CurrLine := InputLines[i];

    var p := RegEx.Match(CurrLine);
    while p.Success do begin
      // do/don't instructions will only match if RegEx initialized in DoPart2 above
      if p.Value = DoInstruction then
        DoMul := True
      else if p.Value = DontInstruction then
        DoMul := False
      else begin
        // this will always be true for Part 1
        if DoMul then begin
          var p1 := TRegEx.Match(p.Value, '[0-9]+').Value;
          var p2 := TRegEx.Match(Copy(p.Value, Pos(',', p.Value) + 1), '[0-9]+').Value;

          if TryStrToInt(p1, Num1) and
             TryStrToInt(p2, Num2) then begin
            Inc(MulCount);
            var TempTotal := Num1 * Num2;
            {$IFDEF DEBUG}
            Writeln(Format('found: %s: %d * %d = %d', [p.Value, Num1, Num2, TempTotal]));
            {$ENDIF}
            Inc(MulTotal, TempTotal);
          end;
        end;
      end;

      p := p.NextMatch;
    end;
  end;

  if DoPart2 then
    AoCSolution('Part 2 - Found Mul Matches:', Format('%d for a grand total of %d', [MulCount, MulTotal]))
  else
    AoCSolution('Part 1 - Found Mul Matches:[', Format('%d for a grand total of %d', [MulCount, MulTotal]));
end;

function ParentPath: string;
begin
  // executables are created in a .\$(Platform)\$(Config) folder, so look two parents up for files
  Result := '..' + TPath.DirectorySeparatorChar + '..';
end;

begin
  AoCHeader('3', 'adventofcode.com/2024/day/3');

  {$IFDEF Sample}
  GenerateAnswer(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input-sm.txt')), False);
  GenerateAnswer(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input-sm.txt')), True);
  {$ELSE}
  GenerateAnswer(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input.txt')), False);
  GenerateAnswer(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input.txt')), True);
  {$ENDIF}
  {$IFDEF DEBUG}
  Readln;
  {$ENDIF}
end.
