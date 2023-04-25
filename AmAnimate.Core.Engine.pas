unit AmAnimate.Core.Engine;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Math,
  AmAnimate.Core.Res,
  AmAnimate.Core.Types,
  AmAnimate.Core.Source.Intf;

var
  AwAnimateCoreEngineDebugMode: boolean = false;
  AwAnimateCoreEngineNotBlockingMode: boolean = false;

type

  TAwProcProcessMessage = procedure of object;
  TAwEventLockedApplication = procedure (IsLocked:boolean) of object;


  // базовые классы анимации
  // базовый интерфейс Source (того объекта который будем анимаровать)
  IAwQueue = interface; // список последовательных анимаций
  TAwAnimateBase = class; // базовый класс одной анимации
  IAwAnimateBase = interface; // базовый интерфейс одной анимации
  TAwAnimateClass = class of TAwAnimateBase;


  // локальные настройки конкретной анимации
  // каждый класс должен сам себе создать если вообще это ему нужно
  // свои настойки,  параметры с которыми он будет работать
  TAwOptionBase = class;
  TAwOptionClass = class of TAwOptionBase;

  TAwEvent = procedure(Animate: IAwAnimateBase) of object;
  TAwEventRef = reference to procedure(Animate:IAwAnimateBase);

  // заглушка  пустая анимация
  IAwAnimateEmpty = interface;
  TAwAnimateEmpty = class;

  // кастомная анимация с событиями
  // в событиях можно написать свое
  IAwAnimateCustom = interface;
  TAwAnimateCustom = class;


  // помошь в создании объектов анимаций
  // 1. отменить для конкретного объекта незавершенные анимации
  // 2. создать разные анимации в наследниках
{$REGION 'FactoryBase'}

  AwFactoryBase = class(TAwObject)
  private
    class function CountAnimatesActiveGet: Cardinal; static;
    class function CountAnimatesCreatedGet: Cardinal; static;
    class function CountObjectsCreatedGet: Cardinal; static;
    class function ProcApplicationProcessMessageGet: TAwProcProcessMessage;static;
    class procedure ProcApplicationProcessMessageSet(const Value: TAwProcProcessMessage);static;
    class function OnLockedApplicationGet: TAwEventLockedApplication; static;
    class procedure OnLockedApplicationSet(
      const Value: TAwEventLockedApplication); static;
  protected
    // что бы блокировка анимации работала IAwAnimateBase.BlockingBehavior = avbLock
    // внешне сюда указать процедуру которая будет вызывать Application.ProcessMessage
    class property ProcApplicationProcessMessage: TAwProcProcessMessage
                                       read ProcApplicationProcessMessageGet
                                       write ProcApplicationProcessMessageSet;
  public
    // helper
    class procedure SourceCancel(Source: IAwSource); static;
    class procedure Clear; static;
    // creator
    class function NewList: IAwQueue;  static;
    class function Base(AClass: TAwAnimateClass = nil): IAwAnimateBase; static;
    class function Empty(): IAwAnimateEmpty; static;

    // debug
    class property CountObjectsCreated: Cardinal read CountObjectsCreatedGet;
    class property CountAnimatesCreated: Cardinal read CountAnimatesCreatedGet;
    class property CountAnimatesActive: Cardinal read CountAnimatesActiveGet;

    // system

    // получить событие что анимация заблокировала приложение и находится в режимме ожидания исполнения анимации
    //c сработает когда IAwAnimateBase.BlockingBehavior = avbLock
    class property OnLockedApplication: TAwEventLockedApplication
                                      read OnLockedApplicationGet
                                      write OnLockedApplicationSet;

  end;
{$ENDREGION}

  // последовательное выполнений анимаций очередь Queue
{$REGION 'Queue'}

  IAwQueue = interface(IInterface)
    // private
    function StartedGet: Boolean;
    function RepeatCountGet: Integer;
    procedure RepeatCountSet(const Value: Integer);
    function RepeatCurIndexGet: Integer;
    procedure RepeatCurIndexSet(const Value: Integer);
    // public
    // StartOffset есди перед текущей анимацием есть другая анимация то эта должна запустится
    // по формуле Prev.Delay + Self.StartOffset может быть <0
    procedure Add(Value: IAwAnimateBase; StartOffset: Integer);
    property RepeatCount: Integer read RepeatCountGet write RepeatCountSet;
    property RepeatCurIndex: Integer read RepeatCurIndexGet write RepeatCurIndexSet;
    property Started: Boolean read StartedGet;
    procedure Start;
    // отмена выполнения очереди если в очереди есть IAmAnimateBase.Source  = Source то вся очередь отменяется
    procedure CancelSource(Source: IAwSource);
    procedure CancelAll;
  end;

  // для внутреннего использования
  IAwLocQueue = interface(IInterface)
    procedure NotifyTick(Sender: IAwAnimateBase; isFinish: boolean);
    procedure CancelAll;
  end;
{$ENDREGION}

  // базовый интерфейс одной анимации
{$REGION 'Animate Base'}

  IAwAnimateBase = interface(IAwAnimateIntf)
    ['{84B0FE44-97BC-4D1B-B4EB-E3E32003191D}']
    // private
    function ActiveGet: boolean;
    function IsDestroyingGet: boolean;
    function IdGet: Cardinal;
    function NameGet: string;
    procedure NameSet(const Value: string);
    function BlockingGet: Boolean;
    procedure BlockingSet(const Value: Boolean);
    function ProgressIndexGet: Integer;
    function ProgressGet: Real;
    function ProgressCountGet: Integer;
    function AsObjectGet: TAwAnimateBase;
    function DebugModeGet: boolean;
    procedure DebugModeSet(const Value: boolean);
    function IntervalHeartBeatGet: Cardinal;
    procedure IntervalHeartBeatSet(const Value: Cardinal);
    function TerminatedGet: boolean;

    function OnFinishGet: TAwEvent;
    procedure OnFinishSet(const Value: TAwEvent);
    function OnProcessGet: TAwEvent;
    procedure OnProcessSet(const Value: TAwEvent);
    function OnStartGet: TAwEvent;
    procedure OnStartSet(const Value: TAwEvent);
    function OnDestroyingGet: TAwEvent;
    procedure OnDestroyingSet(const Value: TAwEvent);
    function OnFinishLastGet: TAwEvent;
    procedure OnFinishLastSet(const Value: TAwEvent);
    function OnFinishLastRefGet: TAwEventRef;
    procedure OnFinishLastRefSet(const Value: TAwEventRef);
    function OnStartFerstGet: TAwEvent;
    procedure OnStartFerstSet(const Value: TAwEvent);


    // public
    // получить объект
    property AsObject: TAwAnimateBase read AsObjectGet;
    // удаляется объект
    property IsDestroying: boolean read IsDestroyingGet;
    // глобальный id текущего
    property Id: Cardinal read IdGet;
    // произвольное имя
    property Name: string read NameGet write NameSet;


    // блокировка анимация
    // анимация запускаем в режиме модальной формы
    //приложение не закроется если будет выполнятся анимация
    // обрабатывайте событие о блокировке закрытия программы
    // AwFactoryBase.OnLockedApplication
    // пока счетчик >0 дайте пользователю подождать при закрытии программы
    // или
    // 1. отмените все анимации
    // 2. не закрывайте программу выполнив отмену закрытия
    // 3. сразу отправьте на форму postmessage
    // 4. примите postmessage а там уже закройте прогу
    // TForm.Release в некоторых случаях может помочь
    // что бы уберечь себя от случайного использования установите
    // AwAnimateCoreEngineNotBlockingMode = true
    property Blocking: Boolean read BlockingGet write BlockingSet;



    // настройка интервал серцебиения по умолчанию 20 ms
    property IntervalHeartBeat: Cardinal read IntervalHeartBeatGet
      write IntervalHeartBeatSet;

    // позволяет ловить каждый кадр в режиме отладки
    // или же установить для всех unit AmAnimated.AmAnimateDebugMode:=true
    property DebugMode: boolean read DebugModeGet write DebugModeSet;

    // старт стоп
    // ........................................
    property Active: boolean read ActiveGet;
    procedure Start;
    // при Terminate запрещаем в будующем запускать эту анимацию
    // Terminate не отменяет проигрывание а запрещает повторно запускатся
    procedure Terminate;
    procedure TerminateReset;
    property Terminated: boolean read TerminatedGet;
    // Cancel отменяет проигрывание текущей тут же и анимацию можно запустить повторно Start
    // если не было  Terminate
    procedure Cancel;
    // ........................................

    // от 0 до 1 прогресс анимации
    property Progress: Real read ProgressGet;
    // индекс фрейма к текуший момент
    property ProgressIndex: Integer read ProgressIndexGet;
    // сколько всего фреймов
    property ProgressCount: Integer read ProgressCountGet;

    property OnStart: TAwEvent read OnStartGet write OnStartSet;
    property OnFinish: TAwEvent read OnFinishGet write OnFinishSet;
    property OnStartFerst: TAwEvent read OnStartFerstGet write OnStartFerstSet;
    property OnFinishLast: TAwEvent read OnFinishLastGet write OnFinishLastSet;
    property OnFinishLastRef: TAwEventRef read OnFinishLastRefGet write OnFinishLastRefSet;
    property OnProcess: TAwEvent read OnProcessGet write OnProcessSet;
    property OnDestroying: TAwEvent read OnDestroyingGet write OnDestroyingSet;

  end;
{$ENDREGION}
  /// TAwLocExecutor базовый локальный исполнитель анимации  для внутреннего использования
  /// IAwLocExecutor локальный исполнитель одной анимации интерфейс для внутреннего использования
  /// тоже что и IAwAnimateBase только со своими правами
{$REGION 'Executor'}

  IAwLocExecutor = interface(IInterface)
    function SourceGet: IAwSource;
    function ActiveGet: boolean;
    function PauseGet: boolean;
    function RunnerGet: TObject;
    function AsAnimateExecutorGet: IAwAnimateBase;
    function IsDestroyingGet: boolean;
    procedure RunnerSet(const Value: TObject);
    function EventRun: Cardinal;
    procedure Cancel;
    procedure Terminate;
    property Runner: TObject read RunnerGet write RunnerSet;
    property AsAnimateExecutor: IAwAnimateBase read AsAnimateExecutorGet;
    property IsDestroying: boolean read IsDestroyingGet;
    property Active: boolean read ActiveGet;
    property Pause: boolean read PauseGet;
    property Source: IAwSource read SourceGet;
  end;

  TAwLocExecutor = class abstract(TAwObject, IAwAnimateBase, IAwAnimateIntf, IAwLocExecutor)
{$REGION 'Bar'}
  type

    // хранит переменные производные от Window.GetTickCount
    /// для слежки за времяним и частотой кадров
    /// есть 2 режима
    /// 1. зависит от  Window.GetTickCount
    /// 2. зависит от кол-ва вызовов таймера
    /// ниже есть описание классов
    TBar = class abstract(TObject)
    strict private
      FCounterRunner: Cardinal;
      FIntervalHeartBeat: Cardinal;
      function IntervalHeartBeatGet: Cardinal;
      procedure IntervalHeartBeatSet(const Value: Cardinal);
    protected

      // настройка интервал серцебиения по умолчанию 20 ms
      property IntervalHeartBeat: Cardinal read IntervalHeartBeatGet
        write IntervalHeartBeatSet;
      // вызвать когда активируется анимация TvLocalExecutor.Active =True
      // TvLocalExecutor.FActive := Activated вадиные ли данные в классе
      function Activated: boolean; virtual; abstract;
      // вызвать когда анимация выключается
      procedure Deactivated; virtual; abstract;

      // обновить переменную FCounterRunner
      property CounterRunner: Cardinal read FCounterRunner write FCounterRunner;

      function IsValid: boolean; virtual; abstract;

      // вызвать в TvLocalExecutor.EventRun
      // обновить текущую дату
      procedure UpdateNow; virtual; abstract;

      // вернуть число от 0.00001 до 1 включительно,  процент заверщенности анимации procent / 100
      function GetProgress: Real; virtual; abstract;

      // обновить дату следушего запуска следующего фрейма
      procedure UpdateNextPlayFrame; virtual; abstract;

      // получить дату следующего ближайшего запуска фрейма
      // вернуть 0 если прямо сейчас
      // вернуть разницу по времяни в ms  через сколько следущий фрейм должен запустится
      // 0 если анимация завершина и нужно или перезапустится или завершить проигрывание
      // если хотим зациклить то вызвать  обратно Activated а затем GetNextPlayFrame
      function GetDeltaNextPlayFrame: Cardinal; virtual; abstract;
    public
      constructor Create; virtual;
      destructor Destroy; override;
    end;

    /// анимация привязна к  Window.GetTickCount
    /// идея если длительность анимаци 1000 а  гл. поток завис на 2000  то анимация не будет проиграна
    /// т.к время ее жизни вышло ее 1 сек назад
    /// при debug вы не получите все кадры анимации т.к точка остонова будет приводить к зависанию гл. потока
    /// но зато это визуально гарантирут что анимация будет заверщена за 1000 ms
    /// конечно это не гарантирут что через 1000 ms вы получите событие о завершении т.к гл. поток может быть в зависании
    TBarTick = class(TBar)
    private
      FNow: Cardinal;
      FFirstTick, FNextTick, FLastTick: Int64;
      FCommonTimePlayBack: Cardinal;
      function CommonTimePlayBackGet: Cardinal;
      procedure CommonTimePlayBackSet(const Value: Cardinal);
      function FrameCountGet: Cardinal;
      function FrameIndexGet: Cardinal;
    protected
      function Activated: boolean; override;
      procedure Deactivated; override;
      function IsValid: boolean; override;
      procedure UpdateNow; override;
      function GetProgress: Real; override;
      procedure UpdateNextPlayFrame; override;
      function GetDeltaNextPlayFrame: Cardinal; override;
    public
      constructor Create; override;
      destructor Destroy; override;
      // настройка общее время проигрывание анимации
      property CommonTimePlayBack: Cardinal read CommonTimePlayBackGet
        write CommonTimePlayBackSet;
      // расчтет кол-ва frame   CommonTimePlayBack / IntervalHeartBeat
      property FrameCount: Cardinal read FrameCountGet;
      // текущий индекс
      property FrameIndex: Cardinal read FrameIndexGet;
    end;

    /// анимация привязна к  кол-ву фреймов и итерируется по индексу
    /// идея если длительность анимаци 1000 а  гл. поток завис на 2000  то анимация будет проиграна (продолжит проигрыватся)
    /// после разблокировки гл. потока
    /// при debug вы  получите все кадры анимации
    /// визуально анимация может занять больше времяни чем вы указали
    /// нет гарантий что через 1000 ms вы получите событие о завершении т.к гл. поток может быть в зависании
    /// событие о заверщении наступил когда  FrameIndex = FrameCount-1
    TBarDebug = class(TBar)
    private
      FFrameCount: Cardinal;
      FFrameIndex: Cardinal;
      FNextTick: Cardinal;
      FNow: Cardinal;
      function FrameCountGet: Cardinal;
      procedure FrameCountSet(const Value: Cardinal);
      function FrameIndexGet: Cardinal;
      procedure FrameIndexSet(const Value: Cardinal);
    protected
      function Activated: boolean; override;
      procedure Deactivated; override;
      procedure UpdateNow; override;
      function GetProgress: Real; override;
      procedure UpdateNextPlayFrame; override;
      function GetDeltaNextPlayFrame: Cardinal; override;
      function IsValid: boolean; override;
    public
      constructor Create; override;
      destructor Destroy; override;
      // настройка косвенно влияем на длительность анимации
      property FrameCount: Cardinal read FrameCountGet write FrameCountSet;
      // настройка  текущий индекс
      property FrameIndex: Cardinal read FrameIndexGet write FrameIndexSet;
    end;

