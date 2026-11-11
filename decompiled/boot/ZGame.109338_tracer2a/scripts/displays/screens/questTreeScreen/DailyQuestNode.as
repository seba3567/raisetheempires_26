package displays.screens.questTreeScreen
{
   import ZQuest.Init.QuestSettingsInit;
   import ZQuest.Managers.QuestManager;
   import core.ZGlobal;
   import core.managers.questManager.ZGameQuest;
   import core.managers.questManager.ZGameQuestManager;
   import core.ui.ZGameButton;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.quest.QuestCompletePopup;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   
   public class DailyQuestNode extends Node
   {
      
      protected var m_index:int = 0;
      
      protected var m_iconImageLoader:ImageLoader = null;
      
      protected var m_nonFlyoutIconImageLoader:ImageLoader = null;
      
      protected var m_loaders:Array = new Array();
      
      protected var m_enableStartButton:Boolean = true;
      
      public function DailyQuestNode(param1:MovieClip, param2:Dictionary, param3:XML, param4:String, param5:int)
      {
         this.m_index = param5;
         super(param1,param2,param3,param4);
      }
      
      override protected function initializeUI() : void
      {
         if(m_clip)
         {
            m_clip.visible = true;
            m_clip.tooltip_mc.visible = false;
            m_clip.tooltip_mc.mouseEnabled = false;
            m_clip.tooltip_mc.mouseChildren = false;
         }
         UIDispatcher.instance.addEventListener(QuestCompletePopup.EVENT_QUEST_COMPLETE_POPUP_CLOSED,this.onQuestCompleteClosed);
      }
      
      private function onQuestCompleteClosed(param1:Event) : void
      {
         this.m_enableStartButton = true;
         this.updateState();
      }
      
      override protected function onQuestComplete(param1:WorldEvent) : void
      {
         this.m_enableStartButton = false;
         super.onQuestComplete(param1);
      }
      
      override public function updateState() : void
      {
         var _loc1_:ZGameQuest = null;
         var _loc3_:String = null;
         if(!m_clip)
         {
            return;
         }
         _loc1_ = QuestSettingsInit.getInstance().getItemByName(questName) as ZGameQuest;
         var _loc2_:ZGameQuestManager = QuestManager.getInstance() as ZGameQuestManager;
         if(isDone())
         {
            if(m_clip.msg_tf)
            {
               m_clip.msg_tf.visible = true;
            }
            if(m_clip.check_mc)
            {
               m_clip.check_mc.visible = true;
            }
            if(m_clip.door_mc)
            {
               m_clip.door_mc.visible = false;
            }
            if(m_clip.num_tf_gray)
            {
               m_clip.num_tf_gray.visible = false;
            }
            if(m_clip.num_tf_white)
            {
               m_clip.num_tf_white.visible = true;
            }
            if(m_clip.green_bt)
            {
               m_clip.green_bt.visible = false;
            }
            if(m_clip.buy_bt)
            {
               m_clip.buy_bt.visible = false;
            }
            if(m_clip.bg_mc_progress)
            {
               m_clip.bg_mc_progress.visible = false;
            }
            if(m_clip.bg_mc_complete)
            {
               m_clip.bg_mc_complete.visible = true;
            }
            m_state = STATE_DONE;
            if(m_loader == null)
            {
               _loc2_ = QuestManager.getInstance() as ZGameQuestManager;
               m_loader = ImageLoaderFactory.CreateImageLoader(_loc2_.getButtonIconPath(_loc1_.name),m_clip.icon);
            }
            if(Boolean(m_clip.playerIcon) && !this.m_nonFlyoutIconImageLoader)
            {
               _loc3_ = ZGameUtils.callFunctionFromXml(m_xml.@playerImage);
               if(Boolean(_loc3_) && _loc3_ != "")
               {
                  this.m_nonFlyoutIconImageLoader = ImageLoaderFactory.CreateImageLoader(_loc3_,m_clip.playerIcon);
                  this.m_nonFlyoutIconImageLoader.smooth = true;
                  this.m_loaders.push(this.m_nonFlyoutIconImageLoader);
               }
            }
            TextFieldUtil.processTextField(m_clip.num_tf_white,ZGameUtils.ZlocT("DailyQuests","QuestNum",{"num":this.m_index}));
            TextFieldUtil.processTextField(m_clip.msg_tf,ZGameUtils.ZlocT("DailyQuests","CompletedText"));
            if(m_clip.iconActive)
            {
               this.m_loaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(m_xml.@activeBadge),m_clip.iconActive));
            }
         }
         else if(this.isAvailable())
         {
            if(m_clip.buy_bt)
            {
               m_clip.buy_bt.visible = false;
            }
            if(m_clip.check_mc)
            {
               m_clip.check_mc.visible = false;
            }
            if(m_clip.door_mc)
            {
               m_clip.door_mc.visible = false;
            }
            if(m_clip.num_tf_gray)
            {
               m_clip.num_tf_gray.visible = false;
            }
            if(m_clip.num_tf_white)
            {
               m_clip.num_tf_white.visible = true;
            }
            if(m_clip.green_bt)
            {
               m_clip.green_bt.visible = true;
            }
            if(m_clip.bg_mc_progress)
            {
               m_clip.bg_mc_progress.visible = false;
            }
            if(m_clip.bg_mc_complete)
            {
               m_clip.bg_mc_complete.visible = false;
            }
            m_state = STATE_AVAILABLE;
            if(m_loader == null)
            {
               _loc2_ = QuestManager.getInstance() as ZGameQuestManager;
               m_loader = ImageLoaderFactory.CreateImageLoader(_loc2_.getButtonIconPath(_loc1_.name),m_clip.icon);
            }
            if(Boolean(m_clip.playerIcon) && !this.m_nonFlyoutIconImageLoader)
            {
               _loc3_ = ZGameUtils.callFunctionFromXml(m_xml.@playerImage);
               if(Boolean(_loc3_) && _loc3_ != "")
               {
                  this.m_nonFlyoutIconImageLoader = ImageLoaderFactory.CreateImageLoader(_loc3_,m_clip.playerIcon);
                  this.m_nonFlyoutIconImageLoader.smooth = true;
                  this.m_loaders.push(this.m_nonFlyoutIconImageLoader);
               }
            }
            TextFieldUtil.processTextField(m_clip.num_tf_white,ZGameUtils.ZlocT("DailyQuests","QuestNum",{"num":this.m_index}));
            m_button = new ZGameButton(m_clip.green_bt,onAccept);
            m_buttonSounds.addButton(m_button.m_overlay,ButtonSound.DEFAULT);
            if(isActive())
            {
               if(m_clip.msg_tf)
               {
                  m_clip.msg_tf.visible = true;
               }
               m_button.text = ZGameUtils.ZlocT("Dialogs","Continue");
               TextFieldUtil.processTextField(m_clip.msg_tf,ZGameUtils.ZlocT("DailyQuests","InProgressText"));
               if(m_clip.bg_mc_progress)
               {
                  m_clip.bg_mc_progress.visible = true;
               }
               if(m_clip.bg_mc_complete)
               {
                  m_clip.bg_mc_complete.visible = false;
               }
            }
            else
            {
               if(m_clip.msg_tf)
               {
                  m_clip.msg_tf.visible = false;
               }
               m_button.text = ZGameUtils.ZlocT("Dialogs","StartButton");
               if(!this.m_enableStartButton)
               {
                  m_button.disable(true);
                  m_button.hide();
               }
               else
               {
                  m_button.enable();
               }
            }
            if(m_clip.iconActive)
            {
               this.m_loaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(m_xml.@activeBadge),m_clip.iconActive));
            }
         }
         else
         {
            if(m_clip.msg_tf)
            {
               m_clip.msg_tf.visible = false;
            }
            if(m_clip.check_mc)
            {
               m_clip.check_mc.visible = false;
            }
            if(m_clip.door_mc)
            {
               m_clip.door_mc.visible = true;
            }
            if(m_clip.num_tf_gray)
            {
               m_clip.num_tf_gray.visible = true;
            }
            if(m_clip.num_tf_white)
            {
               m_clip.num_tf_white.visible = false;
            }
            if(m_clip.green_bt)
            {
               m_clip.green_bt.visible = false;
            }
            if(m_clip.buy_bt)
            {
               m_clip.buy_bt.visible = true;
            }
            if(m_clip.bg_mc_progress)
            {
               m_clip.bg_mc_progress.visible = false;
            }
            if(m_clip.bg_mc_complete)
            {
               m_clip.bg_mc_complete.visible = false;
            }
            m_state = STATE_LOCKED;
            TextFieldUtil.processTextField(m_clip.num_tf_gray,ZGameUtils.ZlocT("DailyQuests","QuestNum",{"num":this.m_index}));
            if(_loc1_.startCost != 0 && (m_xml.@prequel == undefined || _loc2_.isQuestActive(m_xml.@prequel)))
            {
               m_clip.buy_bt.visible = true;
               m_button = new ZGameButton(m_clip.buy_bt,this.onUnlock);
               m_buttonSounds.addButton(m_button.m_overlay,ButtonSound.DEFAULT);
               m_button.text = ZGameUtils.ZlocT("Dialogs","UnlockForAmount",{"amount":_loc1_.startCost});
            }
            else
            {
               m_clip.buy_bt.visible = false;
            }
            if(m_clip.door_mc.iconInactive)
            {
               this.m_loaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(m_xml.@inactiveBadge),m_clip.door_mc.iconInactive));
            }
         }
         if(m_clip.highlight_mc)
         {
            m_clip.highlight_mc.visible = false;
         }
      }
      
      override public function dispose() : void
      {
         var _loc1_:ImageLoader = null;
         UIDispatcher.instance.removeEventListener(QuestCompletePopup.EVENT_QUEST_COMPLETE_POPUP_CLOSED,this.onQuestCompleteClosed);
         if(this.m_iconImageLoader)
         {
            this.m_iconImageLoader.destroy();
         }
         for each(_loc1_ in this.m_loaders)
         {
            _loc1_.destroy();
         }
         super.dispose();
      }
      
      override protected function isAvailable() : Boolean
      {
         if(isActive())
         {
            return true;
         }
         if(ZGlobal.player.questTrees.isUnlocked(m_treeId,questName))
         {
            return true;
         }
         var _loc1_:Object = new Object();
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(questName) as ZGameQuest;
         var _loc3_:int = ZGameTimeUtil.instance.getDateStatus(_loc1_,_loc2_.xml);
         if(_loc3_ == ZGameTimeUtil.DATE_STATUS_ACTIVE)
         {
            return true;
         }
         if(m_xml.@prequel != undefined && ZGlobal.player.didCompleteQuest(m_xml.@prequel))
         {
            return true;
         }
         return false;
      }
      
      protected function onUnlock(param1:MouseEvent) : void
      {
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(questName) as ZGameQuest;
         if(ZGlobal.player.canBuyCash(_loc2_.startCost,true))
         {
            ZGlobal.player.cash -= _loc2_.startCost;
            ZGlobal.player.questTrees.unlockQuest(questName);
            this.updateState();
         }
         if(this.flyout.playerIcon)
         {
            this.onRollOver(null);
         }
      }
      
      override protected function get flyout() : MovieClip
      {
         return m_clip.tooltip_mc;
      }
      
      override protected function onRollOver(param1:MouseEvent) : void
      {
         var _loc2_:ZGameQuest = null;
         var _loc3_:Object = null;
         var _loc4_:String = null;
         if(m_state == STATE_AVAILABLE)
         {
            if(m_clip.highlight_mc)
            {
               m_clip.highlight_mc.visible = true;
            }
            m_clip.tooltip_mc.visible = true;
            _loc2_ = QuestSettingsInit.getInstance().getItemByName(questName) as ZGameQuest;
            if(_loc2_)
            {
               addRewardIcons(_loc2_);
            }
            if(this.flyout.value_tf)
            {
               _loc3_ = ZGameUtils.callFunctionFromXml(_loc2_.textReplacements);
               TextFieldUtil.compactTextField(this.flyout.value_tf,ZGameUtils.ZlocTP("QuestTrees",_loc2_.title,_loc3_),{"minScale":0.6});
            }
            if(this.flyout.reward_tf)
            {
               TextFieldUtil.compactTextField(this.flyout.reward_tf,ZGameUtils.ZlocT("Dialogs","Rewards"));
            }
            if(Boolean(this.flyout.playerIcon) && !this.m_iconImageLoader)
            {
               _loc4_ = ZGameUtils.callFunctionFromXml(m_xml.@playerImage);
               if((Boolean(_loc4_)) && _loc4_ != "")
               {
                  this.m_iconImageLoader = ImageLoaderFactory.CreateImageLoader(_loc4_,this.flyout.playerIcon);
                  this.m_iconImageLoader.smooth = true;
               }
            }
         }
      }
      
      override protected function onRollOut(param1:MouseEvent) : void
      {
         m_clip.tooltip_mc.visible = false;
         super.onRollOut(param1);
      }
   }
}

