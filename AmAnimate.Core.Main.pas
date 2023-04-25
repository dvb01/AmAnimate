unit AmAnimate.Core.Main;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  AmAnimate.Core.Res,
  AmAnimate.Core.Types,
  AmAnimate.Core.Math,
  AmAnimate.Core.Engine,
  AmAnimate.Core.Source.Intf,
  AmAnimate.Core.Effects.Def.Struct,
  AmAnimate.Core.Effects.Def.Classes,
  AmAnimate.Core.Effects.Dcv.Classes;

  // все что нужно внешне с AmAnimate.Сore.... вынесено в этот модуль
type

  TAwEnumEffectMain = AmAnimate.Core.Math.TAwEnumEffectMain;
  TAwEnumEffectMode = AmAnimate.Core.Math.TAwEnumEffectMode;
  TAwDcvEnumMode =    AmAnimate.Core.Effects.Dcv.Classes.TAwDcvEnumMode;

const
  dcvLine =  AmAnimate.Core.Effects.Dcv.Classes.dcvLine;
  dcvSin =   AmAnimate.Core.Effects.Dcv.Classes.dcvSin;

  // эффекты анимаций
  atlNone = AmAnimate.Core.Math.atlNone;
  atlLine = AmAnimate.Core.Math.atlLine;
  atlPower2 = AmAnimate.Core.Math.atlPower2;
  atlPower3 = AmAnimate.Core.Math.atlPower3;
  atlPower4 = AmAnimate.Core.Math.atlPower4;
  atlPower5 = AmAnimate.Core.Math.atlPower5;
  atlPower6 = AmAnimate.Core.Math.atlPower6;
  atlSin = AmAnimate.Core.Math.atlSin;
  atlElastic = AmAnimate.Core.Math.atlElastic;
  atlBack = AmAnimate.Core.Math.atlBack;
  atlLowWave = AmAnimate.Core.Math.atlLowWave;
  atlMiddleWave = AmAnimate.Core.Math.atlMiddleWave;
  atlHighWave = AmAnimate.Core.Math.atlHighWave;
  atlBounce = AmAnimate.Core.Math.atlBounce;
  atlCircle = AmAnimate.Core.Math.atlCircle;
  atlSwing10 = AmAnimate.Core.Math.atlSwing10;
  atlSwing50 = AmAnimate.Core.Math.atlSwing50;
  atlSwing100 = AmAnimate.Core.Math.atlSwing100;
  atlSwing200 = AmAnimate.Core.Math.atlSwing200;

  // модификация эффекта
  atmNone = AmAnimate.Core.Math.atmNone;
  atmIn = AmAnimate.Core.Math.atmIn;
  atmInInverted = AmAnimate.Core.Math.atmInInverted;
  atmInSnake = AmAnimate.Core.Math.atmInSnake;

  atmInSnakeInverted = AmAnimate.Core.Math.atmInSnakeInverted;
  atmOut = AmAnimate.Core.Math.atmOut;
  atmOutInverted = AmAnimate.Core.Math.atmOutInverted;
  atmOutSnake = AmAnimate.Core.Math.atmOutSnake;

  atmOutSnakeInverted = AmAnimate.Core.Math.atmOutSnakeInverted;
  atmInOut = AmAnimate.Core.Math.atmInOut;
  atmInOutMirrored = AmAnimate.Core.Math.atmInOutMirrored;
  atmInOutCombined = AmAnimate.Core.Math.atmInOutCombined;
  atmOutIn = AmAnimate.Core.Math.atmOutIn;

  atmOutInMirrored = AmAnimate.Core.Math.atmOutInMirrored;
  atmOutInCombined = AmAnimate.Core.Math.atmOutInCombined;

