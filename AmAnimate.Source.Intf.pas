unit AmAnimate.Source.Intf;

interface

uses
  System.SysUtils,
  System.Types,
  System.Generics.Collections,
  AmAnimate.Res;

type

  TAwProc = procedure of object;

  // базовый интерфейс Source (того объекта который будем анимаровать)
  // текущий модуль низко уровневый так что о котролах он не знает
  // используйте unit AmAnimate.Source.Vcl что бы пользоватся прокладками для IAwSource
  // сильная ссылка на IAwSource хранится в TawLocExecutor.FSource
  // допустимо один и тот же IAwSource.Control или IAwSource использовать  в нескольких анимациях одновременно
  // IAmwSource должен использоватся  только как 1 объект а не их список
  // молудь AmAnimate.Engine рассматривает вариант только моногамной интерпритации  IAmwSource
  // ControlGet должен возвращать всегда одну и туже ссылку или nil
  IAwSource = interface(IInterface)
    ['{BFBE373B-0EA6-455D-85A3-10F99A4A080E}']
    // отправьте событие в процедуры которые подписались на SubOnDestroy когда  IAwSource удаляется
    procedure SubOnDestroy(NotifyEvent: TAwProc);
    // объект анимации гарантированно отпищется от события когда будет удалятся
    procedure UnSubOnDestroy(NotifyEvent: TAwProc);
    // ваши данные в объекте валидны можно делать анимацию
    function IsValid: boolean;
    // используется что бы сравнить Pointer при отмене анимации для ControlGet
    // ControlGet это например TControl тот объект над которым выполнятся анимация
    function ControlGet: Pointer;
    property Control: Pointer read ControlGet;
  end;

  // используется в процессе анимации что бы получить установить Bounds контролу
  // используйте модуль AmAnimated.Source.Vcl что бы правильно устанавливать SetBounds
  // ведь SetBounds можно делать не только через объект контрола но и через winapi напрямую
  // для разных анимаций разные способы хороши сморя чего хотим добится
  IAwSourceBounds = interface(IAwSource)
    ['{5A91D83D-80E5-48A9-BAA0-F5729358C94D}']
    function GetBounds(var Rect: TRectF): boolean;
    function SetBounds(const Rect: TRectF): boolean;
  end;

  // используется что бы анимировать прозрачность
  IAwSourceAlfa = interface(IAwSource)
    ['{062872E6-D13A-4A40-89F6-DB4A0D4EE36A}']
    function GetAlfa: byte;
    function SetAlfa(const Value: byte): boolean;
  end;

  // класс помоши для рассылки событий  TAwProc  procedure of object;
  // можете любое что то свое использовать
  TAwHandleBroadcastDestroy = class
  strict private
    FArr: TArray<TAwProc>;
    FCount: Integer;
    FFlagChangedArr:integer;
    FFlagInvokeLock:integer;
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
  FFlagChangedArr:=0;
  FFlagInvokeLock:=0;
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
  Setlength(FArr, Capacity + 20);
end;

procedure TAwHandleBroadcastDestroy.Invoke;
var
  i: Integer;
  Map:TDictionary<TAwProc,Boolean>;
  Proc:TAwProc;
  IsBreaker:boolean;
begin
  if FCount <= 0 then
    exit;
   // Setlength(A, FCount);
   // Move(FArr[0], A[0], Sizeof(TAwProc) * FCount);
   // for i := Length(A) - 1 downto 0 do
   //   A[i]();
   // во время выпонения   A[i]();
   // FArr может поменятся сколько угодно раз как и добавление так и удаление
   // поэтому после каждого вызова нужно заново обращатся к FArr и проходить по списку
   // пока не пройдем все процедуры
   // т.к этот объект используется только для события удаления
   // то в момент вызова Invoke   Sub не может быть вызван
   // на  Sub кинем исключение а UnSub может вызыватся сколько угодно раз
   // в вызваном Invoke

   if FFlagInvokeLock <> 0 then
   raise Exception.CreateResFmt(@RsTAwHandleBroadcast_Invoke,[]);
   inc(FFlagInvokeLock);
   try
       FFlagChangedArr:=0;
       IsBreaker:= false;
       Map:=TDictionary<TAwProc,Boolean>.Create;
       try
          while (FCount > 0) and  not IsBreaker do
          begin
            IsBreaker:=true;
            for I := 0 to FCount - 1 do
             if Map.TryAdd(FArr[i],false) then
             begin
              Proc:= FArr[i];
              Proc();
              if FFlagChangedArr <> 0 then
              begin
                FFlagChangedArr:=0;
                IsBreaker:=false;
                break;
              end;
             end;
          end;
       finally
         FFlagChangedArr:=0;
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
  raise Exception.CreateResFmt(@RsTAwHandleBroadcast_Sub,[]);
  CheckGrow;
  inc(FFlagChangedArr);
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
  inc(FFlagChangedArr);
  Dec(FCount);
  if Index < FCount then
    System.Move(FArr[Index + 1], FArr[Index],
      Sizeof(TAwProc) * (FCount - Index));
end;

end.
