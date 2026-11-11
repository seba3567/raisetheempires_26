package displays.popups.battlelost
{
   import core.ZGlobal;
   import core.managers.ChallengeModeManager;
   import core.managers.PVPManager;
   import core.player.IPVPPlayer;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.battlebase.BattleBasePopup;
   import flash.display.MovieClip;
   import flash.utils.Dictionary;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   
   public class BattleChallengeLostPopup extends BattleDefeatedPopup
   {
      
      public function BattleChallengeLostPopup(param1:Array, param2:Dictionary, param3:Function = null)
      {
         super(param1,param2,param3);
      }
      
      override protected function get screen() : MovieClip
      {
         return m_window.Defeat;
      }
      
      override protected function assetStr() : String
      {
         if(allowUnitBuyBack())
         {
            return "assets/displays/dialogs/PU_Pvp_Defeat2.swf";
         }
         return "assets/displays/dialogs/PU_Pvp_Defeat.swf";
      }
      
      override protected function get loseTextLabel() : String
      {
         var _loc1_:String = ChallengeModeManager.instance.currentChallengerID();
         if(_loc1_ != PVPManager.PVE_MARKER_KEY)
         {
            if(!ChallengeModeManager.instance.isNeighborAssist())
            {
               if(!ChallengeModeManager.instance.isRandomFleetChallenge())
               {
                  return "LoseTextPVPRepel";
               }
            }
         }
         return super.loseTextLabel;
      }
      
      override protected function setUpPopupUI() : void
      {
         var _loc3_:ImageLoader = null;
         super.setUpPopupUI();
         if(ChallengeModeManager.instance.isNeighborAssist())
         {
            ZGameButton(buttons[0]).compactText(ZGameUtils.ZlocT("Dialogs","PostRegret"),{
               "maxLines":1,
               "minScale":0.5,
               "onFail":"return"
            });
         }
         else
         {
            ZGameButton(buttons[0]).compactText(ZGameUtils.ZlocT("Dialogs","PostPraise"),{
               "maxLines":1,
               "minScale":0.5,
               "onFail":"return"
            });
         }
         var _loc1_:String = ChallengeModeManager.instance.currentChallengerID();
         var _loc2_:IPVPPlayer = this.getPVPPlayer(_loc1_);
         _loc3_ = ImageLoaderFactory.CreateImageLoader(_loc2_.portraitURL,this.screen.player_02.icon);
         if(_loc3_)
         {
            _loc3_.smooth = true;
            loaders.push(_loc3_);
         }
         if(ChallengeModeManager.instance.isNeighborAssist())
         {
            _loc3_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.hostPlayer.snUser.picture,this.screen.player_01.icon);
            if(_loc3_)
            {
               _loc3_.smooth = true;
               loaders.push(_loc3_);
            }
            _loc3_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.player.snUser.picture,this.screen.player_03.icon);
            if(_loc3_)
            {
               _loc3_.smooth = true;
               loaders.push(_loc3_);
            }
            this.screen.player_03.visible = true;
            this.screen.lost_tf_0.visible = false;
            this.screen.lost_tf_1.visible = true;
            TextFieldUtil.processTextField(this.screen.lost_tf_1,ZGameUtils.ZlocT("Dialogs","LostText"));
         }
         else
         {
            _loc3_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.player.snUser.picture,this.screen.player_01.icon);
            if(_loc3_)
            {
               _loc3_.smooth = true;
               loaders.push(_loc3_);
            }
            this.screen.player_03.visible = false;
            this.screen.lost_tf_0.visible = true;
            this.screen.lost_tf_1.visible = false;
            TextFieldUtil.processTextField(this.screen.lost_tf_0,ZGameUtils.ZlocT("Dialogs","LostText"));
         }
      }
      
      override protected function dispatchPopupEvent() : void
      {
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,BattleBasePopup.AUTOSHARE_COMMENT));
      }
      
      protected function getPVPPlayer(param1:String) : IPVPPlayer
      {
         return PVPManager.instance.getPVPPlayer(param1);
      }
   }
}

