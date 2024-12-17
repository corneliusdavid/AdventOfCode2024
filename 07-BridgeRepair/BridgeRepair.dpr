program BridgeRepair;
(* as: BridgeRepair.exe, a Windows console app
 * in: Delphi 12.2
 * on: December, 2024
 * by: David Cornelius
 * to: Solve Day 7a of Advent of Code, 2024 (https://adventofcode.com/2024/day/7)
 *)

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Math, System.StrUtils, RegularExpressions;

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

var
  EqAns: Int64;
  CheckAnswer: Int64;
  Numbers: TArray<Int64>;
  EquationsCorrect: Integer;
  TotalEqAnswers: Int64;
begin
  EquationsCorrect := 0;
  TotalEqAnswers := 0;

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

        // number of permutations rises exponentially based on how many numbers we have
        var TotalPerms := Round(IntPower(2, Length(Numbers)-1));

        for var perm := 0 to TotalPerms-1 do begin
          // initialize check answer for this permutation of operators
          CheckAnswer := Numbers[0];
          var GoodEq := EqAns.ToString + ' = ' + CheckAnswer.ToString;

          // the binary bits of the current permutation (perm) will determine what operators are used
          var bitperm := perm;
          for var bit := 1 to Length(Numbers) - 1 do begin
            if Odd(bitperm) then begin
              CheckAnswer := CheckAnswer * Numbers[bit];
              GoodEq := GoodEq + ' * ' + Numbers[bit].ToString;
            end else begin
              CheckAnswer := CheckAnswer + Numbers[bit];
              GoodEq := GoodEq + ' + ' + Numbers[bit].ToString;
            end;
            bitperm := bitperm shr 1;
          end;

          if CheckAnswer = EqAns then begin
            Inc(EquationsCorrect);
            TotalEqAnswers := TotalEqAnswers + EqAns;
            Writeln('Good equation: ' + GoodEq);
            Break;
          end;
        end;
      end;
    end;
  end;

  Writeln(Format('There are %d equations in the input file, %d can be true for a sum total of %d.',
                  [Length(InputLines), EquationsCorrect, TotalEqAnswers]));
end;

function ParentPath: string;
begin
  // executables are created in a .\$(Platform)\$(Config) folder, so look two parents up for files
  Result := '..' + TPath.DirectorySeparatorChar + '..';
end;

begin
  Writeln('Day 7a of Advent of Code, 2024 (https://adventofcode.com/2024/day/7)');
  GenerateAnswer(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input.txt')));
  Readln;
end.
