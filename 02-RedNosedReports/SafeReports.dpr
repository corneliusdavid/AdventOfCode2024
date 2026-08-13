program SafeReports;
(* as: SafeReports.exe, a Windows console app
 * in: Delphi 12.2
 * on: December, 2024
 * by: David Cornelius
 * to: Solve Day 2 of Advent of Code, 2024 (https://adventofcode.com/2024/day/2)
 *)

{$APPTYPE CONSOLE}
{.$DEFINE Sample}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.Generics.Collections,
  uAoCCommon in '..\uAoCCommon.pas';

type
  TIntArray = TArray<Integer>;

function StrListToNumArray(const NumList: string): TIntArray;
var
  ReportStrNums: TStringList;
begin
  ReportStrNums := TStringList.Create;
  try
    ReportStrNums.CommaText := NumList;

    SetLength(Result, ReportStrNums.Count);
    for var i := 0 to ReportStrNums.Count - 1 do
      Result[i] := ReportStrNums[i].ToInteger;
  finally
    ReportStrNums.Free;
  end;
end;

function CheckReportLine(const NumArray: TIntArray): Boolean;
begin
  // initially, assume the worst
  Result := False;

  if Length(NumArray) > 1 then begin
    // assume reports will increase
    var Increasing := True;

    // analyze report line
    for var j := 0 to Length(NumArray) - 1 do begin
      // check the first two number to determine whether the list should be increasing or decreasing
      if j = 0 then
        if NumArray[j] = NumArray[j+1] then
          // two reports cannot be the same--skip this line
          Break
        else begin
          if NumArray[j+1] < NumArray[j] then
            // decreasing reports for this line
            Increasing := False;

          // ok--established increasing/decreasing, now check the rest of the reports in this line
          Continue;
        end;

      // now, we're more optimistic
      Result := True;

      // check distance from previous report and ensure it's in the right direction
      // we're always at least on the 2nd digit or higher
      var RepDiff := NumArray[j] - NumArray[j-1];
      if (((RepDiff > 0) and Increasing) or ((RepDiff < 0) and (not Increasing))) and
         (Abs(RepDiff) <= 3) then
        // so far, good reports
        Continue
      else begin
        // rules broken--bad report sequence: skip this line
        Result := False;
        Break;
      end;
    end;
  end;
end;

function RemoveOneElement(const NumArray: TIntArray; const WhichElem: Integer): TIntArray;
begin
  SetLength(Result, Length(NumArray) - 1);

  for var i := 0 to Length(NumArray) - 1 do
    if i < WhichElem then
      Result[i] := NumArray[i]
    else if (i >= WhichElem) and (i < Length(NumArray) - 1) then
      Result[i] := NumArray[i+1];
end;

function ArrayNumToStr(const NumArray: TIntArray): string;
begin
  Result := EmptyStr;
  for var i := 0 to Length(NumArray) - 1 do
    Result := Result + NumArray[i].ToString + ',';

  SetLength(Result, Length(Result)-1);
end;

procedure GenerateAnswer(const InputLines: TArray<string>);
const
  IncreaseDecreaseStr: array[Boolean] of string = ('Decreasing', 'Increasing');
var
  SafeReportCount: Integer;
  DampenedSafeCount: Integer;
  ReportNums: TArray<Integer>;
begin
  SafeReportCount := 0;
  DampenedSafeCount := 0;

  for var i := 0 to Length(InputLines) - 1 do begin
    ReportNums := StrListToNumArray(InputLines[i]);

    if CheckReportLine(ReportNums) then begin
      {$IFDEF DEBUG}
      Writeln(i, '. Good Report: ', InputLines[i]);
      {$ENDIF}
      Inc(SafeReportCount);
    end else begin
      for var j := 0 to Length(ReportNums) - 1 do begin
        var DampenedReportNums: TIntArray;
        DampenedReportNums := RemoveOneElement(ReportNums, j);
        if CheckReportLine(DampenedReportNums) then begin
          {$IFDEF DEBUG}
          Writeln(i, '. Dampened Report: ', ArrayNumToStr(DampenedReportNums));
          {$ENDIF}
          Inc(DampenedSafeCount);
          Break;
        end;
      end;
    end;
  end;

  Writeln(Format('Part 1: Safe Reports: %d out of %d total reports.',
                 [SafeReportCount, Length(InputLines)]));
  Writeln(Format('Part 2: Dampened Safe Reports: %d plus original safe = %d total safe reports.',
                 [DampenedSafeCount, DampenedSafeCount + SafeReportCount]));
end;

function ParentPath: string;
begin
  // executables are created in a .\$(Platform)\$(Config) folder, so look two parents up for files
  Result := '..' + TPath.DirectorySeparatorChar + '..';
end;

begin
  AoCHeader('2', 'adventofcode.com/2024/day/2');

  {$IFDEF Sample}
  GenerateAnswer(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input-sm.txt')));
  {$ELSE}
  GenerateAnswer(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input.txt')));
  {$ENDIF}
  {$IFDEF DEBUG}
  Readln;
  {$ENDIF}
end.
