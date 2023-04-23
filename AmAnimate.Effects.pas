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

  // мягкий шарик измениние размера контрола
  IAwAnimateBall = interface;
  TAwAnimateBall = class;
   
  // перемешение контрола
  IAwAnimateMove = interface;
  TAwAnimateMove = class;



  // транспарент
  IAwAnimateAlfa = interface;
  TAwAnimateAlfa = class;

  {$REGION 'FACTORY'}
  AwFactoryEffects = class (AwFactoryBase)
    public
    class function Custom: IAwAnimateCustom; static;
    class function Shake(): IAwAnimateShake; static;
    class function Move(): IAwAnimateMove; static;
    class function Ball(): IAwAnimateBall; static;
    class function Alfa(): IAwAnimateAlfa; static;
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


  ////////////////////////////////////////////////////////////////////////////
  ///                                                                      ///
  ///                                                                      ///
  ///                           BOUNDS ABSTRACT                            ///
  ///                                                                      ///
  ///                                                                      ///
  ////////////////////////////////////////////////////////////////////////////
  {$REGION 'BOUNDS ABSTRACT'}
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
  ///                           BOUNDS SHAKE                               ///
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

  TAwAnimateShake = class sealed(TAwAnimateBoundsRecoveryRect, IAwAnimateShake)
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

  ////////////////////////////////////////////////////////////////////////////
  ///                                                                      ///
  ///                                                                      ///
  ///                           BOUNDS BALL                                ///
  ///                                                                      ///
  ///                                                                      ///
  ////////////////////////////////////////////////////////////////////////////
  {$REGION 'BALL'}
  // параметры анимации мягкого мячика
  TAwOptionBall = class (TAwOptionBounds)
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

  IAwAnimateBall = interface(IAwAnimateBase)
    function OptionGet:TAwOptionBall;
    procedure SetParam(ASource: IAwSourceBounds; ADelay: Cardinal;
      DeltaX, DeltaY, CountRepeatX, CountRepeatY: Single);
    property Option: TAwOptionBall read OptionGet;
  end;

  TAwAnimateBall = class sealed(TAwAnimateBoundsRecoveryRect, IAwAnimateBall)
  private
    function OptionGet:TAwOptionBall;
  protected
    procedure EventProcess; override;
  public
    property Option: TAwOptionBall read OptionGet;
    procedure SetParam(ASource: IAwSourceBounds; ADelay: Cardinal;
      DeltaX, DeltaY, CountRepeatX, CountRepeatY: Single);
    class function OptionClassGet:TawOptionClass;override;
  end;

  {$ENDREGION}


  ////////////////////////////////////////////////////////////////////////////
  ///                                                                      ///
  ///                                                                      ///
  ///                           BOUNDS MOVE                                ///
  ///                                                                      ///
  ///                                                                      ///
  ////////////////////////////////////////////////////////////////////////////
  {$REGION 'MOVE'}
  // параметры анимации перемещения
  TAwOptionMove = class (TAwOptionBounds)
    private
       FEffect:TAwEffectBounds;
       FBounds:TAwBounds;
       function EffectGet: PAwEffectBounds;
       function BoundsGet: PAwBounds;
     protected
       procedure Init;override;
       procedure Clear;override;
     public
       property Bounds: PAwBounds read BoundsGet;
       property Effect: PAwEffectBounds read EffectGet;
       function IsValid:boolean; override;
  end;

  IAwAnimateMove = interface(IAwAnimateBase)
    function OptionGet:TAwOptionMove;
    procedure SetParam(ASource: IAwSourceBounds; ADelay: Cardinal;
      NewLeft, NewTop, NewWidth, NewHeight: Single;
      EffectMain: TAwEnumEffectMain; EffectMode: TAwEnumEffectMode);
    property Option: TAwOptionMove read OptionGet;
  end;

  TAwAnimateMove = class sealed (TAwAnimateBoundsCustom, IAwAnimateMove)
  private     
    function OptionGet:TAwOptionMove;
  protected
    procedure EventProcess; override;
  public
    property Option: TAwOptionMove read OptionGet;
    procedure SetParam(ASource: IAwSourceBounds; ADelay: Cardinal;
      NewLeft, NewTop, NewWidth, NewHeight: Single;
      EffectMain: TAwEnumEffectMain; EffectMode: TAwEnumEffectMode);
    class function OptionClassGet:TawOptionClass;override;
  end;

  {$ENDREGION}


  ////////////////////////////////////////////////////////////////////////////
  ///                                                                      ///
  ///                                                                      ///
  ///                           ALFA ABSTRACT                              ///
  ///                                                                      ///
  ///                                                                      ///
  ////////////////////////////////////////////////////////////////////////////
 {$REGION 'ABSTRACT ALFA'}

  // параметры Source которые отвечают за измениние TransparentLevel у контрола
  TAwOptionAlfa = class (TAwOptionBase)
   private
    FEffect:TAwEffectSide;
    function SourceGet: IAwSourceAlfa;
    procedure SourceSet(const Value: IAwSourceAlfa);
    function EffectGet: PAwEffectSide;
   protected
    procedure Init; override;
    procedure Clear; override;
   public
    property Source: IAwSourceAlfa read SourceGet write SourceSet;
    property Effect: PAwEffectSide read EffectGet;
    function IsValid: boolean; override;
  end;

  TAwAnimateAlfaCustom = class abstract(TAwAnimateOpt)
   private
     function OptionGet:TAwOptionAlfa;
   protected
     FSaveAlfa:byte;
     function IsValidParam: boolean; override;
     property Option: TAwOptionAlfa read OptionGet;
   public
     constructor Create; override;
     destructor Destroy; override;
  end;

 {$ENDREGION}

  ////////////////////////////////////////////////////////////////////////////
  ///                                                                      ///
  ///                                                                      ///
  ///                              ALFA                                    ///
  ///                                                                      ///
  ///                                                                      ///
  ////////////////////////////////////////////////////////////////////////////
 {$REGION 'ALFA'}
  IAwAnimateAlfa = interface(IAwAnimateBase)
    function OptionGet:TAwOptionAlfa;
    property Option: TAwOptionAlfa read OptionGet;
    procedure SetParam(ASource: IAwSourceAlfa; ADelay: Cardinal; DeltaDirection: Integer);
  end;
  TAwAnimateAlfa = class sealed (TAwAnimateAlfaCustom, IAwAnimateAlfa)
  protected
    procedure EventProcess; override;
  public
    procedure SetParam(ASource: IAwSourceAlfa; ADelay: Cardinal; DeltaDirection: Integer);
    property Option;
    class function OptionClassGet:TawOptionClass;override;
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
  Result := IAwAnimateShake(Base(TAwAnimateShake)
    .AsObject as TAwAnimateShake);
