unit AmAnimate.Core.Source.Intf;

interface

uses
  System.SysUtils,
  System.Types,
  AmAnimate.Core.Math,
  AmAnimate.Core.Types,
  AmAnimate.Core.Res;
type

  IAwSourceEvent = interface;

  IAwAnimateIntf = interface(IInterface)
   ['{3FA527B0-F6D8-481D-98DA-31391E0907D3}']
  end;



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

    // если вы вернете не nil то в этот интерфйс будут отправлятся события о процессе анимации
    function EventsGet:IAwSourceEvent;
    property Events: IAwSourceEvent read EventsGet;
  end;





  // интерфейс событиий которые происходят в анимации
  // интерфейс являяется свойсвом интефейса IAwSource
  // события вынесены для уведомления и блокировки контрола
  IAwSourceEvent = interface(IInterface)
    ['{B5BF0D26-DC56-4382-85FB-1D309A5B80DB}']
     //   Sender:IAwAnimateIntf as AmAnimate.Engine.IAwAnimateBase
     // предполагается что sender будет использовтся только для чтения состояний анимации
     // пока отдельный интерфейс не делал
     procedure EventStartFerst( const Sender:IAwAnimateIntf);
     procedure EventFinishLast( const Sender:IAwAnimateIntf);
     procedure EventStart(const Sender:IAwAnimateIntf);
     procedure EventFinish(const Sender:IAwAnimateIntf);
     procedure EventProcess(const Sender:IAwAnimateIntf);
     procedure EventActivated( const Sender:IAwAnimateIntf);
     procedure EventDeactivated( const Sender:IAwAnimateIntf);
  end;



  ////////////////////////////////////////////////////////////////////////////
  ///                                                                      ///
  ///                                                                      ///
  ///        интерфейсы для AmAnimate.Core.Effects.Def.Classes             ///
  ///                                                                      ///
  ///                                                                      ///
  ////////////////////////////////////////////////////////////////////////////

  {$REGION 'интерфейсы для AmAnimate.Core.Effects.Def.Classes'}

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
    function GetAlfa(var Value:byte): boolean;
    function SetAlfa(const Value: byte): boolean;
  end;
  {$ENDREGION}


  ////////////////////////////////////////////////////////////////////////////
  ///                                                                      ///
  ///                                                                      ///
  ///        интерфейсы для AmAnimate.Core.Effects.Dcv.Classes             ///
  ///                                                                      ///
  ///                                                                      ///
  ////////////////////////////////////////////////////////////////////////////
  ///  table of dynamic custom variables
  {$REGION 'интерфейсы для AmAnimate.Core.Effects.Dcv.Classes'}
  IAwSourceDcvTable = interface
    ['{94D246BD-C1CC-4075-B2FA-31B4FA8B89D1}']
    // получить FuncCalc можно в  TAwMath.EnumToFuncRef
    function FixedTableGet:boolean;
    procedure FixedTableSet(const Value:boolean);
    function Add(const Name:string;ValueStart,ValueFinish:Double;FuncCalc:TAwCalcRef=nil):boolean;
    function AddPrm(const Name:string;Prm:TAwDcvItem):boolean;
    function Delete(const Name:string):boolean;
    function IsName(const Name:string):boolean;
    function GetNowValue(const Name:string;out Value:Double):boolean;
    function GetPrm(const Name:string;out Prm:PAwDcvItem):boolean;
    procedure Clear;
    function Enumerator:IAwDcvEnumerator;
    function IsValid: boolean;
    // запрещеет добавлять удалять очищать таблицу
    property FixedTable: boolean read FixedTableGet write FixedTableSet;
  end;

  // используется что бы анимировать кастомные переменные на ключу их имяни
  // переменных может быть сколько угодно
  // требуется инициализировать в начале анимации эти переменные
  // допустимые типы числовые
  IAwSourceDcv = interface(IAwSource)
    ['{24FA2E23-36F9-45BD-9E89-008F10BD9B44}']
    // инициализуем переменные анимация стартует
    function DcvStart( const Table:IAwSourceDcvTable):boolean;
    // получаем промежуточное значение
    function DcvProcess( const Table:IAwSourceDcvTable):boolean;
    // анимация закончена
    function DcvFinish( const Table:IAwSourceDcvTable):boolean;
  end;
 {$ENDREGION}


implementation


end.
