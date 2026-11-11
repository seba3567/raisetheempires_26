package displays.popups
{
   import core.ZGlobal;
   import core.managers.BountyCenterManager;
   import core.ui.ZGameButton;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.resource.SWFResource;
   
   public class BountyCenterPopup extends ZGamePopUp
   {
      
      public static const ACCEPTED_ACTIVATE:String = "ACCEPTED";
      
      public static const ACCEPTED_SKIP_COOLING:String = "SKIP_COOLING";
      
      protected var m_fightIconLoaders:Array = new Array();
      
      protected var m_acceptButton:ZGameButton = null;
      
      protected var m_onAcceptCallback:Function;
      
      protected var m_timer:Timer;
      
      public function BountyCenterPopup(param1:Function)
      {
         super(ZGlobal.getAssetURL("assets/displays/screens/BountyCenter.swf"));
         this.m_onAcceptCallback = param1;
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         var _loc2_:Class = param1.getAssetClass("Screen_mc");
         m_window = new _loc2_();
         addChild(m_window);
         this.contentWidth = m_window.width;
         this.contentHeight = m_window.height;
         centerWithinStage(Zlab.mainStage);
         TextFieldUtil.compactTextField(m_window.title_tf,ZGameUtils.ZlocT("Dialogs","BountyCenterTitle"));
         TextFieldUtil.compactTextField(m_window.card_0.instructions_tf,ZGameUtils.ZlocT("Dialogs","PVPLevelUpUnlockLabel"));
         TextFieldUtil.compactTextField(m_window.card_1.instructions_tf,ZGameUtils.ZlocT("Dialogs","DominationOTPU_Title"));
         TextFieldUtil.compactTextField(m_window.card_2.instructions_tf,ZGameUtils.ZlocT("Main","BattleButtonTextBBlitz"));
         var _loc3_:int = BountyCenterManager.instance.bountyPayout;
         var _loc4_:String = "+" + _loc3_.toString() + " " + ZGameUtils.ZlocTokenGetString(ZGameUtils.ZlocTk("Items","expansionkey01_sentenceName",_loc3_ > 1 ? "plural" : "singular"));
         TextFieldUtil.compactTextField(m_window.card_0.description_tf,_loc4_);
         TextFieldUtil.compactTextField(m_window.card_1.description_tf,_loc4_);
         TextFieldUtil.compactTextField(m_window.card_2.description_tf,_loc4_);
         var _loc5_:Loader = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/BlackHeart_01_60.png"),m_window.card_0.icon);
         var _loc6_:Loader = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/PvpGeneralAssetGroup_UI.swf/DominanceStar_60.png"),m_window.card_1.icon);
         var _loc7_:Loader = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/contracts/Contracts_Icons_0.swf/PVPUnlock_96.png"),m_window.card_2.icon);
         this.m_fightIconLoaders.push(_loc5_);
         this.m_fightIconLoaders.push(_loc6_);
         this.m_fightIconLoaders.push(_loc7_);
         this.selectMode();
         BountyCenterManager.instance.addEventListener(BountyCenterManager.EVENT_STATE_CHANGE,this.selectMode);
         m_window.exit_bt.addEventListener(MouseEvent.CLICK,close);
      }
      
      protected function selectMode(param1:Event = null) : void
      {
         switch(BountyCenterManager.instance.currentState)
         {
            case BountyCenterManager.STATE_READY:
               if(this.m_timer)
               {
                  this.m_timer.stop();
                  this.m_timer = null;
               }
               TextFieldUtil.compactTextField(m_window.description_tf,ZGameUtils.ZlocT("Dialogs","BountyCenterActivationDialogDesc"));
               TextFieldUtil.compactTextField(m_window.description_tf_02,ZGameUtils.ZlocT("Dialogs","BountyCenterActivationDialogNote"));
               m_window.green_bt_0.visible = true;
               m_window.energy_mc.visible = true;
               m_window.green_bt_1.visible = false;
               TextFieldUtil.compactTextField(m_window.green_bt_0.generic_tf,ZGameUtils.ZlocT("Dialogs","BountyCenterActivationDialogButton"));
               TextFieldUtil.compactTextField(m_window.energy_mc.value_tf,BountyCenterManager.instance.energyRequired.toString());
               this.m_acceptButton = new ZGameButton(m_window.green_bt_0,this.onAcceptActivate);
               break;
            case BountyCenterManager.STATE_COOLING:
               this.updateTimeRemaining();
               this.m_timer = new Timer(1000);
               this.m_timer.start();
               this.m_timer.addEventListener(TimerEvent.TIMER,this.updateTimeRemaining);
               m_window.green_bt_0.visible = false;
               m_window.energy_mc.visible = false;
               m_window.green_bt_1.visible = true;
               TextFieldUtil.compactTextField(m_window.green_bt_1.generic_tf,ZGameUtils.ZlocT("Dialogs","BountyCenterCooldownStateDialogButton",{"x":BountyCenterManager.instance.skipCost.toString()}));
               m_window.description_tf_02.visible = false;
               this.m_acceptButton = new ZGameButton(m_window.green_bt_1,this.onAcceptSkipCooling);
               break;
            default:
               this.m_timer = null;
               close();
         }
      }
      
      override protected function deinitDialog() : void
      {
         super.deinitDialog();
      }
      
      protected function onAcceptActivate(param1:Event) : void
      {
         close();
         this.m_onAcceptCallback(new Event(ACCEPTED_ACTIVATE));
      }
      
      protected function onAcceptSkipCooling(param1:Event) : void
      {
         close();
         this.m_onAcceptCallback(new Event(ACCEPTED_SKIP_COOLING));
      }
      
      protected function updateTimeRemaining(param1:Event = null) : void
      {
         var _loc2_:String = ZGameTimeUtil.instance.getTimeString(BountyCenterManager.instance.coolingTimeRemaining);
         TextFieldUtil.compactTextField(m_window.description_tf,ZGameUtils.ZlocT("Dialogs","BountyCenterCooldownStateDialogDesc",{"time":_loc2_}));
      }
   }
}

