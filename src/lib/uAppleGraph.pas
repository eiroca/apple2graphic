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
(*
 Author :  Enrico Croce
 Program: Draw Apple 2 shapes
          Show HGR, DHR, GS $C1 images
 Version:  1.0
 Creation Date: 01/09/1996    Last Modify Date: 30/12/06
 NOTE:  Rotation not supported, Scaling and collisions supported
*)
unit uAppleGraph;

interface

uses
  SysUtils, Windows, Graphics;

type
  gMode = (mdBW, mdColor, mdMixed);
  gKind = (kdMode1, kdMode2);

type

  TSprite = record
    w, h: integer;
    x, y: integer;
    order: integer;
    data: PByteArray;
  end;

  TAppleGraphic = class
    private
      ShTbl: PByteArray;
      Sprites: array of TSprite;
    public
     bitmap: TBitmap;
     Collisions: integer;
     Scale: integer;
     Rot: integer;
     bgColor: TColor;
     fgColor: TColor;
    private
     function  ReadByte(var fin: text; flg: boolean): byte;
     procedure MakeSprite(var fin: text; flg: boolean; cnt, dxInt, dyint, svint, xint, yint: integer);
    public
     constructor Create(mode: integer);
     destructor Destroy; override;

     procedure Draw(Shape: integer; XPos, YPos: integer);
     procedure XDraw(Shape: integer; XPos, YPos: integer);
     function  LoadShape(FileName: string): integer;

     procedure DrawHGR(Path: string; mode: gMode);
     procedure DrawDHR(Path: string; kind: gKind; mode: gMode);
     procedure DrawGS(Path: string);

     procedure DrawSprites;
     procedure DrawSprite(cnt: integer; px, py: integer);
     function  LoadSprites(Path: string; merge: boolean): integer;
     procedure ResetPos(sx, sy, MaxX: integer);
     procedure SaveSprites(Path: string);

     procedure Clear;
  end;

implementation

const
  BITS: array [0..7] of word = ($01,$02,$04,$08,$10,$20,$40,$80);
  HexStr = '0123456789ABCDEF';

type

  PHGRImage = ^HGRImage;
  HGRImage = array[0..8191] of byte;

  PDHRImage = ^DHRImage;
  DHRImage = array[0..16383] of byte;

  TPal = array[0..255] of TColor;

  PGSPic = ^GSPic;
  GSPic = record
    img: array[0..31999] of byte;
    scn: array[0..199] of byte;
    fil: array[200..255] of byte;
    pal: array[0..15,0..15] of word;
  end;

var
  YPos  : array[0..191] of integer;
  HGRCol: array[0..7] of TColor;
  DHRCol: array[0..15] of TColor;
  BWCol : array[0..1] of TColor;

constructor TAppleGraphic.Create(mode: integer);
begin
  Collisions:= 0;
  Scale:= 1;
  Rot:= 0;
  bgColor:= $000000;
  fgColor:= $FFFFFF;
  bitmap:= TBitmap.Create;
  case mode of
    0: begin
      bitmap.Width:= 280;
      bitmap.Height:= 192;
    end;
    1: begin
      bitmap.Width:= 560;
      bitmap.Height:= 192;
    end;
    2: begin
      bitmap.Width:= 140;
      bitmap.Height:= 192;
    end;
    3: begin
      bitmap.Width := 320;
      bitmap.Height:= 200;
    end;
    4: begin
      bitmap.Width := 640;
      bitmap.Height:= 200;
    end;
    else begin
      bitmap.Width := 640;
      bitmap.Height:= 480;
    end;
  end;
  Clear;
end;

procedure TAppleGraphic.Clear;
var
  r: TRect;
begin
  r.Left:= 0;
  r.Top:= 0;
  r.Right:= bitmap.Width;
  r.Bottom:= bitmap.Height;
  bitmap.Canvas.Brush.Color:= bgColor;
  bitmap.Canvas.FillRect(r);
