unit AmAnimate.Core.Effects.Dcv.Classes;

//таблица динамических кастомных переменных
// анимируем любые переменные, события о их изменениях будут отправлены в интерфейсы унаследованы от IAwSource

interface
 uses
  System.SysUtils,
  System.Types,
  System.Generics.Collections,
  AmAnimate.Core.Math,
  AmAnimate.Core.Types,
  AmAnimate.Core.Res,
  AmAnimate.Core.Engine,
  AmAnimate.Core.Source.Intf;


  ////////////////////////////////////////////////////////////////////////////
  ///                                                                      ///
  ///                                                                      ///
  ///                table of dynamic custom variables                     ///
  ///                                                                      ///
  ///                                                                      ///
  ////////////////////////////////////////////////////////////////////////////
 type

 IAwAnimateDcv =  interface;
 TAwDcvEnumMode = (dcvLine,dcvSin);
 TAwEventDcv = procedure(const Animate: IAwAnimateDcv; const Table:IAwSourceDcvTable) of object;
 TAwEventRefDcv = reference to procedure(const Animate: IAwAnimateDcv; const Table:IAwSourceDcvTable);

 TAwDcvTable = class (TAwObject,IAwSourceDcvTable)
  private
    FMap: TAwDcvDictionary;
    FFixedTable:boolean;
  protected
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
  public
    function IsValid: boolean;
    property FixedTable: boolean read FixedTableGet write FixedTableSet;
    constructor Create;
    destructor Destroy;override;
 end;



  // параметры  Dcv
 TAwOptionDcv = class (TAwOptionBase)
   private
    FTable:IAwSourceDcvTable;
    FMode:TAwDcvEnumMode;
    function SourceGet: IAwSourceDcv;
    procedure SourceSet(const Value: IAwSourceDcv);
   protected
    procedure Init; override;
    procedure Clear; override;
   public
    property Source: IAwSourceDcv read SourceGet write SourceSet;
    property Table: IAwSourceDcvTable read FTable;
    property Mode: TAwDcvEnumMode read FMode write FMode;
    function IsValid: boolean; override;
  end;


  IAwAnimateDcv = interface(IAwAnimateCustom)
    ['{00A4AABC-1CC6-4C4A-9FDC-4BBB3906494E}']
    function OptionGet:TAwOptionDcv;
    property Option: TAwOptionDcv read OptionGet;
  end;

  TAwAnimateDcv = class (TAwAnimateOpt, IAwAnimateDcv)
  private
    function OptionGet:TAwOptionDcv;
  protected
    function InProcessCheckSource: boolean;override;
    procedure EventProcess; override;
    procedure EventStartFerst; override;
    procedure EventFinishLast; override;
    function IsValidParam: boolean; override;
  public
    property Option: TAwOptionDcv read OptionGet;
    class function OptionClassGet:TawOptionClass;override;
  end;


  IAwAnimateDcvCustom = interface(IAwAnimateDcv)
   ['{39BD2764-F48E-43FF-997B-0481D59B5704}']
    function OnDcvFinishGet: TAwEventDcv;
    function OnDcvFinishRefGet: TAwEventRefDcv;
    procedure OnDcvFinishRefSet(const Value: TAwEventRefDcv);
    procedure OnDcvFinishSet(const Value: TAwEventDcv);
    function OnDcvProcessGet: TAwEventDcv;
    function OnDcvProcessRefGet: TAwEventRefDcv;
    procedure OnDcvProcessRefSet(const Value: TAwEventRefDcv);
    procedure OnDcvProcessSet(const Value: TAwEventDcv);
    function OnDcvStartGet: TAwEventDcv;
    function OnDcvStartRefGet: TAwEventRefDcv;
    procedure OnDcvStartRefSet(const Value: TAwEventRefDcv);
    procedure OnDcvStartSet(const Value: TAwEventDcv);

    property OnDcvStart: TAwEventDcv read OnDcvStartGet write OnDcvStartSet;
    property OnDcvStartRef: TAwEventRefDcv read OnDcvStartRefGet write OnDcvStartRefSet;
    property OnDcvProcess: TAwEventDcv read OnDcvProcessGet write OnDcvProcessSet;
    property OnDcvProcessRef: TAwEventRefDcv read OnDcvProcessRefGet write OnDcvProcessRefSet;
    property OnDcvFinish: TAwEventDcv read OnDcvFinishGet write OnDcvFinishSet;
    property OnDcvFinishRef: TAwEventRefDcv read OnDcvFinishRefGet write OnDcvFinishRefSet;
  end;


  TAwAnimateDcvCustom = class sealed (TAwAnimateDcv,IAwAnimateDcvCustom,IAwAnimateDcv)
   private
    FOnDcvStart:TAwEventDcv;
    FOnDcvStartRef:TAwEventRefDcv;
    FOnDcvProcess:TAwEventDcv;
    FOnDcvProcessRef:TAwEventRefDcv;
    FOnDcvFinish:TAwEventDcv;
    FOnDcvFinishRef:TAwEventRefDcv;
    function OnDcvFinishGet: TAwEventDcv;
    function OnDcvFinishRefGet: TAwEventRefDcv;
    procedure OnDcvFinishRefSet(const Value: TAwEventRefDcv);
    procedure OnDcvFinishSet(const Value: TAwEventDcv);
    function OnDcvProcessGet: TAwEventDcv;
    function OnDcvProcessRefGet: TAwEventRefDcv;
    procedure OnDcvProcessRefSet(const Value: TAwEventRefDcv);
    procedure OnDcvProcessSet(const Value: TAwEventDcv);
    function OnDcvStartGet: TAwEventDcv;
    function OnDcvStartRefGet: TAwEventRefDcv;
    procedure OnDcvStartRefSet(const Value: TAwEventRefDcv);
    procedure OnDcvStartSet(const Value: TAwEventDcv);
   protected
    procedure EventProcess; override;
    procedure EventFinishLast; override;
    function IsValidParam: boolean; override;
   public
    constructor Create; override;
    destructor Destroy; override;
    property OnDcvStart: TAwEventDcv read OnDcvStartGet write OnDcvStartSet;
    property OnDcvStartRef: TAwEventRefDcv read OnDcvStartRefGet write OnDcvStartRefSet;
    property OnDcvProcess: TAwEventDcv read OnDcvProcessGet write OnDcvProcessSet;
    property OnDcvProcessRef: TAwEventRefDcv read OnDcvProcessRefGet write OnDcvProcessRefSet;
    property OnDcvFinish: TAwEventDcv read OnDcvFinishGet write OnDcvFinishSet;
    property OnDcvFinishRef: TAwEventRefDcv read OnDcvFinishRefGet write OnDcvFinishRefSet;
  end;



  //sealed

