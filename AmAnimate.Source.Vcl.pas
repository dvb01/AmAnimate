unit AmAnimate.Source.Vcl;

interface
uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Types,
  Math,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  AmAnimate.Source.Intf,
  AmAnimate.Engine,
  AmControlClasses;


 type
  TAwSourceSimple = class (TInterfacedObject,IAwSourceBounds,IAwSourceAlfa,IAwSource,IAwSourceEvent)
    private
     type
       TNotifer = class (TComponent)
        protected
          [unsafe]SourceSimple:TAwSourceSimple;
          procedure Notification(AComponent: TComponent; Operation: TOperation);override;
        public
          constructor Create(AOwner:TComponent);override;
          destructor Destroy;override;
       end;
     var
     FNotifer:TNotifer;
     FControl:TWinControl;
     FEventBroadcastDestroy:TAwHandleBroadcastDestroy;
     FLockControl:integer;
    protected
     procedure NotiferDestroyControl; virtual;
     //IAwSource
     function IsValid:boolean;
     function ControlGet:Pointer;
     function EventsGet:IAwSourceEvent;
     procedure SubOnDestroy(NotifyEvent:TAwProc);
     procedure UnSubOnDestroy(NotifyEvent:TAwProc);

     // IAwSourceEvent
     procedure EventStartFerst(const Sender:IAwAnimateIntf); virtual;
     procedure EventFinishLast(const Sender:IAwAnimateIntf);virtual;
     procedure EventStart(const Sender:IAwAnimateIntf); virtual;
     procedure EventFinish(const Sender:IAwAnimateIntf);virtual;
     procedure EventProcess(const Sender:IAwAnimateIntf);virtual;

     //IAwSourceBounds
     function GetBounds(var Rect:TRectF):boolean;   virtual;
     function SetBounds(const Rect:TRectF):boolean; virtual;

     //IAwSourceAlfa
     function GetAlfa(var Value:byte): boolean;
     function SetAlfa(const Value:byte):boolean;
    public
     property Control: TWinControl read FControl;
     constructor Create(AControl:TWinControl);
     destructor Destroy;override;
  end;



  TAwSourceVclCustom =  class(TComponent,IAwSourceBounds,IAwSource)
   private
    var
     FControl:TControl;
     FEventBroadcastDestroy:TAwHandleBroadcastDestroy;
     procedure ControlSet(const Value:TControl);
     //IAwSource
     procedure SubOnDestroy(NotifyEvent:TAwProc);
     procedure UnSubOnDestroy(NotifyEvent:TAwProc);
     function ControlGet:Pointer;
   protected
     procedure ControlChanged;virtual;
     procedure Notification(AComponent: TComponent; Operation: TOperation);override;
     //IAwSource
     function IsValid:boolean; virtual;
     function EventsGet:IAwSourceEvent; virtual;
     //IAwSourceBounds
     function GetBounds(var Rect:TRectF):boolean;virtual;
     function SetBounds(const Rect:TRectF):boolean;virtual;
     property Control: TControl read FControl write ControlSet;

   public
     constructor Create(AOwner:TComponent); override;
     destructor Destroy;override;
   published

  end;

  TAwSourceControl =  class (TAwSourceVclCustom)
    published
      property Control;
  end;


  TAwSourceWinControl = class(TAwSourceVclCustom,IAwSourceBounds,IAwSourceAlfa,IAwSource)
   private
    function ControlGet: TWinControl;
    procedure ControlSet(const Value: TWinControl);
   protected
     //IAwSource
     function IsValid:boolean; override;
     //IAwSourceBounds
     function GetBounds(var Rect:TRectF):boolean;override;
     function SetBounds(const Rect:TRectF):boolean;override;
     //IAwSourceAlfa
     function GetAlfa(var Value:byte): boolean; virtual;
     function SetAlfa(const Value:byte):boolean;virtual;
   public
     constructor Create(AOwner:TComponent); override;
     destructor Destroy;override;
   published
     //property BoundsWinApi: boolean read FBoundsWinApi write BoundsWinApiSet;
     property Control: TWinControl read ControlGet write ControlSet;
  end;

