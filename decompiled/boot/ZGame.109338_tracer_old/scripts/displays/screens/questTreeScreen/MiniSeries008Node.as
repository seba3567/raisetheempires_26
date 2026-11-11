package displays.screens.questTreeScreen
{
   import ZQuest.Init.QuestSettingsInit;
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.managers.questManager.ZGameQuest;
   import core.managers.questManager.ZGameQuestManager;
   import displays.ImageLoaderFactory;
   import displays.popups.quest.MiniSeries008DetailsPopup;
   import displays.popups.quest.QuestDetailsPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   
   public class MiniSeries008Node extends DailyRevealNode
   {
      
      public function MiniSeries008Node(param1:MovieClip, param2:Dictionary, param3:XML, param4:String, param5:int, param6:Function)
      {
         super(param1,param2,param3,param4,param5,param6);
      }
      
      override protected function done() : void
      {
         super.done();
         m_clip.visible = true;
         m_clip.buy_bt.visible = false;
         m_clip.green_bt.visible = false;
         m_clip.check_mc.visible = true;
      }
      
      override protected function available(param1:ZGameQuest, param2:ZGameQuestManager) : void
      {
         super.available(param1,param2);
         var _loc3_:String = param2.getButtonIconPath(param1.name);
         if(param1.xml.hasOwnProperty("@buttonIcon2"))
         {
            _loc3_ = ZGlobal.getAssetURL(param1.xml.@buttonIcon2);
         }
         m_iconLoader = ImageLoaderFactory.CreateImageLoader(_loc3_,m_clip.icon,m_callback);
      }
      
      override protected function createQuestDetailsPopup(param1:String) : QuestDetailsPopup
      {
         return new MiniSeries008DetailsPopup(param1);
      }
      
      override protected function onRollOver(param1:MouseEvent) : void
      {
         var _loc2_:ZGameQuest = null;
         if(m_state == STATE_AVAILABLE)
         {
            m_clip.highlight_mc.visible = true;
            m_clip.highlight_mc.gotoAndPlay(1);
            m_tooltip.visible = true;
            m_clip.parent.addChild(m_tooltip);
            m_tooltip.x = param1.currentTarget.x + param1.currentTarget.width * 0.3;
            m_tooltip.y = param1.currentTarget.y;
            m_tooltip.alpha = 0;
            TweenLite.to(m_tooltip,0.5,{"alpha":1});
            m_clip.parent.setChildIndex(m_clip,m_clip.parent.numChildren - 1);
            _loc2_ = QuestSettingsInit.getInstance().getItemByName(questName) as ZGameQuest;
            if(_loc2_)
            {
               addRewardIcons(_loc2_);
            }
         }
      }
   }
}

