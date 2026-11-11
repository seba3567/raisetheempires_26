package displays.screens
{
   import core.gameobjects.CrewTemplateWrapper;
   import core.managers.CrewManager;
   import core.player.Player;
   import flash.events.EventDispatcher;
   import sound.ButtonMouseEventSoundContainer;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   
   public class CrewGatherSlotComplete extends CrewGatherSlot
   {
      
      public function CrewGatherSlotComplete(param1:EventDispatcher, param2:Class, param3:int, param4:CrewTemplateWrapper)
      {
         super(param1,param2,param3,param4);
      }
      
      private function getEffectiveTends() : int
      {
         var _loc2_:IEntity = null;
         var _loc3_:int = 0;
         var _loc1_:CrewGather = m_dispatcher as CrewGather;
         if(_loc1_)
         {
            _loc2_ = _loc1_.owner;
            return CrewManager.getNumPlayerTendsByCrewIndex(_loc2_,m_index);
         }
         return 0;
      }
      
      override protected function updateContextSensitiveElements(param1:Player, param2:ButtonMouseEventSoundContainer) : void
      {
         var _loc3_:int = this.getEffectiveTends();
         TextFieldUtil.processTextField(m_slot.visit_counter_mc.count_tf,String(_loc3_));
         TextFieldUtil.processTextField(m_slot.visit_counter_mc.visits_tf,ZGameUtils.ZlocT("Dialogs","CrewDialogDescVisitorVisitSubtitle"));
         m_slot.visit_counter_mc.visible = true;
         var _loc4_:CrewGather = m_dispatcher as CrewGather;
         if((Boolean(_loc4_)) && Boolean(param1))
         {
            m_slot.star_mc.visible = m_index == 0;
         }
         super.updateContextSensitiveElements(param1,param2);
      }
      
      override protected function enablePortraits() : Boolean
      {
         return true;
      }
      
      override public function enableReplaceableTooltip() : Boolean
      {
         return Boolean(m_player) && m_player.uid != Player.FAKE_PLAYER_ID;
      }
   }
}

