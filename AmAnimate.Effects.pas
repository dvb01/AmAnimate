unit AmAnimate.Effects;

interface
uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  System.Types,
  System.Generics.Collections,
  Math,
  AmAnimate.Struct,
  AmAnimate.Engine,
  AmAnimate.Source.Intf;

  type
  // кастомная анимация с событиями
  // в событиях можно написать свое
  IAwAnimateCustom = interface;
  TAwAnimateCustom = class;



  // взбалтывание контрола
  IAwAnimateShake = interface;
  TAwAnimateShake = class;
   {
  // перемешение контрола
  IAwAnimateMove = interface;
  TAwAnimateMove = class;

  // мягкий шарик измениние размера контрола
  IAwAnimateBall = interface;
  TAwAnimateBall = class;

  // транспарент
  IAwAnimateAlfa = interface;
  TAwAnimateAlfa = class;
  }
  {$REGION 'FACTORY'}
  AwFactoryEffects = class (AwFactoryBase)
    public
    class function Custom: IAwAnimateCustom; static;
    class function Shake(): IAwAnimateShake; static;
   // class function Move(): IAwAnimateMove; static;
   // class function Ball(): IAwAnimateBall; static;
   // class function Alfa(): IAwAnimateAlfa; static;
  end;
 {$ENDREGION}


  ////////////////////////////////////////////////////////////////////////////
  ///                                                                      ///
  ///                                                                      ///
  ///                             CUSTOM                                   ///
  ///                                                                      ///
  ///                                                                      ///
  ////////////////////////////////////////////////////////////////////////////
  {$REGION 'CUSTOM'}
  IAwAnimateCustom = interface(IAwAnimateBase)
    // private
    function PauseGet: boolean;
    procedure PauseSet(const Value: boolean);
    function IntervalHeartBeatGet: Cardinal;
    procedure IntervalHeartBeatSet(const Value: Cardinal);
    function ProgressRepeatIndexGet: Integer;
    function RepeatCountGet: Integer;
    procedure RepeatCountSet(const Value: Integer);
    function DelayGet: Cardinal;
    procedure DelaySet(const Value: Cardinal);
    function SourceGet: IAwSource;
    procedure SourceSet(const Value: IAwSource);
    // public
    // время проигрывания анимации
    property Delay: Cardinal read DelayGet write DelaySet;
    // объект  который анимаруется
    property Source: IAwSource read SourceGet write SourceSet;
    // один тик таймера
    property IntervalHeartBeat: Cardinal read IntervalHeartBeatGet
      write IntervalHeartBeatSet;
    // сколько повторений анимаций делать друг за другом
    property RepeatCount: Integer read RepeatCountGet write RepeatCountSet;
    // пауза
    property Pause: boolean read PauseGet write PauseSet;
    // текуший индекс повтора
    property ProgressRepeatIndex: Integer read ProgressRepeatIndexGet;
  end;

  TAwAnimateCustom = class(TAwAnimateBase, IAwAnimateCustom)end;
  {$ENDREGION}

  {$REGION 'ABSTRACT BOUNDS'}
  // параметры Source которые отвечают за измениние Bounds у контрола
  TAwOptionBounds = class (TAwOptionBase)
   private
    function SourceGet: IAwSourceBounds;
    procedure SourceSet(const Value: IAwSourceBounds);
   public
    property Source: IAwSourceBounds read SourceGet write SourceSet;
  end;


  //TAwAnimateBoundsCustom
  TAwAnimateBoundsCustom = class abstract(TAwAnimateOpt)
   private
     function OptionGet:TAwOptionBounds;
   protected
     FSaveRect:TRectF;
     function IsValidParam: boolean; override;
     property Option: TAwOptionBounds read OptionGet;
   public
     constructor Create; override;
     destructor Destroy; override;
  end;

  //TAwAnimateBoundsRecoveryRect
  TAwAnimateBoundsRecoveryRect = class abstract(TAwAnimateBoundsCustom)
   protected
     procedure EventFinishLast; override;
  end;
 {$ENDREGION}


  ////////////////////////////////////////////////////////////////////////////
  ///                                                                      ///
  ///                                                                      ///
  ///                              SHAKE                                   ///
  ///                                                                      ///
  ///                                                                      ///
  ////////////////////////////////////////////////////////////////////////////
  {$REGION 'SHAKE'}
   // параметры анимации взбалтывания
  TAwOptionShake = class (TAwOptionBounds)
    private
       FEffect:TAwEffectPoint;
       function EffectGet: PAwEffectPoint;
     protected
       procedure Init;override;
       procedure Clear;override;
     public
       property Effect: PAwEffectPoint read EffectGet;
       function IsValid:boolean; override;
  end;

  /// Про параметры IAwAnimateShake
  ///  1.Delta в px на сколько сильно отклонятся от начального полежения
  ///  2. CountRepeat сколько повторов успеть сделать за Delay
  ///     лучшие числа которые кратны 0.5

  IAwAnimateShake = interface(IAwAnimateBase)
    function OptionGet:TAwOptionShake;
    procedure SetParam(ASource: IAwSourceBounds; ADelay: Cardinal;
      DeltaX, DeltaY, CountRepeatX, CountRepeatY: Single);
    property Option: TAwOptionShake read OptionGet;
  end;

  TAwAnimateShake = class(TAwAnimateBoundsRecoveryRect, IAwAnimateShake)
  private
    function OptionGet:TAwOptionShake;
  protected
    procedure EventProcess; override;
  public
    property Option: TAwOptionShake read OptionGet;
    procedure SetParam(ASource: IAwSourceBounds; ADelay: Cardinal;
      DeltaX, DeltaY, CountRepeatX, CountRepeatY: Single);
    class function OptionClassGet:TawOptionClass;override;
  end;
 {$ENDREGION}
  {
   // параметры анимации мягкого мячика
  PAmAnimateBallParam =^TAmAnimateShakeParam;
  TAmAnimateBallParam = record
   private
     procedure EffectToRef;
   public
     [unsafe]Source: IAwSourceBounds;
     Delay: Cardinal;
     DeltaHorz: Single;
     DeltaVert: Single;
     TimeHorz: Single;
     TimeVert: Single;
     FuncRefHorz: TAwCalcRef;
     FuncRefVert: TAwCalcRef;
     EffectMainHorz:TAwEnumEffectMain;
     EffectMainVert:TAwEnumEffectMain;
     EffectModificatorHorz:TAwEnumEffectMode;
     EffectModificatorVert:TAwEnumEffectMode;
     procedure Clear;
     procedure Default;
     procedure Random;
     function IsValid:boolean;
  end;

  IAwAnimateBall = interface(IAwAnimateBase)
   //private
    function ParamGet:PAmAnimateBallParam;
   //public
    property Param: PAmAnimateBallParam read ParamGet;
    procedure SetParam(ASource: IAwSourceBounds; ADelay: Cardinal;
      DeltaW, DeltaH, TimeW, TimeH: Single);
  end;

  TAwAnimateBall = class(TAwAnimateBoundsRecoveryRect, IAwAnimateBall)
  private
    FParam:TAmAnimateBallParam;
    function ParamGet:PAmAnimateBallParam;
  protected
    procedure EventProcess; override;
    function IsValidParam: boolean; override;
  public
    property Param: PAmAnimateBallParam read ParamGet;
    procedure SetParam(ASource: IAwSourceBounds; ADelay: Cardinal;
      DeltaW, DeltaH, TimeW, TimeH: Single);
    constructor Create; override;
    destructor Destroy; override;
  end;



   // параметры анимации перемещения
   // заполнить  (FuncRef или (Line,Mode))
  PAmAnimateMoveParam =^TAmAnimateMoveParam;
  TAmAnimateMoveParam = record
   private
     procedure EffectToRef;
   public
     [unsafe]Source: IAwSourceBounds;
     Delay: Cardinal;
     NewBounds:TAmAnimateBounds;
     FuncRef: TAmAnimateBoundsFuncRef;
     EffectMain:TAmAnimateBoundsEffectMain;
     EffectModificator:TAmAnimateBoundsEffectModificator;
     procedure Clear;
     procedure Default;
     procedure Random;
     function IsValid:boolean;
  end;

  IAwAnimateMove = interface(IAwAnimateBase)
   //private
    function ParamGet:PAmAnimateMoveParam;
   //public
    //ParamMode дает больше возможностей для настройки анимаций
    // чем  SetParamMode и SetParamCustom
    property Param: PAmAnimateMoveParam read ParamGet;
    procedure SetParamMode(ASource: IAwSourceBounds; ADelay: Cardinal;
      NewLeft, NewTop, NewWidth, NewHeight: Single;
      TypLine: TAwEnumEffectMain; TypeMode: TAwEnumEffectMode);
    procedure SetParamCustom(ASource: IAwSourceBounds; ADelay: Cardinal;
      NewLeft, NewTop, NewWidth, NewHeight: Single;
      Func: TAwCalcRef);
  end;

  TAwAnimateMove = class(TAwAnimateBoundsCustom, IAwAnimateMove)
  private
    FParam:TAmAnimateMoveParam;
    function ParamGet:PAmAnimateMoveParam;
  protected
    procedure EventProcess; override;
    procedure EventFinishLast; override;
    function IsValidParam: boolean; override;
  public
    property Param: PAmAnimateMoveParam read ParamGet;
    procedure SetParamMode(ASource: IAwSourceBounds; ADelay: Cardinal;
      NewLeft, NewTop, NewWidth, NewHeight: Single;
      TypLine: TAwEnumEffectMain; TypeMode: TAwEnumEffectMode);
    procedure SetParamCustom(ASource: IAwSourceBounds; ADelay: Cardinal;
      NewLeft, NewTop, NewWidth, NewHeight: Single;
      Func: TAwCalcRef);
    constructor Create; override;
    destructor Destroy; override;
  end;

  //TAwAnimateSourceAlfaCustom

  TAwAnimateSourceAlfaCustom = class abstract(TAwAnimateBase)
   protected
     [unsafe]FLocalSource: IAwSourceAlfa;
     FSaveAlfa:byte;
     function CheckLocalSource:boolean;
     procedure SourceChanged;override;
     function IsValidParam: boolean; override;
      procedure EventStartFerst; override;
     procedure EventFinishLast; override;
   public
     constructor Create; override;
     destructor Destroy; override;
  end;

   // параметры анимации прозрачности
  PAmAnimateAlfaParam =^TAmAnimateAlfaParam;
  TAmAnimateAlfaParam = record
   private
     procedure EffectToRef(IsCheck:boolean);
   public
     [unsafe]Source: IAwSourceAlfa;
     Delay: Cardinal;
     LvlFrom, LvlTo: Byte;
     FuncRef: TAwCalcRef;
     EffectMain:TAwEnumEffectMain;
     EffectModificator:TAwEnumEffectMode;
     procedure Clear;
     procedure Default;
     procedure Random;
     function IsValid:boolean;
  end;


  IAwAnimateAlfa = interface(IAwAnimateBase)
    //private
    function ParamGet:PAmAnimateAlfaParam;
    //public
    property Param: PAmAnimateAlfaParam read ParamGet;
    procedure SetParam(ASource: IAwSourceAlfa; ADelay: Cardinal;
      LvlFrom, LvlTo: Byte);
  end;

  TAwAnimateAlfa = class(TAwAnimateSourceAlfaCustom, IAwAnimateAlfa)
  private
    FParam:TAmAnimateAlfaParam;
    function ParamGet:PAmAnimateAlfaParam;
  protected
    procedure EventProcess; override;
    procedure EventFinishLast; override;
    function IsValidParam: boolean; override;
  public
    property Param: PAmAnimateAlfaParam read ParamGet;
    procedure SetParam(ASource: IAwSourceAlfa; ADelay: Cardinal;
      LvlFrom, LvlTo: Byte);
    constructor Create; override;
    destructor Destroy; override;
  end;

  }

