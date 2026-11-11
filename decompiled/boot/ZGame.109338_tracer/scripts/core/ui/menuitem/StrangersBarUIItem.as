package core.ui.menuitem
{
   import core.ZGlobal;
   import core.managers.PVPManager;
   import core.player.Player;
   import core.ui.Tooltip;
   import dispatchers.UIDispatcher;
   import displays.popups.GenericPopup;
   import displays.popups.PVPSlotMachinePopup;
   import displays.screens.globalpvp.GlobalPVPInfoPopup;
   import displays.screens.neighborScreen.StrangerGrid;
   import events.FriendBarEvent;
   import events.RepositionEvent;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import flash.utils.Timer;
   import sound.SoundEvent;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zgame.assets.ui.StrangerBar.StrangerBarMenuWrapper;
   import zlabs.debug.Logger;
   import zlabs.displays.popups.IWindow;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   
   public class StrangersBarUIItem extends UsersBarUIItem
   {
      
      public static const ITEM_ID:String = "strangersBar";
      
      private static const STRANGERBAR_FADEIN_DURATION_MS:int = 1500;
      
      private static const STRANGERBAR_FADEOUT_DURATION_MS:int = 1333;
      
      private static const RESERVED_NON_NEIGHBORGRID_WIDTH:int = 300;
      
      private static const MAX_FRIENDBAR_WIDTH:int = 1000;
      
      private var m_strangerGrid:StrangerGrid;
      
      private var m_displayObject:MovieClip;
      
      private var m_messageTab:FriendsBarMessageTabUIItem = null;
      
      private var m_wrapper:StrangerBarMenuWrapper;
      
      private var m_strangers:Array;
      
      private var m_timer:Timer;
      
      private var m_slots:Array = [];
      
      private var m_originalWidth:Number = 0;
      
      private var m_cachedVisibleSlotIndex:int = 0;
      
      private var m_holdVisibleSlotIndex:Boolean;
      
      public function StrangersBarUIItem()
      {
         super(ITEM_ID);
         this.m_wrapper = new StrangerBarMenuWrapper();
         this.m_displayObject = this.m_wrapper.hud_mc;
         addChild(this.m_wrapper);
         this.m_timer = new Timer(1000);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.updateTimeDisplay,false,0,true);
         var _loc1_:Object = {"hours":PVPManager.globalPVPDurationHours};
         var _loc2_:String = ZGameUtils.ZlocT("Tooltips","GlobalPVPStrangerBarButtonNormal",_loc1_);
         TextFieldUtil.processTextField(this.m_displayObject.timer_tf,_loc2_);
         var _loc3_:String = ZGameUtils.ZlocT("Tooltips","GlobalPVPStrangerBarTimerTooltip",_loc1_);
         Tooltip.subscribe(this.m_displayObject.clock_mc.clockHover_mc,_loc3_);
         this.m_originalWidth = this.m_displayObject.width;
         this.hideUnusedElements();
         UIDispatcher.instance.addEventListener(RepositionEvent.REPOSITION_FRIENDBAR_RESIZE,this.onResize,false,0,true);
         UIDispatcher.instance.addEventListener(Player.INVENTORY_UPDATED,this.onInventoryUpdated,false,0,true);
         PVPManager.instance.addEventListener(PVPManager.GLOBALPVP_UI_STATECHANGE,this.onGlobalPVPUIStateChange,false,0,true);
         PVPManager.instance.addEventListener(PVPManager.GPVP_WINS_CHANGED,this.onGPVPWinsChanged,false,0,true);
         PVPManager.instance.addEventListener(PVPManager.FIGHT_LIST_CHANGED,this.onFightListChanged,false,0,true);
         this.tokenPlaqueMC.useHandCursor = true;
         this.tokenPlaqueMC.addEventListener(MouseEvent.CLICK,this.onTokenClick,false,0,true);
         this.tokenPlaqueMC.addEventListener(MouseEvent.ROLL_OVER,this.onTokenRollOver,false,0,true);
         this.tokenPlaqueMC.addEventListener(MouseEvent.ROLL_OUT,this.onTokenRollOut,false,0,true);
         this.m_displayObject.clock_mc.tokens_tf.mouseEnabled = false;
      }
      
      private function get tokenPlaqueMC() : MovieClip
      {
         return this.m_displayObject.clock_mc.tokenplaque_mc;
      }
      
      override protected function get displayObject() : MovieClip
      {
         return this.m_displayObject;
      }
      
      private function tryToCreateGrid() : void
      {
         this.m_strangers = PVPManager.instance.getSortedStrangerList();
         if(this.m_strangers.length)
         {
            this.holdVisibleSlotIndex = true;
            if(PVPManager.strangerBarType == PVPManager.STRANGERBAR_NORMAL)
            {
               if(this.m_strangers.length < PVPManager.globalPVPMaxProgress)
               {
                  this.m_strangers.unshift(StrangerGrid.STRANGERBAR_DUMMY_SLOT);
               }
            }
            Logger.print(this," showing stranger list: " + this.m_strangers.length);
            this.m_strangerGrid = new StrangerGrid(this.m_displayObject.grid_mc,this.m_strangers,this);
            this.m_strangerGrid.loadCardImages();
            this.m_strangerGrid.visible = true;
            this.holdVisibleSlotIndex = false;
         }
         else if(this.m_strangerGrid)
         {
            this.m_strangerGrid.visible = false;
         }
      }
      
      private function onGlobalPVPUIStateChange(param1:WorldEvent) : void
      {
         switch(param1.eventData.newState)
         {
            case PVPManager.GLOBALPVP_UI_FADEIN:
               SoundEvent.getSoundEvent("StrangerBarFadeIn").play();
               this.updateTokenCount();
               this.m_timer.start();
               this.updateTimeDisplay();
               break;
            case PVPManager.GLOBALPVP_UI_FADEOUT:
               SoundEvent.getSoundEvent("StrangerBarFadeOut").play();
               break;
            case PVPManager.GLOBALPVP_UI_NONE:
               this.m_timer.stop();
         }
      }
      
      private function disposeStrangerGrid() : void
      {
         if(this.m_strangerGrid)
         {
            this.m_strangerGrid.dispose();
            this.m_strangerGrid = null;
         }
      }
      
      private function onGPVPWinsChanged(param1:WorldEvent) : void
      {
         this.updateTabSubtitleDigits();
      }
      
      private function onFightListChanged(param1:WorldEvent) : void
      {
         this.disposeStrangerGrid();
         this.tryToCreateGrid();
         this.updateTabSubtitleDigits();
      }
      
      private function onTokenClick(param1:MouseEvent) : void
      {
         WindowManager.instance.push(new PVPSlotMachinePopup());
      }
      
      private function onTokenRollOver(param1:MouseEvent) : void
      {
         this.tokenPlaqueMC.filters = [ZGameUtils.HighlightFilter];
      }
      
      private function onTokenRollOut(param1:MouseEvent) : void
      {
         this.tokenPlaqueMC.filters = [];
      }
      
      private function updateTimeDisplay(param1:TimerEvent = null) : void
      {
         var _loc2_:Object = PVPManager.instance.getFightBatchRemainingTime();
         var _loc3_:int = int(_loc2_.remaining);
         var _loc4_:Object = ZGameTimeUtil.instance.getTimeObject(_loc3_);
         var _loc5_:String = String(_loc4_["days.10"]);
         var _loc6_:String = String(_loc4_["days.1"]);
         var _loc7_:String = String(_loc4_["hours.10"]);
         var _loc8_:String = String(_loc4_["hours.1"]);
         var _loc9_:String = String(_loc4_["minutes.10"]);
         var _loc10_:String = String(_loc4_["minutes.1"]);
         var _loc11_:String = String(_loc4_["seconds.10"]);
         var _loc12_:String = String(_loc4_["seconds.1"]);
         TextFieldUtil.processTextField(this.m_displayObject.clock_mc.num_tf1,_loc5_);
         TextFieldUtil.processTextField(this.m_displayObject.clock_mc.num_tf1_red,_loc5_);
         TextFieldUtil.processTextField(this.m_displayObject.clock_mc.num_tf2,_loc6_);
         TextFieldUtil.processTextField(this.m_displayObject.clock_mc.num_tf2_red,_loc6_);
         TextFieldUtil.processTextField(this.m_displayObject.clock_mc.num_tf3,_loc7_);
         TextFieldUtil.processTextField(this.m_displayObject.clock_mc.num_tf3_red,_loc7_);
         TextFieldUtil.processTextField(this.m_displayObject.clock_mc.num_tf4,_loc8_);
         TextFieldUtil.processTextField(this.m_displayObject.clock_mc.num_tf4_red,_loc8_);
         TextFieldUtil.processTextField(this.m_displayObject.clock_mc.num_tf5,_loc9_);
         TextFieldUtil.processTextField(this.m_displayObject.clock_mc.num_tf5_red,_loc9_);
         TextFieldUtil.processTextField(this.m_displayObject.clock_mc.num_tf6,_loc10_);
         TextFieldUtil.processTextField(this.m_displayObject.clock_mc.num_tf6_red,_loc10_);
         TextFieldUtil.processTextField(this.m_displayObject.clock_mc.num_tf7,_loc11_);
         TextFieldUtil.processTextField(this.m_displayObject.clock_mc.num_tf7_red,_loc11_);
         TextFieldUtil.processTextField(this.m_displayObject.clock_mc.num_tf8,_loc12_);
         TextFieldUtil.processTextField(this.m_displayObject.clock_mc.num_tf8_red,_loc12_);
         if(Boolean(_loc2_.success) && Boolean(!_loc3_) && PVPManager.instance.globalPVPUIState == PVPManager.GLOBALPVP_UI_ACTIVE)
         {
            PVPManager.instance.handleFightBatchExpired();
            this.disposeStrangerGrid();
            this.tryToCreateGrid();
         }
      }
      
      private function onInventoryUpdated(param1:WorldEvent) : void
      {
         this.updateTokenCount();
      }
      
      private function updateTokenCount() : void
      {
         var _loc1_:int = ZGlobal.player.getNumberOfInventoryItems("GPTK");
         TextFieldUtil.processTextField(this.m_displayObject.clock_mc.tokens_tf,String(_loc1_));
         this.updateTokenPlaqueTooltip(_loc1_);
      }
      
      private function onResize(param1:RepositionEvent) : void
      {
         var _loc2_:Number = NaN;
         _loc2_ = Math.min(param1.width,MAX_FRIENDBAR_WIDTH);
         this.x = Math.floor((param1.width - _loc2_) * 0.5);
         var _loc3_:int = int(this.m_displayObject.bg_mc.width);
         this.m_displayObject.bg_mc.width = _loc2_;
         this.m_displayObject.floatR_mc.x = _loc2_;
         var _loc4_:int = this.m_displayObject.bg_mc.width - _loc3_;
         this.m_displayObject.clock_mc.x += _loc4_;
         if(this.m_strangerGrid)
         {
            this.holdVisibleSlotIndex = true;
            this.m_strangerGrid.onResize();
            this.m_displayObject.grid_mc.x = Math.max(Math.round((_loc2_ - RESERVED_NON_NEIGHBORGRID_WIDTH - this.m_strangerGrid.uiWidth() - 4) * 0.5),0);
            this.holdVisibleSlotIndex = false;
         }
      }
      
      public function get neighbors() : Array
      {
         if(this.m_strangerGrid != null)
         {
            return this.m_strangerGrid.neighbors;
         }
         return new Array();
      }
      
      public function get originalWidth() : Number
      {
         return this.m_originalWidth;
      }
      
      public function get uiHeight() : Number
      {
         return this.m_displayObject.bg_mc.height;
      }
      
      public function get neighborGridWidth() : Number
      {
         return this.m_displayObject.bg_mc.width - RESERVED_NON_NEIGHBORGRID_WIDTH;
      }
      
      public function get strangerGrid() : StrangerGrid
      {
         return this.m_strangerGrid;
      }
      
      public function doFadeIn() : int
      {
         this.m_wrapper.gotoAndPlay("_show");
         return STRANGERBAR_FADEIN_DURATION_MS;
      }
      
      public function doFadeOut() : int
      {
         this.m_wrapper.gotoAndPlay("_hide");
         return STRANGERBAR_FADEOUT_DURATION_MS;
      }
      
      override public function removeItem() : void
      {
         UIDispatcher.instance.removeEventListener(RepositionEvent.REPOSITION_FRIENDBAR_RESIZE,this.onResize);
         UIDispatcher.instance.removeEventListener(Player.INVENTORY_UPDATED,this.onInventoryUpdated);
         PVPManager.instance.removeEventListener(PVPManager.GLOBALPVP_UI_STATECHANGE,this.onGlobalPVPUIStateChange);
         PVPManager.instance.removeEventListener(PVPManager.GPVP_WINS_CHANGED,this.onGPVPWinsChanged);
         PVPManager.instance.removeEventListener(PVPManager.FIGHT_LIST_CHANGED,this.onFightListChanged);
         this.m_displayObject.clock_mc.tokenplaque_mc.removeEventListener(MouseEvent.CLICK,this.onTokenClick);
         this.m_timer.removeEventListener(TimerEvent.TIMER,this.updateTimeDisplay);
         this.m_timer = null;
         this.m_displayObject.parent.removeChild(this.m_displayObject);
         this.m_displayObject = null;
         this.m_wrapper = null;
         super.removeItem();
      }
      
      override protected function onFlagMove(param1:MouseEvent) : void
      {
         activateFlag();
      }
      
      override protected function get flagText() : String
      {
         return ZGameUtils.ZlocT("Tooltips","GlobalPVPStrangerBarOptOutButton");
      }
      
      private function onClose(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.YES && PVPManager.instance.globalPVPOptedIn)
         {
            PVPManager.instance.optInOut(false);
            PVPManager.instance.hideGlobalPVPBar();
         }
      }
      
      override protected function onFlagClick(param1:MouseEvent) : void
      {
         var _loc2_:IWindow = null;
         super.onFlagClick(param1);
         if(PVPManager.instance.globalPVPOptedIn)
         {
            _loc2_ = new GlobalPVPInfoPopup(GlobalPVPInfoPopup.MODE_OPTOUT);
            PopupManager.instance.push(_loc2_);
         }
      }
      
      private function hideUnusedElements() : void
      {
         this.m_displayObject.grid_mc.slot_0.visible = false;
         this.m_displayObject.grid_mc.mask_mc.visible = false;
      }
      
      override protected function onUserGridScrolled(param1:FriendBarEvent) : void
      {
         if(this.strangerGrid)
         {
            this.strangerGrid.loadCardImages();
         }
      }
      
      private function updateTokenPlaqueTooltip(param1:int) : void
      {
         var _loc2_:Object = {"hours":PVPManager.globalPVPDurationHours};
         var _loc3_:String = ZGameUtils.ZlocT("Tooltips","GlobalPVPStrangerBarTokenTooltip",_loc2_);
         if(_loc3_)
         {
            Tooltip.subscribe(this.m_displayObject.clock_mc.tokenplaque_mc,_loc3_);
         }
      }
      
      private function set holdVisibleSlotIndex(param1:Boolean) : void
      {
         this.m_holdVisibleSlotIndex = param1;
         if(Boolean(!this.m_holdVisibleSlotIndex) && Boolean(this.m_cachedVisibleSlotIndex) && Boolean(this.m_strangerGrid))
         {
            this.m_strangerGrid.makeSlotsVisible(this.m_cachedVisibleSlotIndex);
            this.m_cachedVisibleSlotIndex = 0;
         }
      }
      
      public function makeSlotsVisible(param1:int) : void
      {
         if(Boolean(this.strangerGrid) && !this.m_holdVisibleSlotIndex)
         {
            this.strangerGrid.makeSlotsVisible(param1);
         }
         else
         {
            this.m_cachedVisibleSlotIndex = param1;
         }
      }
      
      override protected function get localizedTabSubtitleLabel() : String
      {
         return ZGameUtils.ZlocT("Main","WinCount");
      }
      
      private function get currentProgress() : int
      {
         return int(Math.max(0,PVPManager.instance.globalPVPWinProgress));
      }
      
      override protected function updateTabSubtitleDigits() : void
      {
         var _loc1_:int = this.currentProgress;
         var _loc2_:int = PVPManager.globalPVPMaxProgress;
         var _loc3_:String = _loc1_ + "/" + _loc2_;
         TextFieldUtil.processSingleLineTextField(this.displayObject.clock_mc.count_tf,_loc3_);
         this.populationTF.x = this.displayObject.clock_mc.count_tf.x - this.populationTF.width;
      }
      
      override protected function updateTabWidth(param1:Number = 0) : void
      {
      }
      
      override protected function get nationFilter() : GlowFilter
      {
         return ZGameUtils.RedHighlighFilter as GlowFilter;
      }
      
      override protected function get populationTF() : TextField
      {
         return this.displayObject.clock_mc.population_tf;
      }
   }
}