implementation

{ TAwSourceSimple }


constructor TAwSourceSimple.Create(AControl: TWinControl);
begin
   inherited Create;
   FNotifer:=TNotifer.Create(nil);
   FNotifer.SourceSimple:= self;
   FControl:=AControl;
   FLockControl:=0;
   FEventBroadcastDestroy:=TAwHandleBroadcastDestroy.Create;
   if (FControl <> nil)
   and not (csDestroying in FControl.ComponentState) then
      FNotifer.FreeNotification(FControl)
   else
     FControl:=nil;
end;

destructor TAwSourceSimple.Destroy;
begin
  FEventBroadcastDestroy.Invoke;
  if (FControl <> nil) then
  FNotifer.RemoveFreeNotification(FControl);
  FControl:=nil;
  FreeAndNil(FEventBroadcastDestroy);
  FreeAndNil(FNotifer);
  inherited;
end;

function TAwSourceSimple.ControlGet: Pointer;
begin
  Result:= FControl;
end;

function TAwSourceSimple.GetAlfa(var Value:byte): boolean;
begin
    Result:= IsValid;
    if not Result then
     exit;
    Value:=  FControl.HelpTransparentLevel;
end;

function TAwSourceSimple.SetAlfa(const Value: byte): boolean;
begin
    Result:= IsValid;
    if not Result then
     exit;
     FControl.HelpTransparentLevel:=Value;
end;

function TAwSourceSimple.GetBounds(var Rect: TRectF): boolean;
begin
    Result:= IsValid;
    if not Result then
     exit;
    Rect.Left:= FControl.Left;
    Rect.Top:=  FControl.Top;
    Rect.Width:= FControl.Width;
    Rect.Height:= FControl.Height;
end;

function TAwSourceSimple.SetBounds(const Rect: TRectF): boolean;
begin
    Result:= IsValid;
    if not Result then
     exit;
   FControl.SetBounds(Round(Rect.Left),
                     Round(Rect.Top),
                     Round(Rect.Width),
                     Round(Rect.Height));
end;

function TAwSourceSimple.IsValid: boolean;
begin
   Result:= (FControl <> nil)
   and not (csDestroying in FControl.ComponentState)
   and  FControl.HandleAllocated;
end;

procedure TAwSourceSimple.SubOnDestroy(NotifyEvent: TAwProc);
begin
   FEventBroadcastDestroy.Sub(NotifyEvent);
end;

procedure TAwSourceSimple.UnSubOnDestroy(NotifyEvent: TAwProc);
begin
  FEventBroadcastDestroy.UnSub(NotifyEvent);
end;

function TAwSourceSimple.EventsGet:IAwSourceEvent;
begin
  Result:= self;
end;

procedure TAwSourceSimple.EventStartFerst(const Sender: IAwAnimateIntf);
begin

end;

procedure TAwSourceSimple.EventFinishLast(const Sender: IAwAnimateIntf);
begin
end;

procedure TAwSourceSimple.EventProcess(const Sender: IAwAnimateIntf);
begin
end;


procedure TAwSourceSimple.EventStart(const Sender: IAwAnimateIntf);
begin
end;

procedure TAwSourceSimple.EventFinish(const Sender: IAwAnimateIntf);
begin
end;

procedure TAwSourceSimple.NotiferDestroyControl;
begin
  FControl:= nil;
end;








{ TAwSourceSimple.TNotifer }

constructor TAwSourceSimple.TNotifer.Create(AOwner: TComponent);
begin
  SourceSimple:=nil;
  inherited;
end;

destructor TAwSourceSimple.TNotifer.Destroy;
begin
  SourceSimple:=nil;
  inherited;
end;

procedure TAwSourceSimple.TNotifer.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = TOperation.opRemove)and (SourceSimple <> nil)
  and (SourceSimple.FControl = AComponent) then
   SourceSimple.NotiferDestroyControl;
end;

{ TAwSourceVclCustom }

