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
unit FMain;

interface

uses
  uAppleGraphicHelper, Classes, SysUtils, Graphics,
  Forms, Menus, Controls, StdCtrls, ExtCtrls, Dialogs;

type

  { TfmMain }

  TfmMain = class(TForm)
    iImg: TImage;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    miReOrderSprite: TMenuItem;
    MenuItemAuto: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    miSave: TMenuItem;
    dlSave: TSaveDialog;
    Image1: TMenuItem;
    miLoadHGR: TMenuItem;
    miLoadDHR: TMenuItem;
    miLoadSHR: TMenuItem;
    Shape1: TMenuItem;
    DrawShape1: TMenuItem;
    DrawSprite1: TMenuItem;
    dlOpen: TOpenDialog;
    miMergeSprite: TMenuItem;
    N2: TMenuItem;
    miAbout: TMenuItem;
    Shape2: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ItemModeClick(Sender: TObject);
    procedure ReorderSpriteClick(Sender: TObject);
     procedure miSaveClick(Sender: TObject);
    procedure miLoadHGRClick(Sender: TObject);
    procedure miLoadSHRClick(Sender: TObject);
    procedure miLoadDHRClick(Sender: TObject);
    procedure DrawShape1Click(Sender: TObject);
    procedure DrawSpriteClick(Sender: TObject);
    procedure MergespriteClick(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
  private
    { Private declarations }
    GraphicHelper: TAppleGraphicHelper;
    ColorConfig: TMenuItem;
    procedure SetFilter(f: string);
    procedure View(img: TBitmap);
  public
    { Public declarations }
  end;

var
  fmMain: TfmMain;

implementation

uses
  FAboutGPL;

{$R *.lfm}

procedure TfmMain.FormCreate(Sender: TObject);
var
  basePath: string;
begin
  GraphicHelper:= TAppleGraphicHelper.Create;
  ColorConfig:= MenuItemAuto;
  miReOrderSprite.Enabled:= false;
  miMergeSprite.Enabled:= false;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(GraphicHelper);
end;

procedure TfmMain.ItemModeClick(Sender: TObject);
var
  item: TMenuItem;
begin
  item:= Sender as TMenuItem;
  ColorConfig.Checked:= false;
  ColorConfig:= Item;
  ColorConfig.Checked:= true;
end;

procedure TfmMain.ReorderSpriteClick(Sender: TObject);
begin
  View(GraphicHelper.ReorderSprites());
end;

procedure TfmMain.setFilter(f: string);
begin
  dlOpen.Filter := f;
end;

procedure TfmMain.View(img: TBitmap);
begin
  miSave.Enabled:= true;
  iImg.Picture.Assign(img);
  img.Free;
end;

procedure TfmMain.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TfmMain.miAboutClick(Sender: TObject);
begin
  AboutGPL(Application.Title);
end;

procedure TfmMain.miSaveClick(Sender: TObject);
begin
  if dlSave.Execute then begin
    iImg.Picture.SaveToFile(dlSave.FileName);
  end;
end;

procedure TfmMain.miLoadHGRClick(Sender: TObject);
begin
  setFilter('HGR Files|*.hgr|All files|*.*');
  if dlOpen.Execute then begin
     View(GraphicHelper.LoadGraphic(dlOpen.FileName, 1, ColorConfig.Tag));
  end;
end;

procedure TfmMain.miLoadDHRClick(Sender: TObject);
begin
  setFilter('DHR Files|*.dhr|All files|*.*');
  if dlOpen.Execute then begin
    View(GraphicHelper.LoadGraphic(dlOpen.FileName, 2, ColorConfig.Tag));
  end;
end;

procedure TfmMain.miLoadSHRClick(Sender: TObject);
begin
  setFilter('SHR ($C1, PIC) Files|*.$C1;*.shr;*.pic|All files|*.*');
  if dlOpen.Execute then begin
    View(GraphicHelper.LoadGraphic(dlOpen.FileName, 3, ColorConfig.Tag));
  end;
end;

procedure TfmMain.DrawShape1Click(Sender: TObject);
begin
  setFilter('Shape Files|*.shp|All files|*.*');
  if dlOpen.Execute then begin
    View(GraphicHelper.DrawShapes(dlOpen.FileName));
  end;
end;

procedure TfmMain.DrawSpriteClick(Sender: TObject);
begin
  setFilter('Sprite Files|*.spr|All files|*.*');
  if dlOpen.Execute then begin
     View(GraphicHelper.DrawSprites(dlOpen.FileName, false));
     miReOrderSprite.Enabled:= true;
     miMergeSprite.Enabled:= true;
  end;
end;

procedure TfmMain.MergespriteClick(Sender: TObject);
begin
  setFilter('Sprite Files|*.spr|All files|*.*');
  if dlOpen.Execute then begin
     miSave.Enabled:= true;
     View(GraphicHelper.DrawSprites(dlOpen.FileName, true));
  end;
end;

end.
