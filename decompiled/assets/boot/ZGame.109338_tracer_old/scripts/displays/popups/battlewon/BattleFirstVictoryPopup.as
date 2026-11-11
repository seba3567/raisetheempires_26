package displays.popups.battlewon
{
   import ZQuest.Init.QuestSettingsInit;
   import core.managers.questManager.ZGameQuest;
   import core.ui.ZGameButton;
   import core.ui.menuitem.FriendsBarUIItem;
   import dispatchers.NeighborsDispatcher;
   import displays.ImageLoaderFactory;
   import displays.popups.battlebase.BattleBasePopup;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   
   public class BattleFirstVictoryPopup extends BattleCampaignWonPopup
   {
      
      private static const WINDOW_HEIGHT:int = 577.25;
      
      private static const WINDOW_WIDTH:int = 574.75;
      
      private var m_questName:String = null;
      
      public function BattleFirstVictoryPopup(param1:String, param2:Function)
      {
         super(null,null,null,param2);
         this.m_questName = param1;
      }
      
      override protected function assetStr() : String
      {
         return "assets/displays/dialogs/PU_FirstVictory.swf";
      }
      
      override protected function setUpPopupUI() : void
      {
         initDialog();
         loaders = new Array();
         var _loc1_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(this.m_questName) as ZGameQuest;
         textObj = _loc1_.getRewardTextObject();
         m_buttonSounds = new ButtonMouseEventSoundContainer();
         mainButton = new ZGameButton(this.screen.greenButton,this.onButtonClicked);
         mainButton.text = ZGameUtils.ZlocT("Dialogs","InviteIdleButton");
         m_buttonSounds.addButton(mainButton.m_overlay,ButtonSound.DEFAULT);
         TextFieldUtil.processTextField(this.screen.title_tf,ZGameUtils.ZlocT("Dialogs","FirstVictoryTitle"));
         TextFieldUtil.processTextField(this.screen.generic_tf,ZGameUtils.ZlocT("Dialogs","FirstVictoryMessage"));
         TextFieldUtil.processTextField(this.screen.title01_tf,ZGameUtils.ZlocT("Dialogs","Rewards"));
         TextFieldUtil.processTextField(this.screen.tip_tf,ZGameUtils.ZlocT("Dialogs","FirstVictoryFriendsMessage"));
         this.checkFriendCards();
         this.setRewards();
         this.screen.exit_bt.addEventListener(MouseEvent.CLICK,onExit,false,0,true);
         m_buttonSounds.addButton(this.screen.exit_bt,ButtonSound.DEFAULT);
         if(null != closeCallback)
         {
            addEventListener(GenericPopupEvent.SELECTED,closeCallback,false,0,true);
         }
      }
      
      override protected function get screen() : MovieClip
      {
         return m_window.first_victory_mc;
      }
      
      override protected function get windowWidth() : Number
      {
         return 574.75;
      }
      
      override protected function get windowHeight() : Number
      {
         return 577.25;
      }
      
      private function checkFriendCards() : void
      {
         var _loc1_:Array = FriendsBarUIItem(FriendsBarUIItem.getFriendsBar()).suggestedNeighbors;
         if(_loc1_ == null)
         {
            NeighborsDispatcher.instance.addEventListener(FriendsBarUIItem.SUGGESTED_NEIGHBORS_RECEIVED,this.setFriendCards,false,0,true);
            FriendsBarUIItem(FriendsBarUIItem.getFriendsBar()).forceSuggestedNeighborTransaction();
         }
         else
         {
            this.setFriendCards(null);
         }
      }
      
      private function setFriendCards(param1:Event) : void
      {
         var _loc6_:int = 0;
         if(NeighborsDispatcher.instance.hasEventListener(FriendsBarUIItem.SUGGESTED_NEIGHBORS_RECEIVED))
         {
            NeighborsDispatcher.instance.removeEventListener(FriendsBarUIItem.SUGGESTED_NEIGHBORS_RECEIVED,this.setFriendCards);
         }
         var _loc2_:Array = FriendsBarUIItem(FriendsBarUIItem.getFriendsBar()).suggestedNeighbors;
         var _loc3_:Array = [this.screen.cards_mc.card0,this.screen.cards_mc.card1,this.screen.cards_mc.card2];
         var _loc4_:int = int(_loc3_.length);
         var _loc5_:* = 0;
         if(Boolean(_loc2_) && _loc2_.length > 0)
         {
            switch(_loc2_.length)
            {
               case 1:
                  this.screen.cards_mc.x = this.screen.anchor1_mc.x;
                  _loc4_ = 1;
                  break;
               case 2:
                  this.screen.cards_mc.x = this.screen.anchor2_mc.x;
                  _loc4_ = 2;
                  break;
               default:
                  this.screen.cards_mc.x = this.screen.anchor3_mc.x;
            }
            _loc5_ = 0;
            while(_loc5_ < _loc4_)
            {
               _loc6_ = (FriendsBarUIItem.suggestedNeighborOffset + _loc5_) % _loc2_.length;
               loaders.push(ImageLoaderFactory.CreateImageLoader(_loc2_[_loc6_].pic_square,_loc3_[_loc5_].icon));
               TextFieldUtil.processTextField(_loc3_[_loc5_].generic_tf,_loc2_[_loc6_].first_name);
               _loc3_[_loc5_].visible = true;
               _loc5_++;
            }
            FriendsBarUIItem.suggestedNeighborOffset = (FriendsBarUIItem.suggestedNeighborOffset + _loc4_) % _loc2_.length;
         }
         while(_loc5_ < _loc3_.length)
         {
            _loc3_[_loc5_++].visible = false;
         }
      }
      
      private function setRewards() : void
      {
         var _loc1_:Array = [this.screen.rewardAnchor1_mc,this.screen.rewardAnchor2_mc,this.screen.rewardAnchor3_mc];
         this.screen.rewards_mc.x = _loc1_[textObj.rewardPairs.length - 1].x;
         var _loc2_:Array = [this.screen.rewards_mc.card0_mc,this.screen.rewards_mc.card1_mc,this.screen.rewards_mc.card2_mc];
         var _loc3_:int = 0;
         while(_loc3_ < textObj.rewardPairs.length)
         {
            loaders.push(ImageLoaderFactory.CreateImageLoader(textObj.rewardIcons[_loc3_],_loc2_[_loc3_].icon));
            TextFieldUtil.processTextField(_loc2_[_loc3_].value_tf,ZGameUtils.ZlocT("Dialogs","WinRewardResult",{"reward":textObj.rewardText[_loc3_]}));
            _loc3_++;
         }
         while(_loc3_ < 3)
         {
            _loc2_[_loc3_].visible = false;
            _loc3_++;
         }
      }
      
      override protected function onButtonClicked(param1:MouseEvent) : void
      {
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,BattleBasePopup.INVITE));
         close();
      }
      
      override protected function deinitDialog() : void
      {
         NeighborsDispatcher.instance.removeEventListener(FriendsBarUIItem.SUGGESTED_NEIGHBORS_RECEIVED,this.setFriendCards);
         super.deinitDialog();
      }
      
      override protected function allowUnitBuyBack() : Boolean
      {
         return false;
      }
   }
}

