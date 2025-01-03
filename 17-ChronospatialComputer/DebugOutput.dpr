program DebugOutput;
(* as: DebugOutput.exe, a Windows console app
 * in: Delphi 12.2
 * on: December, 2024
 * by: David Cornelius
 * to: Solve Day 17a of Advent of Code, 2024 (https://adventofcode.com/2024/day/17)
 *)

{$APPTYPE CONSOLE}

{$R *.res}

{.$DEFINE Sample}

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Math, System.StrUtils;

function OpDivide(const RegA: Int64; const Denominator: Double): Double;
begin
  Result := Trunc(RegA / Denominator);
end;

function OpBitXor(const RegB, Operand: Int64): Int64;
begin
  Result := RegB xor Operand;
end;

function OpMod8(const Operand: Int64): Int64;
begin
  Result := Operand mod 8;
end;

procedure OpJnz(const RegA, Operand: Integer; var InstPtr: Integer);
begin
  if RegA > 0 then
    InstPtr := Operand;
end;

procedure GenerateAnswer(const InputLines: TArray<string>);
var
  RegA, RegB, RegC: Int64;
  Instructions: TStringList;
  InstPtr: Integer;
  OpCode: Char;

  function Combo(const Operand: Integer): Int64;
  begin
    case Operand of
      0..3: Result := Operand;
      4: Result := RegA;
      5: Result := RegB;
      6: Result := RegC;
    else
      raise ERangeError.Create(Format('Combo operand %d is undefined', [Operand]));
    end;
  end;

  procedure ShowRegisters;
  begin
    Writeln('Register A: ', RegA);
    Writeln('Register B: ', RegB);
    Writeln('Register C: ', RegC);
  end;

begin
  Instructions := TStringList.Create;
  try
    // read registers and instructions
    for var i := 0 to Length(InputLines) - 1 do
      if SameText(LeftStr(InputLines[i], 8), 'Register') then
        case InputLines[i][10] of
          'A': RegA := StrToInt64(Copy(InputLines[i], 12, 20));
          'B': RegB := StrToInt64(Copy(InputLines[i], 12, 20));
          'C': RegC := StrToInt64(Copy(InputLines[i], 12, 20));
        end
      else if SameText(LeftStr(InputLines[i], 8), 'Program:') then
        Instructions.CommaText := Copy(InputLines[i], 10, 300);

    var Output := TStringList.Create;
    try
      InstPtr := 0;
      while InstPtr < Instructions.Count do begin
        OpCode := Instructions[InstPtr][1];
        case OpCode of
          '0': RegA := Trunc(OpDivide(RegA, IntPower(2, Combo(StrToInt(Instructions[InstPtr+1][1])))));
          '1': RegB := OpBitXor(RegB, StrToInt(Instructions[InstPtr+1]));
          '2': RegB := OpMod8(Combo(StrToInt(Instructions[InstPtr+1][1])));
          '3': OpJnz(RegA, StrToInt(Instructions[InstPtr+1]), InstPtr);
          '4': RegB := OpBitXor(RegB, RegC);
          '5': Output.Add(IntToStr(OpMod8(Combo(StrToInt(Instructions[InstPtr+1][1])))));
          '6': RegB := Trunc(OpDivide(RegA, IntPower(2, Combo(StrToInt(Instructions[InstPtr+1][1])))));
          '7': RegC := Trunc(OpDivide(RegA, IntPower(2, Combo(StrToInt(Instructions[InstPtr+1][1])))));
        end;

        if (OpCode <> '3') or (RegA = 0) then
          Inc(InstPtr, 2);
      end;

      Writeln(Output.CommaText);
    finally
      Output.Free;
    end;

  finally
    Instructions.Free;
  end;

end;

function ParentPath: string;
begin
  // executables are created in a .\$(Platform)\$(Config) folder, so look two parents up for files
  Result := '..' + TPath.DirectorySeparatorChar + '..';
end;

begin
  Writeln('Day 17a of Advent of Code, 2024 (https://adventofcode.com/2024/day/17)');
  {$IFDEF Sample}
  GenerateAnswer(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input-sm.txt')));
  {$ELSE}
  GenerateAnswer(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input.txt')));
  {$ENDIF}
  Readln;
end.
