program ClawMachinePrizes;
(* as: ClawMachinePrizes.exe, a Windows console app
 * in: Delphi 12.2
 * on: December, 2024
 * by: David Cornelius
 * to: Solve Day 13 of Advent of Code, 2024 (https://adventofcode.com/2024/day/13
 *)

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Math, System.StrUtils,
  RegularExpressions;

type
  TButtonMove = record
    XSteps: Integer;
    YSteps: Integer;
    constructor Create(const ButtonMoveStr: string);
  end;
  TLocation = record
    X: Integer;
    Y: Integer;
    constructor Create(const LocStr: string);
  end;
  TClawMachine = record
    ButtonA: TButtonMove;
    ButtonB: TButtonMove;
    PrizeLoc: TLocation;
  end;

var
  ClawMachines: TArray<TClawMachine>;

procedure GenerateAnswer(const InputLines: TArray<string>; const SolutionTwo: Boolean = False);
const
  BtnA_Cost = 3;
  BtnB_Cost = 1;
var
  a1, b1, c1: Double;  // Coefficients for first equation: a1x + b1y = c1
  a2, b2, c2: Double;  // Coefficients for second equation: a2x + b2y = c2
  BtnA, BtnB: Double;  // Solutions
  determinant: Double;
  WinableMachines: Integer;
  TotalBtnA, TotalBtnB: Int64;
begin
  SetLength(ClawMachines, 0);
  WinableMachines := 0;
  TotalBtnA := 0;
  TotalBtnB := 0;

  for var i := 0 to Length(InputLines) - 1 do begin
    var CurrLine := InputLines[i];
    if not CurrLine.IsEmpty then
      if SameText(LeftStr(CurrLine, 8), 'Button A') then begin
        SetLength(ClawMachines, Length(ClawMachines) + 1);
        ClawMachines[Length(ClawMachines)-1].ButtonA.Create(CurrLine);
      end else if SameText(LeftStr(CurrLine, 8), 'Button B') then
        ClawMachines[Length(ClawMachines)-1].ButtonB.Create(CurrLine)
      else if SameText(LeftStr(CurrLine, 6), 'Prize:') then
        ClawMachines[Length(ClawMachines)-1].PrizeLoc.Create(CurrLine);
  end;

  { Known Example:
    Button A: X+94, Y+34
    Button B: X+22, Y+67
    Prize: X=8400, Y=5400

    Therefore...
    94a + 22b = 8400  -> a1*x + b1*y = c1
    34a + 67b = 5400  -> a2*x + b2*y = c2
  }
  for var i := 0 to Length(ClawMachines) - 1 do begin
    // equation 1
    a1 := ClawMachines[i].ButtonA.XSteps;
    b1 := ClawMachines[i].ButtonB.XSteps;
    c1 := ClawMachines[i].PrizeLoc.X;
    if SolutionTwo then
      c1 := c1 + 10000000000000;

    // equation 2
    a2 := ClawMachines[i].ButtonA.YSteps;
    b2 := ClawMachines[i].ButtonB.YSteps;
    c2 := ClawMachines[i].PrizeLoc.Y;
    if SolutionTwo then
      c2 := c2 + 10000000000000;

    // Calculate determinant to check if system has a unique solution
    determinant := a1 * b2 - a2 * b1;
    if determinant = 0.0 then
      // no combination of A/B buttons can get the prize
      Continue;

    // Solve for x and y using Cramer's rule
    BtnA := (c1 * b2 - c2 * b1) / determinant;
    BtnB := (a1 * c2 - a2 * c1) / determinant;

    if (BtnA <> Trunc(BtnA)) or (BtnB <> Trunc(BtnB)) then
      // can't have fractional button pushes
      Continue;

    Inc(WinableMachines);
    Writeln(Format('Machine %d needs %d Button A pushes and %d Button B pushes.',
                   [i+1, Trunc(BtnA), Trunc(BtnB)]));

    TotalBtnA := TotalBtnA + Trunc(BtnA);
    TotalBtnB := TotalBtnB + Trunc(BtnB);
  end;

  if SolutionTwo then
    Writeln(sLineBreak + 'Solution Two: ')
  else
    Writeln(sLineBreak + 'Solution One: ');

  Writeln(Format(sLineBreak +
                 'There are %d Claw Machines in the input file; of these, %d are winable.' + sLineBreak +
                 'A total of %d Button A pushes are needed and %d Button B pushes.' + sLineBreak +
                 'This means %d * %d tokens + %d * %d tokens for a total of %d tokens are needed.' + sLineBreak,
                 [Length(ClawMachines), WinableMachines,
                  TotalBtnA, TotalBtnB,
                  TotalBtnA, BtnA_Cost, TotalBtnB, BtnB_Cost,
                  TotalBtnA * BtnA_Cost + TotalBtnB * BtnB_Cost]));
end;

function ParentPath: string;
begin
  // executables are created in a .\$(Platform)\$(Config) folder, so look two parents up for files
  Result := '..' + TPath.DirectorySeparatorChar + '..';
end;

{ TButtonMove }

constructor TButtonMove.Create(const ButtonMoveStr: string);
begin
  var XMatch := TRegEx.Match(ButtonMoveStr, 'X\+[0-9]+');
  XSteps := TRegEx.Match(XMatch.Value, '[0-9]+').Value.ToInteger;

  var YMatch := TRegEx.Match(ButtonMoveStr, 'Y\+[0-9]+');
  YSteps := TRegEx.Match(YMatch.Value, '[0-9]+').Value.ToInteger;
end;

{ TLocation }

constructor TLocation.Create(const LocStr: string);
begin
  var XMatch := TRegEx.Match(LocStr, 'X\=[0-9]+');
  X := TRegEx.Match(XMatch.Value, '[0-9]+').Value.ToInteger;

  var YMatch := TRegEx.Match(LocStr, 'Y\=[0-9]+');
  Y := TRegEx.Match(YMatch.Value, '[0-9]+').Value.ToInteger;
end;

begin
  Writeln('Day 13 of Advent of Code, 2024 (https://adventofcode.com/2024/day/13');
  GenerateAnswer(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input.txt')));
  GenerateAnswer(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input.txt')), True);
  Readln;
end.
