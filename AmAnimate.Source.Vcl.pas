unit AmAnimate.Source.Vcl;

interface
uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Types,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  AmAnimate.Source.Intf,
  AmAnimate.Engine;

 type
  TAwSourceSimple = class (TInterfacedObject,IAwSourceBounds,IAwSourceAlfa,IAwSource)
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
      FEvent:TAwHandleBroadcastDestroy;
    protected
     procedure SubOnDestroy(NotifyEvent:TAwProc);
     procedure UnSubOnDestroy(NotifyEvent:TAwProc);
     function IsValid:boolean;
     function GetBounds(var Rect:TRectF):boolean;
     function SetBounds(const Rect:TRectF):boolean;
     function GetAlfa:byte;
     function SetAlfa(const Value:byte):boolean;
     function ControlGet:Pointer;
    public
     constructor Create(AControl:TWinControl);
     destructor Destroy;override;
  end;

implementation

{ TAwSourceSimple }


constructor TAwSourceSimple.Create(AControl: TWinControl);
begin
   inherited Create;
   FNotifer:=TNotifer.Create(nil);
   FNotifer.SourceSimple:= self;
   FControl:=AControl;
   FEvent:=TAwHandleBroadcastDestroy.Create;
   if (FControl <> nil)
   and not (csDestroying in FControl.ComponentState) then
      FNotifer.FreeNotification(FControl)
   else
     FControl:=nil;
end;

destructor TAwSourceSimple.Destroy;
begin
  FEvent.Invoke;
  if (FControl <> nil) then
  FNotifer.RemoveFreeNotification(FControl);
  FControl:=nil;
  FreeAndNil(FEvent);
  FreeAndNil(FNotifer);
  inherited;
end;


function TAwSourceSimple.ControlGet: Pointer;
begin
  Result:= FControl;
end;

function TAwSourceSimple.GetAlfa: byte;
begin
   Result:=255;
end;

function TAwSourceSimple.SetAlfa(const Value: byte): boolean;
begin
   Result:=false;
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
   FEvent.Sub(NotifyEvent);
end;

procedure TAwSourceSimple.UnSubOnDestroy(NotifyEvent: TAwProc);
begin
  FEvent.UnSub(NotifyEvent);
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
   SourceSimple.FControl:= nil;
end;

end.
