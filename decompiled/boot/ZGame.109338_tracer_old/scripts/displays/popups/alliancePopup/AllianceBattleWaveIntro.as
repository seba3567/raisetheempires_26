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
   
   public class AllianceBattleWaveIntro extends ModalPopup
   {
      
      private var m_transition:Boolean;
      
      private var m_allianceName:String;
      
      private var m_memberId:String;
      
      private var m_loaders:Array;
      
      private var m_revange:int = 0;
      
      public function AllianceBattleWaveIntro(param1:String, param2:String, param3:Boolean = true)
      {
         this.m_transition = param3;
         this.m_allianceName = param1;
         this.m_memberId = param2;
         super("",null,this.assetURL());
      }
      
      public function assetURL() : String
      {
         var _loc1_:String = "assets/displays/dialogs/PU_ModalPopUp.swf";
         if(this.m_transition)
         {
            _loc1_ = "assets/displays/dialogs/PU_AllianceWaveIntro.swf";
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
         var _loc2_:int = AlliancesManager.instance.getAllianceMemberLegionNum();
         var _loc3_:int = AlliancesManager.instance.getAllianceMemberTotal();
         var _loc4_:String = ZGameUtils.ZlocT("Dialogs","Alliance4Fights_Label",{
            "x":_loc2_,
            "total":_loc3_
         });
         TextFieldUtil.compactTextField(this.screen.title_mc.title_tf,_loc4_);
         var _loc5_:Object = DominationModeManager.instance.getDominationInfo(this.m_memberId,true);
         this.setupAllianceMemberInfo(_loc5_);
         this.setupRewardInfo(_loc5_);
         addChild(m_window);
         centerWithinStage(Zlab.mainStage);
      }
      
      private function setupAllianceMemberInfo(param1:Object) : void
      {
         var _loc7_:ImageLoader = null;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc2_:MovieClip = this.screen.allianceInfo_mc;
         var _loc3_:Object = DominationModeManager.instance.getAllianceInfo(this.m_allianceName);
         var _loc4_:String = AlliancesManager.instance.getPath(_loc3_.crestId,96);
         var _loc5_:String = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Member_title",{"Aname":_loc3_.name});
         TextFieldUtil.compactTextField(_loc2_.rank_tf,"" + _loc3_.numCrowns);
         TextFieldUtil.compactTextField(_loc2_.generic_tf,_loc5_);
         var _loc6_:Array = _loc3_.members;
         this.m_loaders = new Array();
         var _loc8_:MovieClip = _loc2_["player_mc"];
         if(param1)
         {
            _loc7_ = ImageLoaderFactory.CreateImageLoader(param1.u_info.image,_loc8_.icon);
            this.m_loaders.push(_loc7_);
         }
         _loc4_ = ZGlobal.getAssetURL(_loc4_);
         _loc7_ = ImageLoaderFactory.CreateImageLoader(_loc4_,_loc2_.crest_mc);
         this.m_loaders.push(_loc7_);
         if(Boolean(param1) && Boolean(param1.d_info.dr))
         {
            if(int(param1.d_info.dr) < 0)
            {
               _loc9_ = "0";
            }
            _loc9_ = "" + param1.d_info.dr;
         }
         else
         {
            _loc9_ = "0";
         }
         if(Boolean(param1) && Boolean(param1.u_info.name))
         {
            _loc10_ = param1.u_info.name;
         }
         else
         {
            _loc10_ = "";
         }
         if(Boolean(_loc3_ && _loc3_.int) && Boolean(param1) && Boolean(param1.d_info) && Boolean(param1.d_info.revengeBonus))
         {
            this.m_revange = int(param1.d_info.revengeBonus);
         }
         TextFieldUtil.compactTextField(_loc2_.playerpoints_tf,_loc9_);
         TextFieldUtil.compactTextField(_loc2_.playername_tf,_loc10_);
      }
      
      private function setupRewardInfo(param1:Object) : void
      {
         var _loc5_:String = null;
         var _loc2_:MovieClip = this.screen.points_mc;
         var _loc3_:String = ZGameUtils.ZlocT("Dialogs","Alliance4Fights_Rewards");
         TextFieldUtil.compactTextField(_loc2_.rewardTitle_tf,_loc3_);
         var _loc4_:int = 0;
         if(Boolean(param1) && Boolean(param1.d_info.scInc))
         {
            _loc4_ += param1.d_info.scInc;
         }
         else
         {
            _loc4_ += 0;
         }
         if(Boolean(param1) && Boolean(param1.d_info.attackBonus))
         {
            _loc4_ += param1.d_info.attackBonus;
         }
         else
         {
            _loc4_ += 0;
         }
         if(this.m_revange > 0)
         {
            _loc4_ += this.m_revange;
         }
         if(_loc4_ > 0)
         {
            _loc5_ = "+" + _loc4_.toString();
         }
         else
         {
            _loc5_ = _loc4_.toString();
         }
         TextFieldUtil.compactTextField(_loc2_.generic_tf,_loc5_);
      }
      
      override protected function deinitButtons() : void
      {
         var _loc1_:ImageLoader = null;
         for each(_loc1_ in this.m_loaders)
         {
            if(_loc1_)
            {
               _loc1_.destroy();
            }
         }
         this.m_loaders = null;
      }
   }
}

