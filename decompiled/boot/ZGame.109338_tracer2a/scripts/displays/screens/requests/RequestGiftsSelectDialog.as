package displays.screens.requests
{
   import com.adobe.utils.ArrayUtil;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import displays.popups.GallantPopup;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   
   public class RequestGiftsSelectDialog extends GallantPopup
   {
      
      private static const NUM_SLOTS:int = 10;
      
      private static var m_instanceExists:Boolean = false;
      
      private var m_gifts:Array;
      
      private var m_partsGift:Object = new Object();
      
      private var m_cards:Array;
      
      private var m_title:String;
      
      private var m_body:String;
      
      private var m_hint:String;
      
      private var m_currentPage:int = 1;
      
      private var m_forwardBt:SimpleButton;
      
      private var m_backBt:SimpleButton;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      public function RequestGiftsSelectDialog()
      {
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_RequestsGifts.swf"));
         this.initGifts();
         m_instanceExists = true;
         this.m_title = ZGameUtils.ZlocT("Dialogs","GiftSelectRequestTitle");
         this.m_body = ZGameUtils.ZlocT("Dialogs","GiftSelectRequestBody");
         this.m_hint = ZGameUtils.ZlocT("Dialogs","GiftSelectRequestHint");
      }
      
      public static function instanceExists() : Boolean
      {
         return m_instanceExists;
      }
      
      private function initGifts() : void
      {
         var _loc1_:GameItem = null;
         var _loc3_:Array = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:Array = null;
         var _loc2_:String = ZGlobal.freeGiftPartsBuildingData;
         if(Boolean(_loc2_) && _loc2_.length > 1)
         {
            _loc3_ = _loc2_.split(",");
            for each(_loc4_ in _loc3_)
            {
               _loc6_ = _loc4_.split(":");
               this.m_partsGift[_loc6_[0]] = _loc6_[1];
            }
            _loc3_ = new Array();
            for(_loc5_ in this.m_partsGift)
            {
               _loc1_ = ZGlobal.gameSettings.getItemByCode(_loc5_,GameItem) as GameItem;
               _loc3_.push(_loc1_);
            }
            this.m_gifts = ArrayUtil.createUniqueCopy(_loc3_.concat(ZGlobal.gameSettings.getDisplayableGifts()));
         }
         else
         {
            this.m_gifts = ZGlobal.gameSettings.getDisplayableGifts();
         }
      }
      
      private function get mc() : MovieClip
      {
         return m_window.requests_mc;
      }
      
      override protected function initializeScreen() : void
      {
         super.initializeScreen();
         this.contentWidth = this.mc.background_mc.width;
         this.contentHeight = this.mc.background_mc.height;
         ZGameUtils.hideIfExists(this.mc.background_mc);
         centerWithinStage(Zlab.mainStage);
         TextFieldUtil.compactTextField(this.mc.title_tf,this.m_title,{"minScale":0.5});
         TextFieldUtil.compactTextField(this.mc.body_tf,this.m_body,{"minScale":0.5});
         TextFieldUtil.compactTextField(this.mc.hint_tf,this.m_hint,{"minScale":0.5});
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_buttonSounds.addButton(this.mc.exit_mc,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.mc.forward_bt,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.mc.back_bt,ButtonSound.DEFAULT);
         this.mc.exit_mc.addEventListener(MouseEvent.CLICK,this.exitButtonClicked,false,0,true);
         this.m_currentPage = 1;
         this.createCards();
         this.updateGiftCards();
         this.updateArrows();
      }
      
      override protected function deinitDialog() : void
      {
         this.mc.exit_mc.removeEventListener(MouseEvent.CLICK,this.exitButtonClicked);
         this.mc.forward_bt.removeEventListener(MouseEvent.CLICK,this.onFwdClicked);
         this.mc.back_bt.removeEventListener(MouseEvent.CLICK,this.onBackClicked);
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         this.disposeCards();
         m_instanceExists = false;
         super.deinitDialog();
      }
      
      private function createCards() : void
      {
         var _loc1_:Object = null;
         var _loc2_:Object = null;
         var _loc3_:String = null;
         var _loc4_:RequestGiftCard = null;
         var _loc5_:String = null;
         this.m_cards = new Array();
         for(_loc1_ in this.m_gifts)
         {
            if(_loc1_ != null)
            {
               _loc2_ = this.m_gifts[_loc1_];
               _loc3_ = null;
               if(_loc2_)
               {
                  _loc5_ = _loc2_.code;
                  if(this.m_partsGift.hasOwnProperty(_loc5_))
                  {
                     _loc3_ = this.m_partsGift[_loc5_];
                  }
               }
               _loc4_ = new RequestGiftCard(_loc2_,this.onGiftSelected,_loc3_);
               _loc4_.sounds = ButtonSound.DEFAULT;
               this.m_cards.push(_loc4_);
            }
         }
         this.createDummyCards();
      }
      
      private function createDummyCards() : void
      {
         var _loc1_:RequestGiftCard = null;
         while(this.m_cards.length < this.maxPages * this.maxSlots)
         {
            _loc1_ = new RequestGiftCard(null,this.onGiftSelected);
            this.m_cards.push(_loc1_);
         }
      }
      
      private function disposeCards() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this.m_cards.length)
         {
            this.m_cards[_loc1_].dispose();
            _loc1_++;
         }
      }
      
      private function updateGiftCards() : void
      {
         var _loc2_:int = 0;
         var _loc1_:int = 0;
         while(_loc1_ < this.m_cards.length)
         {
            if(_loc1_ >= (this.m_currentPage - 1) * this.maxSlots && _loc1_ < this.m_currentPage * this.maxSlots)
            {
               _loc2_ = _loc1_ - (this.m_currentPage - 1) * this.maxSlots;
               this.m_cards[_loc1_].setCard(this.mc["card_mc_" + _loc2_]);
            }
            else
            {
               this.m_cards[_loc1_].setCard(null);
            }
            _loc1_++;
         }
      }
      
      private function onGiftSelected() : void
      {
         close();
      }
      
      private function exitButtonClicked(param1:MouseEvent) : void
      {
         close();
      }
      
      private function onFwdClicked(param1:MouseEvent) : void
      {
         this.incrementPage();
      }
      
      private function onBackClicked(param1:MouseEvent) : void
      {
         this.decrementPage();
      }
      
      private function get maxSlots() : int
      {
         return NUM_SLOTS;
      }
      
      private function get maxPages() : int
      {
         return Math.max(1,(this.numGifts - 1) / NUM_SLOTS + 1);
      }
      
      private function get numGifts() : uint
      {
         return this.m_gifts.length;
      }
      
      private function incrementPage() : void
      {
         ++this.m_currentPage;
         if(this.m_currentPage > this.maxPages)
         {
            this.m_currentPage = 1;
         }
         this.updateGiftCards();
         this.updateArrows();
      }
      
      private function decrementPage() : void
      {
         --this.m_currentPage;
         if(this.m_currentPage < 0)
         {
            this.m_currentPage = this.maxPages;
         }
         this.updateGiftCards();
         this.updateArrows();
      }
      
      private function updateArrows() : void
      {
         if(this.m_currentPage > 1)
         {
            ZGameUtils.enableButton(this.mc.back_bt,this.onBackClicked);
         }
         else
         {
            ZGameUtils.disableButton(this.mc.back_bt,this.onBackClicked);
         }
         if(this.m_currentPage < this.maxPages)
         {
            ZGameUtils.enableButton(this.mc.forward_bt,this.onFwdClicked);
         }
         else
         {
            ZGameUtils.disableButton(this.mc.forward_bt,this.onFwdClicked);
         }
      }
   }
}