implementation

{ TAwDcvTable }

constructor TAwDcvTable.Create;
begin
   inherited;
   FMap:= TAwDcvDictionary.Create(8);
   FFixedTable:=false;
end;

destructor TAwDcvTable.Destroy;
begin
  FFixedTable:=false;
  Clear;
  FreeAndNil(FMap);
  inherited;
end;

function TAwDcvTable.FixedTableGet: boolean;
begin
   Result:= FFixedTable;
end;

procedure TAwDcvTable.FixedTableSet(const Value: boolean);
begin
  FFixedTable:=Value;
end;

function TAwDcvTable.Add(const Name: string; ValueStart, ValueFinish: Double;
  FuncCalc: TAwCalcRef=nil): boolean;
var Prm: TAwDcvItem;
begin
    Result:= not FFixedTable;
    if not Result then
      exit;

    Prm.Start:= ValueStart;
    Prm.Finish:= ValueFinish;
    Prm.Now:= ValueStart;
    Prm.FuncCalc:= FuncCalc;
    Result:= AddPrm(Name,Prm);
end;

function TAwDcvTable.AddPrm(const Name: string; Prm: TAwDcvItem): boolean;
var P:PAwDcvItem;
begin
    Result:= not FFixedTable;
    if not Result then
      exit;

    New(P);
    P^:= Prm;
    if not Assigned(P.FuncCalc) then
    P.FuncCalc:=  TAwMath.EnumToFuncRef(AwEnumEffectMainRec.Default, AwEnumEffectModeRec.Default);
    Result:= FMap.TryAdd(Name,P);
    if  Result then
      exit;
    P.FuncCalc:=nil;
    Dispose(P);
