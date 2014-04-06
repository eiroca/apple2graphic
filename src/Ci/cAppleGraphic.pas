// Generated automatically with "cito". Do not edit.
// GPL > 3.0
// Copyright (C) 1996-2014 eIrOcA Enrico Croce & Simona Burzio
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
//  Author :  Enrico Croce
//  Library: Draw Apple 2 shapes, HGR, DHR, GS $C1(PIC) images
//  Version:  1.0.1
//  Creation Date: 01/09/1996
//  Last Modify Date: 02/04/2014
//
//  NOTE:  Rotation not supported, Scaling and collisions supported
//
unit cAppleGraphic;

interface

uses SysUtils, Classes;

type

  gKind = (
    /// MAIN - AUX order
    kdMode1,
    /// AUX - MAIN order
    kdMode2
  );

  gMode = (mdAuto, mdBW, mdColor, mdMixed);

  TSize = class;
  TSprite = class;

  ArrayOf_integer = array of integer;
  ArrayOf_byte = array of byte;
  ArrayOf_TSprite = array of TSprite;

  TAppleGraphic = class(TInterfacedObject)
    private
      screen: ArrayOf_integer;
    protected
      Height: integer;
      Width: integer;
      bgColor: integer;
      fgColor: integer;
    public
      constructor Create;
      procedure Clear();
      function GetHeight(): integer;
      function GetPixel(X: integer; Y: integer): integer;
      function GetScreen(): ArrayOf_integer;
      function GetWidth(): integer;
      procedure SetMode(mode: integer);
      procedure SetPixel(X: integer; Y: integer; C: integer);
  end;

  TAppleImage = class(TAppleGraphic)
    protected
      function DecodeMode(aType: byte): gMode;
      procedure DecodePal(var Pic: ArrayOf_byte; var Pal: ArrayOf_integer);
      function GetColor(var Pic: ArrayOf_byte; x: integer; y: integer): byte;
    public
      constructor Create;
      procedure DrawDHR(var img: ArrayOf_byte; kind: gKind; mode: gMode);
      procedure DrawDHRBW(var img: ArrayOf_byte; mainFirst: boolean);
      procedure DrawDHRCol(var img: ArrayOf_byte; mainFirst: boolean; solid: boolean);
      procedure DrawHGR(var img: ArrayOf_byte; mode: gMode);
      procedure DrawHGRBW(var img: ArrayOf_byte);
      procedure DrawHGRCol(var img: ArrayOf_byte; solid: boolean);
      procedure DrawSHR(var img: ArrayOf_byte);
  end;

  TAppleShape = class(TAppleGraphic)
    private
      Collisions: integer;
      Rot: integer;
      Scale: integer;
      ShTbl: ArrayOf_byte;
    protected
      function GetBaseAddr(Shape: integer): integer;
      procedure InternalDraw(Shape: integer; XPos: integer; aYPos: integer; mask: integer);
    public
      constructor Create;
      procedure ComputeRect(Shape: integer; rect: TSize);
      procedure Draw(Shape: integer; XPos: integer; aYPos: integer);
      function GetCollisions(): integer;
      function NumShapes(): integer;
      procedure SetRotation(rotation: integer);
      procedure SetScale(aScale: integer);
      procedure SetShape(var source: ArrayOf_byte);
      procedure XDraw(Shape: integer; XPos: integer; aYPos: integer);
  end;

  TAppleSprite = class(TAppleGraphic)
    private
      NumSprites: integer;
      Sprites: ArrayOf_TSprite;
    public
      constructor Create;
      procedure AddSprite(sprite: TSprite);
      procedure DeleteSprites();
      procedure DrawSprite(s: TSprite);
      procedure DrawSprites();
      function GetNumSprites(): integer;
      function GetSprite(i: integer): TSprite;
      procedure ResetPos(sx: integer; sy: integer; MaxX: integer);
  end;

  TSize = class(TInterfacedObject)
    protected
      Height: integer;
      OffX: integer;
      OffY: integer;
      Width: integer;
    public
      constructor Create;
      function GetHeight(): integer;
      function GetOffsetX(): integer;
      function GetOffsetY(): integer;
      function GetWidth(): integer;
  end;

  TSprite = class(TInterfacedObject)
    protected
      data: ArrayOf_byte;
      h: integer;
      w: integer;
      x: integer;
      y: integer;
    public
      constructor Create;
      procedure Define(width: integer; height: integer; var def: ArrayOf_byte);
      function GetData(): ArrayOf_byte;
      function GetHeight(): integer;
      function GetWidth(): integer;
      function GetX(): integer;
      function GetY(): integer;
      procedure SetPosition(px: integer; py: integer);
  end;

