program DiskFragmenter;
(* as: DiskFragmenter.exe, a Windows console app
 * in: Delphi 12.2
 * on: December, 2024
 * by: David Cornelius
 * to: Solve Day 9a of Advent of Code, 2024 (https://adventofcode.com/2024/day/9)
 *)

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Math, System.StrUtils;

procedure GenerateAnswer(const InputLines: TArray<string>);
var
  BlockIDs: TArray<Integer>;
  TotalBlocks: Int64;

  procedure AllocateBlockArray(const BlockStr: string);
  begin
    TotalBlocks := 0;
    for var i := 1 to BlockStr.Length do
      TotalBlocks := TotalBlocks + StrToInt64(BlockStr[i]);
    SetLength(BlockIDs, TotalBlocks);
  end;

  procedure WriteDiskMap;
  const
    MAX_LINE_LEN = 50;
  var
    i: Int64;
  begin
    for i := 0 to Length(BlockIDs) - 1 do begin
      if BlockIDs[i] = -1 then
        Write('.')
      else
        //Write('#');
        Write(RightStr(UIntToStr(BlockIDs[i]), 1));
      if i+1 mod MAX_LINE_LEN = 0 then
        Writeln;
    end;
    Writeln;
  end;

  function FindFirstUnusedBlockID: Int64;
  var
    i: Int64;
  begin
    for i := 0 to Length(BlockIDs) do
      if BlockIDs[i] = -1 then begin
        Result := i;
        Break;
      end;
  end;

  procedure DefragDisk;
  var
    blk: Int64;
    FirstEmptyBlk: Int64;
  begin
    for blk := Length(BlockIDs) - 1 downto 0 do begin
       if BlockIDs[blk] <> -1 then begin
         FirstEmptyBlk := FindFirstUnusedBlockID;
         if FirstEmptyBlk > blk then
           Break;
         BlockIDs[FirstEmptyBlk] := BlockIDs[blk];
         BlockIDs[blk] := -1;
       end;
    end;
  end;

  function GetDiskCheckSum: Int64;
  var
    i: Int64;
  begin
    Result := 0;
    for i := 0 to Length(BlockIDs) - 1 do
    begin
      if BlockIDs[i] > -1 then
        Result := Result + i * BlockIDs[i];
    end;
  end;

begin
  var CurrLine := InputLines[0];

  AllocateBlockArray(CurrLine);

  var FileID := 0;
  var LineLen := 0;
  var CurrBlkPtr := 0;

  // build a map of the disk blocks
  for var i := 1 to CurrLine.Length do begin
    // get the length of the current block
    var blklen := StrToInt(CurrLine[i]);
    // map out the array of blocks and blank space
    for var j := 1 to blklen do
      // each number alternates between file size and empty space
      if Odd(i) then
        BlockIDs[CurrBlkPtr+j-1] := FileID
      else
        BlockIDs[CurrBlkPtr+j-1] := -1;

    // if we mapped a file, increment the file ID
    if Odd(i) then
      Inc(FileID);

    // go to the next space in our block array
    CurrBlkPtr := CurrBlkPtr + blklen;
  end;

  //Writeln('Before defragmentation...');
  //WriteDiskMap;
  DefragDisk;
  //Writeln('After defragmentation...');
  //WriteDiskMap;
  var CheckSum := GetDiskCheckSum;

  Writeln;
  Writeln(Format('There are %d characters in the input file that map out %d blocks ' +
                 'for a total checksum of %d.',
                 [Length(InputLines[0]), Length(BlockIDs), CheckSum]));
end;

function ParentPath: string;
begin
  // executables are created in a .\$(Platform)\$(Config) folder, so look two parents up for files
  Result := '..' + TPath.DirectorySeparatorChar + '..';
end;

begin
  Writeln('Day 9a of Advent of Code, 2024 (https://adventofcode.com/2024/day/9)');
  GenerateAnswer(TFile.ReadAllLines(TPath.Combine(ParentPath, 'input.txt')));
  Readln;
end.