end;

class function AwFactoryEffects.Ball(): IAwAnimateBall;
begin
  Result := IAwAnimateBall(Base(TAwAnimateBall)
    .AsObject as TAwAnimateBall);
end;

 
class function AwFactoryEffects.Move: IAwAnimateMove;
begin
  Result := IAwAnimateMove(Base(TAwAnimateMove)
    .AsObject as TAwAnimateMove);
end;



class function AwFactoryEffects.Alfa(): IAwAnimateAlfa;
begin
  Result := IAwAnimateAlfa(Base(TAwAnimateAlfa)
    .AsObject as TAwAnimateAlfa);
end;




{$REGION 'BOUNDS ABSTRACT'}
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
{$ENDREGION}

{$REGION 'SHAKE'}
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

{$ENDREGION}




{$REGION 'BALL'}

 { TAwOptionBall }

procedure TAwOptionBall.Clear;
begin
  inherited;
   FEffect.Clear;
end;

function TAwOptionBall.EffectGet: PAwEffectPoint;
begin
   Result:= @FEffect;
end;

procedure TAwOptionBall.Init;
begin
  inherited;
  FEffect.Clear;
end;

function TAwOptionBall.IsValid: boolean;
begin
  Result:=  inherited IsValid and FEffect.IsValid;
end;