var
  BWCol: ArrayOf_integer;
  DHRCol: ArrayOf_integer;
  HGRCol: ArrayOf_integer;
  YPos: ArrayOf_integer;
  BITS: ArrayOf_byte;

implementation

var EMPTY_ArrayOf_integer: ArrayOf_integer;
procedure __CCLEAR(var x: ArrayOf_integer); overload; var i: integer; begin for i:= low(x) to high(x) do x[i]:= 0; end;
procedure __CFILL (var x: ArrayOf_integer; v: integer); overload; var i: integer; begin for i:= low(x) to high(x) do x[i]:= v; end;
procedure __CCOPY (const source: ArrayOf_integer; sourceStart: integer; var dest: ArrayOf_integer; destStart: integer; len: integer); overload; var i: integer; begin for i:= 0 to len do dest[i+destStart]:= source[i+sourceStart]; end;
var EMPTY_ArrayOf_byte: ArrayOf_byte;
procedure __CCLEAR(var x: ArrayOf_byte); overload; var i: integer; begin for i:= low(x) to high(x) do x[i]:= 0; end;
procedure __CFILL (var x: ArrayOf_byte; v: byte); overload; var i: integer; begin for i:= low(x) to high(x) do x[i]:= v; end;
procedure __CCOPY (const source: ArrayOf_byte; sourceStart: integer; var dest: ArrayOf_byte; destStart: integer; len: integer); overload; var i: integer; begin for i:= 0 to len do dest[i+destStart]:= source[i+sourceStart]; end;
var EMPTY_ArrayOf_TSprite: ArrayOf_TSprite;
procedure __CCLEAR(var x: ArrayOf_TSprite); overload; var i: integer; begin for i:= low(x) to high(x) do x[i]:= nil; end;
procedure __CFILL (var x: ArrayOf_TSprite; v: TSprite); overload; var i: integer; begin for i:= low(x) to high(x) do x[i]:= v; end;
procedure __CCOPY (const source: ArrayOf_TSprite; sourceStart: integer; var dest: ArrayOf_TSprite; destStart: integer; len: integer); overload; var i: integer; begin for i:= 0 to len do dest[i+destStart]:= source[i+sourceStart]; end;
function  __CINC_Pre (var x: integer): integer; overload; inline; begin inc(x); Result:= x; end;
function  __CINC_Pre (var x: byte): byte; overload; inline; begin inc(x); Result:= x; end;
function  __CINC_Post(var x: integer): integer; overload; inline; begin Result:= x; inc(x); end;
function  __CINC_Post(var x: byte): byte; overload; inline; begin Result:= x; inc(x); end;

constructor TAppleGraphic.Create;
begin
  Self.bgColor:= 0;
  Self.fgColor:= 16777215;
  Self.SetMode(-1);
end;

procedure TAppleGraphic.Clear();
var
  size: integer;
  i: integer;
begin
  if Self.screen <> EMPTY_ArrayOf_integer then begin
    screen:= EMPTY_ArrayOf_integer;
  end;
  size:= Self.Width * Self.Height;
  SetLength(Self.screen, size);
  for i:= 0 to size-1 do begin
    Self.screen[i]:= Self.bgColor;
  end;
end;

function TAppleGraphic.GetHeight(): integer;
begin
  Result:= Self.Height;
end;

function TAppleGraphic.GetPixel(X: integer; Y: integer): integer;
begin
  Result:= Self.screen[(Y * Self.Width) + X];
end;

function TAppleGraphic.GetScreen(): ArrayOf_integer;
begin
  Result:= Self.screen;
end;

function TAppleGraphic.GetWidth(): integer;
begin
  Result:= Self.Width;
end;

