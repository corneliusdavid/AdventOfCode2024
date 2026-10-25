unit uAoCCommon;
(* as: uAoCCommon.pas
 * in: Delphi 13.0
 * on: August, 2026
 * by: David Cornelius
 * to: provide common output procedures for use in AOC 2024 console programs
 *)

interface

procedure AoCHeader(const DayPartStr, DayLink: string);
procedure AoCSolution(const Preface, Answer: string);


implementation

uses
  SysUtils,
  System.Console;

procedure AoCHeader(const DayPartStr, DayLink: string);
begin
  Console.Clear;
  Console.SetColors(TConsoleColor.Yellow, TConsoleColor.DarkBlue);
  Console.WriteLine(Format('Day %s of Advent of Code, 2024 (https://%s)',
                         [DayPartStr, DayLink]));
  Console.ResetColor;
end;

procedure AoCSolution(const Preface, Answer: string);
begin
  Console.ForegroundColor := TConsoleColor.Yellow;
  Console.Write(Preface + ' ');
  Console.BackgroundColor := TConsoleColor.DarkGreen;
  Console.Write(Answer);
  Console.ResetColor;
  Console.WriteLine;
end;

end.

