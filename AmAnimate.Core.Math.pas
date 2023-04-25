unit AmAnimate.Core.Math;

interface
uses
  System.Classes,
  System.Types,
  System.TypInfo,
  Math;


 type

  TAwCalcRef = reference to function(Progress: Real): Real;
  TAwCalcStd = function(Progress: Real): Real;

  TAwEnumEffectMain = (atlNone, atlLine, atlPower2, atlPower3, atlPower4,
    atlPower5, atlPower6, atlSin, atlElastic, atlBack, atlLowWave,
    atlMiddleWave, atlHighWave, atlBounce, atlCircle, atlSwing10, atlSwing50,
    atlSwing100, atlSwing200);

  TAwEnumEffectMode = (atmNone, atmIn, atmInInverted, atmInSnake,
    atmInSnakeInverted, atmOut, atmOutInverted, atmOutSnake,
    atmOutSnakeInverted, atmInOut, atmInOutMirrored, atmInOutCombined, atmOutIn,
    atmOutInMirrored, atmOutInCombined);

  AwEnumEffectModeRec = record
    class function Count: integer; static;
    class function Random: TAwEnumEffectMode; static;
    class function Default: TAwEnumEffectMode; static;
    class procedure ToStrings(L: TStrings); static;
    class function ToString(Value: TAwEnumEffectMode): string; static;
    class function ToEnum(Value: string): TAwEnumEffectMode; static;
  end;

  AwEnumEffectMainRec = record
    class function Count: integer; static;
    class function Random: TAwEnumEffectMain; static;
    class function Default: TAwEnumEffectMain; static;
    class procedure ToStrings(L: TStrings); static;
    class function ToString(Value: TAwEnumEffectMain): string; static;
    class function ToEnum(Value: string): TAwEnumEffectMain; static;
  end;

  // математика
  TAwMath = class(TObject)
    class function Linear(Progress: Real): Real; static;
    class function Power2(Progress: Real): Real; static;
    class function Power3(Progress: Real): Real; static;
    class function Power4(Progress: Real): Real; static;
    class function Power5(Progress: Real): Real; static;
    class function Power6(Progress: Real): Real; static;
    class function Sinus(Progress: Real): Real; static;
    class function Elastic(Progress: Real): Real; static;
    class function LowWave(Progress: Real): Real; static;
    class function MiddleWave(Progress: Real): Real; static;
    class function HighWave(Progress: Real): Real; static;
    class function Back(Progress: Real): Real; static;
    class function Bounce(Progress: Real): Real; static;
    class function Circle(Progress: Real): Real; static;

    class function SwingCustom(Progress, Swings: Real): Real; static;
    class function Swing10(Progress: Real): Real; static;
    class function Swing50(Progress: Real): Real; static;
    class function Swing100(Progress: Real): Real; static;
    class function Swing200(Progress: Real): Real; static;

    class function SwingTime(CountRepeat, Diff: Single; Progress: Real): Single; static;
    class function SwingToSingle(StartValue, EndValue: Single; Progress: Real; const Func: TAwCalcRef): Single; static;

    class function MoveEffect(Start, Stop: TPointF; Progress: Real; FuncCalcX, FuncCalcY: TAwCalcRef): TPointF;static;

    class function EnumToFuncRef(Line: TAwEnumEffectMain; Mode: TAwEnumEffectMode): TAwCalcRef;static;
    class function EnumLineToFunc(Line: TAwEnumEffectMain): TAwCalcStd; static;
    class function EnumModeToFunc(Func: TAwCalcStd; Mode: TAwEnumEffectMode) : TAwCalcRef; static;
  end;

implementation


{ AwEnumEffectModeRec }

class function AwEnumEffectModeRec.Count: integer;
begin
  Result := integer(System.High(TAwEnumEffectMode)) + 1;
end;

class function AwEnumEffectModeRec.Default: TAwEnumEffectMode;
begin
  Result := atmIn;
end;

class function AwEnumEffectModeRec.Random: TAwEnumEffectMode;
begin
  Result := TAwEnumEffectMode(Math.RandomRange(1, Count));
