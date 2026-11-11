package displays.screens
{
   import core.ZGameStats;
   import core.ZGlobal;
   import core.gameobjects.CrewTemplateWrapper;
   import core.gameobjects.GameItem;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   
   public class CrewRewardGatherOwnerPartial extends CrewGatherOwnerPartial
   {
      
      protected var _crewBackgroundSWFURL:String;
      
      protected var _teaserIconURL:String;
      
      protected var _crewPopupValue:String;
      
      protected var _crewPopupChance:String;
      
      protected var _paddingTop:int;
      
      protected var _kingdom:String;
      
      protected var _fourInALine:Boolean;
      
      protected var _overrideWidth:Boolean;
      
      protected var _paddingLeft:int;
      
      public function CrewRewardGatherOwnerPartial(param1:IEntity, param2:CrewTemplateWrapper, param3:GameItem, param4:Array, param5:Object, param6:String, param7:String, param8:String, param9:String, param10:int, param11:String, param12:Boolean = false, param13:Boolean = false, param14:int = 0)
      {
         this._crewBackgroundSWFURL = param6;
         this._teaserIconURL = param7;
         this._crewPopupValue = param8;
         this._crewPopupChance = param9;
         this._paddingTop = param10;
         this._kingdom = param11;
         this._fourInALine = param12;
         this._overrideWidth = param13;
         this._paddingLeft = param14;
         super(param1,param2,param3,param4,param5);
         addEventListener(CrewResizablePopUp.SLOT_BOUGHT,this.onSlotBought);
      }
      
      override protected function deinitDialog() : void
      {
         removeEventListener(CrewResizablePopUp.SLOT_BOUGHT,this.onSlotBought);
         super.deinitDialog();
      }
      
      override protected function getAsset() : String
      {
         return this._crewBackgroundSWFURL;
      }
      
      override protected function get resize() : Boolean
      {
         return false;
      }
      
      override protected function setupText() : void
      {
         super.setupText();
         var _loc1_:ImageLoader = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(this._teaserIconURL),this.teaser.icon.icon);
         _loc1_.smooth = true;
         var _loc2_:Array = this._crewPopupValue.split(":");
         TextFieldUtil.compactTextField(this.teaser.value_tf,ZGameUtils.ZlocT(_loc2_[0],_loc2_[1]));
         var _loc3_:Array = this._crewPopupChance.split(":");
         TextFieldUtil.processTextField(this.teaser.chance_tf,ZGameUtils.ZlocT(_loc3_[0],_loc3_[1]));
      }
      
      private function get teaser() : MovieClip
      {
         return mc.teaser_mc;
      }
      
      override protected function get dialogHeight() : int
      {
         return 238;
      }
      
      override protected function get dialogWidth() : int
      {
         return 570;
      }
      
      override protected function get dialogPaddingBottom() : uint
      {
         return 0;
      }
      
      override protected function get dialogPaddingTop() : uint
      {
         return this._paddingTop;
      }
      
      override protected function get dialogPaddingRight() : uint
      {
         return 0;
      }
      
      override protected function get dialogPaddingLeft() : uint
      {
         if(this._paddingLeft != 0)
         {
            return this._paddingLeft;
         }
         return 150;
      }
      
      private function onSlotBought(param1:WorldEvent) : void
      {
         ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_GENERIC_BUTTON_CLICKED,{
            "counter":"dialog",
            "kingdom":this._kingdom,
            "phylum":"pay"
         }));
      }
      
      override protected function onConfirmClick(param1:MouseEvent) : void
      {
         ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_GENERIC_BUTTON_CLICKED,{
            "counter":"dialog",
            "kingdom":this._kingdom,
            "phylum":"ask"
         }));
         super.onConfirmClick(param1);
      }
      
      override protected function getGridLayout(param1:int) : Point
      {
         if(this._fourInALine)
         {
            return new Point(param1,1);
         }
         return super.getGridLayout(param1);
      }
      
      override protected function onWidthSet(param1:uint) : void
      {
         if(this._overrideWidth)
         {
            return;
         }
         super.onWidthSet(param1);
      }
   }
}

