package core.entities
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.SuperOreManager;
   import core.managers.WorldResourceManager;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.resource.SWFResource;
   
   public class ContractProgressBar extends Sprite implements IDynamicProgressBar
   {
      
      private var m_destroyed:Boolean;
      
      private var m_referenceItem:String;
      
      private var m_ownerGameItem:GameItem;
      
      private var m_clipClass:Class;
      
      private var m_clip:MovieClip;
      
      private var m_timeString:String = "";
      
      private var m_iconLoader:ImageLoader = null;
      
      public function ContractProgressBar()
      {
         var _loc1_:String = ZGlobal.getAssetURL("assets/ui/SpeedUpNotice.swf");
         if(Zlab.resourceManager.validUrl(_loc1_))
         {
            Zlab.resourceManager.load(_loc1_,SWFResource,this.onLoadComplete);
         }
         super();
      }
      
      public function setPosition(param1:Number, param2:Number) : void
      {
         this.x = param1;
         this.y = -param2;
      }
      
      public function updateProgressBarPercentage(param1:String, param2:Number = 0) : void
      {
         this.m_timeString = param1;
         this.checkCreate();
         this.updateTimeString();
         this.resize();
      }
      
      public function set ownerGameItem(param1:GameItem) : void
      {
         this.m_ownerGameItem = param1;
         this.checkCreate();
         this.updateTitleString();
         this.resize();
      }
      
      public function set referenceItem(param1:String) : void
      {
         this.m_referenceItem = param1;
         this.checkCreate();
         this.updateRefItemInfo();
         this.resize();
      }
      
      public function get referenceItem() : String
      {
         return this.m_referenceItem;
      }
      
      public function get displaysOverUI() : Boolean
      {
         return true;
      }
      
      public function get UIDisplayOffsetX() : Number
      {
         return 0;
      }
      
      public function get UIDisplayOffsetY() : Number
      {
         return -60;
      }
      
      private function onLoadComplete(param1:SWFResource) : void
      {
         this.m_clipClass = param1.getAssetClass("speedUpBub_mc");
         this.checkCreate();
      }
      
      private function checkCreate() : void
      {
         var _loc1_:String = null;
         if(Boolean(!this.m_clip && this.m_clipClass && this.m_referenceItem) && Boolean(this.m_ownerGameItem) && Boolean(this.m_timeString.length))
         {
            this.m_clip = new this.m_clipClass();
            this.info.time_tf.x = this.info.icon.width;
            this.info.name_tf.x = this.info.icon.width;
            if(this.m_ownerGameItem.isResearchItem())
            {
               _loc1_ = ZGameUtils.ZlocT("Tooltips","research_action");
            }
            else
            {
               _loc1_ = ZGameUtils.ZlocT("Tooltips","contract_action");
            }
            TextFieldUtil.processSingleLineTextField(this.m_clip.generic_tf,_loc1_);
            this.updateTitleString();
            this.updateRefItemInfo();
            this.updateTimeString();
            this.resize();
            this.m_clip.info.icon.filters = [ZGameUtils.ImageStrokeFilter];
            addChild(this.m_clip);
         }
      }
      
      private function updateTitleString() : void
      {
         var _loc1_:String = null;
         if(Boolean(this.m_clip) && Boolean(this.m_ownerGameItem))
         {
            _loc1_ = this.m_ownerGameItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
            TextFieldUtil.processSingleLineTextField(this.m_clip.title_tf,_loc1_);
         }
      }
      
      private function updateRefItemInfo() : void
      {
         var _loc2_:String = null;
         var _loc1_:GameItem = this.m_referenceItem ? ZGlobal.gameSettings.getItemByName(this.m_referenceItem,GameItem) as GameItem : null;
         if(Boolean(this.m_clip) && Boolean(_loc1_))
         {
            this.updateIcon();
            _loc2_ = _loc1_.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
            TextFieldUtil.processSingleLineTextField(this.m_clip.info.name_tf,_loc2_);
         }
      }
      
      private function updateTimeString() : void
      {
         if(this.m_clip)
         {
            TextFieldUtil.processSingleLineTextField(this.m_clip.info.time_tf,this.m_timeString);
         }
      }
      
      private function updateIcon() : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         if(this.m_iconLoader)
         {
            this.m_iconLoader.destroy();
            this.m_iconLoader = null;
         }
         var _loc1_:GameItem = ZGlobal.gameSettings.getItemByName(this.m_referenceItem,GameItem) as GameItem;
         if(_loc1_.isSuperOre())
         {
            _loc3_ = SuperOreManager.instance.getResourceName();
            if(_loc3_)
            {
               _loc4_ = WorldResourceManager.instance.getResourceImageURLByType(_loc3_);
               this.m_iconLoader = ImageLoaderFactory.CreateImageLoader(_loc4_,this.m_clip.info.icon);
               return;
            }
         }
         var _loc2_:String = ZGlobal.gameSettings.getImageByName(this.m_referenceItem,"icon");
         if(_loc2_)
         {
            this.m_iconLoader = ImageLoaderFactory.CreateImageLoader(_loc2_,this.m_clip.info.icon);
         }
      }
      
      private function get info() : MovieClip
      {
         return this.m_clip.info;
      }
      
      private function resize() : void
      {
         if(this.m_clip)
         {
            this.info.time_tf.x = this.info.icon.width;
            this.info.name_tf.x = this.info.icon.width;
            this.adjustDialogSize(this.totalWidth + 40);
            this.centerInfo();
            this.m_clip.title_tf.x = -(this.m_clip.title_tf.width * 0.5);
            this.m_clip.generic_tf.x = -(this.m_clip.generic_tf.width * 0.5);
         }
      }
      
      private function get totalWidth() : int
      {
         var _loc1_:int = 0;
         var _loc2_:Array = new Array(this.m_clip.title_tf.width,this.info.width,this.m_clip.generic_tf.width);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length)
         {
            _loc1_ = Math.max(_loc1_,_loc2_[_loc3_]);
            _loc3_++;
         }
         return _loc1_;
      }
      
      private function adjustDialogSize(param1:int) : void
      {
         var _loc2_:int = param1 / 2 - 15;
         this.m_clip.bubble_mc.box_lt.width = _loc2_;
         this.m_clip.bubble_mc.box_rt.width = _loc2_;
      }
      
      private function centerInfo() : void
      {
         var _loc1_:int = 0;
         this.info.x = -(this.info.width * 0.5);
         if(this.info.name_tf.width > this.info.time_tf.width)
         {
            _loc1_ = this.info.width * 0.5;
            this.info.time_tf.x = _loc1_ - this.info.time_tf.width * 0.5;
            this.info.time_tf.x = Math.max(this.info.icon.width,this.info.time_tf.x);
         }
      }
   }
}

