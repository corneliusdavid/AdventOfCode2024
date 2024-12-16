program GuardGallivant;
(* as: GuardGallivant.exe, a Windows console app
 * in: Delphi 12.2
 * on: December, 2024
 * by: David Cornelius
 * to: Solve Day 6a of Advent of Code, 2024 (https://adventofcode.com/2024/day/6)
 *)

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Math, System.StrUtils, RegularExpressions;

procedure GenerateAnswer(const InputLines: TArray<string>);
type
  TGuardDirections = (gdUp, gdDown, gdLeft, gdRight);
  TGuardPosChars = set of Char;
const
  GuardPosChars: TGuardPosChars = ['^', 'v', '<', '>'];
  ObstacleChar = '#';

  function GuardLeftArea(const X, Y: Integer): Boolean;
  begin
    Result := (x < 1) or (x > Length(InputLines[0]))   // before or after edge of string
           or (y < 0) or (y > Length(InputLines) - 1); // before or after edge of row array
  end;

  function PosCharToDirection(const GuardPosChar: Char): TGuardDirections;
  begin
    if GuardPosChar = '^' then
      Result := gdUp
    else if GuardPosChar = 'v' then
      Result := gdDown
    else if GuardPosChar = '<' then
      Result := gdLeft
    else if GuardPosChar = '>' then
      Result := gdRight;
  end;

  function GuardFacingObstacle(const X, Y: Integer; const Dir: TGuardDirections): Boolean;
  begin
    Result := False;

    case Dir of
      gdUp:
        if (y > 0) and (InputLines[y-1][x] = ObstacleChar) then
          Result := True;
      gdDown:
        if (y < Length(InputLines)-1) and (InputLines[y+1][x] = ObstacleChar) then
          Result := True;
      gdLeft:
        if (x > 1) and (InputLines[y][x-1] = ObstacleChar) then
          Result := True;
      gdRight:
        if (x < Length(InputLines[0])) and (InputLines[y][x+1] = ObstacleChar) then
          Result := True;
    end;
  end;

  procedure TurnGuardRight(var CurrGuardDir: TGuardDirections);
  begin
    case CurrGuardDir of
      gdUp:
        CurrGuardDir := gdRight;
      gdDown:
        CurrGuardDir := gdLeft;
      gdLeft:
        CurrGuardDir := gdUp;
      gdRight:
        CurrGuardDir := gdDown;
    end;
  end;

var
  GuardPosCount: Integer;
  GuardPosX: Integer;   // 1-based: string
  GuardPosY: Integer;   // 0-based: array
  GuardDir: TGuardDirections;
begin
  GuardPosCount := 0;

  // find starting guard position
  GuardPosX := 0;
  GuardPosY := -1;
  for var row := 0 to Length(InputLines) - 1 do begin
    for var col := 1 to Length(InputLines[0]) do
      if CharInSet(InputLines[row][col], GuardPosChars) then begin
        GuardPosX := col;
        GuardPosY := row;
        GuardDir := PosCharToDirection(InputLines[row][col]);
        InputLines[row][col] := '.';
        Break;
      end;
    if GuardPosX > 0 then
      Break;
  end;

  Writeln(Format('starting guard position: %d, %d', [GuardPosX, GuardPosY]));

  // move the guard position repeatedly until off the grid
  repeat
    if InputLines[GuardPosY][GuardPosX] = '.' then begin
      Inc(GuardPosCount);
      InputLines[GuardPosY][GuardPosX] := ' ';
    end;

    while GuardFacingObstacle(GuardPosX, GuardPosY, GuardDir) do
      TurnGuardRight(GuardDir);

    // move guard one step in current direction
    case GuardDir of
      gdUp:
        Dec(GuardPosY);
      gdDown:
        Inc(GuardPosY);
      gdLeft:
        Dec(GuardPosX);
      gdRight:
        Inc(GuardPosX);
    end;
  until GuardLeftArea(GuardPosX, GuardPosY);


  Writeln(Format('The guard was in %d distinct positions.', [GuardPosCount]));
end;

function ParentPath: string;
begin
  // executables are created in a .\$(Platform)\$(Config) folder, so look two parents up for files
  Result := '..' + TPath.DirectorySeparatorChar + '..';
end;

begin
  Writeln('Day 6a of Advent of Code, 2024 (https://adventofcode.com/2024/day/6)');
  GenerateAnswer(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input.txt')));
  Readln;
end.