{$ENDREGION}
  private
    FId: Cardinal;
    FName: string;
    [unsafe]FRunner: TObject; // TbwRunner;
    [weak] FParentQueue: IAwLocQueue;
    FBar: TBar;
    FActive: boolean;
    FPause: boolean;
    FBlocking: Boolean;
    FIsDestroying: boolean;
    FDebugMode: boolean;
    FIsWasTickRun: boolean;
    FTerminated: boolean;
    FSource: IAwSource; // weak
    FOption: TAwOptionBase;
    FRepeatCount: Integer;
    FRepeatIndex: Integer;
    FStartOffset: Integer;
    FOnStart: TAwEvent;
    FOnFinish: TAwEvent;
    FOnStartFerst: TAwEvent;
    FOnFinishLast: TAwEvent;
    FOnFinishLastRef: TAwEventRef;
    FOnProcess: TAwEvent;
    FOnDestryoing: TAwEvent;

    // IAwAnimateBase
    function ActiveGet: boolean;
    procedure ActiveSet(const Value: boolean);
    function DelayGet: Cardinal;
    procedure DelaySet(const Value: Cardinal);
    function PauseGet: boolean;
    procedure PauseSet(const Value: boolean);
    function ProgressGet: Real;
    function BlockingGet: Boolean;
    procedure BlockingSet(const Value: Boolean);
    function SourceGet: IAwSource;
    procedure SourceSet(const Value: IAwSource);
    function ProgressIndexGet: Integer;
    function IntervalHeartBeatGet: Cardinal;
    procedure IntervalHeartBeatSet(const Value: Cardinal);
    function ProgressCountGet: Integer;
    function ProgressRepeatIndexGet: Integer;
    function RepeatCountGet: Integer;
    procedure RepeatCountSet(const Value: Integer);
    function IdGet: Cardinal;
    function NameGet: string;
    procedure NameSet(const Value: string);
    function DebugModeGet: boolean;
    procedure DebugModeSet(const Value: boolean);
    function StartOffsetGet: Integer;
    procedure StartOffsetSet(const Value: Integer);
    function TerminatedGet: boolean;

    function OnFinishGet: TAwEvent;
    procedure OnFinishSet(const Value: TAwEvent);
    function OnProcessGet: TAwEvent;
    procedure OnProcessSet(const Value: TAwEvent);
    function OnStartGet: TAwEvent;
    procedure OnStartSet(const Value: TAwEvent);
    function OnDestroyingGet: TAwEvent;
    procedure OnDestroyingSet(const Value: TAwEvent);
    function OnFinishLastRefGet: TAwEventRef;
    procedure OnFinishLastRefSet(const Value: TAwEventRef);
    function IsDestroyingGet: boolean;
    function OnFinishLastGet: TAwEvent;
    procedure OnFinishLastSet(const Value: TAwEvent);
    function OnStartFerstGet: TAwEvent;
    procedure OnStartFerstSet(const Value: TAwEvent);
    function AsObjectGet: TAwAnimateBase;

    procedure CheckBar;
    procedure ReCreateBar;
    // IAwLocExecutor
    function EventRun: Cardinal;
    function RunnerGet: TObject;
    procedure RunnerSet(const Value: TObject);
    function AsAnimateExecutorGet: IAwAnimateBase;
  protected
    property Runner: TObject read RunnerGet;
    procedure EventActivated; virtual;
    procedure EventDeactivated; virtual;
    procedure EventStartFerst; virtual;
    procedure EventFinishLast; virtual;
    procedure EventFinish; virtual;
    procedure EventStart; virtual;
    procedure EventProcess; virtual;
    procedure EventError(E: Exception); virtual;
    procedure EventToParentQueue(isFinish: boolean);
    function IsValidParam: boolean; virtual;
    procedure SourceNotifyDestroy; virtual;
    procedure SourceChanged; virtual;
    procedure OptionReCreate(AClass: TAwOptionClass);
    procedure OptionDestroyEvent;//virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure BeforeDestruction; override;
    property IsDestroying: boolean read IsDestroyingGet;
    class function OptionClassGet: TAwOptionClass; virtual;
    property Option: TAwOptionBase read FOption;
    property Id: Cardinal read IdGet;
    property Name: string read NameGet write NameSet;
    property Delay: Cardinal read DelayGet write DelaySet;
    property IntervalHeartBeat: Cardinal read IntervalHeartBeatGet
      write IntervalHeartBeatSet;
    property Source: IAwSource read SourceGet write SourceSet;
    property Blocking: Boolean read BlockingGet write BlockingSet;
    property RepeatCount: Integer read RepeatCountGet write RepeatCountSet;
    property StartOffset: Integer read StartOffsetGet write StartOffsetSet;
    property DebugMode: boolean read DebugModeGet write DebugModeSet;

    property Active: boolean read ActiveGet write ActiveSet;
    property Pause: boolean read PauseGet write PauseSet;
    procedure Start;
    procedure Cancel;
    procedure Terminate;
    procedure TerminateAndCancel;
    procedure TerminateReset;
    property Terminated: boolean read TerminatedGet;

    property Progress: Real read ProgressGet; // от 0 до 1
    property ProgressIndex: Integer read ProgressIndexGet;
    property ProgressCount: Integer read ProgressCountGet;
    property ProgressRepeatIndex: Integer read ProgressRepeatIndexGet;

    property OnStart: TAwEvent read OnStartGet write OnStartSet;
    property OnFinish: TAwEvent read OnFinishGet write OnFinishSet;
    property OnStartFerst: TAwEvent read OnStartFerstGet write OnStartFerstSet;
    property OnFinishLast: TAwEvent read OnFinishLastGet write OnFinishLastSet;
    property OnProcess: TAwEvent read OnProcessGet write OnProcessSet;
    property OnDestroying: TAwEvent read OnDestroyingGet write OnDestroyingSet;
  end;
{$ENDREGION}

  TAwAnimateBase = class abstract(TAwLocExecutor)
  end;

  // заглушка для таймера пустая анимация
  IAwAnimateEmpty = interface(IAwAnimateBase)
    // private
    function DelayGet: Cardinal;
    procedure DelaySet(const Value: Cardinal);
    // public
    property Delay: Cardinal read DelayGet write DelaySet;
  end;

  TAwAnimateEmpty = class(TAwAnimateBase, IAwAnimateEmpty)
  end;


  IAwAnimateCustom = interface(IAwAnimateBase)
    ['{22709519-E0AE-40CD-8A08-A27C62E755BF}']
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


  // начиная с этого класса анимация должна взаимодейстровать с Source  и с Option
  TAwAnimateOpt = class abstract(TAwAnimateBase)
  protected
    function InProcessCheckSource: boolean; virtual;
    function IsValidParam: boolean; override;
    procedure EventStartFerst; override;
    procedure EventFinishLast; override;
  end;

  // локальные настройки конкретной анимации
  // каждый класс анимации TAwAnimateOpt
  // должен сам себе создать наследника TAwOptionBase
  TAwOptionBase = class
  private
    [unsafe] FOwner: TAwLocExecutor;
    function DelayGet: Cardinal;
    procedure DelaySet(const Value: Cardinal);
    function SourceGet: IAwSource;
    procedure SourceSet(const Value: IAwSource);
  protected
    function IsValidSource: boolean; virtual;
    procedure Init; virtual;
    procedure Clear; virtual;
  public
    property Source: IAwSource read SourceGet write SourceSet;
    property Delay: Cardinal read DelayGet write DelaySet;
    function IsValid: boolean; virtual;
    constructor Create(AOwner: TAwLocExecutor); virtual;
    destructor Destroy; override;
  end;