procedure TAppleGraphic.SetMode(mode: integer);
begin
  case (mode) of
    0: begin
      Self.Width:= 280;
      Self.Height:= 192;
    end;
    1: begin
      Self.Width:= 560;
      Self.Height:= 192;
    end;
    2: begin
      Self.Width:= 320;
      Self.Height:= 200;
    end;
    else begin
      Self.Width:= 640;
      Self.Height:= 480;
    end;
  end;
  Self.Clear();
end;

procedure TAppleGraphic.SetPixel(X: integer; Y: integer; C: integer);
begin
  Self.screen[(Y * Self.Width) + X]:= C;
end;

constructor TAppleImage.Create;
begin
  inherited;
end;

function TAppleImage.DecodeMode(aType: byte): gMode;
var
  mode: gMode;
begin
  case (aType) of
    0, 4: mode:= gMode.mdBW;
    1, 5: mode:= gMode.mdMixed;
    2, 6: mode:= gMode.mdBW;
    3, 7: mode:= gMode.mdColor;
    else mode:= gMode.mdMixed;
  end;
  Result:= mode;
end;

procedure TAppleImage.DecodePal(var Pic: ArrayOf_byte; var Pal: ArrayOf_integer);
var
  off: integer;
  base: integer;
  j: integer;
  i: integer;
  tmp1: byte;
  tmp2: byte;
  bb: integer;
  gg: integer;
  rr: integer;
begin
  off:= 0;
  base:= 32256;
  for j:= 0 to 15 do begin
    for i:= 0 to 15 do begin
      tmp1:= Pic[__CINC_Post(base)];
      tmp2:= Pic[__CINC_Post(base)];
      bb:= tmp1 and 15;
      gg:= (tmp1 and 240) shr 4;
      rr:= tmp2 and 15;
      Pal[__CINC_Post(off)]:= (((bb * 17) shl 16) + ((gg * 17) shl 8)) + (rr * 17);
    end;
  end;
end;

procedure TAppleImage.DrawDHR(var img: ArrayOf_byte; kind: gKind; mode: gMode);
var
  mainFirst: boolean;
begin
  Self.SetMode(1);
  if mode = gMode.mdAuto then begin
    mode:= Self.DecodeMode(img[120]);
  end;
  mainFirst:= kind = gKind.kdMode1;
  case (mode) of
    gMode.mdBW: Self.DrawDHRBW(img, mainFirst);
    gMode.mdColor: Self.DrawDHRCol(img, mainFirst, true);
    gMode.mdMixed: Self.DrawDHRCol(img, mainFirst, false);
  end;
end;

procedure TAppleImage.DrawDHRBW(var img: ArrayOf_byte; mainFirst: boolean);
var
  off1: integer;
  off2: integer;
  y: integer;
  tx: integer;
  base1: integer;
  base2: integer;
  bx: integer;
  vl1: byte;
  vl2: byte;
  v: integer;
  ox: integer;
  c: integer;
begin
  if mainFirst then off1:= 0 else off1:= 8192;
  if mainFirst then off2:= 8192 else off2:= 0;
  for y:= 0 to 191 do begin
    tx:= 0;
    base1:= YPos[y] + off1;
    base2:= YPos[y] + off2;
    for bx:= 0 to 39 do begin
      vl1:= (img[__CINC_Post(base1)] and 127);
      vl2:= (img[__CINC_Post(base2)] and 127);
      v:= (vl2 shl 7) + vl1;
      for ox:= 0 to 13 do begin
        c:= BWCol[v and 1];
        Self.SetPixel(tx, y, c);
        v:= v shr 1;
        inc(tx);
      end;
    end;
  end;
end;

procedure TAppleImage.DrawDHRCol(var img: ArrayOf_byte; mainFirst: boolean; solid: boolean);
var
  off1: integer;
  off2: integer;
  y: integer;
  tx: integer;
  base1: integer;
  base2: integer;
  bx: integer;
  vl1: byte;
  vl2: byte;
  vl3: byte;
  vl4: byte;
  v: integer;
  ox: integer;
  nibble: byte;
  c: integer;
  i: integer;
