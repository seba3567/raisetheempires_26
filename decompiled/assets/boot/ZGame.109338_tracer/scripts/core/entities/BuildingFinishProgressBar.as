package core.entities
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import displays.ImageLoader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.resource.SWFResource;
   
   public class BuildingFinishProgressBar extends Sprite implements IDynamicProgressBar
   {
      
      private static var HORIZ_PADDING:int = 20;
      
      private var m_destroyed:Boolean;
      
      private var m_ownerGameItem:GameItem;
      
      private var m_clipClass:Class;
      
      private var m_clip:MovieClip;
      
      private var m_iconLoader:ImageLoader = null;
      
      public function BuildingFinishProgressBar()
      {
         var _loc1_:String = ZGlobal.getAssetURL("assets/ui/BuildingCompleteNotice.swf");
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
      }
      
      public function set ownerGameItem(param1:GameItem) : void
      {
         this.m_ownerGameItem = param1;
         this.checkCreate();
         this.update();
      }
      
      public function set referenceItem(param1:String) : void
      {
      }
      
      public function get referenceItem() : String
      {
         return null;
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
         this.m_clipClass = param1.getAssetClass("finishBub_mc");
         this.checkCreate();
      }
      
      private function checkCreate() : void
      {
         var _loc1_:String = null;
         if(Boolean(!this.m_clip) && Boolean(this.m_clipClass) && Boolean(this.m_ownerGameItem))
         {
            this.m_clip = new this.m_clipClass();
            _loc1_ = ZGameUtils.ZlocT("Tooltips","finishbuilding_action");
            TextFieldUtil.processSingleLineTextField(this.m_clip.info.desc_tf,_loc1_);
            this.update();
            addChild(this.m_clip);
         }
      }
      
      private function update() : void
      {
         var _loc1_:String = null;
         if(Boolean(this.m_clip) && Boolean(this.m_ownerGameItem))
         {
            _loc1_ = this.m_ownerGameItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
            TextFieldUtil.processSingleLineTextField(this.m_clip.title_tf,_loc1_);
            this.resize();
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
            this.adjustDialogSize(this.totalWidth + HORIZ_PADDING);
            this.info.x = -this.info.desc_tf.width * 0.5;
            this.m_clip.title_tf.x = -(this.m_clip.title_tf.width * 0.5);
         }
      }
      
      private function get totalWidth() : int
      {
         var _loc1_:int = int(this.m_clip.title_tf.width);
         var _loc2_:int = int(this.info.desc_tf.width);
         return Math.max(_loc1_,_loc2_);
      }
      
      private function adjustDialogSize(param1:int) : void
      {
         var _loc2_:int = int(this.m_clip.bubble_mc.box_ctr.width);
         var _loc3_:int = param1 - _loc2_;
         var _loc4_:int = _loc3_ / 2;
         this.m_clip.bubble_mc.box_lt.width = _loc4_;
         this.m_clip.bubble_mc.box_rt.width = _loc4_;
         this.m_clip.bubble_mc.height = 50;
      }
   }
}