implementation

type
  TbwProcClearRef = reference to procedure;

  TbwList = class(TList)
  public
    function BinaryOfIndex(Value: Pointer; var IndexInsert: Integer): boolean;
    function ToArrayAndClear(): TArray<Pointer>;
  end;


  TbwTimer = class
  strict private
    FInterval: Cardinal;
    FWindowHandle: HWND;
    FOnTimer: TNotifyEvent;
    FEnabled: boolean;
    procedure UpdateTimer;
    procedure SetEnabled(Value: boolean);
    procedure SetInterval(Value: Cardinal);
    procedure SetOnTimer(Value: TNotifyEvent);
    procedure WndProc(var Msg: TMessage);
  protected
    procedure Timer;
  public
    constructor Create;
    destructor Destroy; override;
    property Enabled: boolean read FEnabled write SetEnabled;
    property Interval: Cardinal read FInterval write SetInterval;
    property OnTimer: TNotifyEvent read FOnTimer write SetOnTimer;
  end;

  // список используется для воспоизведения списка анимаций последовательно
  // используется внешне что бы наполнить список IAmAnimateQueue
  TbwQueue = class(TAwObject, IAwQueue, IAwLocQueue)
  private
    FList: TbwList; // item as IAmAnimateBase
    FCurIndex: Integer;
    FRepeatCount: Integer;
    FRepeatCurIndex: Integer;
    FIsDestoying: boolean;
    FTerminated: boolean;
    FStarted:boolean;
    function CheckCurIndex: boolean;
    function MoveRepeatReset: boolean;
    function MoveNext: boolean;
    function MovePrev: boolean;
    function CurrentGet: IAwAnimateBase;
    property Current: IAwAnimateBase read CurrentGet;
    procedure InternalCancelAll;
    procedure InternalClearWeak;
  protected
    // IAwQueue
    function StartedGet: Boolean;
    function RepeatCountGet: Integer;
    procedure RepeatCountSet(const Value: Integer);
    function RepeatCurIndexGet: Integer;
    procedure RepeatCurIndexSet(const Value: Integer);
    procedure Insert(Index: Integer; Value: IAwAnimateBase;
      StartOffset: Integer);
    procedure Add(Value: IAwAnimateBase; StartOffset: Integer);
    procedure Start;
    procedure CancelSource(Source: IAwSource);
    // IAwLocQueue
    procedure NotifyTick(Sender: IAwAnimateBase; isFinish: boolean);
    procedure CancelAll;
  public
    constructor Create;
    destructor Destroy; override;
    procedure BeforeDestruction; override;
  end;
  {
    // итем для таблицы TbwTab
    // хранит все анимации которые относятся к ключю Source
    TbwTab = class(TObject)
    strict private
    FList: TbwList; // Item as IvLocalExecutor
    function CountGet: Integer;
    function ItemsGet(const Index: Integer): IAwLocExecutor;
    procedure InternalDelete(Index: Integer);
    procedure InternalInsert(Index: Integer; const Value: IAwLocExecutor);
    procedure InternalClear();
    private
    function BinaryOfIndex(Value: Pointer; var IndexInsert: Integer): boolean;
    procedure Add(const Value: IAwLocExecutor);
    function Remove(const Value: IAwLocExecutor): boolean;
    property Count: Integer read CountGet;
    property Items[const Index: Integer]: IAwLocExecutor read ItemsGet;
    public
    constructor Create;
    destructor Destroy; override;
    end;

    // что бы можно было отменить все анимации для конкретного объекта
    TbwTable = class(TObject)
    strict private
    type
    TMap = class(TDictionary<Pointer,TbwTab>);

    var
    FMap: TMap;
    procedure CancelAll();
    function  TabGet(const Key: IAwSource):TbwTab;
    function KeyRemove(Key:TObject):TbwTab;
    private
    procedure Add(const Value: IAwLocExecutor);
    procedure Remove(const Value: IAwLocExecutor);
    procedure SourceUnRegistred(const Source: IAwSource);
    function SourceRegistred(const Source: IAwSource):boolean;
    function CancelAllExternal: TbwProcClearRef;
    public
    constructor Create;
    destructor Destroy; override;
    end;

  }

  // хранит список активных анимаций запущеных в текущий момент
  // и вызывает таймер для обхода списока  активных анимаций
  TbwRunner = class(TObject)
  strict private
    FList: TbwList; // item IvLocalExecutor
    FTimer: TbwTimer;
    FFlagListChanged: Integer;
    FFlagTimerLocked: Integer;
    procedure Delete(Value: IAwLocExecutor; AIndex: Integer);
    procedure Clear;
    function CountGet: Integer;
    function ItemsGet(Index: Integer): IAwLocExecutor;
    procedure TimerEvent(Sender: TObject);
    procedure TimerUpdate(AInterval: Cardinal);
    property Count: Integer read CountGet;
    property Items[index: Integer]: IAwLocExecutor read ItemsGet;
    procedure WaitFor(Value: IAwLocExecutor);
  private
    procedure Add(Value: IAwLocExecutor);
    procedure Remove(Value: IAwLocExecutor);
    function ClearExternal: TbwProcClearRef;
    procedure CancelSource(Source: IAwSource);
  public
    constructor Create;
    destructor Destroy; override;
  end;

  // TbwStorageListQueue
  // хранитель списка очередей ( списоков последовательных анимаций )
  TbwStorageListQueue = class(TObject)
  strict private
    FList: TbwList; // Item as IAmAnimateList
    procedure Clear();
  private
    procedure Add(const Value: IAwQueue);
    procedure Remove(const Value: IAwQueue);
    function ClearExternal: TbwProcClearRef;
    procedure CancelSource(Source: IAwSource);
  public
    constructor Create;
    destructor Destroy; override;
  end;

  // главный класс в одном эксемпляре
  TbwManager = class(TObject)
  strict private
    Runner: TbwRunner;
    StorageListQueue: TbwStorageListQueue;
    class var Instance: TbwManager;
    class var AnimateCounterId: Cardinal;
    procedure InternalAdd(Value: IAwLocExecutor);
    procedure InternalRemove(Value: IAwLocExecutor);
    procedure InternalClear;
    procedure InternalSourceCancel(Source: IAwSource);
  private
    class procedure InstanceInit;
    class procedure InstanceDestroy;
    class procedure InstanceCheckCreate;
  protected
    class var CountObjectsCreated: Cardinal;
    class var CountAnimatesCreated: Cardinal;
    class var CountAnimatesActive: Cardinal;
    class var ProcApplicationProcessMessage: TAwProcProcessMessage;
    class var OnLockedApplication: TAwEventLockedApplication;

    class function AnimateNewId: Cardinal;
    class procedure AnimateAddToExcecute(Value: IAwLocExecutor);
    class procedure AnimateRemoveFromExcecute(Value: IAwLocExecutor);
    class procedure Clear;
    class procedure SourceCancel(Source: IAwSource);
    class procedure StorageListQueueAdd(ListAnimate: IAwQueue);
    class procedure StorageListQueueRemove(ListAnimate: IAwQueue);

  public
    constructor Create;
    destructor Destroy; override;
  end;

procedure LocalHandleException(Sender: TObject);
var
  O: TObject;