begin
  if mainFirst then off1:= 0 else off1:= 8192;
  if mainFirst then off2:= 8192 else off2:= 0;
  for y:= 0 to 191 do begin
    tx:= 0;
    base1:= YPos[y] + off1;
    base2:= YPos[y] + off2;
    for bx:= 0 to 19 do begin
      vl1:= (img[__CINC_Post(base1)] and 127);
      vl2:= (img[__CINC_Post(base2)] and 127);
      vl3:= (img[__CINC_Post(base1)] and 127);
      vl4:= (img[__CINC_Post(base2)] and 127);
      v:= ((vl4 shl 21) + (vl3 shl 14)) + (vl2 shl 7) + vl1;
      for ox:= 0 to 6 do begin
        nibble:= (v and 15);
        c:= DHRCol[nibble];
        for i:= 0 to 3 do begin
          if solid or ((nibble and BITS[i]) <> 0) then begin
            Self.SetPixel(tx, y, c);
          end;
          inc(tx);
        end;
        v:= v shr 4;
      end;
    end;
  end;
end;

procedure TAppleImage.DrawHGR(var img: ArrayOf_byte; mode: gMode);
begin
  Self.SetMode(0);
  if mode = gMode.mdAuto then begin
    mode:= Self.DecodeMode(img[120]);
  end;
  case (mode) of
    gMode.mdBW: Self.DrawHGRBW(img);
    gMode.mdColor: Self.DrawHGRCol(img, true);
    gMode.mdMixed: Self.DrawHGRCol(img, false);
  end;
end;

procedure TAppleImage.DrawHGRBW(var img: ArrayOf_byte);
var
  y: integer;
  tx: integer;
  base: integer;
  bx: integer;
  vl: integer;
  ox: integer;
begin
  for y:= 0 to 191 do begin
    tx:= 0;
    base:= YPos[y];
    for bx:= 0 to 39 do begin
      vl:= img[__CINC_Post(base)];
      for ox:= 0 to 6 do begin
        Self.SetPixel(__CINC_Post(tx), y, BWCol[vl and 1]);
        vl:= vl shr 1;
      end;
    end;
  end;
end;

procedure TAppleImage.DrawHGRCol(var img: ArrayOf_byte; solid: boolean);
var
  y: integer;
  tx: integer;
  base: integer;
  v1: byte;
  v2: byte;
  fl1: byte;
  fl2: byte;
  v: integer;
  ox: integer;
  c: byte;
  oc1: integer;
  oc2: integer;
begin
  for y:= 0 to 191 do begin
    tx:= 0;
    base:= YPos[y];
    repeat
      v1:= img[__CINC_Post(base)];
      v2:= img[__CINC_Post(base)];
      if (v1 and 128) <> 0 then fl1:= 4 else fl1:= 0;
      if (v2 and 128) <> 0 then fl2:= 4 else fl2:= 0;
      v:= (v1 and 127) + ((v2 and 127) shl 7);
      for ox:= 0 to 6 do begin
        c:= (v and 3);
        v:= v shr 2;
        if ox < 3 then begin
          oc2:= c + fl1;
          oc1:= oc2;
        end
        else if ox > 3 then begin
          oc2:= c + fl2;
          oc1:= oc2;
        end
        else begin
          oc1:= c + fl1;
          oc2:= c + fl2;
        end;
        if solid or ((c and 1) <> 0) then oc1:= HGRCol[oc1] else oc1:= 0;
        if solid or ((c and 2) <> 0) then oc2:= HGRCol[oc2] else oc2:= 0;
        Self.SetPixel(__CINC_Post(tx), y, oc1);
        Self.SetPixel(__CINC_Post(tx), y, oc2);
      end;
    until not(tx < 280);
  end;
end;

procedure TAppleImage.DrawSHR(var img: ArrayOf_byte);
var
  Pal: ArrayOf_integer;
  y: integer;
  x: integer;
  c: integer;
begin
  SetLength(Pal, 256);
  Self.SetMode(2);
  Self.DecodePal(img, Pal);
  for y:= 0 to 199 do begin
    for x:= 0 to 319 do begin
      c:= Pal[Self.GetColor(img, x, y)];
      Self.SetPixel(x, y, c);
    end;
  end;
end;

function TAppleImage.GetColor(var Pic: ArrayOf_byte; x: integer; y: integer): byte;
var
  tmp: byte;
begin
  tmp:= Pic[(y * 160) + (x shr 1)];
  if (x and 1) <> 0 then begin
    Result:= ((Pic[32000 + y] shl 4) + (tmp and 15));
    exit;
  end
  else begin
    Result:= ((Pic[32000 + y] shl 4) + (tmp shr 4));
    exit;
  end;
