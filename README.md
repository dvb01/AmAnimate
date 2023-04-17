# AmAnimate
Анимация для графики и контролов 
Пока только Shake работает
```pascal

  var Shake:IAwAnimateShake;
  begin
   Shake:= AwFactoryEffects.Shake;
   Shake.OnDestroying:=  AntDestroy;
   // быстрая установка параметров
   Shake.SetParam(TAwSourceSimple.Create(AmComboBox1),3000,10,15,2.5,1.5);
   // расширенная
   Shake.Option.Effect.X.Effect.EffectSet(TAwEnumEffectMain(8),TAwEnumEffectMode(1));
   Shake.Option.Effect.Y.Effect.EffectSet(TAwEnumEffectMain(8),TAwEnumEffectMode(1));
   Shake.Start;
   //...
```
![Preview](/READMEFILES/1.gif "Фото Программы")
![Preview](/READMEFILES/2.gif "Фото Программы")