begin
   if Assigned(System.Classes.ApplicationHandleException) then
   System.Classes.ApplicationHandleException(Sender)
   else
    begin
        if GetCapture <> 0 then SendMessage(GetCapture, WM_CANCELMODE, 0, 0);
        O := ExceptObject;
      {$IF DEFINED(CLR)}
          SysUtils.ShowException(O, nil);
      {$ELSE}
          System.SysUtils.ShowException(O, ExceptAddr);
      {$ENDIF}
    end;
end;

function TbwList.BinaryOfIndex(Value: Pointer;
  var IndexInsert: Integer): boolean;
var
  lo, hi, mid: Integer;
  cmp: Int64;
begin
  Result := false;
  lo := 0;
  hi := Count - 1;
  while lo <= hi do
  begin
    mid := lo + ((hi - lo) shr 1);
    cmp := Int64(Value) - Int64(List[mid]);
    if cmp = 0 then
    begin
      hi := mid - 1;
      Result := true;
    end
    else if cmp > 0 then
      lo := mid + 1
    else
      hi := mid - 1;
  end;
  IndexInsert := lo;
end;

function TbwList.ToArrayAndClear(): TArray<Pointer>;
begin
  SetLength(Result, Count);
  if Count <= 0 then
    exit;
  System.Move(List[0], Result[0], Sizeof(Pointer) * Count);
  Clear;
end;

{ TbwTimer }

constructor TbwTimer.Create;
begin
  inherited Create;
  FEnabled := true;
  FInterval := 1000;
  FWindowHandle := AllocateHWnd(WndProc);
end;

destructor TbwTimer.Destroy;
begin
  FEnabled := false;
  if FWindowHandle <> 0 then
  begin
    UpdateTimer;
    DeallocateHWnd(FWindowHandle);
    FWindowHandle := 0;
  end;
  inherited Destroy;
end;



procedure TbwTimer.WndProc(var Msg: TMessage);
begin
    if Msg.Msg = WM_TIMER then
      try
        Timer;
      except
        LocalHandleException(self);
      end
    else
     Msg.Result := DefWindowProc(FWindowHandle, Msg.Msg, Msg.wParam, Msg.lParam);
end;

procedure TbwTimer.UpdateTimer;
begin
  KillTimer(FWindowHandle, 1);
  if (FInterval <> 0) and FEnabled and Assigned(FOnTimer) then
  begin
    if SetTimer(FWindowHandle, 1, FInterval, nil) = 0 then
        raise Exception.CreateResFmt(@RsTbwTimer_UpdateTimer, []);
  end;
end;

procedure TbwTimer.SetEnabled(Value: boolean);
begin
  if Value <> FEnabled then
  begin
    FEnabled := Value;
    UpdateTimer;
  end;
end;

procedure TbwTimer.SetInterval(Value: Cardinal);
begin
  if Value <> FInterval then
  begin
    FInterval := Value;
    UpdateTimer;
  end;
end;

procedure TbwTimer.SetOnTimer(Value: TNotifyEvent);
begin
  FOnTimer := Value;
  UpdateTimer;
end;

procedure TbwTimer.Timer;
begin
  if Assigned(FOnTimer) then
    FOnTimer(Self);
end;

{ TvLocalExecutorList }

constructor TbwQueue.Create;
begin
  inherited;
  FStarted:=false;
  FList := TbwList.Create;
  FTerminated := false;
  FCurIndex := -1;
  FRepeatCount := 1;
  FRepeatCurIndex := 0;
  FIsDestoying := false;
  inc(TbwManager.CountObjectsCreated);
end;

destructor TbwQueue.Destroy;
begin
  InternalCancelAll;
  FreeAndNil(FList);
  dec(TbwManager.CountObjectsCreated);
  inherited;
end;

procedure TbwQueue.BeforeDestruction;
begin
  FIsDestoying := true;
  FTerminated := true;
  InternalClearWeak;
  inherited;
end;

function TbwQueue.StartedGet: Boolean;
begin
  Result:= FStarted;
end;

function TbwQueue.RepeatCountGet: Integer;
begin
  Result := FRepeatCount;
end;

procedure TbwQueue.RepeatCountSet(const Value: Integer);
begin
  FRepeatCount := Value;
end;

function TbwQueue.RepeatCurIndexGet: Integer;
begin
  Result := FRepeatCurIndex;
end;

procedure TbwQueue.RepeatCurIndexSet(const Value: Integer);
begin
  FRepeatCurIndex := Value;
end;

function TbwQueue.CheckCurIndex: boolean;
begin
  Result := (FCurIndex >= 0) and (FCurIndex < FList.Count);
end;

function TbwQueue.MoveNext: boolean;
begin
  inc(FCurIndex);
  Result := CheckCurIndex;
end;

function TbwQueue.MovePrev: boolean;
begin
  dec(FCurIndex);
  Result := CheckCurIndex;
end;

function TbwQueue.MoveRepeatReset: boolean;
begin
  Result := FRepeatCurIndex < FRepeatCount - 1;
  if Result then
  begin
    inc(FRepeatCurIndex);
    FCurIndex := -1;
    Result := MoveNext;
  end;
end;

function TbwQueue.CurrentGet: IAwAnimateBase;
begin
  if CheckCurIndex then
    Result := IAwAnimateBase(FList[FCurIndex])
  else
    Result := nil;
end;

procedure TbwQueue.InternalCancelAll;
var
  I: Integer;
  Value: IAwAnimateBase;
  Arr: TArray<Pointer>;
begin
  FTerminated := true;
  Arr := FList.ToArrayAndClear;
  FCurIndex := -1;
  for I := 0 to length(Arr) - 1 do
  begin
    Value := IAwAnimateBase(Arr[I]);
    Value.AsObject.FParentQueue := nil;
    Value.Terminate;
  end;
  for I := 0 to length(Arr) - 1 do
  begin
    Value := IAwAnimateBase(Arr[I]);
    Value.Cancel;
    Value._Release;
    Value := nil;
  end;
end;

procedure TbwQueue.InternalClearWeak;
var
  I: Integer;
  Value: IAwAnimateBase;
begin
  for I := 0 to FList.Count - 1 do
  begin
    Value := IAwAnimateBase(FList.List[I]);
    Value.AsObject.FParentQueue := nil;
  end;
end;

procedure TbwQueue.Add(Value: IAwAnimateBase; StartOffset: Integer);
begin
  Insert(-1, Value, StartOffset);
end;

procedure TbwQueue.Insert(Index: Integer; Value: IAwAnimateBase;
  StartOffset: Integer);
begin
 // if FStarted then
 //  raise Exception.CreateResFmt(@RsTbwQueue_Insert,[]);

  if (Value = nil) or (Value.AsObject = nil) then
    exit;

  Value.AsObject.StartOffset := StartOffset;
  if Index >= 0 then
    FList.Insert(Index, Value)
  else
    FList.Add(Value);

  Value.AsObject.FParentQueue := Self;
  Value._AddRef;
end;

procedure TbwQueue.CancelAll;
begin
  FStarted:=false;
  InternalCancelAll;
  TbwManager.StorageListQueueRemove(Self);
end;

procedure TbwQueue.CancelSource(Source: IAwSource);
var
  I: Integer;
  Item: IAwAnimateBase;
begin
  if (Source = nil) or (Source.Control = nil) then
    exit;
  for I := FList.Count - 1 downto 0 do
  begin
    Item := IAwAnimateBase(FList.List[I]);
    if (Item.AsObject.Source <> nil) and
      (Item.AsObject.Source.Control = Source.Control) then
    begin
      CancelAll;
      exit;
    end;
  end;
end;

procedure TbwQueue.Start;
begin
  if not FIsDestoying and not FStarted and MoveNext then
  begin
    FStarted:=true;
    TbwManager.StorageListQueueAdd(Self);
    Current.Start;
    if not Current.Active then
      CancelAll;
  end;
end;

procedure TbwQueue.NotifyTick(Sender: IAwAnimateBase; isFinish: boolean);
var
  b,IsStartUp: boolean;

  function LocGetPrev: IAwAnimateBase;
  begin
    MovePrev;
    try
      Result := Current;
    finally
      MoveNext;
    end;
  end;

  function LocCurrentStart:boolean;
  begin
     Result:=false;
     if Current = nil then
     begin
       exit;
     end;
     Current.Start;
     Result:= Current.Active;
     IsStartUp:= Result;
  end;

  procedure LocFinish;
  var
    APrev: IAwAnimateBase;
    APad: IAwAnimateEmpty;
    R: boolean;
  begin
    R := MoveNext;
    if not R then
    begin
      if  not MoveRepeatReset then
        exit;
      LocCurrentStart;
    end
    else
    begin
      APrev := LocGetPrev;
      if ((APrev = nil) or not(APrev.AsObject is TAwAnimateEmpty)) and
        (Current.AsObject.StartOffset > 0) then
      begin
        APad := TAwAnimateEmpty.Create;
        APad.Delay := Current.AsObject.StartOffset;
        Insert(FCurIndex, APad, 0);
      end;
      LocCurrentStart; // тоже что и Pad.Start;
    end;
  end;

  procedure LocTick;
  var
    R: boolean;
    ADelta: Int64;
    ADelay: Cardinal;
    AProgress: Real;
  begin
    R := MoveNext;
    try
      if R and (Current.AsObject.StartOffset < 0) then
      begin
        AProgress := Sender.Progress;
        ADelay := Sender.AsObject.Delay;
        ADelta := Round(AProgress * ADelay);
        ADelta := ADelay - ADelta + Current.AsObject.StartOffset;
        if ADelta <= 0 then
        begin
          if LocCurrentStart then
          MoveNext;
        end;
      end;
    finally
      MovePrev;
    end;
  end;

begin
  //  анимация прислана событие что она или выполняется или завершается
  b := (Sender = nil) or (Sender.AsObject = nil) or
    (Sender as IInterface <> Current as IInterface) or FIsDestoying;
  if b then
  begin
    if FTerminated or FIsDestoying or not CheckCurIndex then
      CancelAll;
    exit;
  end;
  // если выполняется то проверить на необходимость запуска и запустить
  //следующую анимацию если у нее  StartOffset < 0
  // если завершается то запустить следующую

  IsStartUp:=false;
  if not isFinish then
  begin
     LocTick;
     exit;
  end;
  try
   LocFinish;
  finally
    if not IsStartUp then
     CancelAll;
  end;