end;

constructor TAppleShape.Create;
begin
  inherited;
  Self.Collisions:= 0;
  Self.Scale:= 1;
  Self.Rot:= 0;
end;

procedure TAppleShape.ComputeRect(Shape: integer; rect: TSize);
var
  Base: integer;
  minX: integer;
  X: integer;
  maxX: integer;
  minY: integer;
  Y: integer;
  maxY: integer;
  Vector: byte;
  VByte: byte;
begin
  Base:= Self.GetBaseAddr(Shape);
  X:= 0;
  maxX:= X;
  minX:= maxX;
  Y:= 0;
  maxY:= Y;
  minY:= maxY;
  VByte:= Self.ShTbl[Base];
  while (VByte <> 0) do begin
    while (VByte <> 0) do begin
      Vector:= (VByte and 3);
      case (Vector) of
        0: begin
          dec(Y);
          if Y < minY then minY:= Y;
        end;
        1: begin
          inc(X);
          if X > maxX then maxX:= X;
        end;
        2: begin
          inc(Y);
          if Y > maxY then maxY:= Y;
        end;
        3: begin
          dec(X);
          if X < minX then minX:= X;
        end;
      end;
      VByte:= VByte shr 3;
    end;
    VByte:= Self.ShTbl[__CINC_Pre(Base)];
  end;
  rect.OffX:= -(minX);
  rect.OffY:= -(minY);
  rect.Width:= (maxX - minX) + 1;
  rect.Height:= (maxY - minY) + 1;
end;

procedure TAppleShape.Draw(Shape: integer; XPos: integer; aYPos: integer);
begin
  Self.InternalDraw(Shape, XPos, aYPos, 0);
end;

function TAppleShape.GetBaseAddr(Shape: integer): integer;
var
  offset: integer;
begin
  if Self.ShTbl = EMPTY_ArrayOf_byte then Raise Exception.Create('Invalid Shape Table');
  if (Shape < 1) or (Shape > Self.NumShapes()) then Raise Exception.Create('Invalid Shape');
  offset:= Shape shl 1;
  Result:= Self.ShTbl[offset] + (Self.ShTbl[offset + 1] shl 8);
end;

function TAppleShape.GetCollisions(): integer;
begin
  Result:= Self.Collisions;
end;

procedure TAppleShape.InternalDraw(Shape: integer; XPos: integer; aYPos: integer; mask: integer);
var
  Base: integer;
  Vector: byte;
  VByte: byte;
  i: integer;
  c: integer;
begin
  Base:= Self.GetBaseAddr(Shape);
  Self.Collisions:= 0;
  VByte:= Self.ShTbl[Base];
  while (VByte <> 0) do begin
    while (VByte <> 0) do begin
      Vector:= (VByte and 7);
      for i:= 0 to Self.Scale-1 do begin
        if Vector > 3 then begin
          Vector:= Vector and 3;
          c:= Self.GetPixel(XPos, aYPos);
          if c <> Self.bgColor then inc(Self.Collisions);
          Self.SetPixel(XPos, aYPos, (c and mask) xor Self.fgColor);
        end;
        case (Vector) of
          0: dec(aYPos);
          1: inc(XPos);
          2: inc(aYPos);
          3: dec(XPos);
        end;
      end;
      VByte:= VByte shr 3;
    end;
    VByte:= Self.ShTbl[__CINC_Pre(Base)];
  end;
end;

function TAppleShape.NumShapes(): integer;
begin
  if Self.ShTbl = EMPTY_ArrayOf_byte then Result:= 0 else Result:= Self.ShTbl[0];
end;

procedure TAppleShape.SetRotation(rotation: integer);
begin
  Self.Rot:= rotation;
end;

procedure TAppleShape.SetScale(aScale: integer);
begin
  Self.Scale:= aScale;
end;

procedure TAppleShape.SetShape(var source: ArrayOf_byte);
begin
  Self.ShTbl:= source;
end;

procedure TAppleShape.XDraw(Shape: integer; XPos: integer; aYPos: integer);
begin
  Self.InternalDraw(Shape, XPos, aYPos, 16777215);
end;

