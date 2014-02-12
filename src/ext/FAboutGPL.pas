(* GPL > 3.0
Copyright (C) 1996-2014 eIrOcA Enrico Croce & Simona Burzio

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*)
(*
 @author(Enrico Croce)
*)
unit FAboutGPL;

interface

uses
  SysUtils, Classes, LCLIntf, LCLType, Forms, Controls, StdCtrls, Buttons;

type

  { TfmAbout }

  TfmAbout = class(TForm)
    BitBtn1: TBitBtn;
    Label1: TLabel;
    procedure Label1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

procedure AboutGPL(me: string);

implementation

{$R *.lfm}

procedure AboutGPL(me: string);
var
  fmAbout: TfmAbout;
begin
  fmAbout:= TfmAbout.Create(nil);
  try
    fmAbout.Caption:= 'About - '+me;
    fmAbout.ShowModal;
  finally
    fmAbout.Free;
  end;
end;

procedure TfmAbout.Label1Click(Sender: TObject);
begin

end;

{ TfmAbout }

end.
