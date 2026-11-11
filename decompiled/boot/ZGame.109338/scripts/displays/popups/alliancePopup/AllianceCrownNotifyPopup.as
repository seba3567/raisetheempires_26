package displays.popups.alliancePopup
{
   import Engine.Managers.StatsManager;
   import core.ZGlobal;
   import core.managers.AlliancesManager;
   import core.managers.domination.DominationModeManager;
   import core.ui.ZGameButton;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.display.MovieClip;
   import flash.events.Event;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.resource.SWFResource;
   
   public class AllianceCrownNotifyPopup extends ZGamePopUp
   {
      
      private var m_acceptBt:ZGameButton;
      
      public function AllianceCrownNotifyPopup()
      {
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_AllianceFinalVictory.swf"));
      }
      
      override protected function initDialog() : void
      {
         super.initDialog();
         this.m_acceptBt = new ZGameButton(this.screen.ok_bt,this.onClickOK);
         this.setupText();
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         this.initDialog();
         addChild(m_window);
      }
      
      private function setupText() : void
      {
         var _loc1_:String = AlliancesManager.instance.clanName;
         var _loc2_:int = AlliancesManager.CROWN_DOMINATION_POINTS;
         var _loc3_:String = ZGameUtils.ZlocT("Dialogs","Alliance4VictoryNotify_Description",{
            "Aname":_loc1_,
            "x":_loc2_
         });
         TextFieldUtil.compactTextField(this.screen.generic_tf,_loc3_);
         this.m_acceptBt.text = ZGameUtils.ZlocT("Dialogs","Alliance4VictoryNotify_Button");
      }
      
      private function get screen() : MovieClip
      {
         return m_window.screen_mc;
      }
      
      private function onClickOK(param1:Event) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Object = null;
         DominationModeManager.instance.dominance += 1000;
         var _loc2_:int = DominationModeManager.instance.dominanceRank;
         var _loc3_:Array = AlliancesManager.instance.members;
         if(Boolean(_loc3_) && _loc3_.length > 0)
         {
            _loc4_ = 0;
            _loc5_ = -1;
            _loc6_ = 0;
            while(_loc6_ < _loc3_.length)
            {
               _loc7_ = DominationModeManager.instance.getDominationInfo(_loc3_[_loc6_]);
               if(_loc7_)
               {
                  if(_loc7_.dr > _loc5_)
                  {
                     _loc5_ = int(_loc7_.dr);
                  }
                  if(_loc7_.dr > 0)
                  {
                     _loc4_ += _loc7_.dr;
                  }
               }
               _loc6_++;
            }
            _loc4_ = Math.floor(_loc4_ / _loc3_.length);
            StatsManager.count("alliances","alliances.crest.collection",_loc4_.toString(),_loc2_.toString(),_loc5_.toString());
         }
         this.clearEvents();
         super.close();
      }
      
      private function clearEvents() : void
      {
         if(this.m_acceptBt)
         {
            this.m_acceptBt.dispose();
            this.m_acceptBt = null;
         }
      }
   }
}

