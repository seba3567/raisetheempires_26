package core.entities
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.WorldResourceManager;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zgame.assets.ui.AssetGroup_UI.ProgressBarArt;
   
   public class ProgressBar extends Sprite
   {
      
      protected var m_progressDisplayObject:MovieClip;
      
      protected var m_referenceItem:String = null;
      
      protected var m_actionBarWidth:Number;
      
      protected var m_imageLoader:ImageLoader = null;
      
      protected var m_assetClass:Class = ProgressBarArt;
      
      public function ProgressBar(param1:Class = null, param2:uint = 0)
      {
         super();
         if(param1)
         {
            this.m_assetClass = param1;
         }
         this.initialize();
      }
      
      public function get mc() : MovieClip
      {
         return this.m_progressDisplayObject;
      }
      
      protected function initialize() : void
      {
         this.m_progressDisplayObject = new this.m_assetClass();
         this.m_actionBarWidth = this.m_progressDisplayObject.bar.width;
         addChild(this.m_progressDisplayObject);
      }
      
      public function updateProgressBarPercentage(param1:String, param2:Number = 0) : void
      {
         TextFieldUtil.processTextField(this.m_progressDisplayObject.label_tf,param1);
         this.m_progressDisplayObject.bar.width = this.m_actionBarWidth * param2;
      }
      
      public function setPosition(param1:Number, param2:Number) : void
      {
         this.x = -(this.m_actionBarWidth * scaleX) * 0.5 + param1;
         this.y = -param2;
      }
      
      private function clearIcon() : void
      {
         if(this.m_imageLoader)
         {
            this.m_imageLoader.destroy();
            this.m_imageLoader = null;
         }
      }
      
      public function set ownerGameItem(param1:GameItem) : void
      {
      }
      
      public function set referenceItem(param1:String) : void
      {
         var _loc2_:String = null;
         if(this.m_referenceItem != param1)
         {
            this.m_referenceItem = param1;
            this.clearIcon();
            if(this.m_referenceItem)
            {
               _loc2_ = ZGlobal.gameSettings.getImageByName(this.m_referenceItem,"icon",WorldResourceManager.SMALL_ICON);
               if(_loc2_)
               {
                  this.m_imageLoader = ImageLoaderFactory.CreateImageLoader(_loc2_,this.m_progressDisplayObject.icon_mc);
                  this.m_progressDisplayObject.icon_mc.filters = [ZGameUtils.ImageStrokeFilter];
               }
            }
         }
      }
      
      public function get referenceItem() : String
      {
         return this.m_referenceItem;
      }
      
      public function get displaysOverUI() : Boolean
      {
         return false;
      }
      
      public function get UIDisplayOffsetX() : Number
      {
         return 0;
      }
      
      public function get UIDisplayOffsetY() : Number
      {
         return 0;
      }
      
      public function destroy() : void
      {
         this.clearIcon();
         removeChild(this.m_progressDisplayObject);
         this.m_progressDisplayObject = null;
      }
   }
}

