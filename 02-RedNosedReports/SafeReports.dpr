program SafeReports;
(* as: SafeReports.exe, a Windows console app
 * in: Delphi 12.2
 * on: December, 2024
 * by: David Cornelius
 * to: Solve Day 2a of Advent of Code, 2024 (https://adventofcode.com/2024/day/2)
 *)

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Generics.Collections;

procedure GenerateAnswer(const InputLines: TArray<string>);
const
  IncreaseDecreaseStr: array[Boolean] of string = ('Decreasing', 'Increasing');
var
  SafeReportCount: Integer;
  ReportNums: TList<Integer>;
  ReportLine: TStringList;
  GoodRepLine: Boolean;
  Increasing: Boolean;
  RepNum: Integer;
begin
  SafeReportCount := 0;

  ReportLine := TStringList.Create;
  try
    ReportNums := TList<Integer>.Create;
    try
      for var i := 0 to Length(InputLines) - 1 do begin
        ReportLine.CommaText := InputLines[i];

        // store report numbers for this line in a list
        ReportNums.Clear;
        for var j := 0 to ReportLine.Count - 1 do
          if TryStrToInt(ReportLine[j], RepNum) then
            ReportNums.Add(RepNum);

        GoodRepLine := False;
        if ReportNums.Count <= 1 then
          // only one report number--skip this line
          Break;

        // assume reports will increase
        Increasing := True;

        // analyze report line
        for var j := 0 to ReportNums.Count - 1 do begin
          // check the first two number to determine whether the list should be increasing or decreasing
          if j = 0 then
            if ReportNums.Items[j] = ReportNums.Items[j+1] then
              // two reports cannot be the same--skip this line
              Break
            else begin
              if ReportNums.Items[j+1] < ReportNums.Items[j] then
                // decreasing reports for this line
                Increasing := False;

              // ok--established increasing/decreasing, now check the rest of the reports in this line
              Continue;
            end;

          // assume we're going to have a good report line
          GoodRepLine := True;

          // check distance from previous report and ensure it's in the right direction
          // we're always at least on the 2nd digit or higher
          var RepDiff := ReportNums.Items[j] - ReportNums[j-1];
          if (((RepDiff > 0) and Increasing) or ((RepDiff < 0) and (not Increasing))) and
             (Abs(RepDiff) <= 3) then
            // so far, good reports
            Continue
          else begin
            // rules broken--bad report sequence: skip this line
            GoodRepLine := False;
            Break;
          end;
        end;

        // the line passed!
        if GoodRepLine then begin
          Writeln('Good Report: ', ReportLine.CommaText, ' (', IncreaseDecreaseStr[Increasing], ')');
          Inc(SafeReportCount);
        end;
      end;

      Writeln(Format('Safe Reports: %d out of %d total reports.', [SafeReportCount, Length(InputLines)]));
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
  Writeln('Day 2a of Advent of Code, 2024 (https://adventofcode.com/2024/day/2)');
  GenerateAnswer(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input.txt')));
  Readln;
end.