end;

procedure TAwDcvTable.Clear;
var i:integer;
   Arr:TArray<PAwDcvItem>;
begin
    if  FFixedTable then
      exit;

   Arr:= FMap.Values.ToArray;
   FMap.Clear;
   for I := 0 to length(Arr)-1 do
   begin
     Arr[i].FuncCalc:=nil;
     Dispose(Arr[i]);
   end;
   Arr:=nil;
end;

function TAwDcvTable.Delete(const Name: string): boolean;
var P:PAwDcvItem;
begin
  Result:= not FFixedTable;
  if not Result then
    exit;

  Result:= FMap.TryGetValue(Name,P);
  if  not Result then
  exit;
  FMap.Remove(Name);
  if P <> nil then
  begin
   P.FuncCalc:=nil;
   Dispose(P);
  end;
end;

function TAwDcvTable.Enumerator:IAwDcvEnumerator;
begin
  Result:= FMap.DcvEnumerator;
end;


function TAwDcvTable.GetNowValue(const Name: string; out Value: Double): boolean;
var P:PAwDcvItem;
begin
   P:=nil;
   Value:=0;
   Result:= FMap.TryGetValue(Name,P);
   if Result then
     Value:= P.Now;
end;

function TAwDcvTable.GetPrm(const Name: string; out Prm: PAwDcvItem): boolean;
begin
   Prm:=nil;
   Result:= FMap.TryGetValue(Name,Prm);
end;

function TAwDcvTable.IsName(const Name: string): boolean;
begin
   Result:= FMap.ContainsKey(Name);
end;

function TAwDcvTable.IsValid: boolean;
begin
  Result:= FMap.Count > 0;
end;

{ TAwOptionDcv }

procedure TAwOptionDcv.Init;
begin
  inherited;
  FTable:= TAwDcvTable.Create;
  FMode:=  dcvLine;
end;

procedure TAwOptionDcv.Clear;
begin
  inherited;
   FTable:=nil;
end;

function TAwOptionDcv.IsValid: boolean;
begin
   Result:= inherited IsValid and (FTable <> nil) and FTable.isValid;
end;

function TAwOptionDcv.SourceGet: IAwSourceDcv;
begin
   Result:=  inherited Source as IAwSourceDcv;
end;

procedure TAwOptionDcv.SourceSet(const Value: IAwSourceDcv);
begin
  inherited Source:= Value;
end;

{ TAwAnimateDcvAbstract }


class function TAwAnimateDcv.OptionClassGet: TawOptionClass;
begin
  Result:= TAwOptionDcv;
end;

function TAwAnimateDcv.OptionGet: TAwOptionDcv;
begin
   Result:=  inherited Option as  TAwOptionDcv;
end;

function TAwAnimateDcv.InProcessCheckSource: boolean;
begin
  Result:= inherited  InProcessCheckSource
  and (Option.Table<>nil) and Option.Table.IsValid;
  if not Result then
    TerminateAndCancel;
end;

function TAwAnimateDcv.IsValidParam: boolean;
begin
   Result:= (Option <> nil) and (Option.Source <> nil)
   and (Option.Table<>nil) and Option.Source.DcvStart(Option.Table)
   and  inherited IsValidParam;
   Option.Table.FixedTable := Result;
end;

procedure TAwAnimateDcv.EventStartFerst;
begin
  inherited EventStartFerst;
end;



procedure TAwAnimateDcv.EventFinishLast;
begin
  if (Option <> nil) and (Option.Source <> nil) and (Option.Table<>nil) then
   Option.Source.DcvFinish(Option.Table);
  inherited;
end;

procedure TAwAnimateDcv.EventProcess;
var
  List:IAwDcvEnumerator;
  Item:PAwDcvItem;
  Bar:Real;
begin
  inherited;
  if not InProcessCheckSource then
  begin
    self.TerminateAndCancel;
    exit;
  end;
  Bar:= Progress;
  List:= Option.Table.Enumerator;
  List.Reset;
  while List.MoveNext do
  begin
     Item:= List.Current;

     if Option.Mode = dcvSin then
     begin
        Bar:= Item.FuncCalc(Bar);
        Item.Now:= Item.Start + TAwMath.SwingTime(0.5,Item.Finish - Item.Start,Bar);
     end
     else
     begin
        Item.Now:= TAwMath.SwingToSingle(Item.Start, Item.Finish, Progress, Item.FuncCalc);
     end;
     


  end;
  if  not Option.Source.DcvProcess(Option.Table) then
   TerminateAndCancel;