end;

procedure TAppleGraphic.Draw(Shape: integer; XPos, YPos: integer);
var
  Base: integer;
  VByte: integer;
  Vector: integer;
  i: integer;
  c: TColor;
begin
  Collisions:= 0;
  if (ShTbl<>nil) and (Shape <= ShTbl^[0]) and (Shape>=1) then begin
    Base:= PWordArray(ShTbl)^[Shape];
    VByte:= ShTbl^[Base];
    while VByte <> 0 do begin
      repeat
        for i:= 1 to scale do begin
          Vector:= VByte and $07;
          if Vector > 3 then begin
            Dec(Vector,4);
            c:= bitmap.canvas.Pixels[XPos, YPos];
            if c <> bgColor then inc(Collisions);
            bitmap.canvas.Pixels[XPos, YPos]:= fgColor;
          end;
          case Vector of
            0: YPos:= YPos - 1;
            1: XPos:= XPos + 1;
            2: YPos:= YPos + 1;
            3: XPos:= XPos - 1;
          end;
        end;
        VByte:= VByte shr 3;
      until VByte = 0;
      inc(Base);
      VByte:= ShTbl^[Base];
    end;
  end;
end;

procedure TAppleGraphic.XDraw(Shape: integer; XPos, YPos: integer);
var
  Base: integer;
  VByte: integer;
  Vector: integer;
  i: integer;
  c: TColor;
begin
  Collisions:= 0;
  if (ShTbl<>nil) and (Shape <= ShTbl^[0]) and (Shape>=1) then begin
    Base:= PWordArray(ShTbl)^[Shape];
    VByte:= ShTbl^[Base];
    while VByte <> 0 do begin
      repeat
        for i:= 1 to scale do begin
          Vector:= VByte and $07;
          if Vector > 3 then begin
            Dec(Vector,4);
            c:= bitmap.canvas.Pixels[XPos, YPos];
            if c <> bgColor then inc(Collisions);
            bitmap.canvas.Pixels[XPos, YPos]:=  c xor fgColor;
          end;
          case Vector of
            0: YPos:= YPos - 1;
            1: XPos:= XPos + 1;
            2: YPos:= YPos + 1;
            3: XPos:= XPos - 1;
          end;
        end;
        VByte:= VByte shr 3;
      until VByte = 0;
      inc(Base);
      VByte:= ShTbl^[Base];
    end;
  end;
end;

function TAppleGraphic.LoadShape(FileName: string): integer;
var
  fin: file;
  siz: word;
begin
  assign(fin, FileName);
  Reset(fin, 1);
  siz:= FileSize(fin);
  GetMem(ShTbl, Siz);
  if ShTbl <> nil then begin
    BlockRead(fin, ShTbl^, Siz);
  end;
  Close(fin);
  LoadShape:= ShTbl^[0];
end;

destructor TAppleGraphic.Destroy;
begin
  bitmap.Free;
end;

procedure TAppleGraphic.DrawHGR(Path: string; mode: gMode);
var
  f: file;
  mappa: PHGRImage;
  y, bx, ox, tx: integer;
  fl1, fl2: integer;
  v, vl: integer;
