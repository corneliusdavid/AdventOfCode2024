program GuardGallivant;
(* as: GuardGallivant.exe, a Windows console app
 * in: Delphi 12
 * on: December, 2024
 * by: David Cornelius
 * to: Solve Day 6 of Advent of Code, 2024 (https://adventofcode.com/2024/day/6)
 *)

{$APPTYPE CONSOLE}
{.$DEFINE Sample}
{.$DEFINE SHOWWORK}

{$R *.res}

uses
  System.SysUtils,
  System.IOUtils,
  System.Console,
  uAoCCommon in '..\uAoCCommon.pas';

const
  ObstacleChar = '#';
type
  TGuardDirections = (gdUp, gdDown, gdLeft, gdRight);
  TGuardPosChars = set of AnsiChar;
  TGuardLocation = record
    row, col: Integer;
    constructor Create(const NewRow, NewCol: Integer);
  end;
  TObstacle = record
    row, col: Integer;
    dir: TGuardDirections;
    constructor Create(const NewRow, NewCol: Integer; const NewGuardDir: TGuardDirections);
  end;

const
  GuardPosChars: TGuardPosChars = ['^', 'v', '<', '>'];
  GuardPosStrs: array[TGuardDirections] of string = ('Up', 'Down', 'Left', 'Right');
  RightTurn: array[TGuardDirections] of TGuardDirections = (gdRight, gdLeft, gdUp, gdDown);

var
  GuardStartPosX: Integer;   // 1-based: string
  GuardStartPosY: Integer;   // 0-based: array
  GuardStartDir: TGuardDirections;
  UniqueGuardPositions: TArray<TGuardLocation>;


function GuardLeftArea(const row, col: Integer; const MappedArea: TArray<string>): Boolean;
begin
  Result := (col < 1) or (col > Length(MappedArea[0]))   // before or after edge of string
         or (row < 0) or (row > Length(MappedArea) - 1); // before or after edge of row array
end;

function PosCharToDirection(const GuardPosChar: Char): TGuardDirections;
begin
  if GuardPosChar = '^' then
    Result := gdUp
  else if GuardPosChar = 'v' then
    Result := gdDown
  else if GuardPosChar = '<' then
    Result := gdLeft
  else {if GuardPosChar = '>' then}
    Result := gdRight;
end;

function GuardFacingObstacle(const MappedArea: TArray<string>; const Row, Col: Integer; const Dir: TGuardDirections): Boolean;
begin
  Result := False;

  case Dir of
    gdUp:
      if (Row > 0) and (MappedArea[Row-1][Col] = ObstacleChar) then
        Result := True;
    gdDown:
      if (Row < Length(MappedArea)-1) and (MappedArea[Row+1][Col] = ObstacleChar) then
        Result := True;
    gdLeft:
      if (Col > 1) and (MappedArea[Row][Col-1] = ObstacleChar) then
        Result := True;
    gdRight:
      if (Col < Length(MappedArea[0])) and (MappedArea[Row][Col+1] = ObstacleChar) then
        Result := True;
  end;
end;

procedure FindGuardStartingPos(const Map: TArray<string>);
begin
  GuardStartPosX := 0;
  GuardStartPosY := -1;
  for var row := 0 to Length(Map) - 1 do begin
    for var col := 1 to Length(Map[0]) do
      if CharInSet(Map[row][col], GuardPosChars) then begin
        GuardStartPosX := col;
        GuardStartPosY := row;
        GuardStartDir := PosCharToDirection(Map[row][col]);
        Map[row][col] := '.';
        Break;
      end;
    if GuardStartPosX > 0 then
      Break;
  end;
end;

procedure MoveGuard(const map: TArray<string>; var GuardRow, GuardCol: Integer; const GuardDir: TGuardDirections);
var
  HitSomething: Boolean;
  LeftArea: Boolean;
begin
  if not GuardFacingObstacle(map, GuardRow, GuardCol, GuardDir) then
    repeat
      case GuardDir of
        gdUp:
          Dec(GuardRow);
        gdDown:
          Inc(GuardRow);
        gdLeft:
          Dec(GuardCol);
        gdRight:
          Inc(GuardCol);
      end;

      HitSomething := GuardFacingObstacle(map, GuardRow, GuardCol, GuardDir);
      LeftArea := GuardLeftArea(GuardRow, GuardCol, map);

    until HitSomething or LeftArea;
end;

procedure GenerateAnswer1(const InputLines: TArray<string>);
var
  GuardPosCount: Integer;
  GuardPosCol: Integer;   // 1-based: string
  GuardPosRow: Integer;   // 0-based: array
  GuardDir: TGuardDirections;
begin
  GuardPosCount := 0;
  SetLength(UniqueGuardPositions, 0);


  FindGuardStartingPos(InputLines);
  GuardPosCol := GuardStartPosX;
  GuardPosRow := GuardStartPosY;
  GuardDir := GuardStartDir;

  {$IFDEF SHOWWORK}
  Writeln(Format('starting guard position: %d, %d', [GuardStartPosY, GuardStartPosX]));
  {$ENDIF}

  // part 1: move the guard position repeatedly until off the grid, counting unique positions
  repeat
    if InputLines[GuardPosRow][GuardPosCol] = '.' then begin
      Inc(GuardPosCount);
      InputLines[GuardPosRow][GuardPosCol] := ' ';

      // remember this position for later
      SetLength(UniqueGuardPositions, Length(UniqueGuardPositions) + 1);
      UniqueGuardPositions[Length(UniqueGuardPositions) - 1] := TGuardLocation.Create(GuardPosRow, GuardPosCol);
    end;

    while GuardFacingObstacle(InputLines, GuardPosRow, GuardPosCol, GuardDir) do begin
      {$IFDEF SHOWWORK}
      Writeln(Format('Gaurd is facing an obstacle at %d, %d while facing %s',
                     [GuardPosRow, GuardPosCol, GuardPosStrs[GuardDir]]));
      {$ENDIF}
      GuardDir := RightTurn[GuardDir];
    end;

    // move guard one step in current direction
    case GuardDir of
      gdUp:
        Dec(GuardPosRow);
      gdDown:
        Inc(GuardPosRow);
      gdLeft:
        Dec(GuardPosCol);
      gdRight:
        Inc(GuardPosCol);
    end;
  until GuardLeftArea(GuardPosRow, GuardPosCol, InputLines);

  AoCSolution('Part 1 - The guard was in ', Format('%d distinct positions.', [GuardPosCount]));
end;

procedure GenerateAnswer2(const InputLines: TArray<string>);
var
  InfiniteObstacles: Integer;
  TestArea: TArray<string>;
  GuardX: Integer;   // 1-based: string
  GuardY: Integer;   // 0-based: array
  GuardDir: TGuardDirections;
  ObstaclesEncountered: TArray<TObstacle>;
begin
  InfiniteObstacles := 0;

  // try placing an obstacle in every place where the guard will go to see if it causes an infinite loop
  for var test_pos in UniqueGuardPositions do begin
    SetLength(ObstaclesEncountered, 0);
    if not ((test_pos.row = GuardStartPosY) and (test_pos.col = GuardStartPosX)) then begin
      // copy the map
      TestArea := Copy(InputLines);
      // the guard will be virtual--place a non-obstacle marker at his starting position
      TestArea[GuardStartPosY][GuardStartPosX] := '.';
      // place the obstacle at this round's test position
      TestArea[test_pos.row][test_pos.col] := ObstacleChar;

      // recall guard stating position from problem part 1
      GuardX := GuardStartPosX;
      GuardY := GuardStartPosY;
      GuardDir := GuardStartDir;

      var LoopFound := False;
      repeat
        // move to each obstacle and check: have we been here before in the same direction?
        MoveGuard(TestArea, GuardY, GuardX, GuardDir);

        if GuardLeftArea(GuardY, GuardX, TestArea) then
          Break;

        while GuardFacingObstacle(TestArea, GuardY, GuardX, GuardDir) do begin
          // first, check to see if we've hit this obstacle in this direction before
          for var ob := 0 to Length(ObstaclesEncountered) - 1 do begin
            if (ObstaclesEncountered[ob].col = GuardX) and (ObstaclesEncountered[ob].row = GuardY) and
               (ObstaclesEncountered[ob].dir = GuardDir) then begin
              // we've been here before--this round's test is over
              LoopFound := True;
              Inc(InfiniteObstacles);
              {$IFDEF SHOWWORK}
              Writeln('We''ve been here before! Infinite loop found at: ', Format('%d, %d', [GuardX, GuardY]));
              {$ENDIF}
              Break;
            end;
          end;

          if LoopFound then
            Break
          else begin
            // new obstacle/direction--record it in case we encounter it again
            SetLength(ObstaclesEncountered, Length(ObstaclesEncountered) + 1);
            ObstaclesEncountered[Length(ObstaclesEncountered) - 1] := TObstacle.Create(GuardY, GuardX, GuardDir);

            // turn
            GuardDir := RightTurn[GuardDir];
          end;
        end;
      until LoopFound;
    end;
  end;

  AoCSolution('Part 2 - To cause an infinite guard-walking loop:',
                   Format('%d obstacle place options', [InfiniteObstacles]));
end;

function ParentPath: string;
begin
  // executables are created in a .\$(Platform)\$(Config) folder, so look two parents up for files
  Result := '..' + TPath.DirectorySeparatorChar + '..';
end;

{ TGuardLocation }

constructor TGuardLocation.Create(const NewRow, NewCol: Integer);
begin
  col := NewCol;
  row := NewRow;
end;

{ TObstacle }

constructor TObstacle.Create(const NewRow, NewCol: Integer; const NewGuardDir: TGuardDirections);
begin
  row := NewRow;
  col := NewCol;
  dir := NewGuardDir;
end;

begin
  AoCHeader('6', 'adventofcode.com/2024/day/6');

  {$IFDEF SAMPLE}
  GenerateAnswer1(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input-sm.txt')));
  GenerateAnswer2(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input-sm.txt')));
  {$ELSE}
  GenerateAnswer1(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input.txt')));
  GenerateAnswer2(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input.txt')));
  {$ENDIF}

  {$IFDEF DEBUG}
  Console.ReadLine;
  {$ENDIF}
end.
