package Engine.Classes.EasterEggs
{
   import Engine.Classes.FontNames;
   import Engine.Interfaces.IEasterEgg;
   import com.greensock.TweenLite;
   import com.greensock.easing.Linear;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   
   public class CreditsEasterEgg implements IEasterEgg
   {
      
      private static const TEXT_WIDTH:Number = 500;
      
      private static const TEXT_HEIGHT:Number = 340;
      
      public function CreditsEasterEgg()
      {
         super();
      }
      
      public function get code() : String
      {
         return "credits";
      }
      
      public function execute() : void
      {
         var _loc1_:URLLoader = new URLLoader();
         _loc1_.addEventListener(Event.COMPLETE,this.onCreditsLoadComplete);
         _loc1_.load(new URLRequest(Config.BASE_PATH + "credits.txt"));
      }
      
      private function onCreditsLoadComplete(param1:Event) : void
      {
         var creditsText:TextField;
         var bitmapData:BitmapData;
         var bitmap:Bitmap;
         var background:Sprite;
         var mask:Sprite;
         var credits:Sprite = null;
         var event:Event = param1;
         var position:Point = new Point(GlobalEngine.stage.stageWidth / 2 - TEXT_WIDTH / 2,GlobalEngine.stage.stageHeight / 2 - TEXT_HEIGHT / 2);
         var textFormat:TextFormat = GlobalEngine.fontMapper.mapTextFormat("Credits",new TextFormat(FontNames.UNSTYLED_UI_FONT,24,16777215,false));
         textFormat.align = TextFormatAlign.CENTER;
         textFormat.leftMargin = 5;
         textFormat.rightMargin = 5;
         creditsText = new TextField();
         creditsText.defaultTextFormat = textFormat;
         creditsText.selectable = false;
         creditsText.x = position.x;
         creditsText.y = position.y;
         creditsText.wordWrap = true;
         creditsText.multiline = true;
         creditsText.htmlText = URLLoader(event.currentTarget).data as String;
         creditsText.width = TEXT_WIDTH;
         creditsText.height = 24 * creditsText.numLines;
         bitmapData = new BitmapData(creditsText.width,creditsText.height,true,0);
         bitmapData.draw(creditsText);
         bitmap = new Bitmap(bitmapData);
         credits = new Sprite();
         background = new Sprite();
         credits.addChild(background);
         background.graphics.beginFill(0,0.5);
         background.graphics.drawRoundRect(0,0,TEXT_WIDTH,TEXT_HEIGHT,20,20);
         background.graphics.endFill();
         credits.addChild(bitmap);
         credits.x = position.x;
         credits.y = position.y;
         mask = new Sprite();
         mask.x = position.x;
         mask.y = position.y;
         mask.graphics.beginFill(16777215,1);
         mask.graphics.drawRect(0,0,TEXT_WIDTH,TEXT_HEIGHT);
         mask.graphics.endFill();
         credits.mask = mask;
         GlobalEngine.stage.addChild(credits);
         TweenLite.to(bitmap,creditsText.numLines * 0.75,{
            "y":-1 * creditsText.height + TEXT_HEIGHT + position.y - 10,
            "ease":Linear.easeNone,
            "delay":3,
            "onComplete":function():void
            {
               if(credits != null)
               {
                  GlobalEngine.stage.removeChild(credits);
                  credits = null;
               }
            }
         });
      }
   }
}