end;
(*

  { TvItemTablSource }
  constructor TbwTab.Create;
  begin
  inherited;
  FList := TbwList.Create;
  inc(TbwManager.CountObjectsCreated);
  end;

  destructor TbwTab.Destroy;
  begin
  InternalClear();
  FreeAndNil(FList);
  dec(TbwManager.CountObjectsCreated);
  inherited;
  end;

  function TbwTab.BinaryOfIndex(Value: Pointer; var IndexInsert: Integer)
  : boolean;
  begin
  Result := FList.BinaryOfIndex(Value, IndexInsert);
  end;

  function TbwTab.CountGet: Integer;
  begin
  Result := FList.Count;
  end;

  procedure TbwTab.Add(const Value: IAwLocExecutor);
  var
  I: Integer;
  begin
  if Value = nil then
  exit;
  if not BinaryOfIndex(Value, I) then
  InternalInsert(I, Value);
  end;

  function TbwTab.ItemsGet(const Index: Integer): IAwLocExecutor;
  begin
  Result := IAwLocExecutor(FList.List[Index]);
  end;

  function TbwTab.Remove(const Value: IAwLocExecutor): boolean;
  var
  I: Integer;
  begin
  if Value = nil then
  exit(false);
  Result := BinaryOfIndex(Value, I);
  if Result then
  InternalDelete(I);
  end;

  procedure TbwTab.InternalClear();
  var
  I: Integer;
  Arr: TArray<Pointer>;
  Item: IAwLocExecutor;
  begin
  Arr := FList.ToArrayAndClear;
  for I := length(Arr) - 1 downto 0 do
  begin
  Item := IAwLocExecutor(Arr[I]);
  Item.Terminate;
  end;
  for I := length(Arr) - 1 downto 0 do
  begin
  Item := IAwLocExecutor(Arr[I]);
  Item._Release;
  Item.Cancel;
  Item := nil;
  end;
  end;

  procedure TbwTab.InternalDelete(Index: Integer);
  var
  Item: IAwLocExecutor;
  begin
  Item := Items[Index];
  FList.Delete(Index);
  Item._Release;
  Item.Cancel;
  Item := nil;
  end;

  procedure TbwTab.InternalInsert(Index: Integer; const Value: IAwLocExecutor);
  begin
  FList.Insert(Index, Value);
  Value._AddRef;
  end;

  { TvTablSource }

  constructor TbwTable.Create;
  begin
  inherited;
  FMap := TMap.Create(128);
  inc(TbwManager.CountObjectsCreated);
  end;

  destructor TbwTable.Destroy;
  begin
  CancelAll;
  FreeAndNil(FMap);
  dec(TbwManager.CountObjectsCreated);
  inherited;
  end;

  function  TbwTable.TabGet(const Key: IAwSource):TbwTab;
  var
  Item: TbwTab;
  procedure LocItemCheckCreate;
  begin
  if Item <> nil then
  exit;
  Item := TbwTab.Create;
  FMap.Items[Key.AsSource] := Item;
  end;
  begin
  if (Key = nil) or (Key.AsSource = nil) then
  exit(nil);
  Item := nil;
  if FMap.TryAdd(Key.AsSource, nil) then
  LocItemCheckCreate
  else
  begin
  Item := FMap.Items[Key.AsSource];
  LocItemCheckCreate;
  end;
  Result:=Item;
  end;

  procedure TbwTable.Add(const Value: IAwLocExecutor);
  var
  Item: TbwTab;
  procedure LocItemCheckCreate;
  begin
  if Item <> nil then
  exit;
  Item := TbwTab.Create;
  FMap.Items[Value.Source.AsSource] := Item;
  end;

  begin
  if (Value = nil) or (Value.Source = nil) or (Value.Source.AsSource = nil) then
  exit;
  Item := nil;
  if FMap.TryAdd(Value.Source.AsSource, nil) then
  begin
  LocItemCheckCreate;
  Item.Add(Value);
  end
  else
  begin
  Item := FMap.Items[Value.Source.AsSource];
  LocItemCheckCreate;
  Item.Add(Value);
  end;
  end;

  procedure TbwTable.Remove(const Value: IAwLocExecutor);
  var
  Item: TbwTab;
  begin
  Item := nil;
  if (Value = nil) or (Value.Source = nil) or (Value.Source.AsSource = nil) then
  exit;
  if not FMap.TryGetValue(Value.Source.AsSource, Item) then
  exit;
  if Item = nil then
  begin
  FMap.Remove(Value.Source.AsSource);
  exit;
  end;
  Item.Remove(Value);
  if Item.Count <= 0 then
  begin
  FMap.Remove(Value.Source.AsSource);
  Item.Free;
  end;
  end;

  procedure TbwTable.CancelAll;
  begin
  CancelAllExternal()();
  end;

  function TbwTable.CancelAllExternal: TbwProcClearRef;
  var
  Arr: TArray<TbwTab>;
  begin
  Arr := FMap.Values.ToArray;
  FMap.Clear;
  Result := procedure
  var
  I: Integer;
  begin
  for I := length(Arr) - 1 downto 0 do
  if Arr[I] <> nil then
  Arr[I].Free;
  end;
  end;

  procedure TbwTable.SourceUnRegistred(const Source: IAwSource);
  var
  Item: TbwTab;
  begin
  if (Source = nil) or  (Source.Control = nil)  then
  exit;
  Item := nil;
  if not FMap.TryGetValue(Source.Control, Item) then
  exit;
  FMap.Remove(Source.Control);
  if Item = nil then
  exit;
  FreeAndNil(Item);
  end;

  function TbwTable.SourceRegistred(const Source: IAwSource):boolean;
  begin
  Result:=false;
  if (Source = nil) or  (Source.Control = nil) then
  exit;
  Result:= FMap.TryAdd(Source.Control, nil);
  end;
*)

{ TvRunner }

constructor TbwRunner.Create;
begin
  inherited;
  FList := TbwList.Create;
  FTimer := TbwTimer.Create();
  FTimer.OnTimer := TimerEvent;
  FTimer.Interval := 10;
  FTimer.Enabled := false;
  FFlagListChanged := 0;
  FFlagTimerLocked := 0;
  inc(TbwManager.CountObjectsCreated);
end;

destructor TbwRunner.Destroy;
begin
  Clear;
  FreeAndNil(FList);
  FreeAndNil(FTimer);
  dec(TbwManager.CountObjectsCreated);
  inherited;
end;

procedure TbwRunner.Clear;
begin
  ClearExternal()();
end;

function TbwRunner.ClearExternal: TbwProcClearRef;
var
  Arr: TArray<Pointer>;
begin
  if FList.Count > 0 then
    inc(FFlagListChanged);
  FTimer.Enabled := false;
  Result := procedure
    var
      I: Integer;
      Item: IAwLocExecutor;
    begin
      Arr := FList.ToArrayAndClear;
      for I := length(Arr) - 1 downto 0 do
      begin
        Item := IAwLocExecutor(Arr[I]);
        Item._Release;
        Item := nil;
      end;
    end;
end;

procedure TbwRunner.WaitFor(Value: IAwLocExecutor);
begin
  if AwAnimateCoreEngineNotBlockingMode or not Value.AsAnimateExecutor.Blocking
  or (Value.AsAnimateExecutor.AsObject.FParentQueue <> nil)
  or not Assigned(TbwManager.ProcApplicationProcessMessage) then
   exit;

  if Assigned(TbwManager.OnLockedApplication) then
   TbwManager.OnLockedApplication(true);
  try
    while Value.Active and
    Assigned(TbwManager.ProcApplicationProcessMessage) do
    begin
       TbwManager.ProcApplicationProcessMessage();
       sleep(1);
    end;
  finally
   if Assigned(TbwManager.OnLockedApplication) then
   TbwManager.OnLockedApplication(false);
  end;

end;

procedure TbwRunner.Add(Value: IAwLocExecutor);
var
  I: Integer;
begin
  if (Value = nil) or (Value.Runner = Self) then
    exit;
  Value.Runner := Self;
  if FList.BinaryOfIndex(Value, I) then
    exit;
  FList.Insert(I, Value);
  inc(FFlagListChanged);
  Value._AddRef;
  inc(TbwManager.CountAnimatesActive);
  TimerUpdate(10);
  WaitFor(Value);
end;

procedure TbwRunner.Delete(Value: IAwLocExecutor; AIndex: Integer);
begin
  FList.Delete(AIndex);
  inc(FFlagListChanged);
  Value._Release;
  dec(TbwManager.CountAnimatesActive);
end;

procedure TbwRunner.Remove(Value: IAwLocExecutor);
var
  I: Integer;
begin
  if (Value = nil) or (Value.Runner <> Self) then
    exit;
  Value.Runner := nil;
  if FList.Count > 0 then
  begin
    if FList.Last = Pointer(Value) then
      Delete(Value, FList.Count - 1)
    else if FList.BinaryOfIndex(Value, I) then
      Delete(Value, I);
  end;
  TimerUpdate(10);
end;

procedure TbwRunner.CancelSource(Source: IAwSource);
var
  I: Integer;
  Item: IAwLocExecutor;
  Arr: TArray<IAwLocExecutor>;
  ACount: Integer;
begin
  if (Source = nil) or (Source.Control = nil) then
    exit;
  SetLength(Arr, Count);
  ACount := 0;
  for I := Count - 1 downto 0 do
  begin
    Item := Items[I];
    if (Item.Source <> nil) and (Item.Source.Control = Source.Control) then
    begin
      Delete(Item, I);
      Arr[ACount] := Item;
      inc(ACount);
    end;
    Item := nil;
  end;
  for I := 0 to ACount - 1 do
    Arr[I].Cancel;
  SetLength(Arr, 0);
  TimerUpdate(10);
end;

function TbwRunner.CountGet: Integer;
begin
  Result := FList.Count;
end;

function TbwRunner.ItemsGet(Index: Integer): IAwLocExecutor;
begin
  Result := IAwLocExecutor(FList.List[Index]);
end;