constructor TAwSourceVclCustom.Create(AOwner: TComponent);
begin
  inherited;
   FControl:=nil;
   FEventBroadcastDestroy:=TAwHandleBroadcastDestroy.Create;
end;

destructor TAwSourceVclCustom.Destroy;
begin
   FEventBroadcastDestroy.Invoke;
   if (FControl <> nil) then
    FControl.RemoveFreeNotification(self);
   FControl:=nil;
   FreeAndNil(FEventBroadcastDestroy);
  inherited;
end;

procedure TAwSourceVclCustom.ControlChanged;
begin
end;

function TAwSourceVclCustom.ControlGet: Pointer;
begin
   Result:= FControl;
end;

procedure TAwSourceVclCustom.ControlSet(const Value: TControl);
begin
   if Value <> FControl then
   begin
      if FControl <> nil then
           FControl.RemoveFreeNotification(self);
      FControl:= nil;
      if (Value <> nil)
       and not (csDestroying in Value.ComponentState) then
       begin
         FControl:= Value;
         FControl.FreeNotification(FControl);
       end;
       ControlChanged;
   end;

end;

function TAwSourceVclCustom.GetBounds(var Rect: TRectF): boolean;
begin
    Result:= IsValid;
    if not Result then
     exit;
    Rect.Left:= FControl.Left;
    Rect.Top:=  FControl.Top;
    Rect.Width:= FControl.Width;
    Rect.Height:= FControl.Height;
end;

function TAwSourceVclCustom.EventsGet:IAwSourceEvent;
begin
  Result:= nil;
end;

function TAwSourceVclCustom.IsValid: boolean;
begin
   Result:= (FControl <> nil)
   and not (csDestroying in FControl.ComponentState);
end;

procedure TAwSourceVclCustom.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = TOperation.opRemove)and (FControl <> nil)
  and (FControl = AComponent) then
   FControl:= nil;
end;

function TAwSourceVclCustom.SetBounds(const Rect: TRectF): boolean;
begin
    Result:= IsValid;
    if not Result then
     exit;
   FControl.SetBounds(Round(Rect.Left),
                     Round(Rect.Top),
                     Round(Rect.Width),
                     Round(Rect.Height));
end;

procedure TAwSourceVclCustom.SubOnDestroy(NotifyEvent: TAwProc);
begin
   FEventBroadcastDestroy.Sub(NotifyEvent);
end;

procedure TAwSourceVclCustom.UnSubOnDestroy(NotifyEvent: TAwProc);
begin
   FEventBroadcastDestroy.UnSub(NotifyEvent);
end;

{ TAwSourceWinControl }

constructor TAwSourceWinControl.Create(AOwner: TComponent);
begin
  inherited;

end;

destructor TAwSourceWinControl.Destroy;
begin

  inherited;
end;

function TAwSourceWinControl.ControlGet: TWinControl;
begin
   Result:= inherited Control as TWinControl;
end;

procedure TAwSourceWinControl.ControlSet(const Value: TWinControl);
begin
   inherited Control := Value;
end;

function TAwSourceWinControl.IsValid: boolean;
begin
    Result:= inherited IsValid and Control.HandleAllocated;
end;

function TAwSourceWinControl.GetAlfa(var Value:byte): boolean;
begin
   Result:= IsValid;
   if not Result then
     exit();
   Value:= Control.HelpTransparentLevel;
end;

function TAwSourceWinControl.SetAlfa(const Value: byte): boolean;
begin
   Result:= IsValid;
   if not Result then
     exit();
   Control.HelpTransparentLevel := Value;
end;

function TAwSourceWinControl.GetBounds(var Rect: TRectF): boolean;
begin
   Result:= inherited GetBounds(Rect);
end;

function TAwSourceWinControl.SetBounds(const Rect: TRectF): boolean;
begin
     Result:= inherited SetBounds(Rect);
end;


type
 LocAwFactoryBase = class (AwFactoryBase)end;



initialization
 LocAwFactoryBase.ProcApplicationProcessMessage:=Application.ProcessMessages;
finalization
  LocAwFactoryBase.ProcApplicationProcessMessage:=nil;

end.
