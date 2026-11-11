package displays.popups.alliancePopup
{
   import core.ZGlobal;
   import core.managers.AlliancesManager;
   import core.managers.domination.DominationModeManager;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.genericPopup.ModalPopup;
   import flash.display.MovieClip;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.resource.SWFResource;
   
   public class AllianceBattleTransitionPopup extends ModalPopup
   {
      
      private var m_transition:Boolean;
      
      private var m_allianceName:String;
      
      private var m_loaders:Array;
      
      public function AllianceBattleTransitionPopup(param1:String, param2:Boolean = true)
      {
         this.m_transition = param2;
         this.m_allianceName = param1;
         super("",null,this.assetURL());
      }
      
      public function assetURL() : String
      {
         var _loc1_:String = "assets/displays/dialogs/PU_ModalPopUp.swf";
         if(this.m_transition)
         {
            _loc1_ = "assets/displays/dialogs/PU_AllianceTransition.swf";
         }
         return _loc1_;
      }
      
      public function get screen() : MovieClip
      {
         return m_window.waveTransition_mc;
      }
      
      override public function onShow() : void
      {
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         this.screen.background_mc.visible = false;
         var _loc2_:String = ZGameUtils.ZlocT("Dialogs","Alliance4StartBattlePopup_Title");
         TextFieldUtil.compactTextField(this.screen.title_mc.title_tf,_loc2_);
         this.setupAllianceInfo();
         addChild(m_window);
         centerWithinStage(Zlab.mainStage);
      }
      
      private function setupAllianceInfo() : void
      {
         var _loc6_:ImageLoader = null;
         var _loc1_:MovieClip = this.screen.allianceInfo_mc;
         var _loc2_:Object = DominationModeManager.instance.getAllianceInfo(this.m_allianceName);
         var _loc3_:String = AlliancesManager.instance.getPath(_loc2_.crestId,96);
         var _loc4_:String = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Member_title",{"Aname":_loc2_.name});
         TextFieldUtil.compactTextField(_loc1_.rank_tf,"" + _loc2_.numCrowns);
         TextFieldUtil.compactTextField(_loc1_.alliance_tf,_loc4_);
         var _loc5_:Array = _loc2_.members;
         this.m_loaders = new Array();
         _loc3_ = ZGlobal.getAssetURL(_loc3_);
         _loc6_ = ImageLoaderFactory.CreateImageLoader(_loc3_,_loc1_.crest_mc);
         this.m_loaders.push(_loc6_);
         var _loc7_:int = _loc2_.members.length - 1;
         var _loc8_:String = ZGameUtils.ZlocT("Dialogs","Alliance4WorldDomination_LabelLeader",{"lName":_loc2_.leaderName});
         TextFieldUtil.compactTextField(_loc1_.leadername_tf,_loc8_);
         if(_loc7_ > 0)
         {
            TextFieldUtil.compactTextField(_loc1_.members_tf,ZGameUtils.ZlocT("Dialogs","Alliance4StartBattlePopup_members",{"total":_loc7_}));
         }
         else
         {
            _loc1_.members_tf.visible = false;
         }
      }
      
      override protected function deinitButtons() : void
      {
         var _loc1_:ImageLoader = null;
         for each(_loc1_ in this.m_loaders)
         {
            _loc1_.destroy();
         }
         this.m_loaders = null;
      }
   }
}

