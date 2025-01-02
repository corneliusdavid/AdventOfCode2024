program BoxCoords;
(* as: BoxCoords.exe, a Windows console app
 * in: Delphi 12.2
 * on: December, 2024
 * by: David Cornelius
 * to: Solve Day 15a of Advent of Code, 2024 (https://adventofcode.com/2024/day/15)
 *)

{$APPTYPE CONSOLE}

{.$DEFINE Sample}

{$R *.res}

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Math, System.StrUtils;

const
  ROBOT_CHAR = '@';
  EMPTY_CHAR = '.';
  WALL_CHAR = '#';
  BOX_CHAR = 'O';

type
  CharArray2D = array of array of Char;

var
  WHMap: CharArray2D;

function ConvertToArray2D(StringArray: TArray<string>): CharArray2D;
var
  RowCount, ColCount: Integer;
begin
  // how many lines describe a warehouse wall?
  for var r := 0 to Length(StringArray) - 1 do
    if (Length(StringArray[r]) = 0) or (StringArray[r][1] <> '#') then begin
      RowCount := r;
      Break;
    end;

  ColCount := Length(StringArray[0]);

  SetLength(Result, RowCount, ColCount);

  for var r := 0 to RowCount - 1 do
    for var c := 1 to ColCount do
      Result[r,c-1] := StringArray[r][c];
end;

procedure ShowWarehouseMap;
begin
  for var row := 0 to Length(WHMap) - 1 do begin
    for var col := 0 to Length(WHMap[0]) - 1 do
      Write(WHMap[row,col]);
    Writeln;
  end;
end;

procedure MoveRobot(const DeltaX, DeltaY: Integer);

  function IsWall(const x, y: Integer): Boolean;
  begin
    Result := WHMap[y, x] = WALL_CHAR;
  end;

  function IsBox(const x, y: Integer): Boolean;
  begin
    Result := WHMap[y, x] = BOX_CHAR;
  end;

  procedure MoveThing(const cx, cy, newx, newy: Integer; const Thing: Char); inline;
  begin
    WHMap[newy, newx] := Thing;
    WHMap[cy, cx] := EMPTY_CHAR;
  end;

  function MoveBox(const x, y, NewX, NewY: Integer): Boolean;
  begin
    Result := False;

    if not IsWall(NewX, NewY) then
      if IsBox(NewX, NewY) then begin
        var DeltaX := NewX - x;
        var DeltaY := NewY - y;
        if MoveBox(NewX, NewY, NewX + DeltaX, NewY + DeltaY) then begin
          MoveThing(x, y, NewX, NewY, BOX_CHAR);
          Result := True;
        end;
      end else begin
        MoveThing(x, y, NewX, NewY, BOX_CHAR);
        Result := True;
      end;
  end;

var
  CurrX, CurrY: Integer;
  NewX, NewY: Integer;
begin
  // where is the robot currently (look inside warehouse walls)?
  CurrX := -1;
  CurrY := -1;
  for var row := 1 to Length(WHMap) - 2 do begin
    for var col := 1 to Length(WHMap[0]) - 2 do begin
      if WHMap[row, col] = ROBOT_CHAR then begin
        CurrX := col;
        CurrY := row;
        Break;
      end;
    end;
    if CurrX > 0 then
      Break;
  end;

  NewX := CurrX + DeltaX;
  NewY := CurrY + DeltaY;

  if not IsWall(NewX, NewY) then begin
    if IsBox(NewX, NewY) then begin
      if MoveBox(NewX, NewY, NewX+DeltaX, NewY+DeltaY) then
        MoveThing(CurrX, CurrY, NewX, NewY, ROBOT_CHAR);
    end else
      MoveThing(CurrX, CurrY, NewX, NewY, ROBOT_CHAR);
  end;
end;

procedure CountBoxCoords(var BoxCount: Integer; var TotalBoxCoords: Int64);
begin
  BoxCount := 0;
  TotalBoxCoords := 0;

  for var row := 0 to Length(WHMap) - 1 do
    for var col := 0 to Length(WHMap[0]) - 1 do
      if WHMap[row][col] = BOX_CHAR then begin
        Inc(BoxCount);
        TotalBoxCoords := TotalBoxCoords + row * 100 + col;
      end;
end;

procedure GenerateAnswer(const InputLines: TArray<string>);
var
  Moves: string;
  Boxes: Integer;
  GPSTotal: Int64;
begin
  // convert the first part of the Input lines to a warehouse map
  WHMap := ConvertToArray2D(InputLines);

  // read in robot moves
  Moves := EmptyStr;
  for var i := 0 to Length(InputLines) - 1 do
    if (Length(InputLines[i]) > 0) and CharInSet(InputLines[i][1], ['<','^','v','>']) then
      Moves := Moves + InputLines[i];


  {$IFDEF Sample}
  ShowWarehouseMap;
  {$ENDIF}

  for var i := 1 to Moves.Length do
    case Moves[i] of
      '<': MoveRobot(-1,  0);
      '^': MoveRobot( 0, -1);
      '>': MoveRobot( 1,  0);
      'v': MoveRobot( 0,  1);
    end;

  {$IFDEF Sample}
  ShowWarehouseMap;
  {$ENDIF}

  CountBoxCoords(Boxes, GPSTotal);

  Writeln(Format('There are %d boxes in the warehouse with a total GPS Value of %d.',
                 [Boxes, GPSTotal]));
end;

function ParentPath: string;
begin
  // executables are created in a .\$(Platform)\$(Config) folder, so look two parents up for files
  Result := '..' + TPath.DirectorySeparatorChar + '..';
end;

begin
  Writeln('Day 15a of Advent of Code, 2024 (https://adventofcode.com/2024/day/15)');
  {$IFDEF Sample}
  GenerateAnswer(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input-sm.txt')));
  {$ELSE}
  GenerateAnswer(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input.txt')));
  {$ENDIF}
  Readln;
end.
