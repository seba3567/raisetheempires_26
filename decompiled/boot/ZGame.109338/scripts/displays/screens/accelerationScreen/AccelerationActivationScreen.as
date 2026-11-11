package displays.screens.accelerationScreen
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.WorldResourceManager;
   import core.resource.WorldResource;
   import core.ui.Style;
   import core.ui.UIManager;
   import core.ui.ZGameButton;
   import core.ui.menuitem.PlayerStatsUIItem;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GenericCountdownClock;
   import displays.popups.buyEnergy.BuyEnergyPopup;
   import displays.popups.zgamepopup.ZGamePopUp;
   import entity.GameDataComponent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.displays.popups.PopUpBase;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class AccelerationActivationScreen extends ZGamePopUp
   {
      
      public static const SHOW_ONLY_IF_OWNED:String = "onlyIfOwned";
      
      public static const ACTIVATION:String = "activation";
      
      public static const EXIT:String = "exit";
      
      public static const SHOW_SPEEDUP_SCREEN:String = "show_speedup_screen";
      
      private static const ID:String = "ResearchUnitSelectionScreen";
      
      public static const RECENT_PLAYERS_RECEIVED:String = "recentPlayersReceived";
      
      protected var m_type:String = "Buildable";
      
      private var m_itemCode:String = null;
      
      protected var m_entity:IEntity = null;
      
      protected var m_eventDispatcher:EventDispatcher = null;
      
      protected var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      protected var m_buildingIconLoader:ImageLoader = null;
      
      protected var m_active:Boolean;
      
      protected var m_duration:Number;
      
      protected var m_state:String;
      
      protected var ActivateButton:ZGameButton;
      
      public function AccelerationActivationScreen(param1:EventDispatcher, param2:String, param3:IEntity, param4:Number, param5:Boolean, param6:String)
      {
         this.m_itemCode = param2;
         this.m_eventDispatcher = param1;
         this.m_entity = param3;
         this.m_active = param5;
         this.m_duration = param4;
         this.m_state = param6;
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_AcceleratorActivate.swf"));
      }
      
      public static function display(param1:EventDispatcher, param2:String, param3:IEntity, param4:Number, param5:Boolean, param6:String) : PopUpBase
      {
         var _loc7_:PopUpBase = new AccelerationActivationScreen(param1,param2,param3,param4,param5,param6);
         WindowManager.instance.push(_loc7_);
         return _loc7_;
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         var _loc3_:WorldResource = null;
         var _loc4_:Boolean = false;
         var _loc5_:String = null;
         var _loc6_:Object = null;
         var _loc7_:TextField = null;
         var _loc8_:TextFormat = null;
         var _loc9_:String = null;
         var _loc10_:Boolean = false;
         var _loc11_:TextField = null;
         var _loc12_:TextFormat = null;
         var _loc13_:GenericCountdownClock = null;
         m_window = param1["clip"];
         m_window["screen_mc"].exit_bt.addEventListener(MouseEvent.CLICK,this.onExitClicked,false,0,true);
         var _loc2_:GameDataComponent = GameDataComponent(this.m_entity.lookupComponentByType(GameDataComponent));
         if(_loc2_)
         {
            TextFieldUtil.compactTextField(m_window["screen_mc"].title_tf,_loc2_.gameData.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
            TextFieldUtil.compactTextField(m_window["screen_mc"].description_tf_0,ZGameUtils.ZlocT("Dialogs","AccelerationCenterDesc0"));
            TextFieldUtil.compactTextField(m_window["screen_mc"].description_tf_1,ZGameUtils.ZlocT("Dialogs","AccelerationCenterDesc1"));
            TextFieldUtil.compactTextField(m_window["screen_mc"].description_tf_2,ZGameUtils.ZlocT("Dialogs","AccelerationCenterDesc2"));
            TextFieldUtil.compactTextField(m_window["screen_mc"].red_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","AccelerationCenterButton"));
            _loc3_ = WorldResourceManager.instance.createResource("oil",-50);
            _loc4_ = ZGlobal.player.hasResource(_loc3_);
            _loc5_ = WorldResourceManager.instance.getResourceImageURLByType(_loc3_.type,WorldResourceManager.LARGE_ICON);
            ImageLoaderFactory.CreateImageLoader(_loc5_,m_window["screen_mc"].icon0);
            _loc6_ = {"minScale":0.6};
            _loc7_ = m_window["screen_mc"].value_tf_0;
            TextFieldUtil.compactTextField(_loc7_,ZGameUtils.ZlocT("Dialogs","AccelerationCenter_Value1",{"value":50}),_loc6_);
            _loc8_ = _loc7_.getTextFormat();
            _loc8_.color = _loc4_ ? _loc8_.color : Style.COLOR_UNSUFFICIENT_RESOURCES;
            _loc9_ = ZGlobal.getAssetURL("assets/game/contracts/Contracts_Icons_0.swf/EnergyBattery07_96.png");
            ImageLoaderFactory.CreateImageLoader(_loc9_,m_window["screen_mc"].icon1);
            _loc10_ = ZGlobal.player.m_energy.checkEnergy(20,true);
            _loc11_ = m_window["screen_mc"].value_tf_1;
            TextFieldUtil.compactTextField(_loc11_,ZGameUtils.ZlocT("Dialogs","AccelerationCenter_Value2",{"value":20}),_loc6_);
            _loc12_ = _loc11_.getTextFormat();
            _loc12_.color = _loc10_ ? _loc12_.color : Style.COLOR_UNSUFFICIENT_RESOURCES;
            this.ActivateButton = new ZGameButton(m_window["screen_mc"].red_bt,this.onActivateClicked);
            this.ActivateButton.text = ZGameUtils.ZlocT("Dialogs","AccelerationCenterButton");
            if(this.m_active)
            {
               m_window["screen_mc"].red_bt.button_mc.glow_mc.generic_tf.getTextFormat().color = 8421504;
               m_window["screen_mc"].red_bt.generic_tf.getTextFormat().color = 8421504;
               this.ActivateButton.disableWithTooltip("Already Activated");
               this.ActivateButton.text = ZGameUtils.ZlocT("Dialogs","AccelerationCenterButton");
               if(this.m_state == "11")
               {
                  TextFieldUtil.compactTextField(m_window["screen_mc"].description_tf_1,ZGameUtils.ZlocT("Dialogs","AccelerationCenterDesc1_CoolDown"),{"minScale":1});
               }
               else if(this.m_state == "10")
               {
                  TextFieldUtil.compactTextField(m_window["screen_mc"].description_tf_1,ZGameUtils.ZlocT("Dialogs","AccelerationCenterDesc1_Active"),{"minScale":1});
               }
            }
            else
            {
               TextFieldUtil.compactTextField(m_window["screen_mc"].red_bt.button_mc.glow_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","AccelerationCenterButton"));
            }
            _loc13_ = new GenericCountdownClock(m_window["screen_mc"].clock_mc,this.m_duration / 1000,this.onUpdate);
         }
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_buttonSounds.addButton(m_window["screen_mc"].exit_bt,ButtonSound.DEFAULT);
         addChild(m_window);
         m_origOffsetX = m_window["screen_mc"].x;
         m_origOffsetY = m_window["screen_mc"].y;
         this.contentWidth = m_window["screen_mc"].width;
         this.contentHeight = m_window["screen_mc"].height;
         initDialog();
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).toggleRarePanel(true);
         dispatchEvent(new Event(Event.COMPLETE));
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).moveToNewLayer(WindowManager.instance.container,0);
      }
      
      protected function onExitClicked(param1:MouseEvent) : void
      {
         this.ActivateButton.dispose();
         this.close();
      }
      
      protected function onActivateClicked(param1:MouseEvent) : void
      {
         var _loc4_:WorldResource = null;
         var _loc5_:Boolean = false;
         var _loc6_:Boolean = false;
         var _loc7_:GameItem = null;
         if(!this.m_active)
         {
            _loc4_ = WorldResourceManager.instance.createResource("oil",-50);
            _loc5_ = ZGlobal.player.hasResource(_loc4_);
            _loc6_ = ZGlobal.player.m_energy.checkEnergy(20,true);
            if(!((_loc6_) && _loc5_))
            {
               if(!_loc6_)
               {
                  this.close();
                  BuyEnergyPopup.enableWatchToEarn();
                  BuyEnergyPopup.show();
                  return;
               }
               if(!_loc5_)
               {
                  this.close();
                  _loc7_ = ZGlobal.gameSettings.getItemByCode("DU01",GameItem) as GameItem;
                  ZGlobal.player.canBuy(_loc7_,true);
               }
               return;
            }
         }
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode(this.m_itemCode,GameItem) as GameItem;
         var _loc3_:Object = {"referenceItem":_loc2_};
         this.m_eventDispatcher.dispatchEvent(new WorldEvent(ACTIVATION,_loc3_));
         m_window["screen_mc"].red_bt.button_mc.gotoAndStop(4);
         this.ActivateButton.dispose();
         this.close();
      }
      
      override public function forceClose() : void
      {
         this.close();
      }
      
      override protected function close(param1:Event = null) : void
      {
         m_window["screen_mc"].exit_bt.removeEventListener(MouseEvent.CLICK,this.onExitClicked);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).toggleRarePanel(false);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).moveToNewLayer(UIManager.instance.uiDisplay,0);
         this.m_eventDispatcher.dispatchEvent(new Event(EXIT));
         super.close();
      }
      
      private function onUpdate() : void
      {
      }
   }
}

