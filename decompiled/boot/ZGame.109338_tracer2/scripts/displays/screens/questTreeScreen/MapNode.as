package displays.screens.questTreeScreen
{
   import ZQuest.Init.QuestSettingsInit;
   import core.managers.questManager.ZGameQuest;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class MapNode extends Node
   {
      
      public function MapNode(param1:MovieClip, param2:Dictionary, param3:XML, param4:String, param5:Boolean = false, param6:Boolean = false)
      {
         super(param1,param2,param3,param4,param5,param6);
      }
      
      override protected function initFlyout() : void
      {
         var _loc1_:ZGameQuest = null;
         if(!m_flyoutInitialised)
         {
            m_clip.card_mc.click_btn.addEventListener(MouseEvent.CLICK,onAccept,false,0,true);
            _loc1_ = QuestSettingsInit.getInstance().getItemByName(questName) as ZGameQuest;
            if(_loc1_)
            {
               if(_loc1_.hideRewards)
               {
                  hideAllRewards();
                  ZGameUtils.showIfExists(m_clip.card_mc.flyout_mc.mystery_mc);
               }
               else
               {
                  ZGameUtils.hideIfExists(m_clip.card_mc.flyout_mc.mystery_mc);
                  addRewardIcons(_loc1_);
               }
               TextFieldUtil.compactTextField(m_clip.card_mc.flyout_mc.header_tf,ZGameUtils.ZlocTP("QuestTrees",_loc1_.title),{
                  "minScale":0.6,
                  "maxLines":1,
                  "fontSize":16
               });
            }
         }
      }
      
      override protected function onRollOver(param1:MouseEvent) : void
      {
         if(m_state == STATE_AVAILABLE)
         {
            m_clip.parent.setChildIndex(m_clip,m_clip.parent.numChildren - 1);
            m_clip.card_mc.gotoAndPlay("_active");
            this.initFlyout();
         }
      }
      
      override protected function removeEventListeners() : void
      {
         if(m_clip)
         {
            m_clip.card_mc.click_btn.removeEventListener(MouseEvent.CLICK,onAccept);
         }
         super.removeEventListeners();
      }
   }
}

