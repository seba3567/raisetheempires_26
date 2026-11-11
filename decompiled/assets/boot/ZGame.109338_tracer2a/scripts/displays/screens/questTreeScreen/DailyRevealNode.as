package displays.screens.questTreeScreen
{
   import ZQuest.Init.QuestSettingsInit;
   import ZQuest.Managers.QuestManager;
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.managers.questManager.ZGameQuest;
   import core.managers.questManager.ZGameQuestManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class DailyRevealNode extends DailyQuestNode
   {
      
      protected var m_iconLoader:ImageLoader = null;
      
      protected var m_tooltip:MovieClip = null;
      
      protected var m_callback:Function = null;
      
      public function DailyRevealNode(param1:MovieClip, param2:Dictionary, param3:XML, param4:String, param5:int, param6:Function)
      {
         this.m_callback = param6;
         super(param1,param2,param3,param4,param5);
      }
      
      override protected function initializeUI() : void
      {
         if(m_clip)
         {
            m_clip.visible = true;
            this.m_tooltip = m_clip.tooltip_mc;
            this.m_tooltip.visible = false;
         }
      }
      
      override public function updateState() : void
      {
         var _loc1_:ZGameQuest = null;
         var _loc2_:ZGameQuestManager = null;
         var _loc3_:String = null;
         if(!m_clip)
         {
            return;
         }
         _loc1_ = QuestSettingsInit.getInstance().getItemByName(questName) as ZGameQuest;
         _loc2_ = QuestManager.getInstance() as ZGameQuestManager;
         if(isDone())
         {
            m_clip.visible = false;
            m_state = STATE_DONE;
            this.done();
            if(m_loader == null)
            {
               _loc3_ = _loc2_.getButtonIconPath(_loc1_.name);
               if(_loc1_.xml.hasOwnProperty("@buttonIcon2"))
               {
                  _loc3_ = ZGlobal.getAssetURL(_loc1_.xml.@buttonIcon2);
               }
               this.m_iconLoader = ImageLoaderFactory.CreateImageLoader(_loc3_,m_clip.icon,this.m_callback);
            }
            TextFieldUtil.processTextField(m_clip.msg_tf,ZGameUtils.ZlocT("DailyQuests","CompletedText"));
         }
         else if(this.isAvailable())
         {
            m_clip.visible = true;
            m_clip.buy_bt.visible = false;
            m_clip.check_mc.visible = false;
            m_clip.green_bt.visible = true;
            m_state = STATE_AVAILABLE;
            this.available(_loc1_,_loc2_);
            m_button = new ZGameButton(m_clip.green_bt,onAccept);
            m_buttonSounds.addButton(m_button.m_overlay,ButtonSound.DEFAULT);
            if(isActive())
            {
               m_clip.door_mc.visible = true;
               m_clip.msg_tf.visible = true;
               m_button.text = ZGameUtils.ZlocT("Dialogs","Continue");
               TextFieldUtil.processTextField(m_clip.msg_tf,ZGameUtils.ZlocT("DailyQuests","InProgressText"));
               if(m_loader == null)
               {
                  m_loader = ImageLoaderFactory.CreateImageLoader(_loc2_.getButtonIconPath(_loc1_.name),m_clip.door_mc.doorIcon);
               }
            }
            else
            {
               m_clip.door_mc.visible = false;
               m_clip.msg_tf.visible = false;
               m_button.text = ZGameUtils.ZlocT("Dialogs","StartButton");
            }
            if(this.m_iconLoader == null)
            {
               this.m_iconLoader = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(m_xml.@coverImage),m_clip.icon,this.m_callback);
            }
         }
         else
         {
            m_clip.visible = true;
            m_clip.msg_tf.visible = false;
            m_clip.check_mc.visible = false;
            m_clip.door_mc.visible = true;
            m_clip.green_bt.visible = false;
            m_clip.door_mc.visible = false;
            m_state = STATE_LOCKED;
            if(this.m_iconLoader == null)
            {
               this.m_iconLoader = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(m_xml.@coverImage),m_clip.icon,this.m_callback);
            }
            if(_loc1_.startCost != 0 && (m_xml.@prequel == undefined || _loc2_.isQuestActive(m_xml.@prequel)))
            {
               m_clip.buy_bt.visible = true;
               m_button = new ZGameButton(m_clip.buy_bt,onUnlock);
               m_buttonSounds.addButton(m_button.m_overlay,ButtonSound.DEFAULT);
               m_button.text = ZGameUtils.ZlocT("Dialogs","UnlockForAmount",{"amount":_loc1_.startCost});
            }
            else
            {
               m_clip.buy_bt.visible = false;
            }
         }
         m_clip.highlight_mc.visible = false;
      }
      
      protected function done() : void
      {
      }
      
      protected function available(param1:ZGameQuest, param2:ZGameQuestManager) : void
      {
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
         if(m_xml.@prequel != undefined && ZGlobal.player.didCompleteQuest(m_xml.@prequel))
         {
            return true;
         }
         return false;
      }
      
      override public function dispose() : void
      {
         this.m_callback = null;
         if(this.m_iconLoader)
         {
            this.m_iconLoader.destroy();
            this.m_iconLoader = null;
         }
         super.dispose();
      }
      
      override protected function get flyout() : MovieClip
      {
         return this.m_tooltip;
      }
      
      override protected function onRollOver(param1:MouseEvent) : void
      {
         var _loc2_:ZGameQuest = null;
         if(m_state == STATE_AVAILABLE)
         {
            m_clip.highlight_mc.visible = true;
            this.m_tooltip.visible = true;
            m_clip.parent.addChild(this.m_tooltip);
            this.m_tooltip.x = param1.currentTarget.x + param1.currentTarget.width * 0.5;
            this.m_tooltip.y = param1.currentTarget.y;
            this.m_tooltip.alpha = 0;
            TweenLite.to(this.m_tooltip,0.5,{"alpha":1});
            m_clip.parent.setChildIndex(m_clip,m_clip.parent.numChildren - 1);
            _loc2_ = QuestSettingsInit.getInstance().getItemByName(questName) as ZGameQuest;
            if(_loc2_)
            {
               addRewardIcons(_loc2_);
            }
         }
      }
      
      override protected function onRollOut(param1:MouseEvent) : void
      {
         this.m_tooltip.visible = false;
         if(Boolean(this.m_tooltip) && this.m_tooltip.parent == m_clip.parent)
         {
            m_clip.parent.removeChild(this.m_tooltip);
         }
         super.onRollOut(param1);
      }
   }
}

