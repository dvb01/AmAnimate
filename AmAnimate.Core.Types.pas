unit AmAnimate.Core.Types;

interface
uses
  System.SysUtils,
  System.Types,
  System.classes,
  System.Generics.Collections,
  AmAnimate.Core.Math,
  AmAnimate.Core.Res;
type
  TAwProc = procedure of object;
  TAwObject = class abstract(TInterfacedObject);

  PAwBounds = ^TAwBounds;

  TAwBounds = record
  private
    function GetRect: TRectF;
    procedure SetRect(Value: TRectF);
    function LocationGet: TPointF;
    procedure LocationSet(const Value: TPointF);
  public
    Left: Single;
    Top: Single;
    Width: Single;
    Height: Single;
    procedure Clear;
    property Rect: TRectF read GetRect write SetRect;
    property Location: TPointF read LocationGet write LocationSet;
    function IsValid:boolean;
  end;




  PAwDcvItem = ^TAwDcvItem;
  TAwDcvItem = record
    Start:Double;
    Finish:Double;
    Now:Double;
    FuncCalc:TAwCalcRef;
  end;

  IAwDcvEnumerator = interface
    function GetCurrent:PAwDcvItem;
    property Current: PAwDcvItem read GetCurrent;
    function MoveNext: Boolean;
    procedure Reset;
  end;

  TAwDcvDictionary = class (TDictionary<string,PAwDcvItem>)
   private
     FDcvEnumerator:IAwDcvEnumerator;
    function DcvEnumeratorGet: IAwDcvEnumerator;
   public
    constructor Create(ACapacity: Integer = 0);
    destructor Destroy; override;
    property DcvEnumerator: IAwDcvEnumerator read DcvEnumeratorGet;
  end;
  TAwDcvEnumeratorGen = TDictionary<string,PAwDcvItem>.TValueEnumerator;

  TAwDcvEnumerator = class (TAwObject,IAwDcvEnumerator)
   private
    FEnumerator:TAwDcvEnumeratorGen;
   public
    constructor Create(const ADictionary: TAwDcvDictionary);
    destructor Destroy; override;
    function GetCurrent:PAwDcvItem;
    property Current: PAwDcvItem read GetCurrent;
    function MoveNext: Boolean;
    procedure Reset;
  end;

  TAwDcvEnumeratorHelper = class helper for TAwDcvEnumeratorGen
   public
    procedure Reset;
  end;


  // класс помоши для рассылки событий  TAwProc  procedure of object;
  // можете любое что то свое использовать
  // используется например в  AmAnimate.Source.Vcl
  // что бы разослать события об освобождении объекта в анимации
  TAwHandleBroadcastDestroy = class
  strict private
    FArr: TArray<TAwProc>;
    FCount: Integer;
    FFlagChangedArr: boolean;
    FFlagInvokeLock: Integer;
    function Capacity: Integer;
    procedure Grow;
    procedure CheckGrow;
    function IndexOf(const Event: TAwProc): Integer;
    procedure Delete(Index: Integer);
  public
    procedure Sub(Event: TAwProc);
    procedure UnSub(Event: TAwProc);
    procedure Invoke;
    constructor Create;
    destructor Destroy; override;
  end;

implementation


{ TAwHandleBroadcast }

constructor TAwHandleBroadcastDestroy.Create;
begin
  inherited;
  FCount := 0;
  FArr := nil;
  FFlagChangedArr := false;
  FFlagInvokeLock := 0;
end;

destructor TAwHandleBroadcastDestroy.Destroy;
begin
  FArr := nil;
  FCount := 0;
  inherited;
end;

function TAwHandleBroadcastDestroy.Capacity: Integer;
begin
  Result := Length(FArr);
end;

procedure TAwHandleBroadcastDestroy.CheckGrow;
begin
  if FCount >= Capacity then
     Grow;
end;

procedure TAwHandleBroadcastDestroy.Grow;
begin
  Setlength(FArr,GrowCollection(Capacity,Capacity+1));
end;

procedure TAwHandleBroadcastDestroy.Invoke;
var
  i: Integer;
  Map: TDictionary<TAwProc, boolean>;
  Proc: TAwProc;
  IsBreaker: boolean;