constructor TAppleSprite.Create;
begin
  inherited;
  Self.NumSprites:= 0;
  SetLength(Self.Sprites, Self.NumSprites);
end;

procedure TAppleSprite.AddSprite(sprite: TSprite);
var
  NewSprites: ArrayOf_TSprite;
  i: integer;
begin
  SetLength(NewSprites, Self.NumSprites + 1);
  for i:= 0 to Self.NumSprites-1 do begin
    NewSprites[i]:= Self.Sprites[i];
  end;
  NewSprites[Self.NumSprites]:= sprite;
  inc(Self.NumSprites);
  Sprites:= EMPTY_ArrayOf_TSprite;
  Self.Sprites:= NewSprites;
end;

procedure TAppleSprite.DeleteSprites();
var
  i: integer;
begin
  for i:= 0 to Self.NumSprites-1 do begin
    FreeAndNil(Self.Sprites[i]);
  end;
  Self.Sprites:= EMPTY_ArrayOf_TSprite;
  Self.NumSprites:= 0;
end;

procedure TAppleSprite.DrawSprite(s: TSprite);
var
  pos: integer;
  px: integer;
  py: integer;
  w: integer;
  h: integer;
  value: byte;
  k: integer;
  c: integer;
begin
  pos:= 0;
  if (s.x + (s.w * 8)) >= Self.Width then exit;
  if (s.y + s.h) >= Self.Height then exit;
  px:= s.x;
  for w:= 0 to s.w-1 do begin
    py:= s.y;
    for h:= 0 to s.h-1 do begin
      value:= s.data[__CINC_Post(pos)];
      for k:= 0 to 7 do begin
        if (value and BITS[7 - k]) <> 0 then c:= Self.fgColor else c:= Self.bgColor;
        Self.SetPixel(px + k, py, c);
      end;
      inc(py);
    end;
    px:= px + 8;
  end;
end;

procedure TAppleSprite.DrawSprites();
var
  i: integer;
begin
  for i:= 0 to Self.NumSprites-1 do begin
    Self.DrawSprite(Self.Sprites[i]);
  end;
end;

function TAppleSprite.GetNumSprites(): integer;
begin
  Result:= Self.NumSprites;
end;

function TAppleSprite.GetSprite(i: integer): TSprite;
begin
  if (i < 0) or (i >= Self.NumSprites) then Raise Exception.Create('Invalid Sprite');
  Result:= Self.Sprites[i];
end;

procedure TAppleSprite.ResetPos(sx: integer; sy: integer; MaxX: integer);
var
  px: integer;
  py: integer;
  my: integer;
  i: integer;
  s: TSprite;
  wx: integer;
  wy: integer;
begin
  px:= 0;
  py:= 0;
  my:= 0;
  for i:= 0 to Self.NumSprites-1 do begin
    s:= Self.Sprites[i];
    wx:= s.w * 8;
    wy:= s.h;
    if (px + wx) >= MaxX then begin
      px:= 0;
      py:= py + my + sy;
      my:= 0;
    end;
    s.x:= px;
    s.y:= py;
    px:= px + wx + sx;
    if wy > my then begin
      my:= wy;
    end;
  end;
end;

constructor TSize.Create;
begin
end;

function TSize.GetHeight(): integer;
begin
  Result:= Self.Height;
end;

function TSize.GetOffsetX(): integer;
begin
  Result:= Self.OffX;
end;

function TSize.GetOffsetY(): integer;
begin
  Result:= Self.OffY;
end;

function TSize.GetWidth(): integer;
begin
  Result:= Self.Width;
end;

constructor TSprite.Create;
begin
end;

procedure TSprite.Define(width: integer; height: integer; var def: ArrayOf_byte);
begin
  Self.w:= width;
  Self.h:= height;
  Self.data:= def;
end;

function TSprite.GetData(): ArrayOf_byte;
begin
  Result:= Self.data;
end;

function TSprite.GetHeight(): integer;
begin
  Result:= Self.h;
end;

function TSprite.GetWidth(): integer;
begin
  Result:= Self.w;
end;

function TSprite.GetX(): integer;
begin
  Result:= Self.x;
end;

function TSprite.GetY(): integer;
begin
  Result:= Self.y;
end;

