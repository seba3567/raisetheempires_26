package core.entities.components
{
   import core.managers.MatchMakingManager;
   import core.player.IPVPPlayer;
   import core.ui.ZGameButton;
   import core.ui.components.PortraitSlidePick.PortraitSlidePick;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class ParliamentPickUpgrade extends PortraitSlidePick
   {
      
      protected var m_pickClass:Class;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var pickPlayerInfo:Object;
      
      private var m_init:Boolean;
      
      public function ParliamentPickUpgrade(param1:Number, param2:Class, param3:Boolean = true)
      {
         this.m_pickClass = param2;
         this.m_init = param3;
         super(null,param1);
      }
      
      override protected function getPickClass() : Class
      {
         return this.m_pickClass;
      }
      
      override protected function onCreatePickAsset(param1:IPVPPlayer) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:MovieClip = null;
         var _loc4_:ZGameButton = null;
         var _loc5_:MovieClip = null;
         var _loc6_:MovieClip = null;
         var _loc7_:ZGameButton = null;
         if(this.m_init)
         {
            _loc2_ = m_pick.card_mc;
            TextFieldUtil.compactTextField(_loc2_.title_tf,ZGameUtils.ZlocT("Items","WorldParliamentLabel"));
            TextFieldUtil.compactTextField(_loc2_.body03_tf,ZGameUtils.ZlocT("Dialogs","MMUpgradeDescription"));
            this.m_buttonSounds = new ButtonMouseEventSoundContainer();
            _loc3_ = _loc2_.green_btn;
            _loc4_ = new ZGameButton(_loc3_,this.onUpgrade);
            _loc4_.sounds = ButtonSound.DEFAULT;
            TextFieldUtil.compactTextField(_loc3_.generic_tf,ZGameUtils.ZlocT("Dialogs","UpgradeButton"));
            this.m_buttonSounds.addButton(_loc3_,ButtonSound.DEFAULT);
         }
         else
         {
            _loc5_ = m_pick.card_mc;
            TextFieldUtil.compactTextField(_loc5_.title_tf,ZGameUtils.ZlocT("Items","WorldParliamentLabel"));
            TextFieldUtil.compactTextField(_loc5_.body03_tf,ZGameUtils.ZlocT("Dialogs","MMFetchSuggestions"));
            this.m_buttonSounds = new ButtonMouseEventSoundContainer();
            _loc6_ = _loc5_.green_btn;
            _loc7_ = new ZGameButton(_loc6_,this.onFetchSuggestions);
            _loc7_.sounds = ButtonSound.DEFAULT;
            TextFieldUtil.compactTextField(_loc6_.generic_tf,ZGameUtils.ZlocT("Dialogs","MMFetchButton"));
            this.m_buttonSounds.addButton(_loc6_,ButtonSound.DEFAULT);
         }
      }
      
      private function onUpgrade(param1:MouseEvent) : void
      {
         MatchMakingManager.instance.UpgradeParliament();
      }
      
      private function onFetchSuggestions(param1:MouseEvent) : void
      {
         MatchMakingManager.instance.showMatchMakingData();
      }
      
      override protected function get xOffset() : int
      {
         return 30;
      }
      
      override protected function get yOffset() : int
      {
         return -170;
      }
      
      override protected function onDispose() : void
      {
         this.m_buttonSounds.release();
         this.m_buttonSounds = null;
         m_pick.card_mc.green_btn.removeEventListener(MouseEvent.CLICK,this.onUpgrade);
      }
   }
}

