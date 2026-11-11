package core.managers.worldEventManager
{
   import core.ZGlobal;
   import core.gamemode.battle.BattleQuest;
   import core.player.questTrees.QuestTree;
   import displays.popups.MOTDCountdownClock;
   import displays.popups.megaUnit.MegaUnitSeriesCompletePopup;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.managers.PopupManager;
   import zlabs.utils.MathUtils;
   import zlabs.utils.StringUtils;
   
   public class DestroyItemsEvent extends BaseWorldEvent
   {
      
      private var m_destroyed:int = 0;
      
      private var m_clock:MOTDCountdownClock = null;
      
      public function DestroyItemsEvent(param1:XML)
      {
         super(param1);
      }
      
      override public function dispose() : void
      {
         Zlab.processManager.removeScheduledObject(this);
         this.m_clock.dispose();
         this.m_clock = null;
         super.dispose();
      }
      
      override public function get data() : String
      {
         var _loc1_:int = int(xml.@amount);
         var _loc2_:int = Math.max(0,_loc1_ - this.m_destroyed);
         return _loc2_.toString();
      }
      
      override protected function addClip() : void
      {
         var _loc1_:int = ZGameTimeUtil.instance.getStartSeconds(xml,true);
         var _loc2_:int = ZGameTimeUtil.instance.getEndSeconds(xml,true);
         var _loc3_:int = GlobalEngine.getTimer() / 1000;
         _loc3_ += ZGlobal.player.timeWarpSeconds;
         var _loc4_:int = 3 * 60;
         var _loc5_:int = _loc2_ - _loc1_ - _loc4_;
         var _loc6_:Number = Math.min(1,(_loc3_ - _loc1_) / _loc5_);
         this.m_destroyed = _loc6_ * xml.@amount;
         super.addClip();
         this.m_clock = new MOTDCountdownClock(clip.clock_mc,xml,true);
         TextFieldUtil.processTextField(clip.time_tf,ZGameUtils.ZlocT("WorldEvents","WorldEvent01_title"));
         TextFieldUtil.processTextField(clip.mechsTitle_tf,ZGameUtils.ZlocT("QuestTrees","QT08_MechsLeft"));
         TextFieldUtil.processTextField(clip.killsTitle_tf,ZGameUtils.ZlocT("QuestTrees","QT08_MyKills"));
         Zlab.processManager.schedule(1000,this,this.onTimerCallback);
      }
      
      public function onTimerCallback() : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:Object = null;
         var _loc1_:int = int(xml.@amount);
         var _loc2_:int = MathUtils.randBetween(1,4);
         if(this.m_destroyed + _loc2_ < _loc1_)
         {
            this.m_destroyed += _loc2_;
            Zlab.processManager.schedule(MathUtils.randBetween(100,5000),this,this.onTimerCallback);
         }
         else
         {
            this.m_destroyed = _loc1_;
            _loc3_ = ZGameTimeUtil.instance.getEndSeconds(xml,true);
            _loc4_ = GlobalEngine.getTimer() / 1000;
            if(_loc4_ < _loc3_)
            {
               Zlab.processManager.schedule(1000,this,this.onTimerCallback);
            }
            else
            {
               _loc5_ = ZGlobal.player.getSeenFlag(BattleQuest.TITAN_KILLS);
               _loc6_ = null;
               _loc7_ = null;
               _loc8_ = null;
               if(_loc5_ > 0)
               {
                  _loc6_ = "QT08_Won_Thanks_Header";
                  _loc7_ = "QT08_Won_Thanks_Body";
                  _loc8_ = {"num":_loc5_};
               }
               else
               {
                  _loc6_ = "QT08_Won_NoThanks_Header";
                  _loc7_ = "QT08_Won_NoThanks_Body";
               }
               PopupManager.instance.push(new MegaUnitSeriesCompletePopup(ZGameUtils.ZlocT("QuestTrees",_loc6_),ZGameUtils.ZlocT("QuestTrees",_loc7_,_loc8_),this.onCompletePopupClosed));
            }
         }
         this.setDesc();
      }
      
      override protected function setDesc() : void
      {
         var _loc1_:int = int(xml.@amount);
         var _loc2_:int = Math.max(0,_loc1_ - this.m_destroyed);
         var _loc3_:String = StringUtils.formatNumber(_loc2_);
         TextFieldUtil.processTextField(clip.kills_tf,ZGlobal.player.getSeenFlag(BattleQuest.TITAN_KILLS).toString());
         TextFieldUtil.processTextField(clip.mechs_tf,_loc3_);
      }
      
      override protected function onClicked() : void
      {
         QuestTree.showScreen("QT08","worldevent");
      }
      
      private function onCompletePopupClosed() : void
      {
         this.dispose();
         ZGlobal.player.setSeenFlag(BattleQuest.TITAN_COMPLETE);
      }
   }
}

