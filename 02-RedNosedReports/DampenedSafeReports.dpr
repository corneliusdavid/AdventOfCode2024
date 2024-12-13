program DampenedSafeReports;
(* as: DampenedSafeReports.exe
 * in: Delphi 12.2
 * on: December, 2024
 * by: David Cornelius
 * to: Solve Day 2b of Advent of Code, 2024 (https://adventofcode.com/2024/day/2)
 *)

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Math, System.StrUtils, System.Generics.Collections;

procedure GenerateAnswer(const InputLines: TArray<string>);
const
  IncreaseDecreaseStr: array[Boolean] of string = ('Decreasing', 'Increasing');
type
  // use floating-point type instead of integer to use the Mean() function
  TRepArray = array of Single;
var
  SafeReportCount: Integer;
  ReportNums: TList<Integer>;
  ReportLine: TStringList;
  ReportArray: TRepArray;
  GoodRepLine: Boolean;
  Increasing: Boolean;
  RepSkipped: Boolean;
  RepNum: Integer;
begin
  SafeReportCount := 0;

  ReportLine := TStringList.Create;
  try
    ReportNums := TList<Integer>.Create;
    try
      // analyze reports, one line at a time
      for var i := 0 to Length(InputLines) - 1 do begin
        ReportLine.CommaText := InputLines[i];
        SetLength(ReportArray, ReportLine.Count);

        // store report numbers for this line in a list
        ReportNums.Clear;
        for var j := 0 to ReportLine.Count - 1 do
          if TryStrToInt(ReportLine[j], RepNum) then begin
            ReportNums.Add(RepNum);
            ReportArray[j] := RepNum;
          end;

        GoodRepLine := False;
        if ReportNums.Count <= 1 then
          // only one report number--skip this line
          Break;

        // assume reports will increase
        Increasing := True;
        // initally, no reports skipped
        RepSkipped := False;

        for var PassCount := 1 to 2 do begin
          // analyze report line
          for var j := 0 to ReportNums.Count - 1 do begin
            // check the first number aginst the average to determine whether
            // the list should be increasing or decreasing
            if j = 0 then begin
              if ReportNums.Items[j] > Mean(ReportArray) then
                Increasing := False;

              // now, check the rest of the line
              Continue;
            end;

            // assume we're going to have a good report line
            GoodRepLine := True;

            // check distance from previous report and ensure it's in the right direction
            // we're always at least on the 2nd digit or higher
            var RepDiff := ReportNums.Items[j] - ReportNums[j-1];
            if ReportNums.Items[0] = 21 then
              goodrepline := True;
            if (((RepDiff > 0) and Increasing) or ((RepDiff < 0) and (not Increasing))) and
               (Abs(RepDiff) <= 3) then
              // so far, good reports
              Continue
            else begin
              GoodRepLine := False;
              // rules broken--is this the first one for this line?
              if PassCount = 1 then
                // first offense, delete this report
                RepSkipped := True;
                ReportNums.Delete(j);
              Break;
            end;
          end;

          // if we got a good set of reports during the first pass, we're done
          if GoodRepLine then
            Break;
        end;

        // the line passed!
        if GoodRepLine then begin
          Writeln('Good Report: ', ReportLine.CommaText,
                  ' (', IncreaseDecreaseStr[Increasing], ')',
                  IfThen(RepSkipped, ' -one skipped', ''));
          Inc(SafeReportCount);
        end else
          Writeln('Bad Report: ', ReportLine.CommaText);
      end;

      Writeln(Format('Safe Reports: %d out of %d total reports.', [SafeReportCount, Length(InputLines)]));
      Writeln('========= Number too low!!!  no star :-(');
    finally
      ReportNums.Free;
    end;
  finally
    ReportLine.Free;
  end;
end;

function ParentPath: string;
begin
  // executables are created in a .\$(Platform)\$(Config) folder, so look two parents up for files
  Result := '..' + TPath.DirectorySeparatorChar + '..';
end;

begin
  Writeln('Day 2b of Advent of Code, 2024 (https://adventofcode.com/2024/day/2)');
  GenerateAnswer(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input.txt')));
  Readln;
end.