implementation

  { AwFactoryEffects }
class function AwFactoryEffects.Custom: IAwAnimateCustom;
begin
  Result := IAwAnimateCustom(Base(TAwAnimateCustom) as TAwAnimateCustom);
end;

class function AwFactoryEffects.Shake: IAwAnimateShake;
begin
  Result := IAwAnimateShake(Base(TAwAnimateShake)
    .AsObject as TAwAnimateShake);
end;

  {
class function AwFactoryEffects.Move: IAwAnimateMove;
begin
  Result := IAwAnimateMove(Base(TAwAnimateMove)
    .AsObject as TAwAnimateMove);
end;

class function AwFactoryEffects.Ball(): IAwAnimateBall;
begin
  Result := IAwAnimateBall(Base(TAwAnimateBall)
    .AsObject as TAwAnimateBall);
end;

class function AwFactoryEffects.Alfa(): IAwAnimateAlfa;
begin
  Result := IAwAnimateAlfa(Base(TAwAnimateAlfa)
    .AsObject as TAwAnimateAlfa);
end; }





{ TAwOptionBounds }

function TAwOptionBounds.SourceGet: IAwSourceBounds;
begin
  Result:= inherited Source as IAwSourceBounds;
end;

procedure TAwOptionBounds.SourceSet(const Value: IAwSourceBounds);
begin
  inherited Source:= Value;
