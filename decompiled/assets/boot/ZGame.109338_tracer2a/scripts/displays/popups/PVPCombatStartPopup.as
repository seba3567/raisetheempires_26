package displays.popups
{
   import core.ZGlobal;
   import core.player.IPVPPlayer;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.display.MovieClip;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.resource.SWFResource;
   
   public class PVPCombatStartPopup extends ZGamePopUp
   {
      
      private var m_mc:MovieClip;
      
      private var m_attacker:IPVPPlayer;
      
      private var m_victim:IPVPPlayer;
      
      private var m_helped:IPVPPlayer;
      
      private var m_loaded:Boolean;
      
      private var m_popped:Boolean;
      
      public function PVPCombatStartPopup(param1:IPVPPlayer, param2:IPVPPlayer, param3:IPVPPlayer = null)
      {
         super(ZGlobal.getAssetURL("assets/displays/screens/Pvp_PicksAndMisc.swf"));
         this.m_attacker = param1;
         this.m_victim = param2;
         this.m_helped = param3;
      }
      
      public function pop() : void
      {
         this.m_popped = true;
         if(this.m_loaded)
         {
            close();
         }
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         var _loc2_:Class = param1.getAssetClass("PVPCombatStartModal");
         this.m_mc = new _loc2_();
         addChild(this.m_mc);
         this.initializeMovieClip();
         contentWidth = this.m_mc.width;
         contentHeight = this.m_mc.height;
         initDialog();
         this.m_loaded = true;
         if(this.m_popped)
         {
            close();
         }
      }
      
      private function initializeMovieClip() : void
      {
         var _loc1_:String = null;
         this.initializeLoader(this.m_mc.player_01,this.m_attacker);
         this.initializeLoader(this.m_mc.player_02,this.m_victim);
         this.initializeLoader(this.m_mc.player_03,this.m_helped);
         TextFieldUtil.processTextField(this.m_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","PVPCombatModalLoading"));
         TextFieldUtil.processTextField(this.m_mc.vs_tf,ZGameUtils.ZlocT("Dialogs","BattleSelect_Vs"));
         if(this.m_helped)
         {
            _loc1_ = ZGameUtils.ZlocT("Dialogs","PVPCombatModalHelping");
            TextFieldUtil.processTextField(this.m_mc.message_tf,_loc1_);
         }
         else
         {
            this.m_mc.message_tf.visible = false;
            this.m_mc.player_03.visible = false;
         }
      }
      
      private function initializeLoader(param1:MovieClip, param2:IPVPPlayer) : void
      {
         var _loc3_:String = param2 ? param2.portraitURL : null;
         if(_loc3_)
         {
            ImageLoaderFactory.CreateImageLoader(_loc3_,param1.portrait_mc);
         }
         else
         {
            param1.visible = false;
         }
         if(param1.mindControlSwirl_mc)
         {
            param1.mindControlSwirl_mc.visible = false;
         }
      }
   }
}

