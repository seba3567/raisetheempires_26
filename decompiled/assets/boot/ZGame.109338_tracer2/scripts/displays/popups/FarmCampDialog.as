package displays.popups
{
   import core.ZGlobal;
   import core.entities.components.behaviors.states.FarmCampDialogState;
   import core.managers.FarmCampManager;
   import core.ui.ZGameButton;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.resource.SWFResource;
   
   public class FarmCampDialog extends ZGamePopUp
   {
      
      protected var m_activateButton:ZGameButton;
      
      protected var m_state:FarmCampDialogState;
      
      protected var m_fightIconLoaders:Array = new Array();
      
      public function FarmCampDialog(param1:FarmCampDialogState)
      {
         this.m_state = param1;
         super(ZGlobal.getAssetURL("assets/displays/screens/PU_DecoFarmCamp_Activation.swf"));
      }
      
      protected function setupMarker() : void
      {
         var _loc6_:int = 0;
         var _loc1_:Number = FarmCampManager.FIGHTS_GATE_3;
         var _loc2_:int = FarmCampManager.instance.fightsAccumulated;
         var _loc3_:Number = 0;
         var _loc4_:MovieClip = m_window.progressBar_mc;
         var _loc5_:int = 592;
         if(_loc1_ > _loc3_)
         {
            _loc6_ = _loc5_ / (_loc1_ - _loc3_) * _loc2_;
         }
         else
         {
            _loc6_ = 0;
         }
         var _loc7_:int = _loc2_;
         _loc4_.mask_mc.x = 0;
         _loc4_.mask_mc.width = _loc6_;
         var _loc8_:int = FarmCampManager.instance.getPossibleAcceleration();
         if(_loc7_ >= FarmCampManager.FIGHTS_GATE_1)
         {
            this.m_activateButton.enable();
         }
         var _loc9_:int = _loc8_ / FarmCampManager.instance.getBaseAcceleration();
         var _loc10_:int = 1;
         while(_loc10_ <= 3)
         {
            if(_loc9_ == _loc10_)
            {
               m_window["stage" + _loc10_ + "_mc"].gotoAndStop(2);
            }
            else
            {
               m_window["stage" + _loc10_ + "_mc"].gotoAndStop(1);
            }
            TextFieldUtil.compactTextField(m_window["stage" + _loc10_ + "_mc"].generic_tf,(_loc10_ * FarmCampManager.instance.getBaseAcceleration()).toString());
            _loc10_++;
         }
      }
      
      protected function onActivate(param1:MouseEvent) : void
      {
         this.m_state.done();
         close();
      }
      
      protected function setupUI() : void
      {
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:int = 0;
         m_window.exit_bt.addEventListener(MouseEvent.CLICK,close);
         TextFieldUtil.compactTextField(m_window.title_tf,ZGameUtils.ZlocT("Dialogs","Farm_Camp_UI_Title"));
         var _loc1_:String = ZGameUtils.ZlocT("Dialogs","Farm_Camp_UI_Desc_2");
         if(FarmCampManager.instance.getBaseAcceleration() == 20)
         {
            _loc6_ = 15;
            while(_loc6_ <= 45)
            {
               _loc4_ = _loc6_.toString();
               _loc5_ = (_loc6_ * 4 / 3).toString();
               _loc1_ = _loc1_.replace("%" + _loc4_,"%" + _loc5_);
               _loc1_ = _loc1_.replace(_loc4_ + "%",_loc5_ + "%");
               _loc1_ = _loc1_.replace(_loc4_ + " %",_loc5_ + " %");
               _loc6_ += 15;
            }
         }
         TextFieldUtil.compactTextField(m_window.description_tf,ZGameUtils.ZlocT("Dialogs","Farm_Camp_UI_Desc_1") + "\n" + _loc1_);
         TextFieldUtil.compactTextField(m_window.instructions_tf,ZGameUtils.ZlocT("Dialogs","Farm_Camp_UI_Instructions"));
         TextFieldUtil.compactTextField(m_window.title2_tf,ZGameUtils.ZlocT("Dialogs","Farm_Camp_UI_Meter_Title"));
         TextFieldUtil.compactTextField(m_window.label1_tf,ZGameUtils.ZlocT("Dialogs","Farm_Camp_UI_Label_1"));
         TextFieldUtil.compactTextField(m_window.label2_tf,ZGameUtils.ZlocT("Dialogs","Farm_Camp_UI_Label_2"));
         this.m_activateButton = new ZGameButton(m_window.accelerate_bt,this.onActivate);
         this.m_activateButton.disable_visual();
         this.m_activateButton.compactText(ZGameUtils.ZlocT("Dialogs","Farm_Camp_UI_Button"),null);
         var _loc2_:Loader = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/contracts/Contracts_Icons_0.swf/PVPUnlock_96.png"),m_window.location_mc.card0.icon);
         var _loc3_:Loader = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/PvpGeneralAssetGroup_UI.swf/DominanceStar_96.png"),m_window.location_mc.card1.icon);
         this.m_fightIconLoaders.push(_loc2_);
         this.m_fightIconLoaders.push(_loc3_);
         TextFieldUtil.compactTextField(m_window.location_mc.card0.name_tf,ZGameUtils.ZlocT("Main","BattleButtonTextBBlitz"));
         TextFieldUtil.compactTextField(m_window.location_mc.card1.name_tf,ZGameUtils.ZlocT("Dialogs","DominationOTPU_Title"));
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