end;


  { TAwAnimateBoundsCustom }

constructor TAwAnimateBoundsCustom.Create;
begin
  inherited;
  FSaveRect:=TRectF.Empty;
end;

destructor TAwAnimateBoundsCustom.Destroy;
begin
  inherited;
end;

function TAwAnimateBoundsCustom.IsValidParam: boolean;
begin
  Result := inherited IsValidParam;
  Result:= Result and  Option.Source.GetBounds(FSaveRect);
end;

function TAwAnimateBoundsCustom.OptionGet: TAwOptionBounds;
begin
    Result:= inherited Option as TAwOptionBounds;
end;

{ TAwAnimateBoundsRecoveryRect }
procedure TAwAnimateBoundsRecoveryRect.EventFinishLast;
begin
  inherited EventFinishLast;
  if not InProcessCheckSource
  or not Option.Source.SetBounds(FSaveRect)  then
    TerminateAndCancel;
end;



{ TAwOptionShake }

procedure TAwOptionShake.Clear;
begin
  inherited;
   FEffect.Clear;
end;

function TAwOptionShake.EffectGet: PAwEffectPoint;
begin
   Result:= @FEffect;
end;

procedure TAwOptionShake.Init;
begin
  inherited;
  FEffect.Clear;
end;

function TAwOptionShake.IsValid: boolean;
begin
 Result:=  inherited IsValid and FEffect.IsValid;
