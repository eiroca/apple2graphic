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
unit uAppleGraphicHelper;

{$mode delphi}

interface

uses
  Classes, SysUtils, Graphics, cAppleGraphic,
  Controls, StdCtrls, ExtCtrls;

type

  { TAppleGraphicHelper }

  TAppleGraphicHelper = class
  private
    AppleGraphic: TAppleImage;
    AppleShape: TAppleShape;
    AppleSprite: TAppleSprite;
    function ReadByte(var fin: Text; flg: boolean): byte;
    procedure SaveSprites(Path: string);
  protected
    function DecodeGraphic(gr: TAppleGraphic; mx, my: integer): TBItmap;
    function InitializeGraphic(Width, Height: integer): TBitmap;
    procedure LoadFile(aFileName: string; out Data: ArrayOf_byte);
    function LoadSprites(Path: string; merge: boolean): integer;
    function MakeSprite(var fin: Text; flg: boolean; w, h, order, PosX, PosY: integer): TSprite;
  public
    constructor Create;
    destructor Destroy; override;
    function LoadGraphic(const path: string; format: integer; mode: integer): TBitmap;
    function DrawShapes(const path: string): TBitmap;
    function DrawSprites(const path: string; merge: boolean): TBitmap;
    function ReorderSprites: TBitmap;
  end;

implementation

{ TAppleGraphicHelper }

function TAppleGraphicHelper.DecodeGraphic(gr: TAppleGraphic; mx, my: integer): TBitmap;
var
  x: integer;
  y: integer;
  p: integer;
  sx, sy: integer;
  screen: ArrayOf_integer;
begin
  Result := InitializeGraphic(gr.GetWidth() * mx, gr.Getheight() * my);
  p := 0;
  screen := gr.GetScreen();
  for y := 0 to gr.Getheight() - 1 do begin
    for x := 0 to gr.GetWidth() - 1 do begin
      for sx := 0 to mx - 1 do begin
        for sy := 0 to my - 1 do begin
          Result.Canvas.Pixels[x * mx + sx, y * my + sy] := screen[p];
        end;
      end;
      Inc(p);
    end;
  end;
end;

function TAppleGraphicHelper.InitializeGraphic(Width, Height: integer): TBitmap;
var
  r: TRect;
begin
  Result := TBitmap.Create();
  Result.Width := Width;
  Result.Height := Height;
  r.Left := 0;
  r.Top := 0;
  r.Right := Width;
  r.Bottom := Height;
  Result.Canvas.Brush.Color := 0;
  Result.Canvas.FillRect(r);
end;

procedure TAppleGraphicHelper.LoadFile(aFileName: string; out Data: ArrayOf_byte);
var
  fl: TFileStream;
  siz: integer;
  i: integer;
begin
  fl := TFileStream.Create(aFileName, fmOpenRead);
  try
    siz := fl.Size;
    SetLength(Data, siz);
    for i := 0 to siz - 1 do begin
      Data[i] := fl.ReadByte;
    end;
  finally
    FreeAndNil(fl);
  end;
end;

constructor TAppleGraphicHelper.Create;
begin
  AppleGraphic := TAppleImage.Create;
  AppleSprite := TAppleSprite.Create;
  AppleShape := TAppleShape.Create;
end;

destructor TAppleGraphicHelper.Destroy;
begin
  inherited Destroy;
  FreeAndNil(AppleGraphic);
  FreeAndNil(AppleShape);
  FreeAndNil(AppleSprite);
end;

function TAppleGraphicHelper.LoadGraphic(const path: string; format: integer; mode: integer): TBitmap;
var
  buffer: ArrayOf_byte;
  mx, my: integer;
  md: gMode;
begin
  mx := 1;
  my := 1;
  LoadFile(path, buffer);
  case mode of
    1: begin
      md := mdBW;
    end;
    2: begin
      md := mdColor;
    end;
    3: begin
      md := mdMixed;
    end;
    else begin
      md := mdAuto;
    end;
  end;
  case format of
    1: begin
      AppleGraphic.DrawHGR(buffer, md);
    end;
    2: begin
      AppleGraphic.DrawDHR(buffer, cAppleGraphic.kdMode1, md);
      my := 2;
    end;
    3: begin
      AppleGraphic.DrawSHR(buffer);
    end
  end;
  Result := DecodeGraphic(AppleGraphic, mx, my);
end;

function TAppleGraphicHelper.DrawShapes(const path: string): TBitmap;
var
  buffer: ArrayOf_byte;
  NumShp: word;
  i: integer;
  x, y, h, mh: integer;
  sx, sy: integer;
  siz: TSize;
