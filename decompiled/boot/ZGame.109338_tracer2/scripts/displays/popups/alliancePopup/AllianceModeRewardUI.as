package displays.popups.alliancePopup
{
   import core.managers.AlliancesManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class AllianceModeRewardUI
   {
      
      private static const FADE_RATE:Number = 0.3;
      
      private var m_clip:MovieClip = null;
      
      private var m_alliance:AlliancesManager = null;
      
      public function AllianceModeRewardUI(param1:MovieClip)
      {
         super();
         this.m_clip = param1;
         this.m_clip.visible = false;
         this.m_alliance = AlliancesManager.instance;
      }
      
      public function dispose() : void
      {
      }
      
      public function set visible(param1:Boolean) : void
      {
         this.m_clip.visible = param1;
      }
      
      public function updateState() : void
      {
         var _loc1_:String = this.m_alliance.battleAllianceName;
         var _loc2_:String = this.m_alliance.allianceBattleMember;
         var _loc3_:int = this.m_alliance.getAllianceMemberLegionNum(_loc1_,_loc2_);
         var _loc4_:int = this.m_alliance.getAllianceMemberTotal(_loc1_);
         var _loc5_:String = ZGameUtils.ZlocT("Dialogs","Alliance4Legion_Title",{
            "num":_loc3_,
            "total":_loc4_
         });
         TextFieldUtil.compactTextField(this.m_clip.generic_tf,_loc5_);
      }
      
      private function clearLoaders() : void
      {
      }
      
      private function onRollOver(param1:MouseEvent) : void
      {
      }
      
      private function onRollOut(param1:MouseEvent) : void
      {
      }
   }
}