end;

{ TAmAnimateShake }

class function TAwAnimateShake.OptionClassGet: TawOptionClass;
begin
  Result:= TAwOptionShake;
end;

function TAwAnimateShake.OptionGet:TAwOptionShake;
begin
  Result:= inherited Option as TAwOptionShake;
end;

procedure TAwAnimateShake.SetParam(ASource: IAwSourceBounds; ADelay: Cardinal;
      DeltaX, DeltaY, CountRepeatX, CountRepeatY: Single);
begin
  Option.Source:= ASource;
  Option.Delay:=  ADelay;
  Option.Effect.Default;
  Option.Effect.X.Count:= CountRepeatX;
  Option.Effect.Y.Count:= CountRepeatY;
  Option.Effect.X.Delta:=DeltaX;
  Option.Effect.Y.Delta :=DeltaY;
end;


procedure TAwAnimateShake.EventProcess;
var
  Bar,Bar2: Real;
  Bounds: TAwBounds;
begin
  inherited;
  if not InProcessCheckSource then
   exit;
  Bar := Progress;
  Bounds.Rect:= FSaveRect;
  if Bar < 1 then
  begin
    if Option.Effect.X.Delta <> 0 then
    begin
      Bar2:=Option.Effect.X.Effect.Calc(Bar);
      Bounds.Left := Bounds.Left + TAwMath.SwingTime(Option.Effect.X.Count, Option.Effect.X.Delta, Bar2);
    end;
    if Option.Effect.Y.Delta <> 0 then
    begin
      Bar2:=Option.Effect.Y.Effect.Calc(Bar);
      Bounds.Top := Bounds.Top + TAwMath.SwingTime(Option.Effect.Y.Count, Option.Effect.Y.Delta, Bar2);
    end;
  end;
  if  not Option.Source.SetBounds(Bounds.Rect) then
  TerminateAndCancel;