{ TAwAnimateBall }

class function TAwAnimateBall.OptionClassGet: TawOptionClass;
begin
  Result := TAwOptionBall;
end;

function TAwAnimateBall.OptionGet: TAwOptionBall;
begin
  Result:= inherited Option as TAwOptionBall;
end;

procedure TAwAnimateBall.SetParam(ASource: IAwSourceBounds; ADelay: Cardinal;
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

procedure TAwAnimateBall.EventProcess;
var
  Bar,Bar2: Real;
  Bounds: TAwBounds;
  Value:Single;
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
     // Bar2:=Bar;
      Value := TAwMath.SwingTime(Option.Effect.X.Count, Option.Effect.X.Delta, Bar2) / 2;
      Bounds.Left := Bounds.Left + Value;
      Bounds.Width := Bounds.Width - Value * 2;
    end;
    if Option.Effect.Y.Delta <> 0 then
    begin
      Bar2:=Option.Effect.Y.Effect.Calc(Bar);
      Value :=  TAwMath.SwingTime(Option.Effect.Y.Count, Option.Effect.Y.Delta, Bar2) / 2;
      Bounds.Top := Bounds.Top + Value;
      Bounds.Height := Bounds.Height - Value * 2;
    end;
  end;
  if  not Option.Source.SetBounds(Bounds.Rect) then
  TerminateAndCancel;
end;


{$ENDREGION}



{$REGION 'MOVE'}

{ TAwOptionMove }

function TAwOptionMove.BoundsGet: PAwBounds;
begin
   Result:= @FBounds;
end;

procedure TAwOptionMove.Clear;
begin
  inherited Clear;
  FEffect.Clear;
  FBounds.Clear;
end;

function TAwOptionMove.EffectGet: PAwEffectBounds;
begin
   Result:= @FEffect;
end;

procedure TAwOptionMove.Init;
begin
  inherited;
  FEffect.Clear;
  FBounds.Clear;
end;

function TAwOptionMove.IsValid: boolean;
begin
  Result:= inherited IsValid 
  and FEffect.IsValid 
  and FBounds.isValid;
end;



{ TAwAnimateMove }

class function TAwAnimateMove.OptionClassGet: TawOptionClass;
begin
   Result:= TAwOptionMove;
end;

function TAwAnimateMove.OptionGet: TAwOptionMove;
begin
   Result:= inherited  Option as TAwOptionMove;
end;

procedure TAwAnimateMove.SetParam(ASource: IAwSourceBounds; ADelay: Cardinal;
  NewLeft, NewTop, NewWidth, NewHeight: Single; EffectMain: TAwEnumEffectMain;
  EffectMode: TAwEnumEffectMode);
begin   
  Option.Source:= ASource;
  Option.Delay:=  ADelay;
  Option.Bounds.Left:=   NewLeft;
  Option.Bounds.Top:=    NewTop;
  Option.Bounds.Width:=  NewWidth;
  Option.Bounds.Height:= NewHeight;
  Option.Effect.EffectSet(EffectMain,EffectMode); 
end;

procedure TAwAnimateMove.EventProcess;
var
  Bar: Real;
  NewBounds: TAwBounds;
  FCurRect:TRectF;
begin
  inherited;
  if not InProcessCheckSource 
  or not Option.Source.GetBounds(FCurRect)  then
  begin
    self.TerminateAndCancel;
    exit;
  end;

  Bar := Progress; 
  NewBounds.Location:= TAwMath.MoveEffect(FSaveRect.Location,
                                          Option.Bounds.Location,
                                          Bar,
                                          Option.Effect.Left.Calc,
                                          Option.Effect.Top.Calc);


  if Option.Bounds.Width >= 0 then
    NewBounds.Width := TAwMath.SwingToSingle(FSaveRect.Width, Option.Bounds.Width,
     Bar, Option.Effect.Width.Calc)
  else
    NewBounds.Width := FCurRect.Width;

  if Option.Bounds.Height >= 0 then
    NewBounds.Height := TAwMath.SwingToSingle(FSaveRect.Height, Option.Bounds.Height,
      Bar, Option.Effect.Height.Calc)
  else
    NewBounds.Height := FCurRect.Height;


  if  not Option.Source.SetBounds(NewBounds.Rect) then
   TerminateAndCancel;
end;
{$ENDREGION}


{$REGION 'ABSTRACT ALFA'}
{ TAwOptionAlfa }
procedure TAwOptionAlfa.Init;
begin
  inherited Init;
  FEffect.Clear;
end;

procedure TAwOptionAlfa.Clear;
begin
  inherited Clear;
   FEffect.Clear;
end;

function TAwOptionAlfa.EffectGet: PAwEffectSide;
begin
  Result:= @FEffect;
end;

function TAwOptionAlfa.IsValid: boolean;
begin
 Result:= inherited IsValid and FEffect.IsValid;
end;

function TAwOptionAlfa.SourceGet: IAwSourceAlfa;
begin
  Result:= inherited Source as IAwSourceAlfa;
end;

procedure TAwOptionAlfa.SourceSet(const Value: IAwSourceAlfa);
begin
  inherited Source := Value;
end;


{ TAwAnimateAlfaCustom }

constructor TAwAnimateAlfaCustom.Create;
begin
  inherited;
  FSaveAlfa:=0;
end;

destructor TAwAnimateAlfaCustom.Destroy;
begin

  inherited;
end;

function TAwAnimateAlfaCustom.IsValidParam: boolean;
begin
   Result:= inherited IsValidParam and  Option.Source.GetAlfa(FSaveAlfa);
end;

function TAwAnimateAlfaCustom.OptionGet: TAwOptionAlfa;
begin
   Result:= inherited Option as TAwOptionAlfa;
end;


{ TAwAnimateAlfa }

class function TAwAnimateAlfa.OptionClassGet: TawOptionClass;
begin
 Result:=  TAwOptionAlfa;
end;

procedure TAwAnimateAlfa.SetParam(ASource: IAwSourceAlfa; ADelay: Cardinal; DeltaDirection: Integer);
begin
   Option.Source:=     ASource;
   Option.Delay:=      ADelay;
   Option.Effect.Default;
   Option.Effect.Count:= 0.25;
   Option.Effect.Delta:= DeltaDirection;
end;

procedure TAwAnimateAlfa.EventProcess;
var
  Bar: Real;
  Lvl:byte;
  ValueDelta:integer;
  ValueSing:Single;
  function LocValueToByte(Value:Single):byte;
  var I:Int64;
  begin
    I:= Round(Value);
    if I > 255 then
      I:=255
    else if I < 0 then
      I:=0;
    Result:= byte(I);
  end;
begin
  inherited;
  if not InProcessCheckSource then
   exit;
  Bar := Progress;
  Lvl:= FSaveAlfa;
  ValueDelta:= Round(Option.Effect.Delta);
  if ValueDelta > 255 then
   ValueDelta:= 255;
  if ValueDelta < 255 then
   ValueDelta:= -255;


  if (Bar <= 1) and (ValueDelta <> 0) then
  begin
    Bar:=Option.Effect.Effect.Calc(Bar);
    ValueSing := TAwMath.SwingTime(Option.Effect.Count, ValueDelta, Bar);
    Lvl:= LocValueToByte(Lvl + ValueSing);
    if  not Option.Source.SetAlfa(Lvl) then
      TerminateAndCancel;
  end;


 {
  inherited;
  if not InProcessCheckSource then
   exit;
  Bar := Progress;
  Lvl := Round(abs(Option.LevelFrom - FParam.LvlFrom) * Bar);
  if FParam.LvlTo > FParam.LvlFrom then
    Lvl := FParam.LvlFrom + Lvl
  else
    Lvl := FParam.LvlFrom - Lvl;

  if not Option.Source.SetAlfa(Lvl) then
   self.TerminateAndCancel;
    }
end;



{$ENDREGION}

end.