begin
  if FCount <= 0 then
    exit;
  // Setlength(A, FCount);
  // Move(FArr[0], A[0], Sizeof(TAwProc) * FCount);
  // for i := Length(A) - 1 downto 0 do
  // A[i]();
  // во время выпонения   A[i]();
  // FArr может поменятся сколько угодно раз как и добавление так и удаление
  // поэтому после каждого вызова нужно заново обращатся к FArr и проходить по списку
  // пока не пройдем все процедуры
  // т.к этот объект используется только для события удаления
  // то в момент вызова Invoke   Sub не может быть вызван
  // на  Sub кинем исключение а UnSub может вызыватся сколько угодно раз
  // в вызваном Invoke

  if FFlagInvokeLock <> 0 then
    raise Exception.CreateResFmt(@RsTAwHandleBroadcast_Invoke, []);
  inc(FFlagInvokeLock);
  try
    FFlagChangedArr := false;
    IsBreaker := false;
    Map := TDictionary<TAwProc, boolean>.Create(FCount);
    try
      while (FCount > 0) and not IsBreaker do
      begin
        IsBreaker := true;
        for i := 0 to FCount - 1 do
          if Map.TryAdd(FArr[i], false) then
          begin
            Proc := FArr[i];
            Proc();
            if FFlagChangedArr then
            begin
              FFlagChangedArr := false;
              IsBreaker := false;
              break;
            end;
          end;
      end;
    finally
      FFlagChangedArr := false;
      Map.Free;
    end;
  finally
    dec(FFlagInvokeLock);
  end;

end;

function TAwHandleBroadcastDestroy.IndexOf(const Event: TAwProc): Integer;
begin
  for Result := FCount - 1 downto 0 do
    if TMethod(Event) = TMethod(FArr[Result]) then
      exit;
  Result := -1;
end;

procedure TAwHandleBroadcastDestroy.Sub(Event: TAwProc);
begin
  if (TMethod(Event).Code = nil) or (TMethod(Event).Data = nil) or
    (IndexOf(Event) >= 0) then
    exit;
  if FFlagInvokeLock <> 0 then
    raise Exception.CreateResFmt(@RsTAwHandleBroadcast_Sub, []);
  CheckGrow;
  FFlagChangedArr := true;
  FArr[FCount] := Event;
  inc(FCount);
end;

procedure TAwHandleBroadcastDestroy.UnSub(Event: TAwProc);
var
  i: Integer;
begin
  if (TMethod(Event).Code = nil) or (TMethod(Event).Data = nil) then
    exit;
  if FCount <= 0 then
    exit;
  if TMethod(FArr[FCount - 1]) = TMethod(Event) then
    Delete(FCount - 1)
  else
  begin
    i := IndexOf(Event);
    if i >= 0 then
      Delete(i);
  end;
end;

procedure TAwHandleBroadcastDestroy.Delete(Index: Integer);
begin
  FFlagChangedArr := true;
  dec(FCount);
  if Index < FCount then
    System.Move(FArr[Index + 1], FArr[Index],
      Sizeof(TAwProc) * (FCount - Index));
end;


{ TAmAnimateBounds }

procedure TAwBounds.Clear;
begin
  fillchar(self, sizeof(self), 0);
  Width := -1;
  Height := -1;
end;

function TAwBounds.GetRect: TRectF;
begin
  Result.Left := Left;
  Result.Top := Top;
  Result.Width := Width;
  Result.Height := Height;
end;

function TAwBounds.IsValid: boolean;
begin
 // не нужно чекать параметры для валидности
 // т.к left top может быть любое число а Width Height чекается в исполнителе
 Result:= true;
end;

function TAwBounds.LocationGet: TPointF;
begin
  Result:= Rect.Location;
end;

procedure TAwBounds.LocationSet(const Value: TPointF);
begin
   Left:= Value.X;
   Top:= Value.Y;
end;

procedure TAwBounds.SetRect(Value: TRectF);
begin
  Left := Value.Left;
  Top := Value.Top;
  Width := Value.Width;
  Height := Value.Height;
end;

{ TAwDcvEnumeratorHelper }

procedure TAwDcvEnumeratorHelper.Reset;
begin
  with self do
   FIndex:=-1;
end;

{ TAwDcvDictionary }

constructor TAwDcvDictionary.Create(ACapacity: Integer);
begin
 inherited Create(ACapacity);
 FDcvEnumerator:= nil;
end;

destructor TAwDcvDictionary.Destroy;
begin
  FDcvEnumerator:= nil;
  inherited;
end;

function TAwDcvDictionary.DcvEnumeratorGet: IAwDcvEnumerator;
begin
   if FDcvEnumerator = nil then
    FDcvEnumerator:=  TAwDcvEnumerator.Create(self);
   Result:= FDcvEnumerator;
end;


{ TAwDcvEnumerator }

constructor TAwDcvEnumerator.Create(const ADictionary: TAwDcvDictionary);
begin
  inherited Create;
  FEnumerator:=TAwDcvEnumeratorGen.Create(ADictionary);
end;

destructor TAwDcvEnumerator.Destroy;
begin
  FreeAndNil(FEnumerator);
  inherited;
end;

function TAwDcvEnumerator.GetCurrent: PAwDcvItem;
begin
   Result:= FEnumerator.Current;
end;

function TAwDcvEnumerator.MoveNext: Boolean;
begin
  Result:= FEnumerator.MoveNext;
end;

procedure TAwDcvEnumerator.Reset;
begin
   FEnumerator.Reset;
end;

end.