end;





   (*
{ TAmAnimateBallParam }

procedure TAmAnimateBallParam.Clear;
begin
  Source:=nil;
  FuncRefHorz:=nil;
  FuncRefVert:=nil;
  fillchar(self,sizeof(self),0);
end;

procedure TAmAnimateBallParam.Default;
begin
   Clear;
   Delay:= 500;
   DeltaHorz:=5;
   DeltaVert:=5;
   TimeHorz:=1;
   TimeVert:=1;
end;

procedure TAmAnimateBallParam.EffectToRef;
begin
  if not Assigned(FuncRefHorz) then
    FuncRefHorz:= TAwMath.EnumToFuncRef(EffectMainHorz,EffectModificatorHorz);
  if not Assigned(FuncRefVert) then
    FuncRefVert:= TAwMath.EnumToFuncRef(EffectMainVert,EffectModificatorVert);
end;

function TAmAnimateBallParam.IsValid: boolean;
begin
   EffectToRef;
   Result:=
   ((DeltaHorz <> 0) and (TimeHorz <> 0) and Assigned(FuncRefHorz) ) or
   ((DeltaVert <> 0) and (TimeVert <> 0) and Assigned(FuncRefVert) );
   Result:= Result and (Source<>nil) and (Delay>0);
end;

procedure TAmAnimateBallParam.Random;
var Count:integer;
begin
   Clear;
   DeltaHorz:=Math.RandomRange(1,15);
   DeltaVert:=Math.RandomRange(1,15);
   TimeHorz:=1;
   TimeVert:=1;
   Delay:= Math.RandomRange(200,1000);

    Count:= Integer(System.High(TAwEnumEffectMain))+1;

    EffectMainHorz:= TAwEnumEffectMain(Math.RandomRange(0,Count));
    EffectMainVert:= TAwEnumEffectMain(Math.RandomRange(0,Count));

    Count:= Integer(System.High(TAwEnumEffectMode))+1;

    EffectModificatorHorz:= TAwEnumEffectMode(Math.RandomRange(0,Count));
    EffectModificatorVert:= TAwEnumEffectMode(Math.RandomRange(0,Count));
end;


{ TAmAnimateBall }

constructor TAwAnimateBall.Create;
begin
  inherited;
  FParam.Default;
end;

destructor TAwAnimateBall.Destroy;
begin
  FParam.Clear;
  inherited;
end;

function TAwAnimateBall.ParamGet:PAmAnimateBallParam;
begin
   Result:= @FParam;
end;

function TAwAnimateBall.IsValidParam: boolean;
begin
  Result := inherited IsValidParam and FParam.IsValid;
  FParam.Source:=nil;
end;

procedure TAwAnimateBall.SetParam(ASource: IAwSourceBounds; ADelay: Cardinal;
      DeltaW, DeltaH, TimeW, TimeH: Single);
begin
  FParam.Source:= nil;
  FParam.Delay:=  ADelay;
  FParam.DeltaHorz:= DeltaW;
  FParam.DeltaVert:= DeltaH;
  FParam.TimeHorz:=  TimeW;
  FParam.TimeVert:=  TimeH;
  Source:= ASource;
  Delay := ADelay;
end;

procedure TAwAnimateBall.EventProcess;
var
  Bar: Real;
  Bounds: TAmAnimateBounds;
  Value:Single;
begin
  inherited;
  if not CheckLocalSource then
   exit;
  Bar := Progress;
  Bounds.Rect:= FSaveRect;

  if Bar < 1 then
  begin
    if FParam.DeltaHorz <> 0 then
    begin
      Value := TAwMath.SwingTime(FParam.TimeHorz, FParam.DeltaHorz, Bar) / 2;
      Bounds.Left := Bounds.Left + Value;
      Bounds.Width := Bounds.Width - Value * 2;
    end;
    if FParam.DeltaVert <> 0 then
    begin
      Value := TAwMath.SwingTime(FParam.TimeVert, FParam.DeltaVert, Bar) / 2;
      Bounds.Top := Bounds.Top + Value;
      Bounds.Height := Bounds.Height - Value * 2;
    end;
  end;
 if  not FLocalSource.SetBounds(Bounds.Rect) then
  TerminateAndCancel;
end;






{ TAmAnimateMoveParam }

procedure TAmAnimateMoveParam.Clear;
begin
  Source:=nil;
  NewBounds.Clear;
  FuncRef.Clear;
  EffectMain.Clear;
  EffectModificator.Clear;
  fillchar(self,sizeof(self),0);
end;

procedure TAmAnimateMoveParam.Default;
begin
   Clear;
   Delay:=500;
end;

procedure TAmAnimateMoveParam.EffectToRef;
begin
   if not Assigned(FuncRef.Left) then
    FuncRef.Left:= TAwMath.EnumToFuncRef(EffectMain.Left,EffectModificator.Left);
   if not Assigned(FuncRef.Top) then
    FuncRef.Top:= TAwMath.EnumToFuncRef(EffectMain.Top,EffectModificator.Top);
   if not Assigned(FuncRef.Width) then
    FuncRef.Width:= TAwMath.EnumToFuncRef(EffectMain.Width,EffectModificator.Width);
   if not Assigned(FuncRef.Height) then
    FuncRef.Height:= TAwMath.EnumToFuncRef(EffectMain.Height,EffectModificator.Height);
end;

function TAmAnimateMoveParam.IsValid: boolean;
begin
     EffectToRef;
     Result:= FuncRef.IsValid;
end;

procedure TAmAnimateMoveParam.Random;
begin
   Clear;
   Delay:= Math.RandomRange(200,1000);
   EffectMain.Random;
   EffectModificator.Random;
end;



{ TAmAnimateMove }

constructor TAwAnimateMove.Create;
begin
  inherited;
  FParam.Default;
end;

destructor TAwAnimateMove.Destroy;
begin
  FParam.Clear;
  inherited;
end;

function TAwAnimateMove.ParamGet: PAmAnimateMoveParam;
begin
    Result:= @FParam;
end;

function TAwAnimateMove.IsValidParam: boolean;
begin
  Source:= FParam.Source;
  Delay:= FParam.Delay;
  Result := FParam.IsValid and  inherited IsValidParam;
end;


procedure TAwAnimateMove.SetParamCustom(ASource: IAwSourceBounds;
  ADelay: Cardinal; NewLeft, NewTop, NewWidth, NewHeight: Single;
  Func: TAwCalcRef);
begin
  FParam.Source:=ASource;
  FParam.Delay:=ADelay;
  FParam.NewBounds.Left:=   NewLeft;
  FParam.NewBounds.Top:=    NewTop;
  FParam.NewBounds.Width:=  NewWidth;
  FParam.NewBounds.Height:= NewHeight;

  FParam.FuncRef.Left:=  Func;
  FParam.FuncRef.Top:=  Func;
  FParam.FuncRef.Width:=  Func;
  FParam.FuncRef.Height:=  Func;
end;

procedure TAwAnimateMove.SetParamMode(ASource: IAwSourceBounds;
  ADelay: Cardinal; NewLeft, NewTop, NewWidth, NewHeight: Single;
  TypLine: TAwEnumEffectMain; TypeMode: TAwEnumEffectMode);
begin
  SetParamCustom(ASource, ADelay, NewLeft, NewTop, NewWidth, NewHeight,
    TAwMath.EnumToFuncRef(TypLine, TypeMode));
end;

procedure TAwAnimateMove.EventFinishLast;
var FCurRect:TRectF;
begin
  inherited EventFinishLast;
  if not CheckLocalSource or not FLocalSource.GetBounds(FCurRect) then
    TerminateAndCancel
  else
  begin
      if FParam.NewBounds.Width<0 then
      FParam.NewBounds.Width:= FCurRect.Width;
      if FParam.NewBounds.Height<0 then
      FParam.NewBounds.Height:= FCurRect.Height;
      if not FLocalSource.SetBounds(FParam.NewBounds.Rect) then
        TerminateAndCancel;
  end;
end;

procedure TAwAnimateMove.EventProcess;
var
  Bar: Real;
  Bounds: TAmAnimateBounds;
  APoint:TPointF;
  FCurRect:TRectF;
begin
  inherited;
  if not CheckLocalSource or not FLocalSource.GetBounds(FCurRect)  then
  begin
    self.TerminateAndCancel;
    exit;
  end;

  Bar := Progress;

  APoint:=TAwMath.MoveEffect(FSaveRect.Location,FParam.NewBounds.Rect.Location,Bar);
  Bounds.Left:= APoint.X;
  Bounds.Top:=  APoint.Y;
  {
  Left := TvCalculations.SwingToInteger(FSaveRect.Left, FNewRect.Left, Bar, FFunc);
  Top := TvCalculations.SwingToInteger(FSaveRect.Top, FNewRect.Top, Bar, FFunc);

  }


  if FParam.NewBounds.Width >= 0 then
    Bounds.Width := TAwMath.SwingToSingle(FSaveRect.Width, FParam.NewBounds.Width,
     Bar, FParam.FuncRef.Width)
  else
    Bounds.Width := FCurRect.Width;

  if FParam.NewBounds.Height >= 0 then
    Bounds.Height := TAwMath.SwingToSingle(FSaveRect.Height, FParam.NewBounds.Height,
      Bar, FParam.FuncRef.Height)
  else
    Bounds.Height := FCurRect.Height;


  if  not FLocalSource.SetBounds(Bounds.Rect) then
   TerminateAndCancel;
end;













{ TAmAnimateLocalSourceAlfa }

constructor TAwAnimateSourceAlfaCustom.Create;
begin
   inherited;
   FLocalSource:=nil;
   FSaveAlfa:=0;
end;

destructor TAwAnimateSourceAlfaCustom.Destroy;
begin
   FLocalSource:=nil;
   inherited;
end;

procedure TAwAnimateSourceAlfaCustom.SourceChanged;
begin
   inherited;
   FLocalSource:=nil;
   if (Source = nil) or not Source.IsValid
   or not  Supports(Source,IAwSourceAlfa,FLocalSource) then
    TerminateAndCancel;
end;
function TAwAnimateSourceAlfaCustom.CheckLocalSource: boolean;
begin
   Result:= (FLocalSource <> nil) and FLocalSource.IsValid;
   if not Result then
    TerminateAndCancel;
end;

function TAwAnimateSourceAlfaCustom.IsValidParam: boolean;
begin
  FLocalSource:=nil;
  Result := inherited IsValidParam
  and (Source <> nil)and Source.IsValid
  and Supports(Source,IAwSourceAlfa,FLocalSource);
  if Result then
    FSaveAlfa:= FLocalSource.GetAlfa;
end;

procedure TAwAnimateSourceAlfaCustom.EventStartFerst;
begin
  inherited;
  CheckLocalSource;
end;

procedure TAwAnimateSourceAlfaCustom.EventFinishLast;
begin
  inherited;
  if not CheckLocalSource then
    TerminateAndCancel;
end;




{ TAmAnimateAlfaParam }

procedure TAmAnimateAlfaParam.Clear;
begin
    Source:=nil;
    FuncRef:= nil;
    fillchar(self,sizeof(self),0);
end;

procedure TAmAnimateAlfaParam.Default;
begin
   Clear;
   LvlFrom:=100;
   LvlTo:=255;
end;

procedure TAmAnimateAlfaParam.EffectToRef(IsCheck:boolean);
begin
   if not IsCheck or  not Assigned(FuncRef) then
    FuncRef:= TAwMath.EnumToFuncRef(EffectMain,EffectModificator);
end;

function TAmAnimateAlfaParam.IsValid: boolean;
begin
  EffectToRef(true);
  Result:= (LvlFrom <> LvlTo)
  and  (Source <> nil)
  and  (Delay > 0)
  and Assigned(FuncRef);
end;

procedure TAmAnimateAlfaParam.Random;
var Count:integer;
begin
   Clear;
   LvlFrom:=Math.RandomRange(1,255);
   LvlTo:=Math.RandomRange(1,255);
   Delay:= Math.RandomRange(200,1000);
   Count:= Integer(System.High(TAwEnumEffectMain))+1;
   EffectMain:= TAwEnumEffectMain(Math.RandomRange(0,Count));
   Count:= Integer(System.High(TAwEnumEffectMode))+1;
   EffectModificator:= TAwEnumEffectMode(Math.RandomRange(0,Count));
   EffectToRef(false);
end;




{ TAmAnimateAlfa }

constructor TAwAnimateAlfa.Create;
begin
  inherited;
  FParam.Default;
end;

destructor TAwAnimateAlfa.Destroy;
begin
  FParam.Clear;
  inherited;
end;

function TAwAnimateAlfa.ParamGet:PAmAnimateAlfaParam;
begin
   Result:= @FParam;
end;

function TAwAnimateAlfa.IsValidParam: boolean;
begin
  Source := FParam.Source;
  Delay := FParam.Delay;
  Result := FParam.IsValid and inherited IsValidParam;
end;

procedure TAwAnimateAlfa.SetParam(ASource: IAwSourceAlfa; ADelay: Cardinal;
  LvlFrom, LvlTo: Byte);
begin
  FParam.Source:=   ASource;
  FParam.Delay:=    ADelay;
  FParam.LvlFrom := LvlFrom;
  FParam.LvlTo :=   LvlTo;
end;

procedure TAwAnimateAlfa.EventFinishLast;
begin
   inherited EventFinishLast;
  if not CheckLocalSource or FLocalSource.SetAlfa(FParam.LvlTo) then
    TerminateAndCancel;
end;

procedure TAwAnimateAlfa.EventProcess;
var
  Bar: Real;
  Lvl: Byte;
begin
  inherited;
  if not CheckLocalSource then
   exit;
  Bar := Progress;
  Lvl := Round(abs(FParam.LvlTo - FParam.LvlFrom) * Bar);
  if FParam.LvlTo > FParam.LvlFrom then
    Lvl := FParam.LvlFrom + Lvl
  else
    Lvl := FParam.LvlFrom - Lvl;

  if not FLocalSource.SetAlfa(Lvl) then
   self.TerminateAndCancel;
end;


   *)









end.