procedure TbwRunner.TimerUpdate(AInterval: Cardinal);
begin
  if FFlagTimerLocked > 0 then
    exit;
  FTimer.Interval := max(10, AInterval);
  if Count > 0 then
  begin
    FTimer.Enabled := false;
    FTimer.Enabled := true;
  end
  else
    FTimer.Enabled := false;
end;

procedure TbwRunner.TimerEvent(Sender: TObject);
var
  I: Integer;
  ms, mc: Cardinal;
  Item:IAwLocExecutor;
begin
  if FFlagTimerLocked > 0 then
    exit;
  ms := 5000;
  try
    FTimer.Enabled := false;
    inc(FFlagTimerLocked);
    try
      FFlagListChanged := 0;
      repeat
        for I := Count - 1 downto 0 do
        begin
          Item:= Items[I];
          mc := Item.EventRun;
          Item:=nil;
          if mc > 0 then
            ms := min(mc, ms);
          if FFlagListChanged > 0 then
          begin
            FFlagListChanged := 0;
            ms := 10;
            break;
          end;
        end;
      until (FFlagListChanged = 0) or (Count <= 0);
    finally
      dec(FFlagTimerLocked);
    end;
  finally
    TimerUpdate(ms);
  end;
end;

{ TvStorageListsExecutors }

constructor TbwStorageListQueue.Create;
begin
  inherited;
  FList := TbwList.Create;
  inc(TbwManager.CountObjectsCreated);
end;

destructor TbwStorageListQueue.Destroy;
begin
  Clear;
  FreeAndNil(FList);
  dec(TbwManager.CountObjectsCreated);
  inherited;
end;

procedure TbwStorageListQueue.Clear();
begin
  ClearExternal()();
end;

function TbwStorageListQueue.ClearExternal: TbwProcClearRef;
var
  Arr: TArray<Pointer>;
begin
  Arr := FList.ToArrayAndClear;
  Result := procedure
    var
      I: Integer;
      Item: IAwQueue;
    begin
      for I := length(Arr) - 1 downto 0 do
      begin
        Item := IAwQueue(Arr[I]);
        Item._Release;
        Item := nil;
      end;
    end;
end;

procedure TbwStorageListQueue.CancelSource(Source: IAwSource);
var
  I: Integer;
  Item: IAwQueue;
begin
  if Source = nil then
    exit;
  for I := FList.Count - 1 downto 0 do
  begin
    Item := IAwQueue(FList.List[I]);
    Item.CancelSource(Source);
  end;
end;

procedure TbwStorageListQueue.Add(const Value: IAwQueue);
var
  I: Integer;
begin
  if Value = nil then
    exit;
  if not FList.BinaryOfIndex(Value, I) then
  begin
    FList.Insert(I, Value);
    Value._AddRef;
  end;
end;

procedure TbwStorageListQueue.Remove(const Value: IAwQueue);
var
  I: Integer;
begin
  if Value = nil then
    exit;
  if FList.BinaryOfIndex(Value, I) then
  begin
    FList.Delete(I);
    Value._Release;
  end;
end;

{ TbwManager }

constructor TbwManager.Create;
begin
  inherited;
  Runner := TbwRunner.Create;
  StorageListQueue := TbwStorageListQueue.Create;
  inc(TbwManager.CountObjectsCreated);
end;

destructor TbwManager.Destroy;
begin
  InternalClear;
  FreeAndNil(StorageListQueue);
  FreeAndNil(Runner);
  dec(TbwManager.CountObjectsCreated);
  inherited;
end;

class procedure TbwManager.InstanceInit;
begin
  Instance := nil;
  ProcApplicationProcessMessage:=nil;
  OnLockedApplication:=nil;
  AnimateCounterId := 0;
  CountObjectsCreated := 0;
  CountAnimatesCreated := 0;
  CountAnimatesActive := 0;
end;

class procedure TbwManager.InstanceCheckCreate;
begin
  if Instance = nil then
    Instance := TbwManager.Create;
end;

class procedure TbwManager.InstanceDestroy;
begin
  if Instance <> nil then
    FreeAndNil(Instance);
end;

class function TbwManager.AnimateNewId: Cardinal;
begin
  inc(AnimateCounterId);
  Result := AnimateCounterId;
end;

procedure TbwManager.InternalAdd(Value: IAwLocExecutor);
begin
  Runner.Add(Value);
end;

procedure TbwManager.InternalRemove(Value: IAwLocExecutor);
begin
  Runner.Remove(Value);
end;

procedure TbwManager.InternalClear;
var
  ARunner, AStorage: TbwProcClearRef;
begin
  AStorage := StorageListQueue.ClearExternal();
  ARunner := Runner.ClearExternal();
  AStorage();
  ARunner();
end;

procedure TbwManager.InternalSourceCancel(Source: IAwSource);
begin
  StorageListQueue.CancelSource(Source);
  Runner.CancelSource(Source);
end;

class procedure TbwManager.Clear;
begin
  if Instance <> nil then
    Instance.InternalClear;
end;

class procedure TbwManager.AnimateAddToExcecute(Value: IAwLocExecutor);
begin
  InstanceCheckCreate;
  Instance.InternalAdd(Value);
end;

class procedure TbwManager.AnimateRemoveFromExcecute(Value: IAwLocExecutor);
begin
  if Instance <> nil then
    Instance.InternalRemove(Value);
end;

class procedure TbwManager.SourceCancel(Source: IAwSource);
begin
  if Instance <> nil then
    Instance.InternalSourceCancel(Source);
end;

class procedure TbwManager.StorageListQueueAdd(ListAnimate: IAwQueue);
begin
  InstanceCheckCreate;
  Instance.StorageListQueue.Add(ListAnimate);
end;

class procedure TbwManager.StorageListQueueRemove(ListAnimate: IAwQueue);
begin
  if Instance <> nil then
    Instance.StorageListQueue.Remove(ListAnimate);
end;

{ TAwLocExecutor.TBar }

constructor TAwLocExecutor.TBar.Create;
begin
  inherited;
  FCounterRunner := 0;
  FIntervalHeartBeat := 20;
end;

destructor TAwLocExecutor.TBar.Destroy;
begin
  inherited;
end;

function TAwLocExecutor.TBar.IntervalHeartBeatGet: Cardinal;
begin
  Result := FIntervalHeartBeat;
  if Result <= 0 then
    Result := 1;
end;

procedure TAwLocExecutor.TBar.IntervalHeartBeatSet(const Value: Cardinal);
begin
  FIntervalHeartBeat := Value;
end;

{ TAwLocExecutor.TBarTick }

constructor TAwLocExecutor.TBarTick.Create;
begin
  inherited;
  FNow := 0;
  FFirstTick := 0;
  FNextTick := 0;
  FLastTick := 0;
  FCommonTimePlayBack := 0;
end;

destructor TAwLocExecutor.TBarTick.Destroy;
begin

  inherited;
end;

function TAwLocExecutor.TBarTick.Activated: boolean;
begin
  CounterRunner := 0;
  UpdateNow;
  FFirstTick := FNow;
  FLastTick := FFirstTick + FCommonTimePlayBack;
  UpdateNextPlayFrame;
  Result := IsValid;
end;

procedure TAwLocExecutor.TBarTick.Deactivated;
begin
  CounterRunner := 0;
  FNow := 0;
  FFirstTick := 0;
  FLastTick := 0;
end;

function TAwLocExecutor.TBarTick.IsValid: boolean;
begin
  Result := (FLastTick > FFirstTick) and (FCommonTimePlayBack > 0) and
    (IntervalHeartBeat > 0);
end;

procedure TAwLocExecutor.TBarTick.UpdateNow;
begin
  FNow := GetTickCount;
end;

function TAwLocExecutor.TBarTick.GetDeltaNextPlayFrame: Cardinal;
var
  Value: Int64;
begin
  Result := 0;
  Value := FNextTick - FNow;
  if Value > 0 then
    Result := Cardinal(Value);
end;

function TAwLocExecutor.TBarTick.GetProgress: Real;
var
  tk: Cardinal;
begin
  tk := GetTickCount;
  if (FLastTick = FFirstTick) or (tk >= FLastTick) then
    exit(1);
  Result := (min(tk, FLastTick) - FFirstTick) / (FLastTick - FFirstTick);
end;

procedure TAwLocExecutor.TBarTick.UpdateNextPlayFrame;
begin
  if FNextTick >= FLastTick then
  begin
    FNextTick := 0;
    exit;
  end;
  FNextTick := FNow + IntervalHeartBeat;
end;

function TAwLocExecutor.TBarTick.CommonTimePlayBackGet: Cardinal;
begin
  Result := FCommonTimePlayBack;
end;

procedure TAwLocExecutor.TBarTick.CommonTimePlayBackSet(const Value: Cardinal);
begin
  FCommonTimePlayBack := Value;
end;

function TAwLocExecutor.TBarTick.FrameCountGet: Cardinal;
begin
  Result := Cardinal(Ceil(FCommonTimePlayBack / IntervalHeartBeat));
end;

function TAwLocExecutor.TBarTick.FrameIndexGet: Cardinal;
var
  R: Real;
  c: Cardinal;
begin
  c := FrameCount;
  if c <= 0 then
    exit(0);
  UpdateNow;
  R := GetProgress * 100;
  Result := Floor((c - 1) * R / 100);
end;

{ TvLocalExecutor.TBarIndex }

constructor TAwLocExecutor.TBarDebug.Create;
begin
  inherited;
  FFrameCount := 0;
  FFrameIndex := 0;
  FNextTick := 0;
  FNow := 0;
end;

destructor TAwLocExecutor.TBarDebug.Destroy;
begin
  inherited;
end;

function TAwLocExecutor.TBarDebug.Activated: boolean;
begin
  CounterRunner := 0;
  FFrameIndex := 0;
  FNow := 0;
  UpdateNow;
  FNextTick := FNow + IntervalHeartBeat;
  Result := IsValid;
end;

procedure TAwLocExecutor.TBarDebug.Deactivated;
begin
  FNow := 0;
  CounterRunner := 0;
  FFrameIndex := 0;
  FNextTick := 0;
end;

function TAwLocExecutor.TBarDebug.IsValid: boolean;
begin
  Result := (FFrameIndex < FFrameCount) and (FFrameCount > 0);
end;

