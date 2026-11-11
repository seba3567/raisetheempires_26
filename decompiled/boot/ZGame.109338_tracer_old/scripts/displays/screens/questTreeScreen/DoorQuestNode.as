package displays.screens.questTreeScreen
{
   import ZQuest.Init.QuestSettingsInit;
   import ZQuest.Managers.QuestManager;
   import core.ZGlobal;
   import core.managers.questManager.ZGameQuest;
   import core.managers.questManager.ZGameQuestManager;
   import core.ui.ZGameButton;
   import displays.ImageLoaderFactory;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   
   public class DoorQuestNode extends Node
   {
      
      protected var m_index:int = 0;
      
      public function DoorQuestNode(param1:MovieClip, param2:Dictionary, param3:XML, param4:String, param5:int)
      {
         this.m_index = param5;
         super(param1,param2,param3,param4);
      }
      
      override protected function initializeUI() : void
      {
         if(m_clip)
         {
            m_clip.visible = true;
         }
      }
      
      override public function updateState() : void
      {
         if(!m_clip)
         {
            return;
         }
         var _loc1_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(questName) as ZGameQuest;
         var _loc2_:ZGameQuestManager = null;
         TextFieldUtil.processTextField(m_clip.questTitle_tf,ZGameUtils.ZlocTP("QuestTrees",m_xml.@title));
         if(isDone())
         {
            m_clip.msg_tf.visible = true;
            if(this.isAllDone() && ZGlobal.player.questTrees.validForRestarting(questName))
            {
               m_clip.green_bt.visible = true;
               m_button = new ZGameButton(m_clip.green_bt,this.onPlayAgain);
               m_button.compactText(ZGameUtils.ZlocT("QuestTrees","PlayAgainText"),null);
               m_buttonSounds.addButton(m_button.m_overlay,ButtonSound.DEFAULT);
            }
            else
            {
               m_clip.green_bt.visible = false;
            }
            m_state = STATE_DONE;
            if(m_loader == null)
            {
               _loc2_ = QuestManager.getInstance() as ZGameQuestManager;
               m_loader = ImageLoaderFactory.CreateImageLoader(_loc2_.getButtonIconPath(_loc1_.name),m_clip.icon);
            }
            TextFieldUtil.processTextField(m_clip.msg_tf,ZGameUtils.ZlocT("DailyQuests","CompletedText"));
         }
         else if(isAvailable())
         {
            m_clip.green_bt.visible = true;
            m_clip.msg_tf.visible = true;
            m_state = STATE_AVAILABLE;
            if(m_loader == null)
            {
               _loc2_ = QuestManager.getInstance() as ZGameQuestManager;
               m_loader = ImageLoaderFactory.CreateImageLoader(_loc2_.getButtonIconPath(_loc1_.name),m_clip.icon);
            }
            m_button = new ZGameButton(m_clip.green_bt,onAccept);
            m_buttonSounds.addButton(m_button.m_overlay,ButtonSound.DEFAULT);
            if(isActive())
            {
               m_clip.msg_tf.visible = true;
               m_button.text = ZGameUtils.ZlocT("Dialogs","Continue");
               TextFieldUtil.processTextField(m_clip.msg_tf,ZGameUtils.ZlocT("DailyQuests","InProgressText"));
            }
            else
            {
               m_clip.msg_tf.visible = false;
               m_button.text = ZGameUtils.ZlocT("Dialogs","StartButton");
            }
         }
         else
         {
            m_clip.msg_tf.visible = false;
            m_clip.green_bt.visible = false;
            m_state = STATE_LOCKED;
         }
         m_clip.highlight_mc.visible = false;
         m_clip.tab_mc.visible = false;
      }
      
      protected function isAllDone() : Boolean
      {
         var _loc2_:Array = null;
         var _loc3_:String = null;
         if(!isDone())
         {
            return false;
         }
         var _loc1_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(questName) as ZGameQuest;
         if(_loc1_)
         {
            _loc2_ = _loc1_.sequels;
            for each(_loc3_ in _loc2_)
            {
               if(!ZGlobal.player.didCompleteQuest(_loc3_))
               {
                  return false;
               }
            }
         }
         return true;
      }
      
      override protected function get flyout() : MovieClip
      {
         return m_clip;
      }
      
      override protected function onRollOver(param1:MouseEvent) : void
      {
         m_clip.highlight_mc.visible = true;
         m_clip.tab_mc.visible = true;
      }
      
      override protected function onRollOut(param1:MouseEvent) : void
      {
         m_clip.highlight_mc.visible = false;
         m_clip.tab_mc.visible = false;
      }
      
      protected function onPlayAgain(param1:MouseEvent) : void
      {
         ZGlobal.player.questTrees.resetQuestTreeNode(m_treeId,questName);
      }
      
      override protected function onQuestComplete(param1:WorldEvent) : void
      {
         if(!ZGlobal.player.questTrees.isEndQuest(questName) && param1.eventData.name == questName && !this.isAllDone())
         {
            this.updateState();
         }
      }
      
      override protected function onPopupClosed(param1:Event) : void
      {
         if(this.isAllDone())
         {
            m_clip.green_bt.visible = false;
            TextFieldUtil.processTextField(m_clip.msg_tf,ZGameUtils.ZlocT("DailyQuests","CompletedText"));
         }
         super.onPopupClosed(param1);
      }
   }
}