end;





{ TAwAnimateDcvCustom }

constructor TAwAnimateDcvCustom.Create;
begin
  inherited;
  FOnDcvStart:=nil;
  FOnDcvStartRef:=nil;
  FOnDcvProcess:=nil;
  FOnDcvProcessRef:=nil;
  FOnDcvFinish:=nil;
  FOnDcvFinishRef:=nil;
end;

destructor TAwAnimateDcvCustom.Destroy;
begin
  inherited Destroy;
  FOnDcvStart:=nil;
  FOnDcvStartRef:=nil;
  FOnDcvProcess:=nil;
  FOnDcvProcessRef:=nil;
  FOnDcvFinish:=nil;
  FOnDcvFinishRef:=nil;
end;

procedure TAwAnimateDcvCustom.EventFinishLast;
begin
  if (Option <> nil) and (Option.Table <> nil) then
  begin
    if Assigned(FOnDcvFinishRef) then
    FOnDcvFinishRef(self,Option.Table);

    if Assigned(FOnDcvFinish) then
     FOnDcvFinish(self,Option.Table);
  end;
  inherited EventFinishLast;
end;

procedure TAwAnimateDcvCustom.EventProcess;
begin
  inherited EventProcess;
  if not Terminated and Active then
  begin
    if Assigned(FOnDcvProcessRef) then
     FOnDcvProcessRef(self,Option.Table);

    if Assigned(FOnDcvProcess) then
     FOnDcvProcess(self,Option.Table);
  end;
end;

function TAwAnimateDcvCustom.IsValidParam: boolean;
begin
  if (Option <> nil) and (Option.Table <> nil)
  and (Option.Source<>nil) and Option.Source.IsValid then
  begin
    if Assigned(FOnDcvStartRef) then
    FOnDcvStartRef(self,Option.Table);

    if Assigned(FOnDcvStart) then
     FOnDcvStart(self,Option.Table);
  end;
  Result:= inherited IsValidParam;
end;

function TAwAnimateDcvCustom.OnDcvFinishGet: TAwEventDcv;
begin
  Result:= FOnDcvFinish;
end;

procedure TAwAnimateDcvCustom.OnDcvFinishSet(const Value: TAwEventDcv);
begin
  FOnDcvFinish:= Value;
end;

function TAwAnimateDcvCustom.OnDcvFinishRefGet: TAwEventRefDcv;
begin
  Result:= FOnDcvFinishRef;
end;

procedure TAwAnimateDcvCustom.OnDcvFinishRefSet(const Value: TAwEventRefDcv);
begin
  FOnDcvFinishRef:= Value;
end;

function TAwAnimateDcvCustom.OnDcvProcessGet: TAwEventDcv;
begin
   Result:= FOnDcvProcess;
end;

procedure TAwAnimateDcvCustom.OnDcvProcessSet(const Value: TAwEventDcv);
begin
   FOnDcvProcess:= Value;
end;

function TAwAnimateDcvCustom.OnDcvProcessRefGet: TAwEventRefDcv;
begin
  Result:= FOnDcvProcessRef;
end;

procedure TAwAnimateDcvCustom.OnDcvProcessRefSet(const Value: TAwEventRefDcv);
begin
  FOnDcvProcessRef:= Value;
end;

function TAwAnimateDcvCustom.OnDcvStartGet: TAwEventDcv;
begin
  Result:= FOnDcvStart;
end;

procedure TAwAnimateDcvCustom.OnDcvStartSet(const Value: TAwEventDcv);
begin
  FOnDcvStart := Value;
end;

function TAwAnimateDcvCustom.OnDcvStartRefGet: TAwEventRefDcv;
begin
  Result:= FOnDcvStartRef;
end;

procedure TAwAnimateDcvCustom.OnDcvStartRefSet(const Value: TAwEventRefDcv);
begin
  FOnDcvStartRef:=  Value;
end;



end.