type
  // помошь в рассылке событий при destroy
  TAwHandleBroadcastDestroy = AmAnimate.Core.Types.TAwHandleBroadcastDestroy;
  TAwProc = AmAnimate.Core.Types.TAwProc;

  //процедуры событий
  TAwEvent = AmAnimate.Core.Engine.TAwEvent;
  TAwEventRef = AmAnimate.Core.Engine.TAwEventRef;




  // список последовательных анимаций
  IAwQueue = AmAnimate.Core.Engine.IAwQueue;

  // абстрактный интерфейс анимации
  IAwAnimateIntf = AmAnimate.Core.Source.Intf.IAwAnimateIntf;

  // базавый интерфейс анимации
  IAwAnimateBase = AmAnimate.Core.Engine.IAwAnimateBase;

  // базовый интерфейс объекта для анимации (то что анимируем)
  IAwSource = AmAnimate.Core.Source.Intf.IAwSource;

  // события которые анимация может отправить в объект IAwSource
  IAwSourceEvent = AmAnimate.Core.Source.Intf.IAwSourceEvent;



  // кастомная анимация с событиями
  // в событиях можно написать свое
  IAwAnimateCustom = AmAnimate.Core.Engine.IAwAnimateCustom;

  // заглушка пустая анимация
  IAwAnimateEmpty = AmAnimate.Core.Engine.IAwAnimateEmpty;


  // AmAnimate.Core.Effects.Def.Classes

  //Source используется в процессе анимации что бы получить установить Bounds контролу
  IAwSourceBounds = AmAnimate.Core.Source.Intf.IAwSourceBounds;

  //анимция взбалтывание контрола
  IAwAnimateShake = AmAnimate.Core.Effects.Def.Classes.IAwAnimateShake;

  //анимция  мягкий шарик измениние размера контрола
  IAwAnimateBall = AmAnimate.Core.Effects.Def.Classes.IAwAnimateBall;

  //анимция перемешение контрола
  IAwAnimateMove = AmAnimate.Core.Effects.Def.Classes.IAwAnimateMove;




  //анимция транспарент
  IAwAnimateAlfa = AmAnimate.Core.Effects.Def.Classes.IAwAnimateAlfa;

  //Source используется что бы анимировать прозрачность
  IAwSourceAlfa = AmAnimate.Core.Source.Intf.IAwSourceAlfa;



  // AmAnimate.Core.Effects.Dcv.Classes
  // кастомные переменные
  IAwAnimateDcv = AmAnimate.Core.Effects.Dcv.Classes.IAwAnimateDcv;
  IAwAnimateDcvCustom = AmAnimate.Core.Effects.Dcv.Classes.IAwAnimateDcvCustom;

  // таблица кастоных переменных
  IAwSourceDcvTable =  AmAnimate.Core.Source.Intf.IAwSourceDcvTable;
  //Source используется что бы анимировать кастомные переменные
  IAwSourceDcv =  AmAnimate.Core.Source.Intf.IAwSourceDcv;

  // события
  TAwEventDcv = AmAnimate.Core.Effects.Dcv.Classes.TAwEventDcv;
  TAwEventRefDcv = AmAnimate.Core.Effects.Dcv.Classes.TAwEventRefDcv;



type

{$REGION 'FACTORY'}
  AwFactoryEffects = class(AwFactoryBase)
    // создание анимаций
    // class procedure SourceCancel(Source: IAwSource); static;
    // class procedure Clear; static;
    // creator
    // class function NewList: IAwQueue;  static;
    // class function Base(AClass: TAwAnimateClass = nil): IAwAnimateBase; static;
    // class function Empty(): IAwAnimateEmpty; static;

    class function Custom: IAwAnimateCustom; static;
    class function Shake(): IAwAnimateShake; static;
    class function Move(): IAwAnimateMove; static;
    class function Ball(): IAwAnimateBall; static;
    class function Alfa(): IAwAnimateAlfa; static;
    class function Dcv(): IAwAnimateDcv; static;
    class function DcvCustom(): IAwAnimateDcvCustom; static;

    class procedure EffectMainEnumToStrings(L: TStrings); static;
    class procedure EffectModeEnumToStrings(L: TStrings); static;
  end;
{$ENDREGION}

implementation

{ AwFactoryEffects }
class function AwFactoryEffects.Custom: IAwAnimateCustom;
begin
  Result := IAwAnimateCustom(Base(TAwAnimateCustom) as TAwAnimateCustom);
end;

class function AwFactoryEffects.Shake: IAwAnimateShake;
begin
  Result := IAwAnimateShake(Base(TAwAnimateShake).AsObject as TAwAnimateShake);
end;

class function AwFactoryEffects.Ball(): IAwAnimateBall;
begin
  Result := IAwAnimateBall(Base(TAwAnimateBall).AsObject as TAwAnimateBall);
end;

class function AwFactoryEffects.Move: IAwAnimateMove;
begin
  Result := IAwAnimateMove(Base(TAwAnimateMove).AsObject as TAwAnimateMove);
end;

class function AwFactoryEffects.Alfa(): IAwAnimateAlfa;
begin
  Result := IAwAnimateAlfa(Base(TAwAnimateAlfa).AsObject as TAwAnimateAlfa);
end;

class function AwFactoryEffects.Dcv(): IAwAnimateDcv;
begin
  Result := IAwAnimateDcv(Base(TAwAnimateDcv).AsObject as TAwAnimateDcv);
end;

class function AwFactoryEffects.DcvCustom(): IAwAnimateDcvCustom;
begin
  Result := IAwAnimateDcvCustom(Base(TAwAnimateDcvCustom).AsObject as TAwAnimateDcvCustom);
end;

class procedure AwFactoryEffects.EffectMainEnumToStrings(L: TStrings);
begin
  AwEnumEffectMainRec.ToStrings(L);
end;

class procedure AwFactoryEffects.EffectModeEnumToStrings(L: TStrings);
begin
  AwEnumEffectModeRec.ToStrings(L);
end;

end.
