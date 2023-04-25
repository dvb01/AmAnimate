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
  AmGraphic.Help,
  AmAnimate.Core.Source.Intf,
  AmAnimate.Core.Engine,
  AmAnimate.Source.Vcl,
  AmControlClasses;

  type

  TAwSourceTesterWinApi = class (TAwSourceSimple)
    protected
     procedure NotiferDestroyControl; override;
     procedure EventStart(const Sender:IAwAnimateIntf); override;
     procedure EventFinish(const Sender:IAwAnimateIntf);override;
     function GetBounds(var Rect:TRectF):boolean;   override;
     function SetBounds(const Rect:TRectF):boolean; override;
  end;

  TAwSourceSimpleColor1 = class (TAwSourceSimple)
    protected
     function DcvStart(const Table:IAwSourceDcvTable):boolean;override;
     function DcvProcess(const Table:IAwSourceDcvTable):boolean; override;
     function DcvFinish(const Table:IAwSourceDcvTable):boolean;override;
  end;

implementation

type
TLocWinControl = class(TWinControl);

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

{ TAwSourceSimpleColor1 }

function TAwSourceSimpleColor1.DcvStart(const Table: IAwSourceDcvTable): boolean;
var CBegin,CEnd:TColor;
var H1,L1,S1,H2,L2,S2:integer;
begin
  Result:=IsValid;
  if not Result then
    exit;

  CBegin:=$0058DE49;
  CEnd:=$00E14E46;
  AmColorConvert2.ColorToHLS(CBegin,H1,L1,S1);
  AmColorConvert2.ColorToHLS(CEnd,H2,L2,S2);
  Table.Add('H',H1,H2);
  Table.Add('L',L1,L2);
  Table.Add('S',S1,S2);
end;

function TAwSourceSimpleColor1.DcvProcess(const Table: IAwSourceDcvTable): boolean;
var H,L,S:Double;
begin
  Result:=IsValid;
  if not Result then
    exit;
  Table.GetNowValue('H',H);
  Table.GetNowValue('L',L);
  Table.GetNowValue('S',S);
  TLocWinControl(Control).Color:= AmColorConvert2.HLSToColor(Round(H),Round(L),Round(S));
end;

function TAwSourceSimpleColor1.DcvFinish(const Table: IAwSourceDcvTable): boolean;
var H,L,S:Double;
begin
  Result:=IsValid;
  if not Result then
    exit;
  Table.GetNowValue('H',H);
  Table.GetNowValue('L',L);
  Table.GetNowValue('S',S);
  TLocWinControl(Control).Color:= AmColorConvert2.HLSToColor(Round(H),Round(L),Round(S));
end;

end.
