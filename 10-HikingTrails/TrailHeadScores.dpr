program TrailHeadScores;
(* as: TrailHeadScores.exe, a Windows console app
 * in: Delphi 12.2
 * on: December, 2024
 * by: David Cornelius
 * to: Solve Day 10a of Advent of Code, 2024 (https://adventofcode.com/2024/day/10)
 *)

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Math, System.StrUtils,
  System.Generics.Collections;

type
  CharArray2D = array of array of Char;

function ConvertToArray2D(StringArray: TArray<string>): CharArray2D;
var
  RowCount, ColCount: Integer;
begin
  RowCount := Length(StringArray);
  ColCount := Length(StringArray[0]);

  SetLength(Result, ColCount, RowCount);

  for var r := 0 to RowCount - 1 do
    for var c := 1 to ColCount do
      Result[r,c-1] := StringArray[r][c];
end;

type
  TrailLoc = record
    X: Integer;
    Y: Integer;
    constructor Create(const NewX, NewY: Integer);
  end;

  TrailHeadPeakPair = record
    TrailHead: TrailLoc;
    Peak: TrailLoc;
    constructor Create(const NewTrailHead, NewPeak: TrailLoc);
  end;

var
  TrailMap: CharArray2D;
  PeaksForTrailHeads: TArray<TrailHeadPeakPair>;

function PeakAlreadyFound(const ATrailHeadPeakPair: TrailHeadPeakPair): Boolean;
begin
  Result := False;
  for var i := 0 to Length(PeaksForTrailheads) - 1 do
    if (PeaksForTrailHeads[i].TrailHead.X = ATrailHeadPeakPair.TrailHead.X) and
       (PeaksForTrailHeads[i].TrailHead.Y = ATrailHeadPeakPair.TrailHead.Y) and
       (PeaksForTrailHeads[i].Peak.X = ATrailHeadPeakPair.Peak.X) and
       (PeaksForTrailHeads[i].Peak.Y = ATrailHeadPeakPair.Peak.Y) then begin
      Result := True;
      Break;
    end;
end;

procedure AddPeakForTrailHead(const NewTrailHeadPeakPair: TrailHeadPeakPair);
begin
  SetLength(PeaksForTrailHeads, Length(PeaksForTrailHeads) + 1);
  with PeaksForTrailHeads[Length(PeaksForTrailHeads) - 1] do begin
    TrailHead.X := NewTrailHeadPeakPair.TrailHead.X;
    TrailHead.Y := NewTrailHeadPeakPair.TrailHead.Y;
    Peak.X := NewTrailHeadPeakPair.Peak.X;
    Peak.Y := NewTrailHeadPeakPair.Peak.Y;
  end;
end;

function ValidLocation(const ALoc: TrailLoc; const CheckElevation: Integer): Boolean;
begin
  Result := (ALoc.X >= 0) and (ALoc.Y >= 0) and
            (ALoc.X < Length(TrailMap[0])) and
            (ALoc.Y < Length(TrailMap)) and
            (TrailMap[ALoc.Y, ALoc.X] = CheckElevation.ToString);
end;

function FindPeaks(const TrailHead: TrailLoc;
                   const CurrLoc: TrailLoc;
                   const Elevation: Integer = 0): Integer;
begin
  Result := 0;
  if ValidLocation(CurrLoc, Elevation) then
    if (Elevation < 9) then
      Result := FindPeaks(TrailHead,
                          TrailLoc.Create(CurrLoc.x-1, CurrLoc.Y), Elevation + 1) +
                FindPeaks(TrailHead,
                          TrailLoc.Create(CurrLoc.x, CurrLoc.Y+1), Elevation + 1) +
                FindPeaks(TrailHead,
                          TrailLoc.Create(CurrLoc.X+1, CurrLoc.Y), Elevation + 1) +
                FindPeaks(TrailHead,
                          TrailLoc.Create(CurrLoc.X, CurrLoc.Y-1), Elevation + 1)
    else begin
      if not PeakAlreadyFound(TrailHeadPeakPair.Create(TrailHead, CurrLoc)) then begin
        AddPeakForTrailHead(TrailHeadPeakPair.Create(TrailHead, CurrLoc));
        Result := 1;
      end;
    end;
end;


function FindRatings(const TrailHead: TrailLoc;
                     const CurrLoc: TrailLoc;
                     const Elevation: Integer = 0): Integer;
begin
  Result := 0;
  if ValidLocation(CurrLoc, Elevation) then
    if (Elevation < 9) then
      Result := FindRatings(TrailHead,
                            TrailLoc.Create(CurrLoc.x-1, CurrLoc.Y), Elevation + 1) +
                FindRatings(TrailHead,
                            TrailLoc.Create(CurrLoc.x, CurrLoc.Y+1), Elevation + 1) +
                FindRatings(TrailHead,
                            TrailLoc.Create(CurrLoc.X+1, CurrLoc.Y), Elevation + 1) +
                FindRatings(TrailHead,
                            TrailLoc.Create(CurrLoc.X, CurrLoc.Y-1), Elevation + 1)
    else
      Result := 1;
end;

procedure GenerateAnswer(const InputLines: TArray<string>);
var
  // first string: x,y of Trailhead, second string: x,y of peak
  PeaksForTrailHead: TDictionary<string, string>;

var
  TrailHeads: Integer;
  TrailScore: Integer;
  TrailRating: Integer;
  TotalTrailScore: Integer;
  TotalRatingScore: Integer;
begin
  PeaksForTrailHead := TDictionary<string, string>.Create;
  try
    TrailMap := ConvertToArray2D(InputLines);
    TrailHeads := 0;
    TrailScore := 0;
    TrailRating := 0;
    TotalTrailScore := 0;
    TotalRatingScore := 0;

    for var r := 0 to Length(TrailMap) - 1 do
      for var c := 0 to Length(TrailMap[r]) - 1 do begin
        if TrailMap[r, c] = '0' then begin
          Inc(TrailHeads);
          TrailScore := FindPeaks(TrailLoc.Create(c, r), TrailLoc.Create(c, r));
          TrailRating := FindRatings(TrailLoc.Create(c, r), TrailLoc.Create(c, r));
          Writeln(Format('Trailhead at %d,%d can reach %d peaks and has a rating of %d.',
                         [c, r, TrailScore, TrailRating]));
          TotalTrailScore := TotalTrailScore + TrailScore;
          TotalRatingScore := TotalRatingScore + TrailRating;
        end;
      end;
  finally
    PeaksForTrailHead.Free;
  end;

  Writeln(Format('The %d trailheads have a total score of: %d and a total rating of %d',
                 [TrailHeads, TotalTrailScore, TotalRatingScore]));
end;

function ParentPath: string;
begin
  // executables are created in a .\$(Platform)\$(Config) folder, so look two parents up for files
  Result := '..' + TPath.DirectorySeparatorChar + '..';
end;

{ TrailLoc }

constructor TrailLoc.Create(const NewX, NewY: Integer);
begin
  X := NewX;
  Y := NewY;
end;

{ TrailHeadPeakPair }

constructor TrailHeadPeakPair.Create(const NewTrailHead, NewPeak: TrailLoc);
begin
  TrailHead.X := NewTrailHead.X;
  TrailHead.Y := NewTrailHead.Y;
  Peak.X := NewPeak.X;
  Peak.Y := NewPeak.Y;
end;

begin
  Writeln('Day 10a of Advent of Code, 2024 (https://adventofcode.com/2024/day/10)');
  GenerateAnswer(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input.txt')));
  Readln;
end.
