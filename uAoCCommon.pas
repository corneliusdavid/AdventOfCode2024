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
  VSoft.AnsiConsole;

procedure AoCHeader(const DayPartStr, DayLink: string);
begin
  AnsiConsole.MarkupLine(Format('[yellow]Day %s of Advent of Code, 2024 ([link=https://%s]%s[/])[/]',
                         [DayPartStr, DayLink, DayLink]));
end;

procedure AoCSolution(const Preface, Answer: string);
begin
  AnsiConsole.Write(Widgets.Panel(Preface + ' [bold]' + Answer + '[/]')
    .WithHeader('Solution')
    .WithBorder(TBoxBorderKind.Rounded));
end;

end.