function TAwLocExecutor.TBarDebug.FrameCountGet: Cardinal;
begin
  Result := FFrameCount;
end;

procedure TAwLocExecutor.TBarDebug.FrameCountSet(const Value: Cardinal);
begin
  FFrameCount := Value;
end;

function TAwLocExecutor.TBarDebug.FrameIndexGet: Cardinal;
begin
  Result := FFrameIndex;
end;

procedure TAwLocExecutor.TBarDebug.FrameIndexSet(const Value: Cardinal);
begin
  FFrameIndex := Value;
end;

function TAwLocExecutor.TBarDebug.GetDeltaNextPlayFrame: Cardinal;
var
  Value: Int64;
begin
  if not IsValid then
    exit(0);
  Value := Int64(FNextTick) - Int64(FNow);
  if Value <= 0 then
    Result := 0
  else if Value > Cardinal.MaxValue then
    Result := Cardinal.MaxValue
  else
    Result := Value;
end;

function TAwLocExecutor.TBarDebug.GetProgress: Real;
begin
  if not IsValid then
    exit(0);
  Result := FFrameIndex / FFrameCount;
end;

procedure TAwLocExecutor.TBarDebug.UpdateNextPlayFrame;
begin
  if not IsValid then
    exit;
  inc(FFrameIndex);
  if not IsValid then
  begin
    FNextTick := 0;
    exit;
  end;
  FNextTick := FNow + IntervalHeartBeat;
end;

procedure TAwLocExecutor.TBarDebug.UpdateNow;
begin
  FNow := GetTickCount;
end;

{ TvLocalExecutor }

constructor TAwLocExecutor.Create;
begin
  inherited;
  FTerminated := false;
  FParentQueue := nil;
  FStartOffset := 0;
  FIsWasTickRun := false;
  FId := TbwManager.AnimateNewId;
  FName := '';
  FRunner := nil;
  FRepeatCount := 1;
  FRepeatIndex := -1;
  FBar := nil;
  FActive := false;
  FBlocking := false;
  FPause := false;
  FIsDestroying := false;
  FSource := nil;
  FOption := nil;
  FOnFinishLastRef:=nil;
  FDebugMode := false;
  OptionReCreate(OptionClassGet);
  inc(TbwManager.CountAnimatesCreated);
  inc(TbwManager.CountObjectsCreated);
end;

destructor TAwLocExecutor.Destroy;
begin
  Cancel;
  Source := nil;
  if FSource <> nil then
  begin
    FSource.UnSubOnDestroy(SourceNotifyDestroy);
    FSource := nil;
  end;
  if FOption <> nil then
    FreeAndNil(FOption);
  if FBar <> nil then
    FreeAndNil(FBar);
  FRunner := nil;
  FOnFinishLastRef:=nil;
  dec(TbwManager.CountAnimatesCreated);
  dec(TbwManager.CountObjectsCreated);
  inherited;
end;

procedure TAwLocExecutor.BeforeDestruction;
begin
  FIsDestroying := true;
  Terminate;
  if Assigned(FOnDestryoing) then
    FOnDestryoing(Self);
  FParentQueue := nil;
  inherited;
end;

class function TAwLocExecutor.OptionClassGet: TAwOptionClass;
begin
  Result := nil;
end;

procedure TAwLocExecutor.OptionReCreate(AClass: TAwOptionClass);
begin
  if FOption <> nil then
    FreeAndNil(FOption);
  if AClass = nil then
    exit;
  FOption := AClass.Create(Self);
end;

procedure TAwLocExecutor.OptionDestroyEvent;
begin
  FOption := nil;
end;

procedure TAwLocExecutor.CheckBar;
begin
  if FBar = nil then
    ReCreateBar;
end;

procedure TAwLocExecutor.ReCreateBar;
var
  ADelay, AHeartBeat: Cardinal;
  Old: TBar;
  procedure LocCreate;
  begin
    if AwAnimateCoreEngineDebugMode or FDebugMode then
      FBar := TBarDebug.Create
    else
      FBar := TBarTick.Create;
  end;

begin
  if FIsWasTickRun then
    exit;
  if FBar <> nil then
  begin
    Old := FBar;
    try
      ADelay := Self.Delay;
      AHeartBeat := Self.IntervalHeartBeat;
      LocCreate;
      Delay := ADelay;
      IntervalHeartBeat := AHeartBeat;
    finally
      Old.Free;
    end;
  end
  else
    LocCreate;
end;

function TAwLocExecutor.AsObjectGet: TAwAnimateBase;
begin
  if Self is TAwAnimateBase then
    Result := TAwAnimateBase(Self)
  else
    Result := nil;
end;

procedure TAwLocExecutor.Start;
begin
  Active := true;
end;

procedure TAwLocExecutor.Cancel;
begin
  Active := false;
end;

procedure TAwLocExecutor.Terminate;
begin
  FTerminated := true;
end;

procedure TAwLocExecutor.TerminateAndCancel;
begin
  Terminate;
  Cancel;
end;

procedure TAwLocExecutor.TerminateReset;
begin
  FTerminated := false;
end;

function TAwLocExecutor.TerminatedGet: boolean;
begin
  Result := FTerminated;
end;

function TAwLocExecutor.RepeatCountGet: Integer;
begin
  Result := FRepeatCount;
end;

procedure TAwLocExecutor.RepeatCountSet(const Value: Integer);
begin
  FRepeatCount := Value;
end;

function TAwLocExecutor.EventRun: Cardinal;
var
  I: Cardinal;
begin

  if not Active then // debug чекер что все верно работает
    raise Exception.CreateResFmt(@RsTAwLocExecutor_EventRun,[]);

  FBar.UpdateNow;
  I := FBar.GetDeltaNextPlayFrame;
  if I > 0 then
    exit(I);
  Result := Self.IntervalHeartBeat;
  if not FIsWasTickRun then
  begin
    FIsWasTickRun := true;
    EventStartFerst;
    if not Active then
      exit;
  end;

  if FBar.CounterRunner = 0 then
  begin
    inc(FRepeatIndex);
    if FRepeatIndex < 0 then
      FRepeatIndex := 0;
    EventStart;
    if not Active then
      exit;
  end;

  try
    EventProcess;
    if not Active then
      exit;
  except
    on E: Exception do
    begin
      EventError(E);
      Cancel;
      raise;
    end;
  end;

  FBar.UpdateNow;
  FBar.UpdateNextPlayFrame;
  FBar.CounterRunner := FBar.CounterRunner + 1;
  Result := FBar.GetDeltaNextPlayFrame;

  if Result <= 0 then
  begin
    EventFinish;
    if not Active then
      exit;
    if (FRepeatCount >= 0) and (FRepeatIndex >= FRepeatCount - 1) then
      Cancel
    else
    begin
      FBar.Activated;
      Result := FBar.GetDeltaNextPlayFrame;
    end;
  end
  else if (FRepeatCount > 0) and (FRepeatIndex >= FRepeatCount - 1) then
    EventToParentQueue(false);
end;

procedure TAwLocExecutor.EventError(E: Exception);
begin
  if Assigned(FParentQueue) then
    FParentQueue.CancelAll;
end;

procedure TAwLocExecutor.EventToParentQueue(isFinish: boolean);
var AQueue: IAwLocQueue;
begin
  if Assigned(FParentQueue) then
  begin
    AQueue:=  FParentQueue;
    AQueue.NotifyTick(Self, isFinish);
    AQueue:=nil;
  end;
end;

procedure TAwLocExecutor.EventFinish;
begin
  if Assigned(FSource) and Assigned(FSource.Events) then
    FSource.Events.EventFinish(self);

  if Assigned(FOnFinish) then
    FOnFinish(Self);
end;

procedure TAwLocExecutor.EventFinishLast;
begin
  if Assigned(FSource) and Assigned(FSource.Events) then
    FSource.Events.EventFinishLast(self);

  if Assigned(FOnFinishLastRef) then
    FOnFinishLastRef(self);

  if Assigned(FOnFinishLast) then
    FOnFinishLast(Self);
end;

procedure TAwLocExecutor.EventProcess;
begin
  if Assigned(FSource) and Assigned(FSource.Events) then
    FSource.Events.EventProcess(self);

  if Assigned(FOnProcess) then
    FOnProcess(Self);
end;

procedure TAwLocExecutor.EventStart;
begin
  if Assigned(FSource) and Assigned(FSource.Events) then
    FSource.Events.EventStart(self);

  if Assigned(FOnStart) then
    FOnStart(Self);
end;

procedure TAwLocExecutor.EventStartFerst;
begin
  if Assigned(FSource) and Assigned(FSource.Events) then
    FSource.Events.EventStartFerst(self);

  if Assigned(FOnStartFerst) then
    FOnStartFerst(Self);
end;

procedure TAwLocExecutor.EventActivated;
begin
  if Assigned(FSource) and Assigned(FSource.Events) then
    FSource.Events.EventActivated(self);
end;
procedure TAwLocExecutor.EventDeactivated;
begin
  if Assigned(FSource) and Assigned(FSource.Events) then
    FSource.Events.EventDeactivated(self);
end;

function TAwLocExecutor.StartOffsetGet: Integer;
begin
  Result := FStartOffset;
end;

procedure TAwLocExecutor.StartOffsetSet(const Value: Integer);
begin
  FStartOffset := Value;
end;

function TAwLocExecutor.BlockingGet: Boolean;
begin
  Result := FBlocking;
end;

procedure TAwLocExecutor.BlockingSet(const Value: Boolean);
begin
  FBlocking := Value;
end;

function TAwLocExecutor.DelayGet: Cardinal;
begin
  CheckBar;
  if FBar is TBarTick then
    Result := TBarTick(FBar).CommonTimePlayBack
  else if FBar is TBarDebug then
    Result := TBarDebug(FBar).FrameCount * TBarDebug(FBar).IntervalHeartBeat
  else
    Result := 0;
end;

procedure TAwLocExecutor.DelaySet(const Value: Cardinal);
begin
  CheckBar;
  if FBar is TBarTick then
    TBarTick(FBar).CommonTimePlayBack := Value
  else if FBar is TBarDebug then
    TBarDebug(FBar).FrameCount := Value div TBarDebug(FBar).IntervalHeartBeat
  else
    raise Exception.CreateResFmt(@RsTAwLocExecutor_TBar,[]);