end;

class function AwEnumEffectModeRec.ToEnum(Value: string): TAwEnumEffectMode;
var
  i: integer;
begin
  i := GetEnumValue(TypeInfo(TAwEnumEffectMode), Value);
  if (i >= 0) and (i < Count) then
    Result := TAwEnumEffectMode(i)
  else
    Result := TAwEnumEffectMode(0);
end;

class function AwEnumEffectModeRec.ToString(Value: TAwEnumEffectMode): string;
begin
  Result := GetEnumName(TypeInfo(TAwEnumEffectMode), ord(Value));
end;

class procedure AwEnumEffectModeRec.ToStrings(L: TStrings);
var
  i: integer;
begin
  L.BeginUpdate;
  try
    L.Clear;
    for i := 0 to Count - 1 do
      L.Add(ToString(TAwEnumEffectMode(i)));
  finally
    L.EndUpdate;
  end;
end;

{ AwEnumEffectMainRec }

class function AwEnumEffectMainRec.Count: integer;
begin
  Result := integer(System.High(TAwEnumEffectMain)) + 1;
end;

class function AwEnumEffectMainRec.Default: TAwEnumEffectMain;
begin
  Result := atlLine;
end;

class function AwEnumEffectMainRec.Random: TAwEnumEffectMain;
begin
  Result := TAwEnumEffectMain(Math.RandomRange(1, Count));
end;

class function AwEnumEffectMainRec.ToEnum(Value: string): TAwEnumEffectMain;
var
  i: integer;
begin
  i := GetEnumValue(TypeInfo(TAwEnumEffectMain), Value);
  if (i >= 0) and (i < Count) then
    Result := TAwEnumEffectMain(i)
  else
    Result := TAwEnumEffectMain(0);
end;

class function AwEnumEffectMainRec.ToString(Value: TAwEnumEffectMain): string;
begin
  Result := GetEnumName(TypeInfo(TAwEnumEffectMain), ord(Value));
end;

class procedure AwEnumEffectMainRec.ToStrings(L: TStrings);
var
  i: integer;
begin
  L.BeginUpdate;
  try
    L.Clear;
    for i := 0 to Count - 1 do
      L.Add(ToString(TAwEnumEffectMain(i)));
  finally
    L.EndUpdate;
  end;
end;

{ TAwMath }

class function TAwMath.Linear(Progress: Real): Real;
begin
  Result := Progress;
end;

class function TAwMath.Power2(Progress: Real): Real;
begin
  Result := Progress * Progress;
end;

class function TAwMath.Power3(Progress: Real): Real;
begin
  Result := Power(Progress, 3);
end;

class function TAwMath.Power4(Progress: Real): Real;
begin
  Result := Power(Progress, 4);
end;

class function TAwMath.Power5(Progress: Real): Real;
begin
  Result := Power(Progress, 5);
end;

class function TAwMath.Power6(Progress: Real): Real;
begin
  Result := Power(Progress, 6);
end;

class function TAwMath.Sinus(Progress: Real): Real;
begin
  Result := Sin(Progress * (Pi / 2));
end;

class function TAwMath.Elastic(Progress: Real): Real;
begin
  Result := (Sin(Progress * Pi * (0.2 + 2.5 * Progress * Progress * Progress)) *
    Power(1 - Progress, 2.2) + Progress) * (1 + (1.2 * (1 - Progress)));
end;

class function TAwMath.LowWave(Progress: Real): Real;
begin
  Result := Progress + (Sin(Progress * 3 * Pi) * 0.1);
end;

class function TAwMath.MiddleWave(Progress: Real): Real;
begin
  Result := Progress + (Sin(Progress * 3 * Pi) * 0.2);
end;

class function TAwMath.HighWave(Progress: Real): Real;
begin
  Result := Progress + (Sin(Progress * 3 * Pi) * 0.4);
end;

class function TAwMath.Back(Progress: Real): Real;
begin
  Result := Progress * Progress * ((2.70158 * Progress) - 1.70158);
