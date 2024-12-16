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

type
  TPageOrderRule = class
  public
    BeforePage: Integer;
    AfterPage: Integer;
    constructor Create(const P1Str, P2Str: string);
  end;

{ TPageOrderRule }

constructor TPageOrderRule.Create(const P1Str, P2Str: string);
begin
  BeforePage := P1Str.ToInteger;
  AfterPage  := P2Str.ToInteger;
end;

{ main program }

procedure GenerateAnswer(const InputLines: TArray<string>);

  function MiddlePage(const PageQueue: TArray<Integer>): Integer;
  begin
    var c := Length(PageQueue) div 2;
    Result := PageQueue[c];
  end;

  procedure ReadCurrLineIntoPageQueue(const PQLine: string; var PageQ: TArray<Integer>);
  begin
    var PQStrList := TStringList.Create;
    try
      PQStrList.CommaText := PQLine;
      SetLength(PageQ, PQStrList.Count);
      for var p := 0 to PQStrList.Count - 1 do
        PageQ[p] := PQStrList[p].ToInteger;
    finally
      PQStrList.Free;
    end;
  end;

  function PagesOutOfOrder(const PageQ: TArray<Integer>;
                           const FirstPage, SecondPage: Integer): Boolean;
  begin
    Result := False;
    var HasFirst := -1;
    var HasSecond := -1;

    for var p := 0 to Length(PageQ) - 1 do begin
      if PageQ[p] = FirstPage then
        HasFirst := p
      else if PageQ[p] = SecondPage then
        HasSecond := p;
    end;

    if (HasFirst >= 0) and (HasSecond >= 0) and (HasFirst > HasSecond) then
      Result := True;
  end;

var
  PageOrderRules: TList<TPageOrderRule>;
  TotalPrintQueues: Integer;
  PrintQueuesReady: Integer;
  CurrPageQueue: TArray<Integer>;
  MiddleTotal: Integer;
  QPassed: Boolean;
begin
  PageOrderRules := TList<TPageOrderRule>.Create;
  TotalPrintQueues := 0;
  PrintQueuesReady := 0;
  MiddleTotal := 0;

  try
    // process each line in the input
    for var i := 0 to Length(InputLines) - 1 do begin
      var CurrLine := Trim(InputLines[i]);

      if Pos('|', CurrLine) > 0 then
        // read rules
        PageOrderRules.Add(TPageOrderRule.Create(LeftStr(CurrLine, 2),
                                                 RightStr(CurrLine, 2)))
      else if not CurrLine.IsEmpty then begin
        // all the rules are in the first section of the input;
        // so, by the time we get here, all the rules have been read in.

        ReadCurrLineIntoPageQueue(CurrLine, CurrPageQueue);
        Inc(TotalPrintQueues);
        QPassed := True;
        for var r := 0 to PageOrderRules.Count - 1 do begin
          // for each print queue, go through each rule: any pages out of order?
          if PagesOutOfOrder(CurrPageQueue, PageOrderRules[r].BeforePage,
                                            PageOrderRules[r].AfterPage) then begin
            QPassed := False;
            Break;
          end;
        end;

        // if no rules were broken, we found a good printer queue
        if QPassed then begin
          Inc(PrintQueuesReady);
          Writeln(Format('Good print queue: %s (%d)', [CurrLine, MiddlePage(CurrPageQueue)]));
          MiddleTotal := MiddleTotal + MiddlePage(CurrPageQueue);
        end;
      end;
    end;

    { 6236 is too high }
    Writeln(Format('There are %d rules and %d print queues ready (out of %d total queues); ' + sLineBreak +
                   'the total of the middle pages is %d.',
                   [PageOrderRules.Count, PrintQueuesReady, TotalPrintQueues, MiddleTotal]));
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