begin
  bitmap.Width:= 280;
  bitmap.Height:= 192;
  New(Mappa);
  Assign(f, Path);
  Reset(f,1);
  BlockRead(f, mappa^, SizeOf(Mappa^));
  close(f);
  case mode of
    mdBW: begin
      for y:= 0 to 191 do begin
        tx:= 0;
        for bx:= 0 to 39 do begin
          vl:= mappa^[YPos[y] + bx];
          for ox:= 0 to 6 do begin
            bitmap.canvas.Pixels[tx , y]:= BWCol[(vl and 1)];
            inc(tx);
            vl:= vl shr 1;
          end;
        end;
      end;
    end;
    mdColor: begin
      for y:= 0 to 191 do begin
        bx:= 0;
        tx:= 0;
        repeat
          vl:= mappa^[YPos[y] + bx];
          v:= mappa^[YPos[y] + bx + 1];
          if (vl and 128) <> 0 then fl1:= 4 else fl1:= 0;
          if (v and 128) <> 0 then fl2:= 4 else fl2:= 0;
          vl:= (vl and 127) + (v and 127) shl 7;
          for ox:= 0 to 6 do begin
            v := vl and 3;
            vl:= vl shr 2;
            if ox < 3 then begin
              bitmap.canvas.Pixels[tx, y]:= HGRCol[v+fl1];
              bitmap.canvas.Pixels[tx + 1, y]:= HGRCol[v+fl1];
            end
            else if ox > 3 then begin
              bitmap.canvas.Pixels[tx, y]:= HGRCol[v+fl2];
              bitmap.canvas.Pixels[tx + 1, y]:= HGRCol[v+fl2];
            end
            else begin
              bitmap.canvas.Pixels[tx, y]:= HGRCol[v+fl1];
              bitmap.canvas.Pixels[tx + 1, y]:= HGRCol[v+fl2];
            end;
            inc(tx, 2);
          end;
          inc(bx, 2);
        until bx > 38;
      end;
    end;
    mdMixed: begin
      for y:= 0 to 191 do begin
        bx:= 0;
        tx:= 0;
        repeat
          vl:= mappa^[YPos[y] + bx];
          v:= mappa^[YPos[y] + bx + 1];
          if (vl and 128) <> 0 THEN fl1:= 4 ELSE fl1:= 0;
          if (v and 128) <> 0 THEN fl2:= 4 ELSE fl2:= 0;
          vl:= (vl and 127) + (v and 127) shl 7;
          for ox:= 0 to 6 do begin
            v := vl and 3;
            vl:= vl shr 2;
            if ox < 3 then begin
              bitmap.canvas.Pixels[tx, y]:= HGRCol[v+fl1] * (v and 1);
              bitmap.canvas.Pixels[tx + 1, y]:= HGRCol[v+fl1] * ((v and 2) shr 1);
            end
            else if ox > 3 then begin
              bitmap.canvas.Pixels[tx, y]:= HGRCol[v+fl2] * (v and 1);
              bitmap.canvas.Pixels[tx + 1, y]:= HGRCol[v+fl2] * ((v and 2) shr 1);
            end
            else begin
              bitmap.canvas.Pixels[tx, y]:= HGRCol[v+fl1] * (v and 1);
              bitmap.canvas.Pixels[tx + 1, y]:= HGRCol[v+fl2] * ((v and 2) shr 1);
            end;
            inc(tx, 2);
          end;
          inc(bx, 2);
        until bx > 38;
      end;
    end;
  end;
  Dispose(Mappa);
end;

procedure TAppleGraphic.DrawDHR(Path: string; kind: gKind; mode: gMode);
var
  f: file;
  mappa: PDHRImage;
  y, bx, ox, tx, ty: integer;
  of1, of2: integer;
  vl1, vl2: integer;
  c: TColor;
begin
  bitmap.Width:= 560;
  bitmap.Height:= 192*2;
  new(mappa);
  Assign(f, Path);
  Reset(f,1);
  BlockRead(f, mappa^, SizeOf(Mappa^));
  close(f);
  if kind=kdMode1 then begin
    of1:= 0;
    of2:= 7;
  end
  else begin
    of1:= 7;
    of2:= 0;
  end;
  case mode of
    mdBW: begin
      for y:= 0 to 191 do begin
        ty:= y shl 1;
        for bx:= 0 to 39 do begin
          vl1:= mappa^[YPos[y] + bx ];
          vl2:= mappa^[YPos[y] + bx + 8192];
          tx:= bx * 14 + of1;
          for ox:= 0 to 6 do begin
            c:= BWCol[(vl1 and 1)];
            bitmap.canvas.Pixels[tx, ty]:= c;
            bitmap.canvas.Pixels[tx, ty+1]:= c;
            vl1:= vl1 shr 1;
            inc(tx);
          end;
          tx:= bx * 14 + of2;
          for ox:= 0 to 6 do begin
            c:= BWCol[(vl2 and 1)];
            bitmap.canvas.Pixels[tx, ty]:= c;
            bitmap.canvas.Pixels[tx, ty+1]:= c;
            vl2:= vl2 shr 1;
            inc(tx);
          end;
        end;
      end;
    end;
  end;
  Dispose(Mappa);
