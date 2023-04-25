unit AmAnimate.Core.Effects.Def.Struct;

interface

uses
  System.Classes,
  System.Types,
  System.TypInfo,
  Math,
  AmAnimate.Core.Math;

type

  PAwEffectDefModeficator = ^TAwEffectDefModeficator;

  TAwEffectDefModeficator = record
  private
    FEffectMain: TAwEnumEffectMain;
    FEffectMode: TAwEnumEffectMode;
    FCalc: TAwCalcRef; // функция модификатора
    procedure CalcSet(const Value: TAwCalcRef);
  public
    property Calc: TAwCalcRef read FCalc write CalcSet;
    property EffectMain: TAwEnumEffectMain read FEffectMain;
    property EffectMode: TAwEnumEffectMode read FEffectMode;
    procedure EffectSet(AEffectMain: TAwEnumEffectMain;
      AEffectMode: TAwEnumEffectMode);
    procedure Default;
    procedure Random;
    procedure Clear;
    function IsValid: boolean;
  end;

  PAwEffectDefSide = ^TAwEffectDefSide;

  TAwEffectDefSide = record
    Count: Single; //  CountRepeat сколько повторов успеть сделать за Delay
    Delta: Single; // дельта изменения (размера, прозрачности цвета что угодно может быть)
    Effect: TAwEffectDefModeficator;// с каким эффектом выполнить изменение
    procedure Default;
    procedure Random;
    procedure Clear;
    function IsValid: boolean;
  end;

  PAwEffectDefPoint = ^TAwEffectDefPoint;

  TAwEffectDefPoint = record
    X: TAwEffectDefSide;
    Y: TAwEffectDefSide;
    procedure Default;
    procedure Random;
    procedure Clear;
    function IsValid: boolean;
  end;

  // используется что по уникальному измениять отдельную строну элемента
  PAwEffectDefBounds = ^TAwEffectDefBounds;

  TAwEffectDefBounds = record
    Left: TAwEffectDefModeficator;
    Top: TAwEffectDefModeficator;
    Width: TAwEffectDefModeficator;
    Height: TAwEffectDefModeficator;
    procedure Default;
    procedure Random;
    procedure Clear;
    function IsValid: boolean;
    procedure EffectSet(AEffectMain: TAwEnumEffectMain; AEffectMode: TAwEnumEffectMode);
  end;




implementation


{ TAwEffectDefModeficator }

procedure TAwEffectDefModeficator.Clear;
begin
  FEffectMain := atlNone;
  FEffectMode := atmNone;
  FCalc := nil;
end;

procedure TAwEffectDefModeficator.CalcSet(const Value: TAwCalcRef);
begin
  Clear;
  FCalc := Value;
end;

procedure TAwEffectDefModeficator.Default;
begin
  EffectSet(AwEnumEffectMainRec.Default, AwEnumEffectModeRec.Default);
end;

procedure TAwEffectDefModeficator.EffectSet(AEffectMain: TAwEnumEffectMain;
  AEffectMode: TAwEnumEffectMode);
begin
  Clear;
  FEffectMain := AEffectMain;
  FEffectMode := AEffectMode;
  FCalc := TAwMath.EnumToFuncRef(FEffectMain, FEffectMode);
end;

procedure TAwEffectDefModeficator.Random;
begin
  EffectSet(AwEnumEffectMainRec.Random, AwEnumEffectModeRec.Random);
end;

function TAwEffectDefModeficator.IsValid: boolean;
begin
  Result := Assigned(FCalc);
  if not Result then
  begin
    EffectSet(FEffectMain, FEffectMode);
    Result := Assigned(FCalc);
  end;
end;



{ TAwEffectDefSide }

procedure TAwEffectDefSide.Clear;
begin
  Count := 0;
  Delta := 0;
  Effect.Clear;
end;

procedure TAwEffectDefSide.Default;
begin
  Count := 1;
  Delta := 15;
  Effect.Default;
end;

function TAwEffectDefSide.IsValid: boolean;
begin
  Result := (Count > 0) and (Delta <> 0) and Effect.IsValid;
end;

procedure TAwEffectDefSide.Random;
begin
  Count := 1;
  Delta := Math.RandomRange(5, 30);
  Effect.Random;
end;

{ TAwEffectDefBounds }

procedure TAwEffectDefBounds.Clear;
begin
  Left.Clear;
  Top.Clear;
  Width.Clear;
  Height.Clear;
end;

procedure TAwEffectDefBounds.Default;
begin
  Left.Default;
  Top.Default;
  Width.Default;
  Height.Default;
end;

function TAwEffectDefBounds.IsValid: boolean;
begin
  Result := Left.IsValid or Top.IsValid or Width.IsValid or Height.IsValid;
end;

procedure TAwEffectDefBounds.Random;
begin
  Left.Random;
  Top.Random;
  Width.Random;
  Height.Random;
end;

procedure TAwEffectDefBounds.EffectSet(AEffectMain: TAwEnumEffectMain; AEffectMode: TAwEnumEffectMode);
begin
   Left.EffectSet(AEffectMain,AEffectMode);
   Top.EffectSet(AEffectMain,AEffectMode);
   Width.EffectSet(AEffectMain,AEffectMode);
   Height.EffectSet(AEffectMain,AEffectMode);
end;

{ TAwEffectDefPoint }

procedure TAwEffectDefPoint.Clear;
begin
  X.Clear;
  Y.Clear;
end;

procedure TAwEffectDefPoint.Default;
begin
  X.Default;
  Y.Default;
end;

function TAwEffectDefPoint.IsValid: boolean;
begin
  Result := X.IsValid or Y.IsValid;
end;

procedure TAwEffectDefPoint.Random;
begin
  X.Random;
  Y.Random;
end;

end.