end;

class function TAwMath.Bounce(Progress: Real): Real;
const
  Base: Real = 7.5625;
begin
  if Progress < (1 / 2.75) then
    Result := Base * Progress * Progress
  else if Progress < (2 / 2.75) then
  begin
    Progress := Progress - (1.5 / 2.75);
    Result := (Base * Progress) * Progress + 0.75;
  end
  else if Progress < (2.5 / 2.75) then
  begin
    Progress := Progress - (2.25 / 2.75);
    Result := (Base * Progress) * Progress + 0.9375;
  end
  else
  begin
    Progress := Progress - (2.625 / 2.75);
    Result := (Base * Progress) * Progress + 0.984375;
  end;
end;

class function TAwMath.Circle(Progress: Real): Real;
begin
  Result := 1 - Sqrt(1 - Progress * Progress);
end;

class function TAwMath.SwingCustom(Progress, Swings: Real): Real;
begin
  Result := Progress + (Sin(Progress * Swings * Pi) * (1 / Swings));
end;

class function TAwMath.Swing10(Progress: Real): Real;
begin
  Result := SwingCustom(Progress, 10);
end;

class function TAwMath.Swing50(Progress: Real): Real;
begin
  Result := SwingCustom(Progress, 50);
end;

class function TAwMath.Swing100(Progress: Real): Real;
begin
  Result := SwingCustom(Progress, 100);
end;

class function TAwMath.Swing200(Progress: Real): Real;
begin
  Result := SwingCustom(Progress, 200);
end;

class function TAwMath.SwingTime(CountRepeat, Diff: Single;
  Progress: Real): Single;
begin
  Result := Diff * Sin(Progress * CountRepeat * Pi * 2);
end;

class function TAwMath.SwingToSingle(StartValue, EndValue: Single;
  Progress: Real; const Func: TAwCalcRef): Single;
begin
  if Assigned(Func) then
    Progress := Func(Progress);
  Result := StartValue + ((EndValue - StartValue) * Progress);
end;

class function TAwMath.MoveEffect(Start, Stop: TPointF; Progress: Real; FuncCalcX, FuncCalcY: TAwCalcRef) : TPointF;
//var
 // Ref1, Ref2: TAwCalcRef;
begin
 { Ref1 := EnumToFuncRef(EffectMainX, TAwEnumEffectMode.atmIn);
  Ref2 := TAwMath.EnumToFuncRef(TAwEnumEffectMain.atlCircle,
    TAwEnumEffectMode.atmInSnake);
    }
  Result.X := SwingToSingle(Start.X, Stop.X, Progress, FuncCalcX);
  Result.Y := SwingToSingle(Start.Y, Stop.Y, Progress, FuncCalcY);
end;

class function TAwMath.EnumLineToFunc(Line: TAwEnumEffectMain): TAwCalcStd;
begin
  case Line of
    atlLine:
      Result := Linear;
    atlPower2:
      Result := Power2;
    atlPower3:
      Result := Power3;
    atlPower4:
      Result := Power4;
    atlPower5:
      Result := Power5;
    atlPower6:
      Result := Power6;
    atlSin:
      Result := Sinus;
    atlElastic:
      Result := Elastic;
    atlLowWave:
      Result := LowWave;
    atlMiddleWave:
      Result := MiddleWave;
    atlHighWave:
      Result := HighWave;
    atlBack:
      Result := Back;
    atlBounce:
      Result := Bounce;
    atlCircle:
      Result := Circle;
    atlSwing10:
      Result := Swing10;
    atlSwing50:
      Result := Swing50;
    atlSwing100:
      Result := Swing100;
    atlSwing200:
      Result := Swing200;
  else
    Result := nil;
  end;
end;

class function TAwMath.EnumModeToFunc(Func: TAwCalcStd; Mode: TAwEnumEffectMode)
  : TAwCalcRef;
const
  EPSILON = 0.0000001;