end;

procedure TAppleGraphic.DrawGS(Path: string);
  procedure DecodePal(var Pic: GSPic; var pal: TPal);
  var
    i, j, off: integer;
    tmp: integer;
    rr, gg, bb: integer;
  begin
    off:= 0;
    for j:= 0 to 15 do begin
      for i:= 0 to 15 do begin
        tmp:= Pic.pal[j, i];
        bb:= (tmp and $0F00) shr 8 shl 4;
        gg:= (tmp and $00F0) shr 4 shl 4;
        rr:= (tmp and $000F)       shl 4;
        pal[off]:= rr shl 16 + gg shl 8 + bb;
        inc(off);
      end;
    end;
  end;
  function GetColor(var Pic: GSPic; x, y: integer): integer;
  var
    tmp: integer;
  begin
    tmp:= Pic.img[y*160+x div 2];
    if odd(x) then begin
      GetColor:= Pic.scn[y] shr 4 + tmp and $0F
    end
    else begin
      GetColor:= Pic.scn[y] shr 4 + tmp shr 4;
    end;
  end;
var
  f:  file;
  rd: integer;
  buf: GSPic;
  pal: TPal;
  x, y: integer;
  c: TColor;
begin
  bitmap.Width:= 320;
  bitmap.Height:= 200;
  Assign(f, Path);
  reset(f,1);
  blockread(f, buf, 32768, rd);
  if rd <> 32768 then exit;
  DecodePal(Buf, pal);
  for y:= 0 to 199 do begin
    for x:= 0 to 319 do begin
      c:= pal[GetColor(buf, x, y)];
      bitmap.canvas.Pixels[x, y]:= c;
    end;
  end;
end;

function TAppleGraphic.ReadByte(var fin: text; flg: boolean): byte;
var
  Data: string;
  Value: word;
  qa: integer;
begin
  if flg then read(fin, value)
  else begin
    Readln(fin, Data);
    case Data[1] of
      '%': begin
        Value := 0;
        for QA := 2 to length(Data) do begin
          if Data[QA] = '1' then inc(Value, 1 shl (length(data) - QA));
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
  ReadByte:= value;
end;

procedure TAppleGraphic.MakeSprite(var fin: text; flg: boolean; cnt, dxInt, dyint, svint, xint, yint: integer);
var
  i, t: integer;
begin
  with Sprites[cnt] do begin
    w:= dxint;
    h:= dyint;
    x:= xint;
    y:= yint;
    order:= svint;
    GetMem(data, w*h);
    if SVInt <> 2 then begin
      for i:= 0 TO DYInt - 1 do begin
        for t:= 0 TO DXInt - 1 do begin
          data^[T*h+I]:= ReadByte(fin, flg);
        end;
      end;
    end
    else begin
      for t:= 0 TO DXInt - 1 do begin
        for i:= 0 TO DYInt - 1 do begin
          data^[T*h+I]:= ReadByte(fin, flg);
        end;
      end;
    end;
  end;
end;

function TAppleGraphic.LoadSprites(Path: string; merge: boolean): integer;
var
  fin : text;
  buf: array[0..8191] of byte;
  flg: boolean;
  DXInt, DYInt, SVInt, XInt, YInt : word;