end;

function TAwLocExecutor.RunnerGet: TObject;
begin
  Result := FRunner;
end;

procedure TAwLocExecutor.RunnerSet(const Value: TObject);
begin
  FRunner := Value;
end;

function TAwLocExecutor.AsAnimateExecutorGet: IAwAnimateBase;
begin
  Result := Self;
end;

function TAwLocExecutor.IdGet: Cardinal;
begin
  Result := FId;
end;

function TAwLocExecutor.IntervalHeartBeatGet: Cardinal;
begin
  CheckBar;
  Result := FBar.IntervalHeartBeat;
end;

procedure TAwLocExecutor.IntervalHeartBeatSet(const Value: Cardinal);
begin
  CheckBar;
  FBar.IntervalHeartBeat := Value;
end;

function TAwLocExecutor.ProgressIndexGet: Integer;
begin
  CheckBar;
  if FBar is TBarTick then
    Result := TBarTick(FBar).FrameIndex
  else if FBar is TBarDebug then
    Result := TBarDebug(FBar).FrameIndex
  else
    raise Exception.CreateResFmt(@RsTAwLocExecutor_TBar,[]);
end;

function TAwLocExecutor.ProgressCountGet: Integer;
begin
  CheckBar;
  if FBar is TBarTick then
    Result := TBarTick(FBar).FrameCount
  else if FBar is TBarDebug then
    Result := TBarDebug(FBar).FrameCount
  else
    raise Exception.CreateResFmt(@RsTAwLocExecutor_TBar,[]);
end;

function TAwLocExecutor.ProgressGet: Real;
begin
  CheckBar;
  Result := FBar.GetProgress;
end;

function TAwLocExecutor.ProgressRepeatIndexGet: Integer;
begin
  Result := FRepeatIndex;
end;

function TAwLocExecutor.IsDestroyingGet: boolean;
begin
  Result := FIsDestroying;
end;

function TAwLocExecutor.NameGet: string;
begin
  Result := FName;
end;

function TAwLocExecutor.DebugModeGet: boolean;
begin
  Result := FDebugMode;
end;

procedure TAwLocExecutor.DebugModeSet(const Value: boolean);
begin
  if FDebugMode <> Value then
  begin
    FDebugMode := Value;
    ReCreateBar;
  end;
end;

procedure TAwLocExecutor.NameSet(const Value: string);
begin
  FName := Value;
end;

function TAwLocExecutor.OnDestroyingGet: TAwEvent;
begin
  Result := FOnDestryoing;
end;

procedure TAwLocExecutor.OnDestroyingSet(const Value: TAwEvent);
begin
  FOnDestryoing := Value;
end;

function TAwLocExecutor.OnFinishGet: TAwEvent;
begin
  Result := FOnFinish;
end;

function TAwLocExecutor.OnFinishLastGet: TAwEvent;
begin
  Result := FOnFinishLast;
end;

procedure TAwLocExecutor.OnFinishLastSet(const Value: TAwEvent);
begin
  FOnFinishLast := Value;
end;

function TAwLocExecutor.OnFinishLastRefGet: TAwEventRef;
begin
  Result:= FOnFinishLastRef;
end;

procedure TAwLocExecutor.OnFinishLastRefSet(const Value: TAwEventRef);
begin
 FOnFinishLastRef:= Value;
end;

procedure TAwLocExecutor.OnFinishSet(const Value: TAwEvent);
begin
  FOnFinish := Value;
end;

function TAwLocExecutor.OnProcessGet: TAwEvent;
begin
  Result := FOnProcess;
end;

procedure TAwLocExecutor.OnProcessSet(const Value: TAwEvent);
begin
  FOnProcess := Value;
end;

function TAwLocExecutor.OnStartFerstGet: TAwEvent;
begin
  Result := FOnStartFerst;
end;

procedure TAwLocExecutor.OnStartFerstSet(const Value: TAwEvent);
begin
  FOnStartFerst := Value;
end;

function TAwLocExecutor.OnStartGet: TAwEvent;
begin
  Result := FOnStart;
end;

procedure TAwLocExecutor.OnStartSet(const Value: TAwEvent);
begin
  FOnStart := Value;
end;

function TAwLocExecutor.PauseGet: boolean;
begin
  Result := FPause;
end;

procedure TAwLocExecutor.PauseSet(const Value: boolean);
begin
  if FPause <> Value then
  begin
    // FPause:= Value;// to do
  end;
end;

function TAwLocExecutor.SourceGet: IAwSource;
begin
  Result := FSource;
end;

procedure TAwLocExecutor.SourceSet(const Value: IAwSource);
var
  Old: IAwSource;
begin
  if FSource = Value then
    exit;
  Old := FSource;
  FSource := nil;
  if Old <> nil then
  begin
    Old.UnSubOnDestroy(SourceNotifyDestroy);
    Old := nil;
  end;
  if IsDestroying then
    exit;
  FSource := Value;
  if FSource <> nil then
    FSource.SubOnDestroy(SourceNotifyDestroy);
  SourceChanged;
end;

procedure TAwLocExecutor.SourceNotifyDestroy;
begin
  Source := nil;
end;

procedure TAwLocExecutor.SourceChanged;
begin
end;

function TAwLocExecutor.ActiveGet: boolean;
begin
  Result := FActive;
end;

procedure TAwLocExecutor.ActiveSet(const Value: boolean);
begin
  if FActive <> Value then
  begin
    FActive := Value;
    if FActive then
    begin
      FActive := IsValidParam;
      if FActive then
      begin
        EventActivated;
        TbwManager.AnimateAddToExcecute(Self);
      end;
    end
    else
    begin
      try
        EventFinishLast;
        FBar.Deactivated;
        EventToParentQueue(true);
        TbwManager.AnimateRemoveFromExcecute(Self);
      finally
        EventDeactivated;
      end;
    end;
  end;
end;

function TAwLocExecutor.IsValidParam: boolean;
begin
  Result := not IsDestroying and (FBar <> nil) and  FBar.Activated
  and not Pause and not Terminated and (Delay > 0);
end;

{ AmAnimateFactoryBase }

class procedure AwFactoryBase.Clear;
begin
  TbwManager.Clear();
end;

class procedure AwFactoryBase.SourceCancel(Source: IAwSource);
begin
  TbwManager.SourceCancel(Source);
end;

class function AwFactoryBase.CountAnimatesActiveGet: Cardinal;
begin
  Result := TbwManager.CountAnimatesActive;
end;

class function AwFactoryBase.CountAnimatesCreatedGet: Cardinal;
begin
  Result := TbwManager.CountAnimatesCreated;
end;

class function AwFactoryBase.CountObjectsCreatedGet: Cardinal;
begin
  Result := TbwManager.CountObjectsCreated;
end;

class function AwFactoryBase.NewList: IAwQueue;
begin
  Result := TbwQueue.Create;
end;

class function AwFactoryBase.OnLockedApplicationGet: TAwEventLockedApplication;
begin
   Result:= TbwManager.OnLockedApplication;
end;

class procedure AwFactoryBase.OnLockedApplicationSet(
  const Value: TAwEventLockedApplication);
begin
   TbwManager.OnLockedApplication:= Value;
end;

class function AwFactoryBase.ProcApplicationProcessMessageGet: TAwProcProcessMessage;
begin
    Result:= TbwManager.ProcApplicationProcessMessage;
end;

class procedure AwFactoryBase.ProcApplicationProcessMessageSet(
  const Value: TAwProcProcessMessage);
begin
   TbwManager.ProcApplicationProcessMessage:= Value;
end;

class function AwFactoryBase.Base(AClass: TAwAnimateClass): IAwAnimateBase;
begin
  if AClass = nil then
    AClass := TAwAnimateEmpty;
  Result := AClass.Create;
end;

class function AwFactoryBase.Empty(): IAwAnimateEmpty;
begin
  Result := IAwAnimateEmpty(Base(TAwAnimateEmpty).AsObject as TAwAnimateEmpty);
end;

{ TAwOptionBase }

constructor TAwOptionBase.Create(AOwner: TAwLocExecutor);
begin
  inherited Create;
  FOwner := AOwner;
  Init;
end;

destructor TAwOptionBase.Destroy;
begin
  Clear;
  if FOwner <> nil then
    FOwner.OptionDestroyEvent;
  FOwner := nil;
  inherited;
end;

function TAwOptionBase.IsValid: boolean;
begin
  Result := IsValidSource and (Delay > 0);
end;

function TAwOptionBase.IsValidSource: boolean;
begin
  Result := (Source <> nil) and Source.IsValid;
end;

procedure TAwOptionBase.Init;
begin
end;

procedure TAwOptionBase.Clear;
begin
end;

function TAwOptionBase.DelayGet: Cardinal;
begin
  if FOwner <> nil then
    Result := FOwner.Delay
  else
    Result := 0;
end;

procedure TAwOptionBase.DelaySet(const Value: Cardinal);
begin
  if FOwner = nil then
    raise Exception.CreateResFmt(@RsTAwOption_BaseOwnerNil, []);
  FOwner.Delay := Value;
end;

function TAwOptionBase.SourceGet: IAwSource;
begin
  if FOwner <> nil then
    Result := FOwner.Source
  else
    Result := nil;
end;

procedure TAwOptionBase.SourceSet(const Value: IAwSource);
begin
  if FOwner = nil then
    raise Exception.CreateResFmt(@RsTAwOption_BaseOwnerNil, []);
  FOwner.Source := Value;
end;

{ TAwAnimateOpt }

function TAwAnimateOpt.InProcessCheckSource: boolean;
begin
  Result := (Option <> nil) and Option.IsValidSource;
  if not Result then
    TerminateAndCancel;
end;

procedure TAwAnimateOpt.EventFinishLast;
begin
  inherited;
  InProcessCheckSource;
end;

procedure TAwAnimateOpt.EventStartFerst;
begin
  inherited;
  InProcessCheckSource;
end;

function TAwAnimateOpt.IsValidParam: boolean;
begin
  Result := inherited IsValidParam
  and (Option <> nil) and Option.IsValid;
end;

initialization
begin
  TbwManager.InstanceInit;
end;

finalization

TbwManager.InstanceDestroy;

end.
