program PrintQueue;
(* as: PrintQueue.exe, a Windows console app
 * in: Delphi 12.2
 * on: December, 2024
 * by: David Cornelius
 * to: Solve Day 5a of Advent of Code, 2024 (https://adventofcode.com/2024/day/5)
 *)

{$APPTYPE CONSOLE}
{.$DEFINE Sample}
{.$DEFINE ShowWork}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.Math,
  System.StrUtils,
  System.Generics.Collections,
  System.Console,
  uAoCCommon in '..\uAoCCommon.pas';

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

  procedure FixCurrPageQueue(var PageQ: TArray<Integer>; const PageOrderRules: TList<TPageOrderRule>);
  var
    PassedAllRules: Boolean;
  begin
    PassedAllRules := False;
    while not PassedAllRules do begin
      var Swapped := False;

      for var r := 0 to PageOrderRules.Count - 1 do begin
        var RuleBefore := PageOrderRules[r].BeforePage;
        var RuleAfter := PageOrderRules[r].AfterPage;

        var RuleBeforePos := -1;
        var RuleAfterPos := -1;
        for var p := 0 to Length(PageQ) - 1 do begin
          if PageQ[p] = RuleBefore then
            RuleBeforePos := p;
          if PageQ[p] = RuleAfter then
            RuleAfterPos := p;
        end;

        // if both numbers are in the rule but in the wrong order, swap them
        if (RuleBeforePos > -1) and (RuleAfterPos > -1) and
           (RuleBeforePos > RuleAfterPos) then begin
          var tmp := PageQ[RuleBeforePos];
          PageQ[RuleBeforePos] := PageQ[RuleAfterPos];
          PageQ[RuleAfterPos] := tmp;

          // now that we've swapped, we have to check everything again
          Swapped := True;
          Break;
        end;
      end;

      // if we made it through all the rules without swapping anything, we're good!
      if not Swapped then
        PassedAllRules := True;
    end;
  end;

  function PageQToStr(const PageQ: TArray<Integer>): string;
  begin
    Result := EmptyStr;
    for var i := 0 to Length(PageQ) - 1 do
      Result := Result + PageQ[i].ToString + ', ';

    Result := LeftStr(Result, Length(Result) - 2);
  end;

var
  PageOrderRules: TList<TPageOrderRule>;
  TotalPrintQueues: Integer;
  PrintQueuesReady: Integer;
  PrintQueuesFixed: Integer;
  CurrPageQueue: TArray<Integer>;
  CorrectMiddleTotal: Integer;
  FixedMiddleTotal: Integer;
  QPassed: Boolean;
begin
  PageOrderRules := TList<TPageOrderRule>.Create;
  TotalPrintQueues := 0;
  PrintQueuesReady := 0;
  PrintQueuesFixed := 0;
  CorrectMiddleTotal := 0;
  FixedMiddleTotal := 0;

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
          {$IFDEF SHOWWORK}
          Writeln(Format('Good print queue: %s (%d)', [CurrLine, MiddlePage(CurrPageQueue)]));
          {$ENDIF}
          CorrectMiddleTotal := CorrectMiddleTotal + MiddlePage(CurrPageQueue);
        end

        // if this row's updates are NOT in the right order, fix it
        else begin
          Inc(PrintQueuesFixed);
          FixCurrPageQueue(CurrPageQueue, PageOrderRules);
          {$IFDEF SHOWWORK}
          Writeln(Format('Fixed print queue: %s (%d)', [PageQToStr(CurrPageQueue), MiddlePage(CurrPageQueue)]));
          {$ENDIF}
          FixedMiddleTotal := FixedMiddleTotal + MiddlePage(CurrPageQueue);
        end;
      end;
    end;

    Console.WriteLine(Format('There are %d rules and %d print queues ready (out of %d total queues);',
                             [PageOrderRules.Count, PrintQueuesReady, TotalPrintQueues]));
    AoCSolution('Part 1 - The total of the correct middle pages is ', CorrectMiddleTotal.ToString);
    AoCSolution('Part 2 - The total of the fixed middle pages is ', FixedMiddleTotal.ToString);
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
  AoCHeader('5', 'adventofcode.com/2024/day/5');

  {$IFDEF SAMPLE}
  GenerateAnswer(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input-sm.txt')));
  {$ELSE}
  GenerateAnswer(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input.txt')));
  {$ENDIF}

  {$IFDEF DEBUG}
  Console.ReadLine;
  {$ENDIF}
end.
