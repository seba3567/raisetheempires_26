package displays.popups
{
   import core.ZGlobal;
   import core.entities.components.behaviors.states.CommandoKillDialogState;
   import core.managers.CommandoManager;
   import core.ui.PlayerFeedbackManager;
   import core.ui.ZGameButton;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.resource.SWFResource;
   
   public class CommandoKillDialog extends ZGamePopUp
   {
      
      protected var m_activateButton:ZGameButton;
      
      protected var m_state:CommandoKillDialogState;
      
      protected var m_fightIconLoaders:Array = new Array();
      
      public function CommandoKillDialog(param1:CommandoKillDialogState)
      {
         this.m_state = param1;
         super(ZGlobal.getAssetURL("assets/displays/dialogs/Commando_Main.swf"));
      }
      
      protected function setupMarker() : void
      {
         var markerVal:int;
         var maxVal:Number = NaN;
         var minVal:Number = NaN;
         var progressBar_mc:MovieClip = null;
         var range:int = 0;
         var currentVal:int = 0;
         var timer:Timer = null;
         var TotalValue:String = null;
         var replacements:Object = null;
         maxVal = CommandoManager.instance.getPointsRequiredByLevel(ZGlobal.player.level);
         var level:int = CommandoManager.instance.getpointsAccumulated();
         minVal = 0;
         progressBar_mc = m_window.progressBar_mc;
         range = 180;
         if(maxVal > minVal)
         {
            currentVal = range / (maxVal - minVal) * level;
         }
         else
         {
            currentVal = 0;
         }
         markerVal = level;
         progressBar_mc.level0_tf.text = minVal;
         progressBar_mc.level1_tf.text = maxVal;
         progressBar_mc.marker_mc.y = 0;
         progressBar_mc.commando_mc.y = 0;
         progressBar_mc.mask_mc.y = 80;
         progressBar_mc.marker_mc.visible = false;
         timer = new Timer(50);
         timer.addEventListener(TimerEvent.TIMER,function(param1:TimerEvent):void
         {
            var _loc3_:int = 10;
            if(progressBar_mc.commando_mc.y + _loc3_ < currentVal)
            {
               progressBar_mc.commando_mc.y += _loc3_;
               progressBar_mc.marker_mc.y += _loc3_;
               progressBar_mc.mask_mc.y += _loc3_;
               timer.start();
            }
            else
            {
               progressBar_mc.commando_mc.y = currentVal;
               progressBar_mc.marker_mc.y = currentVal;
               progressBar_mc.mask_mc.y = currentVal + 80;
               timer.removeEventListener(TimerEvent.TIMER,arguments.callee);
               timer.stop();
            }
            var _loc4_:int = Math.ceil(progressBar_mc.marker_mc.y * maxVal / range);
            if(progressBar_mc.marker_mc.y != 0)
            {
               if(_loc4_ <= minVal || _loc4_ >= maxVal)
               {
                  progressBar_mc.marker_mc.visible = false;
               }
               else
               {
                  progressBar_mc.marker_mc.visible = true;
               }
               progressBar_mc.marker_mc.label_tf.text = _loc4_;
            }
         });
         timer.start();
         if(markerVal >= maxVal)
         {
            this.m_activateButton.enable();
            TotalValue = "15";
            replacements = {"total":TotalValue};
            PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Dialogs","Commando_Assault_Yard_Toaster_1",replacements));
         }
      }
      
      protected function onActivate(param1:MouseEvent) : void
      {
         this.m_state.done();
         close();
      }
      
      protected function setupUI() : void
      {
         m_window.exit_bt.addEventListener(MouseEvent.CLICK,close);
         TextFieldUtil.compactTextField(m_window.title_tf,ZGameUtils.ZlocT("Dialogs","Commando_Assault_Yard_Title"));
         var _loc1_:int = CommandoManager.instance.getPointsRequiredByLevel(ZGlobal.player.level) - CommandoManager.instance.getpointsAccumulated();
         TextFieldUtil.compactTextField(m_window.body_tf,ZGameUtils.ZlocT("Dialogs","Commando_Assault_Yard_Desc_1",{"total":_loc1_}));
         TextFieldUtil.compactTextField(m_window.body2_tf,ZGameUtils.ZlocT("Dialogs","Commando_Assault_Yard_Desc_3"));
         TextFieldUtil.compactTextField(m_window.emptyprompt_tf,ZGameUtils.ZlocT("Dialogs","Commando_Assault_Yard_Desc_2"));
         TextFieldUtil.compactTextField(m_window.fightLabel_tf,ZGameUtils.ZlocT("Dialogs","Commando_Assault_Yard_Fight_Meter_Label"));
         TextFieldUtil.compactTextField(m_window.activate_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","Commando_Assault_Yard_Activate_Button"));
         this.m_activateButton = new ZGameButton(m_window.activate_bt,this.onActivate);
         this.m_activateButton.disable_visual();
         var _loc2_:Loader = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/BlackHeart_01_96.png"),m_window.card0_mc.icon);
         var _loc3_:Loader = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/PvpGeneralAssetGroup_UI.swf/DominanceStar_96.png"),m_window.card1_mc.icon);
         var _loc4_:Loader = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/contracts/Contracts_Icons_0.swf/PVPUnlock_96.png"),m_window.card2_mc.icon);
         this.m_fightIconLoaders.push(_loc2_);
         this.m_fightIconLoaders.push(_loc3_);
         this.m_fightIconLoaders.push(_loc4_);
         TextFieldUtil.compactTextField(m_window.card0_mc.name_tf,ZGameUtils.ZlocT("Dialogs","PVPLevelUpUnlockLabel"));
         TextFieldUtil.compactTextField(m_window.card1_mc.name_tf,ZGameUtils.ZlocT("Dialogs","DominationOTPU_Title"));
         TextFieldUtil.compactTextField(m_window.card2_mc.name_tf,ZGameUtils.ZlocT("Main","BattleButtonTextBBlitz"));
         this.setupMarker();
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         m_window = param1.clip.screen_mc;
         this.setupUI();
         addChild(m_window);
         m_origOffsetX = m_window.x;
         m_origOffsetY = m_window.y;
         this.contentWidth = m_window.width;
         this.contentHeight = m_window.height;
         centerWithinStage(Zlab.mainStage);
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

