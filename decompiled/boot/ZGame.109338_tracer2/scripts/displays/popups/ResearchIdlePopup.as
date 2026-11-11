package displays.popups
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.WorldUpgradeManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.screens.researchScreens.ResearchUnitSelectionScreen;
   import displays.screens.researchScreens.UpgradesDisplay;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.events.GenericPopupEvent;
   
   public class ResearchIdlePopup extends GallantPopup
   {
      
      private static const MAX_SLOTS:uint = 3;
      
      private var m_callback:Function = null;
      
      private var m_acceptBtn:ZGameButton = null;
      
      private var m_delayedAccept:Boolean = false;
      
      private var m_imageLoaders:Array = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var m_cards:Array = null;
      
      private var m_units:Array = null;
      
      private var m_buttons:Array = null;
      
      private var m_upgradesDisplays:Array = null;
      
      private var m_armyBuilding:IEntity = null;
      
      private var m_airBuilding:IEntity = null;
      
      private var m_navyBuilding:IEntity = null;
      
      public function ResearchIdlePopup(param1:Function = null, param2:IEntity = null, param3:IEntity = null, param4:IEntity = null)
      {
         this.m_callback = param1;
         this.m_armyBuilding = param2;
         this.m_airBuilding = param3;
         this.m_navyBuilding = param4;
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_ResearchImprovement.swf"));
      }
      
      override protected function initializeScreen() : void
      {
         super.initializeScreen();
         this.m_imageLoaders = new Array();
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_cards = [m_window.energy_mc.card_mc_01,m_window.energy_mc.card_mc_02,m_window.energy_mc.card_mc_03];
         this.m_buttons = new Array();
         this.m_units = new Array();
         this.m_upgradesDisplays = new Array();
         TextFieldUtil.compactTextField(m_window.energy_mc.title_tf,ZGameUtils.ZlocT("Dialogs","ResearchIdlePopup_Title"));
         TextFieldUtil.compactTextField(m_window.energy_mc.popupBox_tf,ZGameUtils.ZlocT("Dialogs","ResearchIdlePopup_Text"));
         this.findSuggestedUnits();
         if(this.m_units.length > 0)
         {
            this.setupCards();
         }
         m_window.energy_mc.exit_bt.addEventListener(MouseEvent.CLICK,this.onExitButton,false,0,true);
         this.m_buttonSounds.addButton(m_window.energy_mc.exit_bt,ButtonSound.DEFAULT);
         if(this.m_callback != null)
         {
            addEventListener(GenericPopupEvent.SELECTED,this.m_callback,false,0,true);
         }
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:ImageLoader = null;
         var _loc2_:ZGameButton = null;
         for each(_loc1_ in this.m_imageLoaders)
         {
            if(_loc1_)
            {
               _loc1_.destroy();
            }
         }
         this.m_imageLoaders = null;
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         if(this.m_buttons)
         {
            for each(_loc2_ in this.m_buttons)
            {
               _loc2_.dispose();
            }
            this.m_buttons = null;
         }
         m_window.energy_mc.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExitButton);
         super.deinitDialog();
      }
      
      private function getNormalUnresearchedUnits(param1:String) : Array
      {
         var _loc3_:Array = null;
         var _loc4_:XML = null;
         var _loc5_:UnitItem = null;
         var _loc6_:Boolean = false;
         var _loc7_:int = 0;
         var _loc2_:Array = new Array();
         if(this.m_units.length < MAX_SLOTS)
         {
            _loc3_ = ZGlobal.gameSettings.getArrayOfItemXMLByType("Buildable",param1);
            for each(_loc4_ in _loc3_)
            {
               _loc5_ = ZGlobal.gameSettings.getItemByCode(_loc4_.@code,UnitItem) as UnitItem;
               _loc6_ = false;
               _loc7_ = 0;
               while(_loc7_ < this.m_units.length)
               {
                  if(_loc5_.code == this.m_units[_loc7_].code)
                  {
                     _loc6_ = true;
                     break;
                  }
                  _loc7_++;
               }
               if(!_loc6_)
               {
                  if(ZGlobal.player.canResearchUnit(_loc5_))
                  {
                     _loc2_.push(_loc5_);
                  }
               }
            }
         }
         return _loc2_;
      }
      
      private function pickUnits(param1:Array, param2:Array, param3:Array) : void
      {
         var _loc4_:uint = this.m_units.length;
         var _loc5_:int = 0;
         while(_loc5_ < MAX_SLOTS)
         {
            if(Boolean(param1 && param1.length > 0 && param1[_loc5_]) && Boolean(this.m_armyBuilding != null) && this.m_units.length < MAX_SLOTS)
            {
               this.m_units[_loc4_] = param1[_loc5_];
               _loc4_++;
            }
            if(Boolean(param2 && param2.length > 0 && param2[_loc5_]) && Boolean(this.m_airBuilding != null) && this.m_units.length < MAX_SLOTS)
            {
               this.m_units[_loc4_] = param2[_loc5_];
               _loc4_++;
            }
            if(Boolean(param3 && param3.length > 0 && param3[_loc5_]) && Boolean(this.m_navyBuilding != null) && this.m_units.length < MAX_SLOTS)
            {
               this.m_units[_loc4_] = param3[_loc5_];
               _loc4_++;
            }
            _loc5_++;
         }
      }
      
      private function findSuggestedUnits() : void
      {
         var _loc1_:Array = _loc1_ = ZGlobal.player.getUnlockedUnitsOfType("army");
         var _loc2_:Array = ZGlobal.player.getUnlockedUnitsOfType("air");
         var _loc3_:Array = ZGlobal.player.getUnlockedUnitsOfType("navy");
         this.pickUnits(_loc1_,_loc2_,_loc3_);
         if(this.m_armyBuilding != null && this.m_units.length < MAX_SLOTS)
         {
            _loc1_ = this.getNormalUnresearchedUnits("army");
            _loc1_.sort(this.sortUnits);
         }
         if(this.m_airBuilding != null && this.m_units.length < MAX_SLOTS)
         {
            _loc2_ = this.getNormalUnresearchedUnits("air");
            _loc2_.sort(this.sortUnits);
         }
         if(this.m_navyBuilding != null && this.m_units.length < MAX_SLOTS)
         {
            _loc3_ = this.getNormalUnresearchedUnits("navy");
            _loc3_.sort(this.sortUnits);
         }
         this.pickUnits(_loc1_,_loc2_,_loc3_);
      }
      
      protected function sortUnits(param1:GameItem, param2:GameItem) : int
      {
         var _loc3_:int = ZGameUtils.sortLE(param1,param2);
         if(_loc3_ == 0)
         {
            _loc3_ = ZGameUtils.sortStrongest(param1,param2);
         }
         return _loc3_;
      }
      
      private function setupCards() : void
      {
         var _loc1_:int = 0;
         var _loc2_:UnitItem = null;
         if(this.m_units.length >= MAX_SLOTS)
         {
            _loc1_ = 0;
            while(_loc1_ < MAX_SLOTS)
            {
               this.fillCard(_loc1_);
               _loc1_++;
            }
         }
         else
         {
            this.m_cards[0].visible = false;
            this.m_cards[2].visible = false;
            if(this.m_units.length == 1)
            {
               this.m_units[1] = this.m_units[0];
            }
            if(this.m_units.length > 1)
            {
               if(int(this.m_units[0].xml.unit.@strength) > int(this.m_units[1].xml.unit.@strength))
               {
                  _loc2_ = this.m_units[1];
                  this.m_units[1] = this.m_units[0];
                  this.m_units[0] = _loc2_;
               }
            }
            this.fillCard(1);
         }
      }
      
      private function fillCard(param1:int) : void
      {
         TextFieldUtil.compactTextField(this.m_cards[param1].itemName_tf,this.m_units[param1].getFriendlyName(GameItem.MENU_FRIENDLYNAME),{
            "minScale":0.65,
            "fontSize":14
         });
         this.m_cards[param1].itemName_tf.mouseEnabled = false;
         this.m_imageLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(this.m_units[param1].name,"icon"),this.m_cards[param1].icon));
         var _loc2_:ZGameButton = new ZGameButton(this.m_cards[param1].ok_bt,this.onResearchButton);
         _loc2_.text = ZGameUtils.ZlocT("Dialogs","ResearchIdleButton");
         _loc2_.addTooltip(ZGameUtils.ZlocT("Dialogs","ResearchIdleButtonTooltip"));
         this.m_buttons.push(_loc2_);
         this.m_buttonSounds.addButton(_loc2_.m_overlay,ButtonSound.DEFAULT);
         this.m_cards[param1].research_bt.visible = false;
         var _loc3_:Array = [this.m_cards[param1].upgrades_mc.icon0,this.m_cards[param1].upgrades_mc.icon1,this.m_cards[param1].upgrades_mc.icon2,this.m_cards[param1].upgrades_mc.icon3,this.m_cards[param1].upgrades_mc.icon4];
         this.m_upgradesDisplays[param1] = new UpgradesDisplay(_loc3_,this.m_cards[param1].upgrades_mc,this.m_cards[param1].tooltip,this.m_cards[param1].upgrades_mc.parent,this.m_units[param1],WorldUpgradeManager.instance.getUpgradesByCode(this.m_units[param1].code));
         TextFieldUtil.compactTextField(this.m_cards[param1].generic_tf,ZGameUtils.ZlocT("Tooltips","Upgrades"));
         if(!ZGameTimeUtil.instance.isLimitedEdition(this.m_units[param1].xml))
         {
            this.m_cards[param1].sunburst_mc.visible = false;
         }
         this.m_cards[param1].visible = true;
         this.m_cards[param1].underlay_mc.visible = false;
         this.m_cards[param1].cost_tf.visible = false;
      }
      
      private function onResearchButton(param1:MouseEvent) : void
      {
         var _loc4_:EventDispatcher = null;
         var _loc2_:int = -1;
         if(param1.target.parent.name == "card_mc_01")
         {
            _loc2_ = 0;
         }
         else if(param1.target.parent.name == "card_mc_02")
         {
            _loc2_ = 1;
         }
         else if(param1.target.parent.name == "card_mc_03")
         {
            _loc2_ = 2;
         }
         if(_loc2_ == -1)
         {
            return;
         }
         var _loc3_:IEntity = null;
         if(this.m_units[_loc2_].subType == "army")
         {
            _loc3_ = this.m_armyBuilding;
         }
         else if(this.m_units[_loc2_].subType == "air")
         {
            _loc3_ = this.m_airBuilding;
         }
         else if(this.m_units[_loc2_].subType == "navy")
         {
            _loc3_ = this.m_navyBuilding;
         }
         if(_loc3_ != null)
         {
            _loc4_ = new EventDispatcher();
            ResearchUnitSelectionScreen.display(_loc4_,this.m_units[_loc2_].subType,_loc3_,this.m_units[_loc2_],false,false);
         }
         this.close();
      }
      
      override protected function close(param1:Event = null) : void
      {
         super.close(param1);
      }
      
      private function onAcceptButton(param1:MouseEvent) : void
      {
         if(this.m_callback != null)
         {
            this.m_callback(true);
         }
         this.close();
      }
      
      private function onExitButton(param1:MouseEvent = null) : void
      {
         if(this.m_callback != null)
         {
            this.m_callback(false);
         }
         this.close();
      }
   }
}

