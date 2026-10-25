program BridgeRepair;
(* as: BridgeRepair.exe, a Windows console app
 * in: Delphi 12.2
 * on: December, 2024
 * by: David Cornelius
 * to: Solve Day 7a of Advent of Code, 2024 (https://adventofcode.com/2024/day/7)
 *)

{$APPTYPE CONSOLE}
{$DEFINE Sample}
{$DEFINE SHOWWORK}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.Math,
  System.StrUtils,
  System.Console,
  RegularExpressions,
  uAoCCommon in '..\uAoCCommon.pas';

procedure GenerateAnswer(const InputLines: TArray<string>);

  function StrsToNums(const NumStr: string): TArray<Int64>;
  var
    NumList: TStringList;
  begin
    NumList := TStringList.Create;
    try
      NumList.CommaText := NumStr;
      SetLength(Result, NumList.Count);
      for var n := 0 to NumList.Count - 1 do
        Result[n] := NumList[n].ToInt64;
    finally
      NumList.Free;
    end;
  end;

  function CheckForGoodEq(const NumList: TArray<Int64>; const CheckAnswer: Int64): string;
  var
    TestAnswer: Int64;
  begin
    Result := EmptyStr;

    // number of permutations rises exponentially based on how many numbers we have
    var TotalPerms := Round(IntPower(2, Length(NumList)-1));

    for var perm := 0 to TotalPerms-1 do begin
      // initialize check answer for this permutation of operators
      TestAnswer := NumList[0];
      var GoodEq := CheckAnswer.ToString + ' = ' + TestAnswer.ToString;

      // the binary bits of the current permutation (perm) will determine what operators are used
      var bitperm := perm;
      for var bit := 1 to Length(NumList) - 1 do begin
        if Odd(bitperm) then begin
          TestAnswer := TestAnswer * NumList[bit];
          GoodEq := GoodEq + ' * ' + NumList[bit].ToString;
        end else begin
          TestAnswer := TEstAnswer + NumList[bit];
          GoodEq := GoodEq + ' + ' + NumList[bit].ToString;
        end;
        bitperm := bitperm shr 1;
      end;

      if TestAnswer = CheckAnswer then begin
        Result := GoodEq;
        Break;
      end;
    end;
  end;

var
  EqAns: Int64;
  Numbers: TArray<Int64>;
  EquationsCorrect: Integer;
  AllEquationsCorrect: Integer;
  TotalEqAnswers: Int64;
  TotalAllEqAnswers: Int64;
begin
  EquationsCorrect := 0;
  AllEquationsCorrect := 0;
  TotalEqAnswers := 0;
  TotalAllEqAnswers := 0;

  // process each line
  for var row := 0 to Length(InputLines) - 1 do begin
    var CurrLine := Trim(InputLines[row]);
    if not CurrLine.IsEmpty then begin
      var CPos := Pos(':', CurrLine);
      if CPos > 0 then begin
        // save the equation answer
        EqAns := StrToInt64(LeftStr(CurrLine, CPos - 1));
        CurrLine := Trim(Copy(CurrLine, CPos + 1, CurrLine.Length));
        // parse the rest of the line into a number array
        Numbers := StrsToNums(CurrLine);

        var GoodEq := CheckForGoodEq(Numbers, EqAns);
        if GoodEq.IsEmpty then begin
          // try various permutatsions of concatenation
          {$IFDEF SHOWWORK}
          Writeln('it wasn''t a good equation--try combining digits');
          {$ENDIF}
        end else begin
          Inc(EquationsCorrect);
          TotalEqAnswers := TotalEqAnswers + EqAns;
          {$IFDEF SHOWWORK}
          Writeln('Good equation: ' + GoodEq);
          {$ENDIF}
        end;
      end;
    end;
  end;

  Console.WriteLine(Format('There are %d equations in the input file,', [Length(InputLines)]));
  AoCSolution('Part 1 - using only + and *,', Format('%d can be true for a sum total of %d.',
               [EquationsCorrect, TotalEqAnswers]));
  AoCSolution('Part 2 - using + and * and ||,', Format('%d can be true for a sum total of %d.',
               [AllEquationsCorrect, TotalAllEqAnswers]));
end;

function ParentPath: string;
begin
  // executables are created in a .\$(Platform)\$(Config) folder, so look two parents up for files
  Result := '..' + TPath.DirectorySeparatorChar + '..';
end;

begin
  AoCHeader('7', 'adventofcode.com/2024/day/7');

  {$IFDEF Sample}
  GenerateAnswer(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input-sm.txt')));
  {$ELSE}
  GenerateAnswer(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input.txt')));
  {$ENDIF}

  {$IFDEF DEBUG}
  Console.ReadLine;
  {$ENDIF}
end.
