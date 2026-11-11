package displays.popups
{
   import core.ZGlobal;
   import core.entities.components.behaviors.states.TBPlayAgainDialogState;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.events.IEventDispatcher;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   
   public class TBPlayAgainPopup extends GallantPopup
   {
      
      protected var m_textIDs:Object;
      
      protected var m_rewardData:Object;
      
      protected var m_loaders:Array = null;
      
      protected var m_title:String;
      
      protected var m_desc:String;
      
      protected var m_button:ZGameButton;
      
      protected var m_eventDispatcher:IEventDispatcher;
      
      public function TBPlayAgainPopup(param1:IEventDispatcher, param2:Object, param3:Object, param4:String)
      {
         this.m_eventDispatcher = param1;
         this.m_textIDs = param2;
         this.m_rewardData = param3;
         super(ZGlobal.getAssetURL(param4));
      }
      
      override protected function initializeScreen() : void
      {
         super.initializeScreen();
         this.setupUI();
      }
      
      protected function setupUI() : void
      {
         this.m_eventDispatcher.addEventListener(TBPlayAgainDialogState.TB_EXPIRY,this.onTBExpiry);
         var _loc1_:String = this.m_textIDs.title ? this.m_textIDs.title : "TimedBuildablePlayAgainTitle";
         if(m_window.screen_mc.title_tf)
         {
            TextFieldUtil.compactTextField(m_window.screen_mc.title_tf,ZGameUtils.localizedStringForToken(_loc1_,"Dialogs"));
         }
         if(Boolean(m_window.screen_mc.generic_tf) && Boolean(this.m_textIDs.desc))
         {
            TextFieldUtil.compactTextField(m_window.screen_mc.generic_tf,ZGameUtils.localizedStringForToken(this.m_textIDs.desc,"Dialogs"));
         }
         var _loc2_:Array = this.getRewardClips();
         var _loc3_:int = int(this.m_rewardData.rewardPairs.length);
         this.m_loaders = new Array();
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            if(_loc4_ < _loc2_.length)
            {
               _loc2_[_loc4_].visible = true;
               TextFieldUtil.compactTextField(_loc2_[_loc4_].qty_tf,"x" + this.m_rewardData.rewardPairs[_loc4_].count);
               TextFieldUtil.compactTextField(_loc2_[_loc4_].name_tf,this.m_rewardData.rewardPairs[_loc4_].reward);
               this.m_loaders[_loc4_] = ImageLoaderFactory.CreateImageLoader(this.m_rewardData.rewardIcons[_loc4_],_loc2_[_loc4_].icon);
            }
            _loc4_++;
         }
         var _loc5_:String = this.m_textIDs.button ? this.m_textIDs.button : "TimedBuildablePlayAgain";
         this.m_button = new ZGameButton(m_window.screen_mc.playAgain_bt,this.onPlayAgain,1.1,true);
         this.m_button.compactText(ZGameUtils.localizedStringForToken(_loc5_,"Dialogs"),null);
         this.m_button.show();
         this.m_button.enable();
      }
      
      protected function onPlayAgain(param1:MouseEvent) : void
      {
         this.m_eventDispatcher.dispatchEvent(new WorldEvent(TBPlayAgainDialogState.PLAY_AGAIN));
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,GenericPopup.CANCEL));
         close();
      }
      
      protected function onTBExpiry(param1:MouseEvent) : void
      {
         close();
      }
      
      private function getRewardClips() : Array
      {
         var _loc1_:Array = null;
         var _loc2_:int = int(this.m_rewardData.rewardPairs.length);
         switch(_loc2_)
         {
            case 1:
               _loc1_ = [m_window.screen_mc.rewardsOdd.reward0];
               m_window.screen_mc.rewardsEven.visible = false;
               m_window.screen_mc.rewardsOdd.visible = true;
               break;
            case 2:
               _loc1_ = [m_window.screen_mc.rewardsEven.reward0,m_window.screen_mc.rewardsEven.reward1];
               m_window.screen_mc.rewardsEven.visible = true;
               m_window.screen_mc.rewardsOdd.visible = false;
               break;
            case 3:
               _loc1_ = [m_window.screen_mc.rewardsEven.reward0,m_window.screen_mc.rewardsOdd.reward0,m_window.screen_mc.rewardsEven.reward1];
               m_window.screen_mc.rewardsEven.visible = true;
               m_window.screen_mc.rewardsOdd.visible = true;
               break;
            case 0:
               _loc1_ = [];
               m_window.screen_mc.rewardsEven.visible = false;
               m_window.screen_mc.rewardsOdd.visible = false;
               break;
            default:
               _loc1_ = [m_window.screen_mc.rewardsEven.reward0,m_window.screen_mc.rewardsOdd.reward0,m_window.screen_mc.rewardsEven.reward1];
               m_window.screen_mc.rewardsEven.visible = true;
               m_window.screen_mc.rewardsOdd.visible = true;
         }
         return _loc1_;
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:ImageLoader = null;
         this.m_eventDispatcher.removeEventListener(TBPlayAgainDialogState.TB_EXPIRY,this.onTBExpiry);
         if(this.m_button)
         {
            this.m_button.dispose();
            this.m_button = null;
         }
         for each(_loc1_ in this.m_loaders)
         {
            _loc1_.destroy();
            _loc1_ = null;
         }
         this.m_loaders = null;
         super.deinitDialog();
      }
   }
}

