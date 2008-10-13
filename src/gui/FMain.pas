(* GPL > 3.0
Copyright (C) 1996-2008 eIrOcA Enrico Croce & Simona Burzio

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
unit FMain;

interface

uses
  uAppleGraph, SysUtils,
  Forms, Menus, Controls, StdCtrls, Classes, ExtCtrls, Dialogs;

type
  TfmMain = class(TForm)
    iImg: TImage;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    SaveBMP1: TMenuItem;
    dlSave: TSaveDialog;
    Image1: TMenuItem;
    LoadHGR1: TMenuItem;
    LoadDGR1: TMenuItem;
    LoadGS1: TMenuItem;
    Shape1: TMenuItem;
    DrawShape1: TMenuItem;
    DrawSprite1: TMenuItem;
    dlOpen: TOpenDialog;
    Mergesprite1: TMenuItem;
    N2: TMenuItem;
    miAbout: TMenuItem;
    Shape2: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure iImgMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SaveBMP1Click(Sender: TObject);
    procedure LoadHGR1Click(Sender: TObject);
    procedure LoadGS1Click(Sender: TObject);
    procedure LoadDGR1Click(Sender: TObject);
    procedure DrawShape1Click(Sender: TObject);
    procedure DrawSprite1Click(Sender: TObject);
    procedure Mergesprite1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
  private
    { Private declarations }
    ag: TAppleGraphic;
    procedure setFilter(f: string);
  public
    { Public declarations }
  end;

var
  fmMain: TfmMain;

implementation

uses FAbout;

{$R *.dfm}

procedure TfmMain.setFilter(f: string);
begin
  dlOpen.Filter:= f;
end;

procedure TfmMain.miAboutClick(Sender: TObject);
begin
  About(Application.Title);
end;

procedure TfmMain.DrawShape1Click(Sender: TObject);
var
  NumShp: word;
  i: integer;
begin
  setFilter('Shape Files|*.shp|All files|*.*');
  if dlOpen.Execute then begin
    ag.bitmap.Width:= 280;
    ag.bitmap.Height:= 192;
    ag.Clear;
    NumShp:= ag.LoadShape(dlOpen.FileName);
    for i:= 0 to NumShp-1 do begin
      ag.Draw(i+1, (i mod 10)*20+10, (i div 10)*20+10);
    end;
    iImg.Picture.Assign(ag.bitmap);
  end;
end;

procedure TfmMain.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TfmMain.FormCreate(Sender: TObject);
var
  basePath: string;
begin
  basePath:= ExtractFilePath(ParamStr(0));
  ag:= TAppleGraphic.Create(-1);
  dlOpen.InitialDir:= basePath;
  dlSave.InitialDir:= basePath;
end;

procedure TfmMain.iImgMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ag.Draw(3, x, y);
  iImg.Picture.Assign(ag.bitmap);
end;

procedure TfmMain.LoadDGR1Click(Sender: TObject);
begin
  setFilter('DHR Files|*.dhr|All files|*.*');
  if dlOpen.Execute then begin
    ag.DrawDHR(dlOpen.FileName, kdMode1, mdBW);
    iImg.Picture.Assign(ag.bitmap);
  end;
end;

procedure TfmMain.LoadGS1Click(Sender: TObject);
begin
  setFilter('$C1 Files|*.$C1|All files|*.*');
  if dlOpen.Execute then begin
    ag.DrawGS(dlOpen.FileName);
    iImg.Picture.Assign(ag.bitmap);
  end;
  iImg.Picture.Assign(ag.bitmap);
end;

procedure TfmMain.LoadHGR1Click(Sender: TObject);
begin
  setFilter('HGR Files|*.hgr|All files|*.*');
  if dlOpen.Execute then begin
    ag.DrawHGR(dlOpen.FileName, mdBW);
    iImg.Picture.Assign(ag.bitmap);
  end;
end;

procedure TfmMain.DrawSprite1Click(Sender: TObject);
begin
  setFilter('Sprite Files|*.spr|All files|*.*');
  if dlOpen.Execute then begin
    ag.bitmap.Width:= 640;
    ag.bitmap.Height:= 480;
    ag.Clear;
    ag.LoadSprites(dlOpen.FileName, false);
    ag.ResetPos(1, 1, ag.bitmap.Width);
    ag.DrawSprites;
    iImg.Picture.Assign(ag.bitmap);
  end;
end;

procedure TfmMain.Mergesprite1Click(Sender: TObject);
begin
  setFilter('Sprite Files|*.dat|All files|*.*');
  if dlOpen.Execute then begin
    ag.LoadSprites(dlOpen.FileName, true);
    ag.ResetPos(1, 1, ag.bitmap.Width);
    ag.DrawSprites;
    iImg.Picture.Assign(ag.bitmap);
  end;

end;

procedure TfmMain.SaveBMP1Click(Sender: TObject);
var
  path: string;
begin
  if dlSave.Execute then begin
    path:= dlSave.FileName;
    ag.bitmap.SaveToFile(path);
  end;
end;

end.

