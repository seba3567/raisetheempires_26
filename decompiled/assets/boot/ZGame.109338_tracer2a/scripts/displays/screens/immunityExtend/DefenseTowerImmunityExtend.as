package displays.screens.immunityExtend
{
   import core.ZGameStats;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.viralsManager.ViralsManager;
   import core.player.Player;
   import core.ui.ZGameButton;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import entity.GameDataComponent;
   import events.CloseEvent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.entity.IEntity;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class DefenseTowerImmunityExtend extends ImmunityExtend
   {
      
      public static const DEFENSE_TIME_CHANGED:String = "defenseTimeChanged";
      
      public static const USE_ITEM:String = "useItem";
      
      public static const BUY_ITEM:String = "buyItem";
      
      private var m_expTS:Number = 0;
      
      private var m_entity:IEntity = null;
      
      private var m_buildingIconLoader:ImageLoader = null;
      
      private var m_askBtn:ZGameButton = null;
      
      private var m_slotsInUse:Number = 0;
      
      private var m_entityItem:GameItem = null;
      
      private var m_extensionItem:GameItem = null;
      
      private var m_extensionItemSeconds:Number = 0;
      
      public function DefenseTowerImmunityExtend(param1:Number, param2:IEntity)
      {
         this.m_expTS = param1;
         this.m_entity = param2;
         var _loc3_:GameDataComponent = this.m_entity.lookupComponentByType(GameDataComponent) as GameDataComponent;
         if(_loc3_)
         {
            this.m_entityItem = _loc3_.gameData;
            this.m_extensionItem = ZGlobal.gameSettings.getItemByCode(this.m_entityItem.extensionTimeItem(),GameItem) as GameItem;
            this.m_extensionItemSeconds = this.m_extensionItem.extensionTimeSeconds();
         }
         super("assets/displays/dialogs/PU_DefenseTower.swf");
         ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_GENERIC_DIALOG_ACTION,{
            "counter":"dialog",
            "kingdom":"defense_tower_activate",
            "phylum":"view"
         }));
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         this.m_askBtn = new ZGameButton(m_mc.ask_bt,this.onAskFriends);
         this.m_askBtn.text = ZGameUtils.ZlocT("Dialogs","DefenseTowerAskButtonText");
         m_buttonSounds.addButton(this.m_askBtn.m_overlay,ButtonSound.DEFAULT);
         this.updateClock();
      }
      
      override protected function addDialogTextAndImages() : void
      {
         if(this.m_entityItem != null)
         {
            TextFieldUtil.processTextField(m_mc.title_tf,this.m_entityItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
            this.m_buildingIconLoader = ImageLoaderFactory.CreateImageLoader(this.m_entityItem.getCachedImage("icon").url,m_mc.icon);
            this.m_buildingIconLoader.smooth = true;
         }
         TextFieldUtil.processTextField(m_mc.title_tf2,ZGameUtils.ZlocT("Dialogs","DefenseTowerActiveDescription",{"num":this.m_extensionItemSeconds / (60 * 60)}));
         TextFieldUtil.processTextField(m_mc.title01_tf,ZGameUtils.ZlocT("Dialogs","DefenseTowerTimer"));
      }
      
      override protected function addEventListeners() : void
      {
         UIDispatcher.instance.addEventListener(Player.INVENTORY_UPDATED,this.onInventoryUpdated,false,0,true);
         this.m_entity.eventDispatcher.addEventListener(DEFENSE_TIME_CHANGED,this.onTimeChanged,false,0,true);
      }
      
      override protected function removeEventListeners() : void
      {
         UIDispatcher.instance.removeEventListener(Player.INVENTORY_UPDATED,this.onInventoryUpdated);
         this.m_entity.eventDispatcher.removeEventListener(DEFENSE_TIME_CHANGED,this.onTimeChanged);
         Zlab.processManager.removeScheduledObject(this);
      }
      
      override protected function createCards() : void
      {
         var _loc1_:MovieClip = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:MovieClip = null;
         var _loc8_:String = null;
         var _loc9_:ZGameButton = null;
         var _loc10_:ZGameButton = null;
         var _loc11_:MovieClip = null;
         var _loc12_:Number = NaN;
         var _loc13_:String = null;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:int = 0;
         var _loc17_:String = null;
         var _loc2_:Number = this.m_expTS - GlobalEngine.serverTime / 1000;
         var _loc3_:Number = _loc2_ <= 0 || this.m_extensionItemSeconds == 0 ? 0 : _loc2_ / this.m_extensionItemSeconds;
         this.m_slotsInUse = Math.ceil(_loc3_);
         var _loc4_:* = int(this.m_entityItem.extensionTimeSlots() - 1);
         while(_loc4_ >= 0)
         {
            _loc5_ = this.m_entityItem.extensionTimeSlots() % 2 == 0 ? "_even" : "_odd";
            _loc6_ = "anchor" + _loc4_ + _loc5_;
            _loc7_ = m_mc[_loc6_];
            _loc9_ = null;
            _loc10_ = null;
            _loc1_ = new m_smallCardClass();
            _loc11_ = _loc1_.bkg_can;
            _loc12_ = Number(_loc11_.maskAnim_mc.height);
            if(_loc4_ < this.m_slotsInUse)
            {
               if(_loc4_ == 0)
               {
                  _loc14_ = _loc3_ == 1 ? _loc2_ : _loc2_ - Math.floor(_loc3_) * this.m_extensionItemSeconds;
                  _loc15_ = _loc14_ / this.m_extensionItemSeconds;
                  _loc11_.maskAnim_mc.y = (_loc12_ - 20) * (1 - _loc15_);
               }
               else
               {
                  _loc11_.maskAnim_mc.y = 0;
               }
               _loc8_ = _loc4_ == 0 ? "PVPImmunityDefendingTitle" : "PVPImmunityReadyTitle";
            }
            else
            {
               _loc11_.maskAnim_mc.y = _loc12_;
               _loc8_ = "PVPImmunityAddTitle";
            }
            _loc11_.info_tf.visible = false;
            if(_loc4_ == this.m_slotsInUse)
            {
               _loc9_ = new ZGameButton(_loc1_.buy_bt,this.onBuyClicked);
               _loc9_.text = String(this.m_extensionItem.cash);
               m_buttonSounds.addButton(_loc9_.m_overlay,ButtonSound.DEFAULT);
               if(ZGlobal.player.getNumberOfInventoryItems(this.m_extensionItem.code))
               {
                  _loc10_ = new ZGameButton(_loc1_.hire_bt,this.onHireClicked);
                  _loc10_.text = ZGameUtils.ZlocT("Dialogs","Use");
                  m_buttonSounds.addButton(_loc10_.m_overlay,ButtonSound.DEFAULT);
               }
               else
               {
                  _loc1_.hire_bt.visible = false;
               }
            }
            else
            {
               _loc1_.buy_bt.visible = false;
               _loc1_.hire_bt.visible = false;
            }
            if(_loc4_ < this.m_slotsInUse)
            {
               m_imageLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(this.m_extensionItem.name,"icon"),_loc1_.player_01.icon));
               TextFieldUtil.processTextField(_loc1_.player_01.name_tf,this.m_extensionItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
               _loc1_.player_01.name_tf.visible = true;
            }
            else
            {
               _loc1_.player_01.name_tf.visible = false;
            }
            if(_loc11_.time_tf)
            {
               _loc16_ = this.m_extensionItemSeconds / (60 * 60);
               _loc17_ = ZGameUtils.ZlocT("Dialogs","PVPImmunitySlotDuration",{"hours":_loc16_});
               TextFieldUtil.processTextField(_loc11_.time_tf,_loc17_);
            }
            _loc13_ = ZGameUtils.ZlocT("Dialogs",_loc8_);
            TextFieldUtil.processTextField(_loc11_.title_tf,_loc13_);
            m_mc.addChild(_loc1_);
            _loc1_.x = _loc7_.x;
            _loc1_.y = _loc7_.y;
            m_cards.push({
               "mc":_loc1_,
               "buyButton":_loc9_,
               "hireButton":_loc10_
            });
            _loc4_--;
         }
      }
      
      override protected function onBuyClicked(param1:Event) : void
      {
         var _loc3_:String = null;
         var _loc4_:Object = null;
         var _loc5_:String = null;
         var _loc6_:GenericPopup2B = null;
         var _loc2_:int = this.m_extensionItem.cash;
         if(ZGlobal.player.canBuyCash(_loc2_,true))
         {
            if(ZGlobal.gameSettings.showConfirmationPopup(_loc2_))
            {
               _loc3_ = ZGameUtils.ZlocT("Dialogs","BuildingPartConfirmPartBuyTitle");
               _loc4_ = ZGameUtils.CashTokenReplacements(_loc2_);
               _loc4_.item = this.m_extensionItem.getSentenceNameLocalizationObject("singular,indefinite",true);
               _loc5_ = ZGameUtils.ZlocT("Dialogs","BuildingPartConfirmPartBuyMessage",_loc4_);
               _loc6_ = GenericPopup2B.NewYesNo(_loc5_,_loc3_,this.buyPartConfirmed);
               PopupManager.instance.push(_loc6_);
            }
            else
            {
               this.buyPart(this.m_extensionItem);
            }
            ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_GENERIC_BUTTON_CLICKED,{
               "counter":"dialog",
               "kingdom":"defense_tower_activate",
               "phylum":"buy"
            }));
         }
      }
      
      override protected function onHireClicked(param1:Event) : void
      {
         if(ZGlobal.player.getNumberOfInventoryItems(this.m_extensionItem.code))
         {
            ZGlobal.player.removeInventoryItem(this.m_extensionItem.code);
            this.m_entity.eventDispatcher.dispatchEvent(new WorldEvent(USE_ITEM,this.m_extensionItem.code));
            ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_GENERIC_BUTTON_CLICKED,{
               "counter":"dialog",
               "kingdom":"defense_tower_activate",
               "phylum":"use"
            }));
         }
      }
      
      private function onAskFriends(param1:Event) : void
      {
         ViralsManager.instance.sendFeedWithLotsOfFriction("ask_for_parts_defense",{
            "itemCode":this.m_extensionItem.code,
            "buildingName":this.m_entityItem.name,
            "ITEMTOKOVERRIDEitem":this.m_extensionItem.name + "|"
         },null);
         ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_GENERIC_BUTTON_CLICKED,{
            "counter":"dialog",
            "kingdom":"defense_tower_activate",
            "phylum":"ask_for_parts"
         }));
      }
      
      override protected function deinitDialog() : void
      {
         if(this.m_buildingIconLoader)
         {
            this.m_buildingIconLoader.destroy();
         }
         if(this.m_askBtn)
         {
            m_buttonSounds.removeButton(this.m_askBtn.m_overlay);
            this.m_askBtn.dispose();
            this.m_askBtn = null;
         }
         super.deinitDialog();
      }
      
      override protected function onExitClicked(param1:MouseEvent) : void
      {
         super.onExitClicked(param1);
         this.m_entity.eventDispatcher.dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
         ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_GENERIC_DIALOG_ACTION,{
            "counter":"dialog",
            "kingdom":"defense_tower_activate",
            "phylum":"close"
         }));
      }
      
      protected function updateElements() : void
      {
         clearCards();
         this.createCards();
      }
      
      private function onInventoryUpdated(param1:WorldEvent) : void
      {
         this.updateElements();
      }
      
      private function buyPartConfirmed(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.YES)
         {
            this.buyPart(this.m_extensionItem);
         }
      }
      
      private function buyPart(param1:GameItem) : void
      {
         var _loc2_:Boolean = false;
         if(param1 != null)
         {
            _loc2_ = true;
            ZGlobal.player.buyItem(param1,_loc2_);
            this.m_entity.eventDispatcher.dispatchEvent(new WorldEvent(BUY_ITEM,this.m_extensionItem.code));
         }
      }
      
      private function onTimeChanged(param1:WorldEvent) : void
      {
         this.m_expTS = Number(param1.eventData);
         var _loc2_:Number = this.m_expTS - GlobalEngine.serverTime / 1000;
         this.m_slotsInUse = _loc2_ <= 0 ? 0 : Math.ceil(_loc2_ / this.m_extensionItemSeconds);
         this.updateElements();
         this.updateClock();
      }
      
      protected function updateClock() : void
      {
         var _loc2_:Object = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc1_:Object = new Object();
         Zlab.processManager.removeScheduledObject(this);
         if(this.m_expTS > GlobalEngine.serverTime / 1000)
         {
            _loc2_ = ZGameTimeUtil.instance.getTimeObject(this.m_expTS - GlobalEngine.serverTime / 1000);
            TextFieldUtil.processTextField(m_mc.clock_mc.num_tf0,String(_loc2_["days.10"]) + String(_loc2_["days.1"]));
            TextFieldUtil.processTextField(m_mc.clock_mc.num_tf1,String(_loc2_["hours.10"]) + String(_loc2_["hours.1"]));
            TextFieldUtil.processTextField(m_mc.clock_mc.num_tf3,String(_loc2_["minutes.10"]));
            TextFieldUtil.processTextField(m_mc.clock_mc.num_tf4,String(_loc2_["minutes.1"]));
            TextFieldUtil.processTextField(m_mc.clock_mc.num_tf5,String(_loc2_["seconds.10"]));
            TextFieldUtil.processTextField(m_mc.clock_mc.num_tf6,String(_loc2_["seconds.1"]));
            _loc3_ = this.m_expTS - GlobalEngine.serverTime / 1000;
            _loc4_ = _loc3_ <= 0 ? 0 : Math.ceil(_loc3_ / this.m_extensionItemSeconds);
            if(_loc4_ < this.m_slotsInUse)
            {
               this.updateElements();
            }
            Zlab.processManager.schedule(1000,this,this.updateClock);
         }
         else
         {
            _loc2_ = ZGameTimeUtil.instance.getTimeObject(0);
            TextFieldUtil.processTextField(m_mc.clock_mc.num_tf0,String(_loc2_["days.10"]) + String(_loc2_["days.1"]));
            TextFieldUtil.processTextField(m_mc.clock_mc.num_tf1,String(_loc2_["hours.10"]) + String(_loc2_["hours.1"]));
            TextFieldUtil.processTextField(m_mc.clock_mc.num_tf3,String(_loc2_["minutes.10"]));
            TextFieldUtil.processTextField(m_mc.clock_mc.num_tf4,String(_loc2_["minutes.1"]));
            TextFieldUtil.processTextField(m_mc.clock_mc.num_tf5,String(_loc2_["seconds.10"]));
            TextFieldUtil.processTextField(m_mc.clock_mc.num_tf6,String(_loc2_["seconds.1"]));
            this.updateElements();
         }
      }
   }
}

