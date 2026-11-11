package core.ui.menuitem
{
   import core.ZGlobal;
   import core.managers.tutorialManager.TutorialManager;
   import core.managers.viralsManager.ViralsManager;
   import core.player.Player;
   import core.ui.Tooltip;
   import core.ui.ZGameButton;
   import dispatchers.NeighborsDispatcher;
   import dispatchers.UIDispatcher;
   import events.FriendBarEvent;
   import events.NeighborsEvent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   
   public class UsersBarUIItem extends MenuItem
   {
      
      public static const WORLD_NAME_UPDATED:String = "worldNameUpdated";
      
      private static const TAB_MARGIN:int = 35;
      
      private static const TAB_MIN_WIDTH:int = 160;
      
      private static const TAB_MAX_WIDTH:int = 450;
      
      private static const POPULATION_TITLE_COUNT_SEPARATION:int = 3;
      
      public static const ALLIANCE_HUD:String = "alliance_hud";
      
      private var m_messageTab:FriendsBarMessageTabUIItem = null;
      
      private var m_title_mc_filters:Array = null;
      
      private var m_shieldButton:ZGameButton = null;
      
      public function UsersBarUIItem(param1:String)
      {
         super(param1);
         NeighborsDispatcher.instance.addEventListener(FriendBarEvent.MOVE,this.onUserGridScrolled,false,0,true);
         NeighborsDispatcher.instance.addEventListener(NeighborsEvent.NEIGHBORS_LOADED,this.onNeighborsLoaded);
         UIDispatcher.instance.addEventListener(UIDispatcher.PLAYER_NAME_LOADED,this.onPlayerNameLoaded);
         UIDispatcher.instance.addEventListener(WORLD_NAME_UPDATED,this.onWorldNameUpdated,false,0,true);
      }
      
      public static function worldNameUpdated(param1:String) : void
      {
         var _loc2_:WorldEvent = new WorldEvent(WORLD_NAME_UPDATED,{"name":param1});
         UIDispatcher.instance.dispatchEvent(_loc2_);
      }
      
      protected function get localizedTabSubtitleLabel() : String
      {
         return "";
      }
      
      protected function get populationTF() : TextField
      {
         return null;
      }
      
      public function postInit() : void
      {
         this.m_messageTab = new FriendsBarMessageTabUIItem(this.displayObject.messageTab_mc);
         this.updateTabWidth();
         TextFieldUtil.processSingleLineTextField(this.populationTF,this.localizedTabSubtitleLabel);
         this.updateTabSubtitleDigits();
         if(this.displayObject.flag)
         {
            this.displayObject.flag.addEventListener(MouseEvent.MOUSE_OUT,this.onFlagOut);
            this.displayObject.flag.addEventListener(MouseEvent.MOUSE_MOVE,this.onFlagMove);
            this.displayObject.flag.addEventListener(MouseEvent.CLICK,this.onFlagClick);
            this.displayObject.flag.useHandCursor = false;
         }
         else if(this.displayObject.shield_bt)
         {
            this.m_shieldButton = new ZGameButton(this.displayObject.shield_bt,this.onAllianceClick);
            TutorialManager.instance.registerUIItem(this.displayObject.shield_bt,ALLIANCE_HUD);
            this.displayObject.alliancesClose_btn.visible = true;
            this.displayObject.alliancesOpen_btn.visible = false;
         }
         this.displayObject.title_mc.addEventListener(MouseEvent.MOUSE_OVER,this.onNationNameOver);
         this.displayObject.title_mc.addEventListener(MouseEvent.MOUSE_OUT,this.onNationNameOut);
         this.displayObject.title_mc.addEventListener(MouseEvent.CLICK,this.onNationNameClick);
         this.m_title_mc_filters = this.displayObject.title_mc.filters;
      }
      
      public function startAllianceAnimation() : void
      {
         this.m_shieldButton.gotoFrame(2);
      }
      
      override public function removeItem() : void
      {
         super.removeItem();
         NeighborsDispatcher.instance.removeEventListener(FriendBarEvent.MOVE,this.onUserGridScrolled);
         NeighborsDispatcher.instance.removeEventListener(NeighborsEvent.NEIGHBORS_LOADED,this.onNeighborsLoaded);
         UIDispatcher.instance.removeEventListener(UIDispatcher.PLAYER_NAME_LOADED,this.onPlayerNameLoaded);
         UIDispatcher.instance.removeEventListener(WORLD_NAME_UPDATED,this.onWorldNameUpdated);
      }
      
      protected function get displayObject() : MovieClip
      {
         return null;
      }
      
      public function get uiWidth() : Number
      {
         return this.displayObject.bg_mc.width;
      }
      
      protected function updateWorldName(param1:String) : void
      {
         if(null == param1)
         {
            param1 = Player.GetWorldName(ZGlobal.hostPlayer.firstName,ZGlobal.hostPlayer.snUser.gender);
         }
         var _loc2_:int = ZGlobal.gameSettings.getInt("maxWorldNameLength");
         if(param1.length > _loc2_)
         {
            param1 = param1.substr(0,_loc2_);
         }
         TextFieldUtil.processSingleLineTextField(this.displayObject.title_mc,param1,10);
         this.updateTabWidth(this.displayObject.title_mc.textWidth);
         this.displayObject.title_mc.mouseEnabled = true;
      }
      
      protected function updateTabWidth(param1:Number = 0) : void
      {
         param1 += TAB_MARGIN;
         param1 = Math.min(TAB_MAX_WIDTH,Math.max(TAB_MIN_WIDTH,param1));
         this.displayObject.dtab_mc.mcap_mc.width = param1;
         this.displayObject.dtab_mc.rcap_mc.x = this.displayObject.dtab_mc.mcap_mc.x + this.displayObject.dtab_mc.mcap_mc.width;
         this.displayObject.messageTab_mc.x = this.displayObject.dtab_mc.x + this.displayObject.dtab_mc.width;
         this.m_messageTab.setMaxWidth(this.uiWidth - this.displayObject.dtab_mc.width - 175);
         if(this.viralNotificationContainer)
         {
            this.viralNotificationContainer.x = this.displayObject.messageTab_mc.x;
         }
      }
      
      protected function onNeighborsLoaded(param1:NeighborsEvent) : void
      {
         NeighborsDispatcher.instance.removeEventListener(NeighborsEvent.NEIGHBORS_LOADED,this.onNeighborsLoaded);
         this.updateWorldName(ZGlobal.player.worldName);
      }
      
      private function onWorldNameUpdated(param1:WorldEvent) : void
      {
         this.updateWorldName(param1.eventData.name);
      }
      
      private function onPlayerNameLoaded(param1:WorldEvent) : void
      {
         this.updateWorldName(param1.eventData as String);
      }
      
      protected function activateFlag() : void
      {
         if(Boolean(this.displayObject.flag) && !this.displayObject.flag.useHandCursor)
         {
            this.displayObject.flag.filters = [ZGameUtils.HighlightFilter];
            this.displayObject.flag.buttonMode = true;
            this.displayObject.flag.useHandCursor = true;
            ButtonSound.getButtonSound(ButtonSound.DEFAULT).play(ButtonSound.ON_ROLLOVER);
            Tooltip.show(this.flagText,null,this.displayObject.flag);
         }
      }
      
      protected function get tabSubtitleNumerator() : int
      {
         return 0;
      }
      
      protected function get tabSubtitleDenominator() : int
      {
         return 0;
      }
      
      protected function updateTabSubtitleDigits() : void
      {
         var _loc1_:int = this.tabSubtitleNumerator;
         var _loc2_:int = this.tabSubtitleDenominator;
         var _loc3_:String = _loc1_ + "/" + _loc2_;
         TextFieldUtil.processSingleLineTextField(this.displayObject.count_tf,_loc3_);
         this.setPopulationCountOffset();
      }
      
      protected function onFlagClick(param1:MouseEvent) : void
      {
         ButtonSound.getButtonSound(ButtonSound.DEFAULT).play(ButtonSound.ON_CLICK);
      }
      
      protected function onFlagMove(param1:MouseEvent) : void
      {
      }
      
      protected function get flagText() : String
      {
         return "";
      }
      
      protected function onFlagOut(param1:MouseEvent) : void
      {
         this.displayObject.flag.filters = [];
         this.displayObject.flag.buttonMode = false;
         this.displayObject.flag.useHandCursor = false;
         if(Tooltip.isCurrDisplayObject(this.displayObject.flag))
         {
            Tooltip.hide();
         }
      }
      
      protected function setPopulationCountOffset() : void
      {
         var _loc1_:Number = Number(this.displayObject.population_tf.x);
         var _loc2_:Number = Number(this.displayObject.population_tf.textWidth);
         this.displayObject.count_tf.x = _loc1_ + _loc2_ + POPULATION_TITLE_COUNT_SEPARATION;
      }
      
      protected function onUserGridScrolled(param1:FriendBarEvent) : void
      {
      }
      
      private function onNationNameOut(param1:MouseEvent) : void
      {
         if(ZGlobal.isHome())
         {
            this.displayObject.title_mc.filters = this.m_title_mc_filters;
         }
      }
      
      protected function get nationFilter() : GlowFilter
      {
         return ZGameUtils.HighlightFilter as GlowFilter;
      }
      
      private function onNationNameOver(param1:MouseEvent) : void
      {
         if(ZGlobal.isHome())
         {
            this.displayObject.title_mc.filters = [this.nationFilter];
            ButtonSound.getButtonSound(ButtonSound.DEFAULT).play(ButtonSound.ON_ROLLOVER);
         }
      }
      
      private function onNationNameClick(param1:MouseEvent) : void
      {
         if(ZGlobal.isHome())
         {
            if(TutorialManager.instance.completedTutorialStep("tut_step_placeFlagStart"))
            {
               ButtonSound.getButtonSound(ButtonSound.DEFAULT).play(ButtonSound.ON_CLICK);
               ViralsManager.instance.onNewNationDialog();
            }
         }
      }
      
      public function get viralNotificationContainer() : MovieClip
      {
         return this.displayObject.viralNotificationHolder_mc;
      }
      
      protected function onAllianceClick(param1:Event) : void
      {
      }
      
      protected function onAllianceOut(param1:MouseEvent) : void
      {
         this.displayObject.shield_bt.filters = [];
         this.displayObject.shield_bt.buttonMode = false;
         this.displayObject.shield_bt.useHandCursor = false;
         if(Tooltip.isCurrDisplayObject(this.displayObject.shield_bt))
         {
            Tooltip.hide();
         }
      }
      
      protected function onAllianceMove(param1:MouseEvent) : void
      {
      }
   }
}