begin
  if not Assigned(Func) then
    exit(nil);
  case Mode of
    atmIn:
      Result := Func;
    atmOut:
      Result :=
    function(Progress: Real): Real
    begin
      Result := Func(1 - Progress);
    end;
    atmInOut:
      Result :=
    function(Progress: Real): Real
    begin
      if CompareValue(Progress, 0.5, EPSILON) < GreaterThanValue then
        Progress := Progress / 0.5
      else
        Progress := 1 - ((Progress - 0.5) / 0.5);
      Result := Func(Progress);
    end;
    atmInInverted:
      Result :=
    function(Progress: Real): Real
    begin
      Result := 1 - Func(1 - Progress);
    end;
    atmOutInverted:
      Result :=
    function(Progress: Real): Real
    begin
      Result := 1 - Func(Progress);
    end;
    atmOutIn:
      Result :=
    function(Progress: Real): Real
    begin
      if CompareValue(Progress, 0.5, EPSILON) < GreaterThanValue then
        Progress := Progress / 0.5
      else
        Progress := 1 - ((Progress - 0.5) / 0.5);
      Result := Func(1 - Progress);
    end;
    atmInOutMirrored:
      Result :=
    function(Progress: Real): Real
    begin
      if CompareValue(Progress, 0.5, EPSILON) < GreaterThanValue then
        Progress := Progress / 0.5
      else
        Progress := 1 - ((Progress - 0.5) / 0.5);
      Result := 1 - Func(1 - Progress);
    end;
    atmOutInMirrored:
      Result :=
    function(Progress: Real): Real
    begin
      if CompareValue(Progress, 0.5, EPSILON) < GreaterThanValue then
        Progress := Progress / 0.5
      else
        Progress := 1 - ((Progress - 0.5) / 0.5);
      Result := 1 - Func(Progress);
    end;
    atmInOutCombined:
      Result :=
    function(Progress: Real): Real
    begin
      if CompareValue(Progress, 0.5, EPSILON) < GreaterThanValue then
        Result := Func(Progress / 0.5)
      else
        Result := 1 - Func((Progress - 0.5) / 0.5);
    end;
    atmOutInCombined:
      Result :=
    function(Progress: Real): Real
    begin
      if CompareValue(Progress, 0.5, EPSILON) < GreaterThanValue then
        Result := Func(1 - (Progress / 0.5))
      else
        Result := 1 - Func(1 - ((Progress - 0.5) / 0.5));
    end;
    atmInSnake:
      Result :=
    function(Progress: Real): Real
    begin
      if CompareValue(Progress, 0.5, EPSILON) < GreaterThanValue then
        Result := Func(Progress / 0.5)
      else
        Result := Func(1) + (1 - Func(1 - ((Progress - 0.5) / 0.5)));
      Result := Result / 2;
    end;
    atmOutSnake:
      Result :=
    function(Progress: Real): Real
    begin
      if CompareValue(Progress, 0.5, EPSILON) < GreaterThanValue then
        Result := 1 + (1 - Func(Progress / 0.5))
      else
        Result := Func(1 - ((Progress - 0.5) / 0.5));
      Result := Result / 2;
    end;
    atmInSnakeInverted:
      Result :=
    function(Progress: Real): Real
    begin
      if CompareValue(Progress, 0.5, EPSILON) < GreaterThanValue then
        Result := 1 - Func(1 - (Progress / 0.5))
      else
        Result := Func(1) + Func((Progress - 0.5) / 0.5);
      Result := Result / 2;
    end;
    atmOutSnakeInverted:
      Result :=
    function(Progress: Real): Real
    begin
      if CompareValue(Progress, 0.5, EPSILON) < GreaterThanValue then
        Result := 1 + Func(1 - Progress / 0.5)
      else
        Result := 1 - Func((Progress - 0.5) / 0.5);
      Result := Result / 2;
    end;
  else
    Result := nil;
  end;
end;

class function TAwMath.EnumToFuncRef(Line: TAwEnumEffectMain;
  Mode: TAwEnumEffectMode): TAwCalcRef;
begin
  Result := EnumModeToFunc(EnumLineToFunc(Line), Mode);
end;

end.
