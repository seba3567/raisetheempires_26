package zlabs.debug
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.system.Capabilities;
   import flash.system.System;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.getTimer;
   
   public class Stats extends Sprite
   {
      
      private var fps:int;
      
      private var timer:int;
      
      private var ms:int;
      
      private var msPrev:int = 0;
      
      private var fpsText:TextField;
      
      private var msText:TextField;
      
      private var memText:TextField;
      
      private var verText:TextField;
      
      private var format:TextFormat;
      
      private var graph:BitmapData;
      
      private var mem:Number = 0;
      
      private var rectangle:Rectangle;
      
      private var ver:Sprite;
      
      public function Stats()
      {
         super();
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         x += 150;
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         graphics.beginFill(51);
         graphics.drawRect(0,0,65,40);
         graphics.endFill();
         this.ver = new Sprite();
         this.ver.graphics.beginFill(51);
         this.ver.graphics.drawRect(0,0,65,30);
         this.ver.graphics.endFill();
         this.ver.y = 90;
         this.ver.visible = false;
         addChild(this.ver);
         this.verText = new TextField();
         this.fpsText = new TextField();
         this.msText = new TextField();
         this.memText = new TextField();
         this.format = new TextFormat("_sans",9);
         this.verText.defaultTextFormat = this.fpsText.defaultTextFormat = this.msText.defaultTextFormat = this.memText.defaultTextFormat = this.format;
         this.verText.width = this.fpsText.width = this.msText.width = this.memText.width = 65;
         this.verText.selectable = this.fpsText.selectable = this.msText.selectable = this.memText.selectable = false;
         this.verText.textColor = 16777215;
         this.verText.text = Capabilities.version.split(" ")[0] + "\n" + Capabilities.version.split(" ")[1];
         this.ver.addChild(this.verText);
         this.fpsText.textColor = 16776960;
         this.fpsText.text = "FPS: ";
         addChild(this.fpsText);
         this.msText.y = 10;
         this.msText.textColor = 65280;
         this.msText.text = "MS: ";
         addChild(this.msText);
         this.memText.y = 20;
         this.memText.textColor = 65535;
         this.memText.text = "MEM: ";
         addChild(this.memText);
         this.graph = new BitmapData(65,50,false,51);
         var _loc2_:Bitmap = new Bitmap(this.graph);
         _loc2_.y = 40;
         addChild(_loc2_);
         this.rectangle = new Rectangle(0,0,1,this.graph.height);
         addEventListener(MouseEvent.CLICK,this.onClick);
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         addEventListener(Event.ENTER_FRAME,this.update);
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         if(this.mouseY > this.height * 0.35)
         {
            --stage.frameRate;
         }
         else
         {
            ++stage.frameRate;
         }
         this.fpsText.text = "FPS: " + this.fps + " / " + stage.frameRate;
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         this.ver.visible = false;
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         this.ver.visible = true;
      }
      
      private function update(param1:Event) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Number = NaN;
         var _loc4_:int = 0;
         this.timer = getTimer();
         ++this.fps;
         if(this.timer - 250 > this.msPrev)
         {
            this.msPrev = this.timer;
            this.mem = Number((System.totalMemory * 9.54e-7).toFixed(3));
            if(stage)
            {
               _loc2_ = Math.min(50,50 / stage.frameRate * this.fps);
            }
            _loc3_ = Math.min(50,Math.sqrt(Math.sqrt(this.mem * 5000))) - 2;
            this.graph.scroll(1,0);
            this.graph.fillRect(this.rectangle,51);
            if(this.timer - this.ms > 100)
            {
               _loc4_ = 0;
               while(_loc4_ < this.graph.height)
               {
                  this.graph.setPixel32(0,this.graph.height - _loc4_,16711680);
                  _loc4_++;
               }
            }
            this.graph.setPixel32(0,this.graph.height - _loc2_,16776960);
            this.graph.setPixel32(0,this.graph.height - (this.timer - this.ms >> 1),65280);
            this.graph.setPixel32(0,this.graph.height - _loc3_,65535);
            if(stage)
            {
               this.fpsText.text = "FPS: " + this.fps * 4 + " / " + stage.frameRate;
            }
            this.memText.text = "MEM: " + this.mem;
            this.fps = 0;
         }
         this.msText.text = "MS: " + (this.timer - this.ms);
         this.ms = this.timer;
      }
   }
}

