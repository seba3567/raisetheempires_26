package core.ui.menuitem
{
   import core.ZGlobal;
   import core.ui.Tooltip;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import fl.containers.UILoader;
   import flash.display.BitmapData;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.ZGameUtils;
   import zlabs.debug.Logger;
   
   public class PromoMenuItem extends MenuItem
   {
      
      private static var colorFill:uint = 51;
      
      public var priority:int;
      
      protected var itemID:String;
      
      protected var swfPath:String;
      
      protected var toolTipFileName:String;
      
      protected var toolTipText:String;
      
      protected var m_buttonSounds:ButtonMouseEventSoundContainer;
      
      protected var m_buttonSound:String = null;
      
      protected var m_loader:ImageLoader;
      
      protected var m_uiloader:UILoader;
      
      private var m_showTime:uint;
      
      private var m_scaleContent:Boolean;
      
      protected var m_removeOnClick:Boolean;
      
      public function PromoMenuItem(param1:String, param2:Boolean = false, param3:Boolean = true, param4:Boolean = true)
      {
         super(param1);
         this.itemID = param1;
         this.priority = 1;
         this.m_scaleContent = param2;
         this.m_removeOnClick = param3;
         if(param4)
         {
            this.setUp();
         }
      }
      
      public function get removeOnClicked() : Boolean
      {
         return false;
      }
      
      protected function setUp() : void
      {
         var _loc1_:String = null;
         if(this.swfPath)
         {
            _loc1_ = ZGlobal.getAssetURL(this.swfPath);
            this.m_uiloader = new UILoader();
            if(this.m_scaleContent)
            {
               this.m_uiloader.setSize(64,64);
            }
            this.m_uiloader.scaleContent = this.m_scaleContent;
            this.m_loader = ImageLoaderFactory.CreateImageLoader(_loc1_,this.m_uiloader,this.onLoadComplete,this.onLoadFailed);
         }
         else
         {
            this.graphics.beginFill(colorFill,1);
            this.graphics.drawRect(0,0,64,64);
            this.graphics.endFill();
            this.show(false);
            colorFill += 51;
         }
         if(this.m_buttonSound == null)
         {
            this.m_buttonSound = ButtonSound.DEFAULT;
         }
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_buttonSounds.addButton(this,this.m_buttonSound);
      }
      
      protected function cleanup() : void
      {
         if(this.m_loader)
         {
            if(this.m_loader.parent)
            {
               this.m_loader.parent.removeChild(this.m_loader);
            }
            this.m_loader.removeEventListener(MouseEvent.CLICK,this.onClicked);
            Tooltip.unsubscribe(this.m_loader);
            this.m_loader.destroy();
            this.m_loader = null;
         }
         if(this.m_uiloader)
         {
            this.m_uiloader.removeEventListener(MouseEvent.CLICK,this.onClicked);
            this.m_uiloader.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
            this.m_uiloader.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOut);
         }
         this.m_uiloader = null;
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
         }
         this.m_buttonSounds = null;
         filters = null;
      }
      
      override public function show(param1:Boolean = false) : void
      {
         super.show(param1);
         this.m_showTime = GlobalEngine.serverTime / 1000;
      }
      
      protected function onLoadComplete(param1:String, param2:BitmapData) : void
      {
         this.m_uiloader.addEventListener(MouseEvent.CLICK,this.onClicked,false,0,true);
         this.m_uiloader.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         this.m_uiloader.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         addChild(this.m_uiloader);
         this.show(false);
      }
      
      protected function onLoadFailed() : void
      {
         Logger.debug(this,"onLoadFailed","Failed to load " + this.swfPath);
      }
      
      override public function removeItem() : void
      {
         super.removeItem();
         this.cleanup();
      }
      
      protected function onMouseOver(param1:MouseEvent) : void
      {
         filters = [ZGameUtils.HighlightFilter];
      }
      
      protected function onMouseOut(param1:MouseEvent) : void
      {
         filters = null;
      }
      
      public function get elapsedSinceShow() : uint
      {
         var _loc1_:uint = GlobalEngine.serverTime / 1000;
         return _loc1_ - this.m_showTime;
      }
      
      protected function onClicked(param1:MouseEvent) : void
      {
      }
      
      public function get removeOnClick() : Boolean
      {
         return this.m_removeOnClick;
      }
   }
}