begin
  sx := 2;
  sy := 2;
  LoadFile(path, buffer);
  AppleShape.SetMode(-1);
  AppleShape.SetShape(buffer);
  NumShp := AppleShape.NumShapes();
  x := 0;
  y := 0;
  mh := 0;
  siz := TSize.Create;
  for i := 1 to NumShp do begin
    AppleShape.ComputeRect(i, siz);
    if (x + siz.GetWidth() > AppleShape.GetWidth()) then begin
      x := 0;
      y += mh + sy;
      mh := 0;
    end;
    AppleShape.Draw(i, x + siz.GetOffsetX(), y + siz.GetOffsetY());
    x += siz.GetWidth() + sx;
    h := siz.GetHeight();
    if (h > mh) then begin
      mh := h;
    end;
  end;
  Result := DecodeGraphic(AppleShape, 1, 1);
end;

function TAppleGraphicHelper.ReorderSprites(): TBitmap;
begin
  AppleSprite.SetMode(-1);
  Applesprite.ResetPos(1, 1, AppleSprite.GetWidth());
  Applesprite.DrawSprites;
  Result := DecodeGraphic(AppleSprite, 1, 1);
end;

function TAppleGraphicHelper.DrawSprites(const path: string; merge: boolean): TBitmap;
begin
  LoadSprites(path, merge);
  AppleSprite.SetMode(-1);
  if (merge) then begin
    AppleSprite.ResetPos(1, 1, AppleSprite.GetWidth());
  end;
  Applesprite.DrawSprites;
  Result := DecodeGraphic(AppleSprite, 1, 1);
end;

function TAppleGraphicHelper.LoadSprites(Path: string; merge: boolean): integer;
var
  fin: Text;
  buf: array[0..8191] of byte;
  flg: boolean;
  Widht, Height, Order, PosX, PosY: word;
begin
  Assign(fin, Path);
  SetTextBuf(fin, buf, sizeof(buf));
  Reset(fin);
  flg := False;
  if not merge then begin
    AppleSprite.DeleteSprites();
  end;
  repeat
    readln(fin, Widht, Height, Order, PosX, PosY);
    if Widht = 0 then begin
      if Height = 0 then begin
        Close(fin);
        break;
      end;
      if Height = 1 then begin
        flg := True;
      end
      else begin
        flg := False;
      end;
      continue;
    end;
    AppleSprite.AddSprite(MakeSprite(fin, flg, Widht, Height, Order, PosX, PosY));
  until False;
  Result := AppleSprite.GetNumSprites();
end;

function TAppleGraphicHelper.MakeSprite(var fin: Text; flg: boolean; w, h, order, PosX, PosY: integer): TSprite;
var
  buffer: ArrayOf_byte;
  x, y, p: integer;
  Sprite: TSprite;
begin
  SetLength(buffer, w * h);
  with Sprite do begin
    if order = 2 then begin
      p := 0;
      for x := 0 to w - 1 do begin
        for y := 0 to h - 1 do begin
          buffer[x * h + y] := ReadByte(fin, flg);
          Inc(p);
        end;
      end;
    end
    else begin
      for y := 0 to h - 1 do begin
        for x := 0 to w - 1 do begin
          buffer[x * h + y] := ReadByte(fin, flg);
        end;
      end;
    end;
  end;
  Result := TSprite.Create();
  Result.Define(w, h, buffer);
  Result.SetPosition(PosX, PosY);
end;

const
  HexStr = '0123456789ABCDEF';

function TAppleGraphicHelper.ReadByte(var fin: Text; flg: boolean): byte;
var
  Data: string;
  Value: word;
  qa: integer;
begin
  if flg then begin
    Read(fin, Value);
  end
  else begin
    Readln(fin, Data);
    case Data[1] of
      '%': begin
        Value := 0;
        for QA := 2 to length(Data) do begin
          if Data[QA] = '1' then begin
            Inc(Value, 1 shl (length(Data) - QA));
          end;
        end;
        Value := Value and $FF;
      end;
      '$': begin
        Value := Pos(pred(Data[2]), HexStr) * 16 + Pos(pred(Data[3]), HexStr);
      end;
      else begin
        Val(Data, Value, qa);
      end;
    end;
  end;
  ReadByte := Value;
end;

procedure TAppleGraphicHelper.SaveSprites(Path: string);
var
  fout: Text;
  s, x, y, p: integer;
  Sprite: TSprite;
  buffer: ArrayOf_byte;
begin
  Assign(fout, Path);
  Rewrite(fout);
  for s := 0 to AppleSprite.GetNumSprites() - 1 do begin
    Sprite := AppleSprite.GetSprite(s);
    with Sprite do begin
      writeln(fout, GetWidth(), ' ', GetHeight(), ' ', 2, ' ', GetX(), ' ', GetY());
      buffer := GetData();
      p := 0;
      for x := 0 to GetWidth() - 1 do begin
        for y := 0 to GetHeight() - 1 do begin
          writeln(fout, buffer[p]);
          Inc(p);
        end;
      end;
    end;
  end;
  writeln(fout, '0 0 0 0 0');
  Close(fout);
end;

end.
