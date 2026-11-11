package displays.popups.mechlab
{
   import core.ZGlobal;
   import core.gamemode.battle.BattleMechlab;
   import core.gameobjects.GameItem;
   import displays.ImageLoaderFactory;
   import displays.popups.GallantPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import utils.getVisibleBounds;
   
   public class FinalReward extends GallantPopup
   {
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer;
      
      private var m_reward:String = null;
      
      public function FinalReward(param1:String)
      {
         this.m_reward = param1;
         super(ZGlobal.getAssetURL("assets/displays/screens/MechLabReward.swf"));
      }
      
      override protected function initializeScreen() : void
      {
         var _loc1_:Rectangle = null;
         _loc1_ = getVisibleBounds(this.screen);
         contentWidth = _loc1_.width;
         contentHeight = _loc1_.height;
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.screen.exit_bt.addEventListener(MouseEvent.CLICK,this.onExit);
         this.m_buttonSounds.addButton(this.screen.exit_bt,ButtonSound.DEFAULT);
         this.screen.place_btn.visible = false;
         this.screen.rewardsEven.visible = false;
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode(this.m_reward,GameItem) as GameItem;
         ImageLoaderFactory.CreateImageLoader(_loc2_.getCachedImage("icon").url,this.screen.rewardsOdd.reward0.icon);
         TextFieldUtil.compactTextField(this.screen.rewardsOdd.reward0.name_tf,_loc2_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         TextFieldUtil.compactTextField(this.screen.header_tf,ZGameUtils.ZlocT("Dialogs","Mechlab_RewardTitle"));
         var _loc3_:uint = BattleMechlab.prizeCount;
         var _loc4_:String = _loc3_ > 1 ? "plural" : "singular";
         TextFieldUtil.compactTextField(this.screen.header2_tf,ZGameUtils.ZlocT("Dialogs","Mechlab_RewardMessage",{
            "amount":_loc3_,
            "item":_loc2_.getSentenceNameLocalizationObject(_loc4_)
         }));
         super.initializeScreen();
      }
      
      override protected function deinitDialog() : void
      {
         this.m_buttonSounds.release();
         this.m_buttonSounds = null;
         this.screen.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExit);
         super.deinitDialog();
      }
      
      protected function get screen() : MovieClip
      {
         return m_window.movie_mc;
      }
      
      protected function onExit(param1:MouseEvent) : void
      {
         close();
      }
   }
}

