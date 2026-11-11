package displays.popups
{
   import Engine.Managers.TransactionManager;
   import ZQuest.Managers.QuestManager;
   import core.ZGlobal;
   import core.managers.AlliancesManager;
   import core.managers.questManager.ZGameQuestManager;
   import core.ui.ZGameButton;
   import displays.popups.alliancePopup.AllianceChangeLook;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import transactions.clans.TCreateClan;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class AllianceQuestMain extends ZGamePopUp
   {
      
      protected var m_currentQuest:int = 0;
      
      protected var m_activateButton:ZGameButton;
      
      protected var m_questButton:ZGameButton;
      
      public function AllianceQuestMain()
      {
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_Alliances.swf"));
         QuestManager.getInstance().addEventListener(ZGameQuestManager.QUEST_COMPLETE,this.setupUI,false,0,true);
         QuestManager.getInstance().addEventListener(ZGameQuestManager.NEW_QUEST_AVAILABLE,this.setupUI,false,0,true);
      }
      
      protected function setupUI(param1:Event = null) : void
      {
         if(m_window == null)
         {
            return;
         }
         this.m_activateButton = new ZGameButton(m_window.mainShield_bt,this.onActivate);
         this.m_activateButton.disable_visual();
         this.m_activateButton.text = "";
         m_window.mainShield_bt.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverActivate);
         m_window.mainShield_bt.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutActivate);
         TextFieldUtil.compactTextField(m_window.tooltip_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","Alliance_Phase_activate_tooltip"));
         m_window.tooltip_mc.visible = false;
         if(ZGameQuestManager.instance.getQuestProgressByName("QALL3") != null && !ZGlobal.player.didCompleteQuest("QALL3"))
         {
            this.setupStage(1,true,false);
            this.setupStage(2,true,false);
            this.setupStage(3,false,true);
            this.m_currentQuest = 3;
         }
         else if(ZGameQuestManager.instance.getQuestProgressByName("QALL2") != null && !ZGlobal.player.didCompleteQuest("QALL2"))
         {
            this.setupStage(1,true,false);
            this.setupStage(2,false,true);
            this.setupStage(3,false,false);
            this.m_currentQuest = 2;
         }
         else if(ZGameQuestManager.instance.getQuestProgressByName("QALL1") != null && !ZGlobal.player.didCompleteQuest("QALL1"))
         {
            this.setupStage(1,false,true);
            this.setupStage(2,false,false);
            this.setupStage(3,false,false);
            this.m_currentQuest = 1;
         }
         else if(ZGlobal.player.didCompleteQuest("QALL3"))
         {
            this.setupStage(1,true,false);
            this.setupStage(2,true,false);
            this.setupStage(3,true,false);
            this.m_activateButton.enable();
            this.m_activateButton.text = ZGameUtils.ZlocT("Dialogs","Alliance_Phase2_Activate");
         }
         else
         {
            this.setupStage(1,ZGlobal.player.didCompleteQuest("QALL1"),false);
            this.setupStage(2,ZGlobal.player.didCompleteQuest("QALL2"),false);
            this.setupStage(3,ZGlobal.player.didCompleteQuest("QALL3"),false);
         }
         m_window.exit_bt.addEventListener(MouseEvent.CLICK,this.close);
         TextFieldUtil.compactTextField(m_window.title_tf,ZGameUtils.ZlocT("Dialogs","Alliance_Phase2_title"));
         TextFieldUtil.compactTextField(m_window.description_tf,ZGameUtils.ZlocT("Dialogs","Alliance_Phase2_info"));
         TextFieldUtil.compactTextField(m_window.hint_tf,ZGameUtils.ZlocT("Dialogs","Alliance_Phase2_hint"));
      }
      
      private function onMouseOverActivate(param1:Event) : void
      {
         if(!this.m_activateButton.enabled)
         {
            m_window.tooltip_mc.visible = true;
         }
      }
      
      private function onMouseOutActivate(param1:Event) : void
      {
         m_window.tooltip_mc.visible = false;
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         m_window = param1.clip.screen_mc;
         param1.destroy();
         if(!AlliancesManager.isValid())
         {
            this.close();
            return;
         }
         addChild(m_window);
         this.setupUI();
         m_origOffsetX = m_window.panel_mc.x;
         m_origOffsetY = m_window.panel_mc.y;
         this.contentWidth = m_window.width;
         this.contentHeight = m_window.height;
         centerWithinStage(Zlab.mainStage);
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      protected function onActivate(param1:Event) : void
      {
         if(!ZGlobal.player.didCompleteQuest("QALL3"))
         {
            return;
         }
         AlliancesManager.instance.clanName = ZGlobal.player.firstName;
         AlliancesManager.instance.crestId = 0;
         var _loc2_:TCreateClan = new TCreateClan(AlliancesManager.instance.clanName,AlliancesManager.instance.crestId);
         TransactionManager.addTransaction(_loc2_,true);
         PopupManager.instance.push(new AllianceChangeLook(null,null,true));
         this.close();
      }
      
      protected function onClose(param1:Event = null) : void
      {
         this.close();
      }
      
      override protected function close(param1:Event = null) : void
      {
         this.m_activateButton.dispose();
         m_window.mainShield_bt.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverActivate);
         m_window.mainShield_bt.removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutActivate);
         QuestManager.getInstance().removeEventListener(ZGameQuestManager.QUEST_COMPLETE,this.setupUI);
         QuestManager.getInstance().removeEventListener(ZGameQuestManager.NEW_QUEST_AVAILABLE,this.setupUI);
         if(this.m_questButton != null)
         {
            this.m_questButton.dispose();
            this.m_questButton = null;
         }
         super.close(param1);
      }
      
      protected function setupStage(param1:int, param2:Boolean, param3:Boolean) : void
      {
         var _loc5_:String = null;
         if(!m_window["stage" + param1 + "_mc"])
         {
            return;
         }
         var _loc4_:MovieClip = m_window["stage" + param1 + "_mc"];
         _loc4_.taskDone_mc.visible = false;
         _loc4_.back_mc.visible = true;
         _loc4_.lock_mc.visible = true;
         _loc4_.stage_bt.visible = true;
         TextFieldUtil.compactTextField(_loc4_.label_tf,ZGameUtils.ZlocT("Dialogs","Alliance_Phase2_QALL" + param1));
         TextFieldUtil.compactTextField(_loc4_.generic_tf," ");
         if(!AlliancesManager.isQuestExperimentEnabled(param1))
         {
            TextFieldUtil.compactTextField(_loc4_.generic_tf,ZGameUtils.ZlocT("Dialogs","AllianceButtonComingDesc"));
         }
         if(param3)
         {
            _loc4_.lock_mc.visible = false;
            if(this.m_questButton != null)
            {
               this.m_questButton.dispose();
               this.m_questButton = null;
            }
            this.m_questButton = new ZGameButton(_loc4_.stage_bt,this.showQuest);
            _loc5_ = ZGameUtils.ZlocT("Dialogs","Alliance_Phase2_tooltip_quest" + param1);
            this.m_questButton.addTooltip(_loc5_);
         }
         else if(param2)
         {
            _loc4_.back_mc.visible = false;
            _loc4_.taskDone_mc.visible = true;
            _loc4_.stage_bt.visible = false;
         }
      }
      
      protected function showQuest(param1:Event) : void
      {
         var _loc2_:AllianceQuestPopup = new AllianceQuestPopup("QALL" + this.m_currentQuest);
         PopupManager.instance.push(_loc2_);
         this.close();
      }
   }
}