begin
  assign(fin, Path);
  SetTextBuf(fin, buf, sizeof(buf));
  Reset(fin);
  flg:= false;
  if merge then begin
    Result:= high(Sprites);
    if (Result<0) then begin
      Result:= 0;
    end;
  end
  else begin
    Result:= 0;
  end;
  repeat
    readln(fin, DXInt, DYInt, SVInt, XInt, YInt);
    if DXInt = 0 then begin
      if DYInt = 0 then begin
        Close(fin);
        break;
      end;
      if DYInt = 1 then flg:= true else flg:= false;
      continue;
    end;
    SetLength(Sprites, Result+1);
    MakeSprite(fin, flg, Result, dxInt, dyint, svint, xint, yint);
    inc(Result);
  until false;
end;

procedure TAppleGraphic.ResetPos(sx, sy, MaxX: integer);
var
  px, py: integer;
  wx, wy: integer;
  my: integer;
  i: integer;
begin
  px:= 0;
  py:= 0;
  my:= 0;
  for i:= low(Sprites) to high(Sprites) do begin
    with Sprites[i] do begin
      wx:= w * 8;
      wy:= h;
      if ((px+wx) >= MaxX) then begin
        px:= 0;
        py:= py + my + sx;
        my:= 0;
      end;
      x:= px;
      y:= py;
      px:= px + wx + sy;
      if wy>my then begin
        my:= wy;
      end;
    end;
  end;
end;

procedure TAppleGraphic.SaveSprites(Path: string);
var
  fout: text;
  s, t, i: integer;
begin
  assign(fout, Path);
  Rewrite(fout);
  for s:= low(Sprites) to high(Sprites) do begin
    with Sprites[s] do begin
      writeln(fout, w, ' ', h, ' ', order, ' ', x, ' ', y);
      if order=2 then begin
        for t:= 0 to w - 1 do begin
          for i:= 0 to h - 1 do begin
            writeln(fout, data^[t*h+i]);
          end;
        end;
      end
      else begin
        for i:= 0 to h - 1 do begin
          for t:= 0 to w - 1 do begin
            writeln(fout, data^[t*h+i]);
          end;
        end;
      end;
    end;
  end;
  writeln(fout, '0 0 0 0 0');
  Close(fout);
end;

procedure TAppleGraphic.DrawSprite(cnt: integer; px, py: integer);
var
  i, t, k: integer;
  pos: integer;
  value: byte;
begin
  with Sprites[cnt] do begin
    pos:= 0;
    x:= px;
    y:= py;
    for t:= 0 TO w - 1 do begin
      py:= y;
      for i:= 0 TO h - 1 do begin
        value:= data^[pos];
        inc(pos);
        for k:= 0 TO 7 do begin
          if (Value and BITS[7-k]) <> 0 then begin
            bitmap.canvas.Pixels[px + k, py]:= fgColor;
          end
          else begin
            bitmap.canvas.Pixels[px + k, py]:= bgColor;
          end;
        end;
        inc(py);
      end;
      inc(px, 8);
    end;
  end;
end;

procedure TAppleGraphic.DrawSprites;
var
  i: integer;
begin
  for i:= low(Sprites) to high(Sprites) do begin
    with Sprites[i] do begin
      DrawSprite(i, x, y);
    end;
  end;
end;

