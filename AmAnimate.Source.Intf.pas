unit AmAnimate.Source.Intf;

interface

uses
  System.SysUtils,
  System.Types;

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
  TAwHandleBroadcast = class
  strict private
    FArr: TArray<TAwProc>;
    FCount: Integer;
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

constructor TAwHandleBroadcast.Create;
begin
  inherited;
  FCount := 0;
  FArr := nil;
end;

destructor TAwHandleBroadcast.Destroy;
begin
  FArr := nil;
  FCount := 0;
  inherited;
end;

function TAwHandleBroadcast.Capacity: Integer;
begin
  Result := Length(FArr);
end;

procedure TAwHandleBroadcast.CheckGrow;
begin
  if FCount >= Capacity then
    Grow;
end;

procedure TAwHandleBroadcast.Grow;
begin
  Setlength(FArr, Capacity + 20);
end;

procedure TAwHandleBroadcast.Invoke;
var
  i: Integer;
  A: TArray<TAwProc>;
begin
  if FCount <= 0 then
    exit;
  Setlength(A, FCount);
  Move(FArr[0], A[0], Sizeof(TAwProc) * FCount);
  for i := Length(A) - 1 downto 0 do
    A[i]();
end;

function TAwHandleBroadcast.IndexOf(const Event: TAwProc): Integer;
begin
  for Result := FCount - 1 downto 0 do
    if TMethod(Event) = TMethod(FArr[Result]) then
      exit;
  Result := -1;
end;

procedure TAwHandleBroadcast.Sub(Event: TAwProc);
begin
  if (TMethod(Event).Code = nil) or (TMethod(Event).Data = nil) or
    (IndexOf(Event) >= 0) then
    exit;
  CheckGrow;
  FArr[FCount] := Event;
  inc(FCount);
end;

procedure TAwHandleBroadcast.UnSub(Event: TAwProc);
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

procedure TAwHandleBroadcast.Delete(Index: Integer);
begin
  Dec(FCount);
  if Index < FCount then
    System.Move(FArr[Index + 1], FArr[Index],
      Sizeof(TAwProc) * (FCount - Index));
end;

end.