procedure TSprite.SetPosition(px: integer; py: integer);
begin
  Self.x:= px;
  Self.y:= py;
end;

initialization
  SetLength(EMPTY_ArrayOf_integer, 0);
  SetLength(EMPTY_ArrayOf_byte, 0);
  SetLength(EMPTY_ArrayOf_TSprite, 0);
  SetLength(BWCol, 2);
  BWCol[0]:= 0;
  BWCol[1]:= 16777215;
  SetLength(DHRCol, 16);
  DHRCol[0]:= 0;
  DHRCol[1]:= 8388608;
  DHRCol[2]:= 32768;
  DHRCol[3]:= 10485760;
  DHRCol[4]:= 128;
  DHRCol[5]:= 8421504;
  DHRCol[6]:= 65280;
  DHRCol[7]:= 8437760;
  DHRCol[8]:= 255;
  DHRCol[9]:= 16711935;
  DHRCol[10]:= 8421504;
  DHRCol[11]:= 16711680;
  DHRCol[12]:= 33023;
  DHRCol[13]:= 12615935;
  DHRCol[14]:= 65535;
  DHRCol[15]:= 16777215;
  SetLength(HGRCol, 8);
  HGRCol[0]:= 0;
  HGRCol[1]:= 14492381;
  HGRCol[2]:= 56593;
  HGRCol[3]:= 16777215;
  HGRCol[4]:= 0;
  HGRCol[5]:= 16720418;
  HGRCol[6]:= 26367;
  HGRCol[7]:= 16777215;
  SetLength(YPos, 192);
  YPos[0]:= 0;
  YPos[1]:= 1024;
  YPos[2]:= 2048;
  YPos[3]:= 3072;
  YPos[4]:= 4096;
  YPos[5]:= 5120;
  YPos[6]:= 6144;
  YPos[7]:= 7168;
  YPos[8]:= 128;
  YPos[9]:= 1152;
  YPos[10]:= 2176;
  YPos[11]:= 3200;
  YPos[12]:= 4224;
  YPos[13]:= 5248;
  YPos[14]:= 6272;
  YPos[15]:= 7296;
  YPos[16]:= 256;
  YPos[17]:= 1280;
  YPos[18]:= 2304;
  YPos[19]:= 3328;
  YPos[20]:= 4352;
  YPos[21]:= 5376;
  YPos[22]:= 6400;
  YPos[23]:= 7424;
  YPos[24]:= 384;
  YPos[25]:= 1408;
  YPos[26]:= 2432;
  YPos[27]:= 3456;
  YPos[28]:= 4480;
  YPos[29]:= 5504;
  YPos[30]:= 6528;
  YPos[31]:= 7552;
  YPos[32]:= 512;
  YPos[33]:= 1536;
  YPos[34]:= 2560;
  YPos[35]:= 3584;
  YPos[36]:= 4608;
  YPos[37]:= 5632;
  YPos[38]:= 6656;
  YPos[39]:= 7680;
  YPos[40]:= 640;
  YPos[41]:= 1664;
  YPos[42]:= 2688;
  YPos[43]:= 3712;
  YPos[44]:= 4736;
  YPos[45]:= 5760;
  YPos[46]:= 6784;
  YPos[47]:= 7808;
  YPos[48]:= 768;
  YPos[49]:= 1792;
  YPos[50]:= 2816;
  YPos[51]:= 3840;
  YPos[52]:= 4864;
  YPos[53]:= 5888;
  YPos[54]:= 6912;
  YPos[55]:= 7936;
  YPos[56]:= 896;
  YPos[57]:= 1920;
  YPos[58]:= 2944;
  YPos[59]:= 3968;
  YPos[60]:= 4992;
  YPos[61]:= 6016;
  YPos[62]:= 7040;
  YPos[63]:= 8064;
  YPos[64]:= 40;
  YPos[65]:= 1064;
  YPos[66]:= 2088;
  YPos[67]:= 3112;
  YPos[68]:= 4136;
  YPos[69]:= 5160;
  YPos[70]:= 6184;
  YPos[71]:= 7208;
  YPos[72]:= 168;
  YPos[73]:= 1192;
  YPos[74]:= 2216;
  YPos[75]:= 3240;
  YPos[76]:= 4264;
  YPos[77]:= 5288;
  YPos[78]:= 6312;
  YPos[79]:= 7336;
  YPos[80]:= 296;
  YPos[81]:= 1320;
  YPos[82]:= 2344;
  YPos[83]:= 3368;
  YPos[84]:= 4392;
  YPos[85]:= 5416;
  YPos[86]:= 6440;
  YPos[87]:= 7464;
  YPos[88]:= 424;
  YPos[89]:= 1448;
  YPos[90]:= 2472;
  YPos[91]:= 3496;
  YPos[92]:= 4520;
  YPos[93]:= 5544;
  YPos[94]:= 6568;
  YPos[95]:= 7592;
  YPos[96]:= 552;
  YPos[97]:= 1576;
  YPos[98]:= 2600;
  YPos[99]:= 3624;
  YPos[100]:= 4648;
  YPos[101]:= 5672;
  YPos[102]:= 6696;
  YPos[103]:= 7720;
  YPos[104]:= 680;
  YPos[105]:= 1704;
  YPos[106]:= 2728;
  YPos[107]:= 3752;
  YPos[108]:= 4776;
  YPos[109]:= 5800;
  YPos[110]:= 6824;
  YPos[111]:= 7848;
  YPos[112]:= 808;
  YPos[113]:= 1832;
  YPos[114]:= 2856;
  YPos[115]:= 3880;
  YPos[116]:= 4904;
  YPos[117]:= 5928;
  YPos[118]:= 6952;
  YPos[119]:= 7976;
  YPos[120]:= 936;
  YPos[121]:= 1960;
  YPos[122]:= 2984;
  YPos[123]:= 4008;
  YPos[124]:= 5032;
  YPos[125]:= 6056;
  YPos[126]:= 7080;
  YPos[127]:= 8104;
  YPos[128]:= 80;
  YPos[129]:= 1104;
  YPos[130]:= 2128;
  YPos[131]:= 3152;
  YPos[132]:= 4176;
  YPos[133]:= 5200;
  YPos[134]:= 6224;
  YPos[135]:= 7248;
  YPos[136]:= 208;
  YPos[137]:= 1232;
  YPos[138]:= 2256;
  YPos[139]:= 3280;
  YPos[140]:= 4304;
  YPos[141]:= 5328;
  YPos[142]:= 6352;
  YPos[143]:= 7376;
  YPos[144]:= 336;
  YPos[145]:= 1360;
  YPos[146]:= 2384;
  YPos[147]:= 3408;
  YPos[148]:= 4432;
  YPos[149]:= 5456;
  YPos[150]:= 6480;
  YPos[151]:= 7504;
  YPos[152]:= 464;
  YPos[153]:= 1488;
  YPos[154]:= 2512;
  YPos[155]:= 3536;
  YPos[156]:= 4560;
  YPos[157]:= 5584;
  YPos[158]:= 6608;
  YPos[159]:= 7632;
  YPos[160]:= 592;
  YPos[161]:= 1616;
  YPos[162]:= 2640;
  YPos[163]:= 3664;
  YPos[164]:= 4688;
  YPos[165]:= 5712;
  YPos[166]:= 6736;
  YPos[167]:= 7760;
  YPos[168]:= 720;
  YPos[169]:= 1744;
  YPos[170]:= 2768;
  YPos[171]:= 3792;
  YPos[172]:= 4816;
  YPos[173]:= 5840;
  YPos[174]:= 6864;
  YPos[175]:= 7888;
  YPos[176]:= 848;
  YPos[177]:= 1872;
  YPos[178]:= 2896;
  YPos[179]:= 3920;
  YPos[180]:= 4944;
  YPos[181]:= 5968;
  YPos[182]:= 6992;
  YPos[183]:= 8016;
  YPos[184]:= 976;
  YPos[185]:= 2000;
  YPos[186]:= 3024;
  YPos[187]:= 4048;
  YPos[188]:= 5072;
  YPos[189]:= 6096;
  YPos[190]:= 7120;
  YPos[191]:= 8144;
  SetLength(BITS, 8);
  BITS[0]:= 1;
  BITS[1]:= 2;
  BITS[2]:= 4;
  BITS[3]:= 8;
  BITS[4]:= 16;
  BITS[5]:= 32;
  BITS[6]:= 64;
  BITS[7]:= 128;
end.

