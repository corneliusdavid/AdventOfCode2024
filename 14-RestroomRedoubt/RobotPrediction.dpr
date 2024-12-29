program RobotPrediction;
(* as: RobotPrediction.exe, a Windows console app
 * in: Delphi 12.2
 * on: December, 2024
 * by: David Cornelius
 * to: Solve Day 14a of Advent of Code, 2024 (https://adventofcode.com/2024/day/14)
 *)

{$APPTYPE CONSOLE}

{.$DEFINE SAMPLE}
{.$DEFINE Part2}

{$R *.res}

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Math, System.StrUtils,
  RegularExpressions;

const
  {$IFDEF Part2}
  MaxSeconds = 1000;
  {$ELSE}
  MaxSeconds = 100;
  {$ENDIF}
  {$IFDEF SAMPLE}
  MaxX = 11;
  MaxY = 7;
  {$ELSE}
  MaxX = 101;
  MaxY = 103;
  {$ENDIF}

type
  Robot = record
    X, Y: Integer;
    XDelta, YDelta: Integer;
    constructor Create(const NewX, NewY, NewXDelta, NewYDelta: Integer); overload;
    constructor Create(const RobotDefStr: string); overload;
  end;

var
  Robots: TArray<Robot>;
  SafeQuad: array[1..4] of Integer;

procedure MoveRobot(const Idx: Integer);
begin
  Robots[Idx].X := Robots[Idx].X + Robots[Idx].XDelta;
  if Robots[Idx].X < 0 then
    Robots[Idx].X := MaxX + Robots[Idx].X
  else if Robots[Idx].X >= MaxX then
    Robots[Idx].X := Robots[Idx].X - MaxX;

  Robots[Idx].Y := Robots[Idx].Y + Robots[Idx].YDelta;
  if Robots[Idx].Y < 0 then
    Robots[Idx].Y := MaxY + Robots[Idx].Y
  else if Robots[Idx].Y >= MaxY then
    Robots[Idx].Y := Robots[Idx].Y - MaxY;
end;

procedure ShowRobotRoom(const ShowQuadrants: Boolean = False);
var
  RobotPlaced: Boolean;
  HideRow: Integer;
  HideCol: Integer;
begin
  if ShowQuadrants then begin
    HideRow := Maxy div 2;
    HideCol := MaxX div 2;
  end else begin
    HideRow := -1;
    HideCol := -1;
  end;

  Writeln;
  for var y := 0 to MaxY - 1 do begin
    if y <> HideRow then
      for var x := 0 to MaxX - 1 do begin
        if x = HideCol then
          Write(' ')
        else begin
          RobotPlaced := False;
          for var r := 0 to Length(Robots) - 1 do
            if (Robots[r].X = x) and (Robots[r].Y = y) then begin
              Write('X');
              RobotPlaced := True;
              Break;
            end;
          if not RobotPlaced then
            Write('.');
        end;
      end;
    Writeln;
  end;
end;

procedure ListRobotCoords;
begin
  for var r := 0 to Length(Robots) - 1 do
    Writeln(Format('Robot[%d]: %d, %d (%d, %d)', [r,
          Robots[r].X, Robots[r].Y, Robots[r].XDelta, Robots[r].YDelta]));
end;

procedure CalculateSafetyForQuadrant(const Quadrant: Integer);
var
  QMinX, QMaxX, QMinY, QMaxY: Integer;
begin
  case Quadrant of
    1: begin
      QMinX := 0;
      QMaxX := MaxX div 2 - 1;
      QMinY := 0;
      QMaxY := MaxY div 2 - 1;
    end;
    2: begin
      QMinX := MaxX div 2 + 1;
      QMaxX := MaxX;
      QMinY := 0;
      QMaxY := MaxY div 2 - 1;
    end;
    3: begin
      QMinX := 0;
      QMaxX := MaxX div 2 - 1;
      QMinY := MaxY div 2 + 1;
      QMaxY := MaxY;
    end;
    4: begin
      QMinX := MaxX div 2 + 1;
      QMaxX := MaxX;
      QMinY := MaxY div 2 + 1;
      QMaxY := MaxY;
    end;
  end;

  SafeQuad[Quadrant] := 0;
  for var i := 0 to Length(Robots) - 1 do
    if (Robots[i].X in [QMinX..QMaxX]) and
       (Robots[i].Y in [QMinY..QMaxY]) then
      Inc(SafeQuad[Quadrant]);
end;

procedure GenerateAnswer(const InputLines: TArray<string>);
begin
  SetLength(Robots, 0);

  for var i := 0 to Length(InputLines) - 1 do
    if Length(InputLines[i]) >= 10 then begin
      SetLength(Robots, Length(Robots) + 1);
      Robots[i].Create(InputLines[i]);
    end;

  {$IFDEF SAMPLE}
  ShowRobotRoom;
  {$ENDIF}

  for var Seconds := 1 to MaxSeconds do begin
    for var i := 0 to Length(Robots) - 1 do begin
      MoveRobot(i);
    end;
    {$IFDEF SAMPLE}
    if Seconds < 5 then
      ShowRobotRoom;
    {$ENDIF}
    {$IFDEF Part2}
    if Seconds > 100 then  begin
      Writeln('Seconds: ', Seconds);
      ShowRobotRoom;
      Sleep(2000);
    end;
    {$ENDIF}
  end;

  {$IFDEF SAMPLE}
  ShowRobotRoom(True);
  ListRobotCoords;
  {$ENDIF}

  CalculateSafetyForQuadrant(1);
  CalculateSafetyForQuadrant(2);
  CalculateSafetyForQuadrant(3);
  CalculateSafetyForQuadrant(4);

  Writeln(Format('There are %d robots in the input file.' + sLineBreak +
                 'Quadrant 1 has %d robots,' + sLineBreak +
                 'Quadrant 2 has %d robots,' + sLineBreak +
                 'Quadrant 3 has %d robots,' + sLineBreak +
                 'Quadrant 4 has %d robots;' + sLineBreak +
                 'Multiplied together, they have a total safety factor of %d.',
                 [Length(Robots), SafeQuad[1], SafeQuad[2],
                  SafeQuad[3], SafeQuad[4], SafeQuad[1] * SafeQuad[2] * SafeQuad[3] * SafeQuad[4]]));
end;

function ParentPath: string;
begin
  // executables are created in a .\$(Platform)\$(Config) folder, so look two parents up for files
  Result := '..' + TPath.DirectorySeparatorChar + '..';
end;

{ Robot }

constructor Robot.Create(const NewX, NewY, NewXDelta, NewYDelta: Integer);
begin
  X := NewX;
  Y := NewY;
  XDelta := NewXDelta;
  YDelta := NewYDelta;
  {$IFDEF SAMPLE}
  Writeln(Format('New robot established at %d,%d with velocity of %d,%d.',
                  [X, Y, XDelta, YDelta]));
  {$ENDIF}
end;

constructor Robot.Create(const RobotDefStr: string);
{  examples
  p=6,3 v=-1,-3
  p=10,3 v=-1,2
}
begin
  if Length(RobotDefStr) < 10 then
    Exit;

  var px := StrToInt(Copy(TRegEx.Match(RobotDefStr, 'p\=-?[0-9]+').Value, 3, 10));
  var py := StrToInt(Copy(TRegEx.Match(RobotDefStr, '\,-?[0-9]+').Value, 2, 10));
  var vx := StrToInt(Copy(TRegEx.Match(RobotDefStr, 'v\=-?[0-9]+').Value, 3, 10));
  var vStr := Copy(RobotDefStr, Pos('v=', RobotDefStr)+2, 50);
  var vy := StrToInt(Copy(TRegEx.Match(vStr, '\,-?[0-9]+').Value, 2, 10));
  Create(px, py, vx, vy);
end;

begin
  Writeln('Day 14 of Advent of Code, 2024 (https://adventofcode.com/2024/day/14');
  {$IFDEF SAMPLE}
  GenerateAnswer(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input-sm.txt')));
  {$ELSE}
  GenerateAnswer(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input.txt')));
  {$ENDIF}
  Readln;
end.
