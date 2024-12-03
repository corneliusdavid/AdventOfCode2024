program SafeReports;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Generics.Collections;

var
  Done: Boolean;

function ParentPath: string;
begin
  // executables are created in a .\$(Platform)\$(Config) folder, so look two parents up for files
  Result := '..' + TPath.DirectorySeparatorChar + '..';
end;

procedure ShowAbout;
begin
  var AboutText := TFile.ReadAllLines(TPath.Combine(ParentPath, ChangeFileExt(ExtractFileName(ParamStr(0)), '.txt')));
  for var i := 0 to Length(AboutText) - 1 do
    Writeln(AboutText[i]);
end;

function MenuPrompt: Char;
var
  Cmd: string;
begin
  Result := ' ';

  Writeln;
  Writeln('Advent of Code 2024 - Day 02: Red-Nosed Reports');
  Writeln;
  Writeln(' ? - Information About this Puzzle');
  Writeln(' A - Generate the Answer for this Puzzle');
  Writeln(' X - Exit this program');
  Writeln;
  Write  ('> ');

  Readln(cmd);
  cmd := UpperCase(Trim(cmd));
  if cmd.IsEmpty then
    Writeln('Please enter a command.')
  else if cmd.Length > 1 then
    Writeln('Please only enter one character.')
  else if not CharInSet(cmd[1], ['?','A','X']) then
    Writeln('Please enter one of the valid characters.')
  else
    Result := cmd[1];
end;

procedure GenerateAnswer;
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
      // read and analyze all reports, one line at a time
      var InputFile := TFile.ReadAllLines(TPath.Combine(ParentPath, 'input.txt'));
      for var i := 0 to Length(InputFile) - 1 do begin
        ReportLine.CommaText := InputFile[i];

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

      Writeln(Format('Safe Reports: %d out of %d total reports.', [SafeReportCount, Length(InputFile)]));
    finally
      ReportNums.Free;
    end;
  finally
    ReportLine.Free;
  end;
end;

procedure MenuAction(const Cmd: Char);
begin
  case Cmd of
    '?': ShowAbout;
    'A': GenerateAnswer;
    'X': Done := True;
  end;
end;

begin
  try
    Done := False;
    repeat
      MenuAction(MenuPrompt);
    until Done;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
