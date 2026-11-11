package displays.popups.alliancePopup
{
   import com.greensock.TweenLite;
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
   
   public class AllianceBattleWaveVictory extends ModalPopup
   {
      
      private var m_transition:Boolean = true;
      
      private var m_allianceName:String;
      
      private var m_memberId:String;
      
      private var m_loaders:Array;
      
      private var m_revenge:Boolean;
      
      public function AllianceBattleWaveVictory(param1:String, param2:String, param3:Boolean = false)
      {
         this.m_allianceName = param1;
         this.m_memberId = param2;
         this.m_revenge = param3;
         super("",null,this.assetURL);
      }
      
      public function get assetURL() : String
      {
         var _loc1_:String = "assets/displays/dialogs/PU_ModalPopUp.swf";
         if(this.m_transition)
         {
            _loc1_ = "assets/displays/dialogs/PU_AllianceWaveVictory.swf";
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
         var _loc2_:String = ZGameUtils.ZlocT("Dialogs","Alliance4Fights_AfterWave");
         TextFieldUtil.compactTextField(this.screen.title_mc.title_tf,_loc2_);
         this.setAllianceVictoryInfo();
         addChild(m_window);
         centerWithinStage(Zlab.mainStage);
      }
      
      private function setAllianceVictoryInfo() : void
      {
         var _loc2_:ImageLoader = null;
         var _loc1_:MovieClip = this.screen.allianceInfo_mc;
         this.m_loaders = new Array();
         var _loc3_:Object = DominationModeManager.instance.getAllianceInfo(this.m_allianceName);
         var _loc4_:String = AlliancesManager.instance.getPath(_loc3_.crestId,96);
         TextFieldUtil.compactTextField(_loc1_.name_tf_02,_loc3_.name);
         var _loc5_:MovieClip = _loc1_["loser_mc"];
         var _loc6_:Object = DominationModeManager.instance.getDominationInfo(this.m_memberId,true);
         if(!_loc6_)
         {
            return;
         }
         _loc2_ = ImageLoaderFactory.CreateImageLoader(_loc6_.u_info.image,_loc5_.icon);
         this.m_loaders.push(_loc2_);
         _loc4_ = ZGlobal.getAssetURL(_loc4_);
         _loc2_ = ImageLoaderFactory.CreateImageLoader(_loc4_,_loc1_.crest2_mc);
         this.m_loaders.push(_loc2_);
         TextFieldUtil.compactTextField(_loc1_.name_tf_01,AlliancesManager.instance.clanName);
         _loc4_ = ZGlobal.getAssetURL(AlliancesManager.instance.getPath(AlliancesManager.instance.crestId,96));
         _loc2_ = ImageLoaderFactory.CreateImageLoader(_loc4_,_loc1_.crest1_mc);
         this.m_loaders.push(_loc2_);
         var _loc7_:Object = AlliancesManager.instance.battleScores;
         TextFieldUtil.compactTextField(_loc1_.points_tf_01,"+" + _loc7_.winner.health.toString());
         TextFieldUtil.compactTextField(_loc1_.points_tf_02,"" + _loc7_.loser.health.toString());
         var _loc8_:int = AlliancesManager.instance.checkHealth(_loc7_.winner.health);
         var _loc9_:int = _loc3_.health + _loc7_.loser.health;
         if(_loc9_ < 0)
         {
            _loc9_ = 0;
         }
         else if(_loc9_ > _loc3_.max_health)
         {
            _loc9_ = int(_loc3_.max_health);
         }
         this.setHealthBarVisual(_loc1_.strength1_mc,_loc8_,AlliancesManager.instance.maxHealth);
         TextFieldUtil.compactTextField(_loc1_.strength1_mc.strength_tf,_loc8_.toString());
         this.setHealthBarVisual(_loc1_.strength2_mc,_loc9_,_loc3_.max_health);
         TextFieldUtil.compactTextField(_loc1_.strength2_mc.strength_tf,_loc9_.toString());
         if(_loc6_.d_info.scDec > 0)
         {
            TextFieldUtil.compactTextField(_loc1_.playerpoints_tf,"-" + _loc6_.d_info.scDec.toString());
         }
         else if(_loc6_.d_info.scDec == 0)
         {
            TextFieldUtil.compactTextField(_loc1_.playerpoints_tf,_loc6_.d_info.scDec.toString());
         }
         else
         {
            _loc1_.playerpoints_tf.visible = false;
         }
         var _loc10_:MovieClip = this.screen.points_mc;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:String = "";
         var _loc14_:String = "";
         var _loc15_:int = 0;
         if(Boolean(_loc6_) && _loc6_.d_info.scInc > 0)
         {
            _loc15_ += _loc6_.d_info.scInc;
         }
         else
         {
            _loc15_ += 0;
         }
         if(_loc6_.d_info.attackBonus)
         {
            _loc15_ += _loc6_.d_info.attackBonus;
         }
         else
         {
            _loc15_ += 0;
         }
         if(this.m_revenge)
         {
            if(_loc6_.d_info.revengeBonus)
            {
               _loc15_ += _loc6_.d_info.revengeBonus;
            }
            else
            {
               _loc15_ += 0;
            }
         }
         if(_loc15_ > 0)
         {
            _loc14_ = "+" + _loc15_.toString();
         }
         else
         {
            _loc14_ = _loc15_.toString();
         }
         TextFieldUtil.compactTextField(_loc10_.generic_tf,_loc14_);
         var _loc16_:String = ZGameUtils.ZlocT("Dialogs","Alliance4Fights_Rewards");
         TextFieldUtil.compactTextField(_loc1_.rewards_tf,_loc16_);
      }
      
      private function setHealthBarVisual(param1:MovieClip, param2:int, param3:int) : void
      {
         var _loc4_:Number = param1.width * (1 * param2 / param3);
         _loc4_ = _loc4_ > 5 ? _loc4_ : 5;
         TweenLite.to(param1.mask_mc,0,{"width":_loc4_});
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

