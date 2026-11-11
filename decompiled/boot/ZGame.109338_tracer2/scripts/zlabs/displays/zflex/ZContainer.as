package zlabs.displays.zflex
{
   import flash.display.DisplayObject;
   
   public class ZContainer extends ZSprite
   {
      
      private var m_contentWidth:Number = 0;
      
      private var m_contentHeight:Number = 0;
      
      private var m_modalView:ZModalView;
      
      private var m_backgroundColor:uint = 0;
      
      private var m_backgroundAlpha:Number = 1;
      
      private var m_backgroundRoundedCorners:Number = 0;
      
      private var m_backgroundVisible:Boolean = false;
      
      public function ZContainer()
      {
         super();
      }
      
      public function get contentWidth() : Number
      {
         return this.m_contentWidth;
      }
      
      public function set contentWidth(param1:Number) : void
      {
         this.m_contentWidth = param1;
         this.updateDisplay();
      }
      
      public function get contentHeight() : Number
      {
         return this.m_contentHeight;
      }
      
      public function set contentHeight(param1:Number) : void
      {
         this.m_contentHeight = param1;
         this.updateDisplay();
      }
      
      public function presentModalView(param1:ZModalView) : void
      {
         if(this.m_modalView)
         {
         }
         param1.x = 0;
         param1.y = 0;
         this.m_modalView = param1;
         addChild(this.m_modalView);
         this.m_modalView.onLoaded();
      }
      
      override protected function updateDisplay() : void
      {
         super.updateDisplay();
         graphics.clear();
         if(this.m_backgroundVisible)
         {
            graphics.beginFill(this.backgroundColor,this.backgroundAlpha);
            graphics.drawRoundRect(0,0,this.contentWidth,this.contentHeight,this.backgroundRoundedCorners,this.backgroundRoundedCorners);
            graphics.endFill();
         }
      }
      
      public function get backgroundColor() : uint
      {
         return this.m_backgroundColor;
      }
      
      public function set backgroundColor(param1:uint) : void
      {
         this.m_backgroundVisible = true;
         this.m_backgroundColor = param1;
         this.updateDisplay();
      }
      
      public function get backgroundAlpha() : Number
      {
         return this.m_backgroundAlpha;
      }
      
      public function set backgroundAlpha(param1:Number) : void
      {
         this.m_backgroundAlpha = param1;
         this.updateDisplay();
      }
      
      public function get backgroundRoundedCorners() : Number
      {
         return this.m_backgroundRoundedCorners;
      }
      
      public function set backgroundRoundedCorners(param1:Number) : void
      {
         this.m_backgroundRoundedCorners = param1;
         this.updateDisplay();
      }
      
      override public function get centerX() : Number
      {
         return this.x + this.contentWidth / 2;
      }
      
      override public function set centerX(param1:Number) : void
      {
         this.x = param1 - this.contentWidth / 2;
      }
      
      override public function get centerY() : Number
      {
         return this.y + this.contentHeight / 2;
      }
      
      override public function set centerY(param1:Number) : void
      {
         this.y = param1 - this.contentHeight / 2;
      }
      
      override public function set enabled(param1:Boolean) : void
      {
         var _loc2_:DisplayObject = null;
         for each(_loc2_ in this.children)
         {
            if(_loc2_ is ZSprite)
            {
               (_loc2_ as ZSprite).enabled = param1;
            }
         }
      }
      
      public function get backgroundVisible() : Boolean
      {
         return this.m_backgroundVisible;
      }
      
      public function set backgroundVisible(param1:Boolean) : void
      {
         this.m_backgroundVisible = param1;
         this.updateDisplay();
      }
   }
}

