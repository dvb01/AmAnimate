# AmAnimate
Анимация для графики и контролов 

```pascal


  
//отмена предыдущих анимаций для этого контрола
 AwFactoryEffects.SourceCancel(TAwSourceSimple.Create(AmComboBox1));

procedure TForm27.NewShakeSimple(C:TWinControl);
var Shake:IAwAnimateShake;
begin
   Shake:= AwFactoryEffects.Shake;
   Shake.Name:= 'Shake '+C.Name;
   Shake.OnDestroying:=  AntDestroy;
   // быстрая установка параметров
   Shake.SetParam(TAwSourceSimple.Create(C),5000,10,15,40.5,20.5);
   // расширенная
   Shake.Option.Effect.X.Effect.EffectSet(TAwEnumEffectMain(8),TAwEnumEffectMode(1));
   Shake.Option.Effect.Y.Effect.EffectSet(TAwEnumEffectMain(8),TAwEnumEffectMode(1));
   Shake.Start;
end;
   
procedure TForm27.NewBallSimple(C:TWinControl);
var Ball:IAwAnimateBall;
begin

   Ball:= AwFactoryEffects.Ball;
   Ball.Name:= 'Ball '+C.Name;
   Ball.OnDestroying:=  AntDestroy;
   Ball.SetParam(TAwSourceTesterWinApi.Create(C),3000,250,120,1,1);
   Ball.Option.Effect.X.Effect.EffectSet(TAwEnumEffectMain(AmComboBox1.ItemIndex),TAwEnumEffectMode(1));
   Ball.Option.Effect.Y.Effect.EffectSet(TAwEnumEffectMain(AmComboBox1.ItemIndex),TAwEnumEffectMode(1));
   Ball.Start;
end;

procedure TForm27.NewMoveSimple(C:TWinControl);
var Move:IAwAnimateMove;
  B: TAmBounds;
begin
   B.BoundsControlSet(C);
   Move:= AwFactoryEffects.Move;
   Move.Name:= 'Move '+C.Name;
   Move.OnDestroying:=  AntDestroy;
   Move.Option.Effect.Left.EffectSet(atlMiddleWave,TAwEnumEffectMode(1));
   Move.Option.Effect.Top.EffectSet(atlLowWave,TAwEnumEffectMode(1));
   Move.Option.Effect.Width.EffectSet(atlSwing50,TAwEnumEffectMode(1));
   Move.Option.Effect.Height.EffectSet(atlElastic,TAwEnumEffectMode(1));
   Move.Option.Bounds.Left:= self.Width - 100;
   Move.Option.Bounds.Top:= 10;
   Move.Option.Bounds.Width:=50;
   Move.Option.Bounds.Height:=50;
   Move.Option.Delay:=3000;
   Move.Option.Source:= TAwSourceTesterWinApi.Create(C);
   Move.OnFinishLastRef := procedure (Animate:IAwAnimateBase) begin   B.BoundsToControl(C); end;
   Move.Start;
end;

procedure TForm27.NewAlfaSimple(C:TWinControl;Delta:Integer);
var Alfa:IAwAnimateAlfa;
begin
   Alfa:= AwFactoryEffects.Alfa;
   Alfa.Name:= 'Alfa '+C.Name;
   Alfa.OnDestroying:=  AntDestroy;
   Alfa.SetParam(TAwSourceTesterWinApi.Create(C),1500,Delta);
   Alfa.Option.Effect.Effect.EffectSet(TAwEnumEffectMain(1),TAwEnumEffectMode(1));
   Alfa.Start;
end;   


// очерель анимаций 
procedure TForm27.PShake_QueueClick(Sender: TObject);
var List:IAwQueue;
var i:integer;
C:TWinControl;
begin
    // перед добавлением нужно отменить все анимации для каждого контрола
    List:=AwFactoryBase.NewList;
    for I := 0 to ListShake.Count-1 do
    begin
       C:=ListShake.Items[i]; // берем 1 контрол
       AwFactoryBase.SourceCancel(TAwSourceSimple.Create(C)); // отменяем
       List.Add(NewShakeFastSimple(C),math.RandomRange(-150,10)); // добавляем в лист
    end;
   // List.RepeatCount:=1000;
    List.Start; //запускаем
end;
   
```
![Preview](/READMEFILES/1.gif "Фото Программы")
![Preview](/READMEFILES/2.gif "Фото Программы")
![Preview](/READMEFILES/3.gif "Фото Программы")
![Preview](/READMEFILES/5.gif "Фото Программы")