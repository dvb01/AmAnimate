unit AmAnimate.Source.VclTester;

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
  AmAnimate.Source.Vcl,
  AmControlClasses;

  type

  TAwSourceTesterWinApi = class (TAwSourceSimple)
    protected
     procedure NotiferDestroyControl; override;
     procedure EventStart(const Sender:IAwAnimateIntf); override;
     procedure EventFinish(const Sender:IAwAnimateIntf);override;
     function GetBounds(var Rect:TRectF):boolean;   virtual;
     function SetBounds(const Rect:TRectF):boolean; virtual;
  end;

implementation


{ TAwSourceTesterWinApi }

procedure TAwSourceTesterWinApi.EventFinish(const Sender: IAwAnimateIntf);
begin
 { if IsValid then
  begin
   inc(FLockControl);
   FControl.EnableAlign;
  end; }
end;

procedure TAwSourceTesterWinApi.EventStart(const Sender: IAwAnimateIntf);
begin
 { if IsValid then
  begin
   inc(FLockControl);
   FControl.DisableAlign;
  end;  }
end;

function TAwSourceTesterWinApi.GetBounds(var Rect: TRectF): boolean;
begin
   Result:= inherited;
end;

function TAwSourceTesterWinApi.SetBounds(const Rect: TRectF): boolean;
begin
    Result:= IsValid;
    if not Result then
     exit;
   Control.SetBounds(Round(Rect.Left),
                     Round(Rect.Top),
                     Round(Rect.Width),
                     Round(Rect.Height));
end;

procedure TAwSourceTesterWinApi.NotiferDestroyControl;
begin

 { if (FControl <> nil) and (FLockControl >0) then
  begin
   while FLockControl > 0 do
   begin
     dec(FLockControl);
     FControl.DisableAlign;
   end;
  end;
  }
  inherited NotiferDestroyControl;
end;

end.