procedure InitAplGraph;
begin
  YPos[  0]:=    0;
  YPos[  1]:= 1024;
  YPos[  2]:= 2048;
  YPos[  3]:= 3072;
  YPos[  4]:= 4096;
  YPos[  5]:= 5120;
  YPos[  6]:= 6144;
  YPos[  7]:= 7168;
  YPos[  8]:=  128;
  YPos[  9]:= 1152;
  YPos[ 10]:= 2176;
  YPos[ 11]:= 3200;
  YPos[ 12]:= 4224;
  YPos[ 13]:= 5248;
  YPos[ 14]:= 6272;
  YPos[ 15]:= 7296;
  YPos[ 16]:=  256;
  YPos[ 17]:= 1280;
  YPos[ 18]:= 2304;
  YPos[ 19]:= 3328;
  YPos[ 20]:= 4352;
  YPos[ 21]:= 5376;
  YPos[ 22]:= 6400;
  YPos[ 23]:= 7424;
  YPos[ 24]:=  384;
  YPos[ 25]:= 1408;
  YPos[ 26]:= 2432;
  YPos[ 27]:= 3456;
  YPos[ 28]:= 4480;
  YPos[ 29]:= 5504;
  YPos[ 30]:= 6528;
  YPos[ 31]:= 7552;
  YPos[ 32]:=  512;
  YPos[ 33]:= 1536;
  YPos[ 34]:= 2560;
  YPos[ 35]:= 3584;
  YPos[ 36]:= 4608;
  YPos[ 37]:= 5632;
  YPos[ 38]:= 6656;
  YPos[ 39]:= 7680;
  YPos[ 40]:=  640;
  YPos[ 41]:= 1664;
  YPos[ 42]:= 2688;
  YPos[ 43]:= 3712;
  YPos[ 44]:= 4736;
  YPos[ 45]:= 5760;
  YPos[ 46]:= 6784;
  YPos[ 47]:= 7808;
  YPos[ 48]:=  768;
  YPos[ 49]:= 1792;
  YPos[ 50]:= 2816;
  YPos[ 51]:= 3840;
  YPos[ 52]:= 4864;
  YPos[ 53]:= 5888;
  YPos[ 54]:= 6912;
  YPos[ 55]:= 7936;
  YPos[ 56]:=  896;
  YPos[ 57]:= 1920;
  YPos[ 58]:= 2944;
  YPos[ 59]:= 3968;
  YPos[ 60]:= 4992;
  YPos[ 61]:= 6016;
  YPos[ 62]:= 7040;
  YPos[ 63]:= 8064;
  YPos[ 64]:=   40;
  YPos[ 65]:= 1064;
  YPos[ 66]:= 2088;
  YPos[ 67]:= 3112;
  YPos[ 68]:= 4136;
  YPos[ 69]:= 5160;
  YPos[ 70]:= 6184;
  YPos[ 71]:= 7208;
  YPos[ 72]:=  168;
  YPos[ 73]:= 1192;
  YPos[ 74]:= 2216;
  YPos[ 75]:= 3240;
  YPos[ 76]:= 4264;
  YPos[ 77]:= 5288;
  YPos[ 78]:= 6312;
  YPos[ 79]:= 7336;
  YPos[ 80]:=  296;
  YPos[ 81]:= 1320;
  YPos[ 82]:= 2344;
  YPos[ 83]:= 3368;
  YPos[ 84]:= 4392;
  YPos[ 85]:= 5416;
  YPos[ 86]:= 6440;
  YPos[ 87]:= 7464;
  YPos[ 88]:=  424;
  YPos[ 89]:= 1448;
  YPos[ 90]:= 2472;
  YPos[ 91]:= 3496;
  YPos[ 92]:= 4520;
  YPos[ 93]:= 5544;
  YPos[ 94]:= 6568;
  YPos[ 95]:= 7592;
  YPos[ 96]:=  552;
  YPos[ 97]:= 1576;
  YPos[ 98]:= 2600;
  YPos[ 99]:= 3624;
  YPos[100]:= 4648;
  YPos[101]:= 5672;
  YPos[102]:= 6696;
  YPos[103]:= 7720;
  YPos[104]:=  680;
  YPos[105]:= 1704;
  YPos[106]:= 2728;
  YPos[107]:= 3752;
  YPos[108]:= 4776;
  YPos[109]:= 5800;
  YPos[110]:= 6824;
  YPos[111]:= 7848;
  YPos[112]:=  808;
  YPos[113]:= 1832;
  YPos[114]:= 2856;
  YPos[115]:= 3880;
  YPos[116]:= 4904;
  YPos[117]:= 5928;
  YPos[118]:= 6952;
  YPos[119]:= 7976;
  YPos[120]:=  936;
  YPos[121]:= 1960;
  YPos[122]:= 2984;
  YPos[123]:= 4008;
  YPos[124]:= 5032;
  YPos[125]:= 6056;
  YPos[126]:= 7080;
  YPos[127]:= 8104;
  YPos[128]:=   80;
  YPos[129]:= 1104;
  YPos[130]:= 2128;
  YPos[131]:= 3152;
  YPos[132]:= 4176;
  YPos[133]:= 5200;
  YPos[134]:= 6224;
  YPos[135]:= 7248;
  YPos[136]:=  208;
  YPos[137]:= 1232;
  YPos[138]:= 2256;
  YPos[139]:= 3280;
  YPos[140]:= 4304;
  YPos[141]:= 5328;
  YPos[142]:= 6352;
  YPos[143]:= 7376;
  YPos[144]:=  336;
  YPos[145]:= 1360;
  YPos[146]:= 2384;
  YPos[147]:= 3408;
  YPos[148]:= 4432;
  YPos[149]:= 5456;
  YPos[150]:= 6480;
  YPos[151]:= 7504;
  YPos[152]:=  464;
  YPos[153]:= 1488;
  YPos[154]:= 2512;
  YPos[155]:= 3536;
  YPos[156]:= 4560;
  YPos[157]:= 5584;
  YPos[158]:= 6608;
  YPos[159]:= 7632;
  YPos[160]:=  592;
  YPos[161]:= 1616;
  YPos[162]:= 2640;
  YPos[163]:= 3664;
  YPos[164]:= 4688;
  YPos[165]:= 5712;
  YPos[166]:= 6736;
  YPos[167]:= 7760;
  YPos[168]:=  720;
  YPos[169]:= 1744;
  YPos[170]:= 2768;
  YPos[171]:= 3792;
  YPos[172]:= 4816;
  YPos[173]:= 5840;
  YPos[174]:= 6864;
  YPos[175]:= 7888;
  YPos[176]:=  848;
  YPos[177]:= 1872;
  YPos[178]:= 2896;
  YPos[179]:= 3920;
  YPos[180]:= 4944;
  YPos[181]:= 5968;
  YPos[182]:= 6992;
  YPos[183]:= 8016;
  YPos[184]:=  976;
  YPos[185]:= 2000;
  YPos[186]:= 3024;
  YPos[187]:= 4048;
  YPos[188]:= 5072;
  YPos[189]:= 6096;
  YPos[190]:= 7120;
  YPos[191]:= 8144;

  HGRCol[0]:= $000000;
  HGRCol[1]:= $FF0000;
  HGRCol[2]:= $00FF00;
  HGRCol[3]:= $FFFFFF;
  HGRCol[4]:= $000000;
  HGRCol[5]:= $0000F0;
  HGRCol[6]:= $00FFFF;
  HGRCol[7]:= $FFFFFF;

  DHRCol[ 0]:= $000000;
  DHRCol[ 1]:= $800000;
  DHRCol[ 2]:= $008000;
  DHRCol[ 3]:= $FF0000;
  DHRCol[ 4]:= $008080;
  DHRCol[ 5]:= $C0C0C0;
  DHRCol[ 6]:= $00FF00;
  DHRCol[ 7]:= $00FF00;
  DHRCol[ 8]:= $0000FF;
  DHRCol[ 9]:= $FF00FF;
  DHRCol[10]:= $808080;
  DHRCol[11]:= $FFFF00;
  DHRCol[12]:= $0000FF;
  DHRCol[13]:= $0000FF;
  DHRCol[14]:= $00FFFF;
  DHRCol[15]:= $FFFFFF;

  BWCol[0]:= $000000;
  BWCol[1]:= $FFFFFF;

end;

initialization
  InitAplGraph;
end.

