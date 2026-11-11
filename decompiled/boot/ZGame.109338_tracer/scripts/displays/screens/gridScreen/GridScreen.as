package displays.screens.gridScreen
{
   import Engine.MathUtil;
   import com.greensock.TweenLite;
   import core.managers.promoManager.PromoManager;
   import core.managers.tutorialManager.TutorialManager;
   import displays.screens.ItemTooltip;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class GridScreen
   {
      
      public static const CONFIGURE_FOR_ITEM:String = "configureForItem";
      
      protected var m_screen:MovieClip = null;
      
      protected var m_cards:Array = null;
      
      protected var m_width:int = 0;
      
      protected var m_height:int = 0;
      
      protected var m_slotAnchorPosition:Number = 0;
      
      protected var m_clickPosition:int = 0;
      
      protected var m_slotWidth:Number = 0;
      
      protected var m_slotHeight:Number = 0;
      
      protected var m_isVerticalGrid:Boolean = false;
      
      protected var m_cardsPerPage:int = 0;
      
      protected var m_itemTooltip:ItemTooltip = null;
      
      protected var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      protected var m_resource:SWFResource = null;
      
      protected var m_disableRtButton:Boolean = false;
      
      public function GridScreen()
      {
         super();
         TutorialManager.instance.addEventListener(GridScreen.CONFIGURE_FOR_ITEM,this.onConfigureForItem,false,0,true);
      }
      
      public function dispose() : void
      {
         TutorialManager.instance.removeEventListener(GridScreen.CONFIGURE_FOR_ITEM,this.onConfigureForItem);
         this.close();
         this.disposeCards();
         this.m_cards = null;
         if(this.m_itemTooltip)
         {
            this.m_screen.removeChild(this.m_itemTooltip);
         }
         this.m_itemTooltip = null;
         this.m_screen = null;
      }
      
      public function disposeCards() : void
      {
         var _loc1_:GridSlot = null;
         for each(_loc1_ in this.m_cards)
         {
            _loc1_.dispose();
         }
      }
      
      public function updateCards() : void
      {
         this.disposeCards();
         this.createCards(this.m_resource);
      }
      
      protected function load(param1:MovieClip, param2:SWFResource) : void
      {
         this.m_screen = param1;
         this.m_resource = param2;
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.setupArrows();
         this.m_screen.anchor_mc.mask = this.m_screen.mask_mc;
         this.createCards(param2);
         PromoManager.instance.addEventListener(PromoManager.XPROMO_VISIBLE_CARD,this.onVisibleCard);
      }
      
      private function onVisibleCard(param1:WorldEvent) : void
      {
         var _loc4_:String = null;
         var _loc2_:Dictionary = param1.eventData.specialCards;
         var _loc3_:Object = null;
         for(_loc4_ in _loc2_)
         {
            _loc3_ = PromoManager.instance.getXPromoById(parseInt(_loc4_));
            if(_loc3_ != null)
            {
               if(_loc2_[_loc4_].newFriendSlot_mc)
               {
                  _loc2_[_loc4_].newFriendSlot_mc.visible = true;
               }
               _loc2_[_loc4_].profilelevel_tf.visible = false;
               _loc2_[_loc4_].heartlevel_tf.visible = false;
               _loc2_[_loc4_].rareloader_mc.visible = false;
               _loc2_[_loc4_].level_mc.visible = false;
               if(_loc2_[_loc4_][_loc3_.ui.reward_title])
               {
                  _loc2_[_loc4_][_loc3_.ui.reward_title].visible = true;
               }
            }
            else
            {
               _loc2_[_loc4_].cardBack_mc.visible = true;
            }
         }
      }
      
      protected function setupArrows() : void
      {
         this.m_buttonSounds.addButton(this.m_screen.arrowRt_bt,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.m_screen.arrowLt_bt,ButtonSound.DEFAULT);
         this.m_screen.arrowRt_bt.addEventListener(MouseEvent.CLICK,this.onRightClick,false,0,true);
         this.m_screen.arrowLt_bt.addEventListener(MouseEvent.CLICK,this.onLeftClick,false,0,true);
      }
      
      protected function close() : void
      {
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         this.disposeArrows();
         this.disposeTooltips();
      }
      
      protected function disposeArrows() : void
      {
         this.m_screen.arrowRt_bt.removeEventListener(MouseEvent.CLICK,this.onRightClick);
         this.m_screen.arrowLt_bt.removeEventListener(MouseEvent.CLICK,this.onLeftClick);
      }
      
      protected function get buttonSounds() : ButtonMouseEventSoundContainer
      {
         return this.m_buttonSounds;
      }
      
      protected function get getID() : String
      {
         return null;
      }
      
      public function get numCards() : int
      {
         return 0;
      }
      
      protected function getMultFactor() : Number
      {
         return 1;
      }
      
      protected function get screen() : MovieClip
      {
         return this.m_screen;
      }
      
      protected function get width() : int
      {
         return this.m_width;
      }
      
      protected function setDimensions(param1:int, param2:int) : void
      {
         this.m_height = param2;
         this.m_width = param1;
         if(this.m_isVerticalGrid)
         {
            this.m_cardsPerPage = this.m_height;
         }
         else
         {
            this.m_cardsPerPage = this.m_width;
         }
      }
      
      protected function setAnchor(param1:int, param2:int) : void
      {
         if(Boolean(this.m_screen) && Boolean(this.m_screen.anchor_mc))
         {
            this.m_screen.anchor_mc.x = param1;
            this.m_screen.anchor_mc.y = param2;
         }
         this.m_slotAnchorPosition = this.m_isVerticalGrid ? param2 : param1;
      }
      
      protected function get slotAnchorPosition() : Number
      {
         return this.m_slotAnchorPosition;
      }
      
      protected function get slotWidth() : Number
      {
         return this.m_slotWidth;
      }
      
      protected function set clickPosition(param1:Number) : void
      {
         this.m_clickPosition = param1;
      }
      
      protected function get clickPosition() : Number
      {
         return this.m_clickPosition;
      }
      
      protected function createCard(param1:SWFResource, param2:MovieClip, param3:int, param4:int, param5:int = 0) : GridSlot
      {
         return null;
      }
      
      protected function createSpecialCard(param1:SWFResource, param2:MovieClip, param3:int, param4:int) : GridSlot
      {
         return null;
      }
      
      protected function specialCardIsAtFirstSlot() : Boolean
      {
         return false;
      }
      
      protected function hasSpecialCard() : Boolean
      {
         return true;
      }
      
      private function disposeTooltips() : void
      {
         if(this.m_itemTooltip)
         {
            this.m_itemTooltip.destroy();
            this.m_itemTooltip = null;
         }
      }
      
      private function onExitClick(param1:MouseEvent) : void
      {
         this.close();
      }
      
      protected function onRightClick(param1:MouseEvent) : void
      {
         this.slide(-this.m_cardsPerPage);
      }
      
      protected function onLeftClick(param1:MouseEvent) : void
      {
         this.slide(this.m_cardsPerPage);
      }
      
      protected function slide(param1:int, param2:Boolean = true) : void
      {
         var _loc3_:int = MathUtil.clamp(this.clickPosition + param1,-(this.m_cards.length - this.numCardsPerPage),0);
         if(this.clickPosition != _loc3_)
         {
            this.clickPosition = _loc3_;
            this.preUpdateVisibility();
            if(param2)
            {
               if(this.m_isVerticalGrid)
               {
                  TweenLite.to(this.screen.anchor_mc,0.2,{
                     "y":this.slotAnchorPosition + this.clickPosition * this.m_slotHeight,
                     "onComplete":this.postUpdateVisibility
                  });
               }
               else
               {
                  TweenLite.to(this.screen.anchor_mc,0.2,{
                     "x":this.slotAnchorPosition + this.clickPosition * this.m_slotWidth,
                     "onComplete":this.postUpdateVisibility
                  });
               }
            }
            else
            {
               if(this.m_isVerticalGrid)
               {
                  this.screen.anchor_mc.y = this.slotAnchorPosition + this.clickPosition * this.m_slotHeight;
               }
               else
               {
                  this.screen.anchor_mc.x = this.slotAnchorPosition + this.clickPosition * this.m_slotWidth;
               }
               this.postUpdateVisibility();
            }
            this.fixArrows(Math.abs(param1));
         }
      }
      
      protected function preUpdateVisibility() : void
      {
      }
      
      protected function postUpdateVisibility() : void
      {
      }
      
      public function getPage() : int
      {
         return Math.abs(this.m_clickPosition) / this.m_cardsPerPage;
      }
      
      protected function get numCardsPerPage() : uint
      {
         return this.m_height * this.m_width;
      }
      
      protected function goToPage(param1:int, param2:Boolean = true) : void
      {
         this.slide(-(this.m_cardsPerPage * param1),param2);
      }
      
      protected function fixArrows(param1:int) : void
      {
         if(this.m_clickPosition == 0)
         {
            this.enableLeftButtons(false);
         }
         else
         {
            this.enableLeftButtons(true);
         }
         if(this.clickPosition * this.m_height <= -(this.m_cards.length - this.numCardsPerPage))
         {
            this.enableRightButtons(false);
         }
         else
         {
            this.enableRightButtons(true);
         }
      }
      
      protected function enableLeftButtons(param1:Boolean) : void
      {
         ZGameUtils.setButtonEnabled(this.m_screen.arrowLt_bt,this.onLeftClick,param1);
      }
      
      protected function enableRightButtons(param1:Boolean) : void
      {
         ZGameUtils.setButtonEnabled(this.m_screen.arrowRt_bt,this.onRightClick,param1);
      }
      
      protected function forceSpecialCardInEmptyGrid() : Boolean
      {
         return false;
      }
      
      protected function createCards(param1:SWFResource) : void
      {
         var _loc9_:GridSlot = null;
         this.m_cards = new Array();
         var _loc2_:* = this.numCards;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Boolean = false;
         var _loc6_:int = 1;
         var _loc7_:int = 0;
         if(_loc2_ == 0 && this.hasSpecialCard() && this.forceSpecialCardInEmptyGrid())
         {
            _loc5_ = true;
            _loc2_++;
         }
         var _loc8_:Boolean = false;
         if(!_loc8_ && this.specialCardIsAtFirstSlot() && this.hasSpecialCard() && this.m_cards.length == 0)
         {
            _loc2_++;
         }
         while(_loc2_ > 0)
         {
            if(!_loc8_ && this.specialCardIsAtFirstSlot() && this.hasSpecialCard() && this.m_cards.length == 0)
            {
               _loc9_ = this.createSpecialCard(param1,this.m_screen.anchor_mc,_loc3_,_loc4_);
               _loc8_ = true;
            }
            else if(!_loc8_ && (_loc3_ % this.m_width == this.m_width - 1 && _loc4_ == this.m_height - 1 || _loc5_) && this.hasSpecialCard())
            {
               _loc9_ = this.createSpecialCard(param1,this.m_screen.anchor_mc,_loc3_,_loc4_);
               if(!_loc5_)
               {
                  _loc2_++;
               }
            }
            else
            {
               _loc9_ = this.createCard(param1,this.m_screen.anchor_mc,_loc3_,_loc4_,_loc7_);
               _loc7_++;
            }
            if(_loc9_ != null)
            {
               _loc9_.rollOverTarget.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver,false,0,true);
               _loc9_.rollOverTarget.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut,false,0,true);
               this.m_slotWidth = _loc9_.sizerWidth * this.getMultFactor();
               this.m_slotHeight = _loc9_.sizerHeight * this.getMultFactor();
               this.m_cards.push(_loc9_);
            }
            if(this.m_isVerticalGrid)
            {
               _loc4_++;
               _loc2_--;
            }
            else
            {
               if(++_loc3_ >= _loc6_ * this.m_width && _loc4_ < this.m_height - 1)
               {
                  _loc3_ = (_loc6_ - 1) * this.m_width;
                  _loc4_++;
               }
               else if(_loc3_ >= _loc6_ * this.m_width)
               {
                  _loc4_ = 0;
                  _loc6_++;
               }
               _loc2_--;
            }
            if(_loc2_ == 0 && !this.m_cards[this.m_cards.length - 1].isSpecialSlot() && this.hasSpecialCard() && !this.specialCardIsAtFirstSlot())
            {
               _loc5_ = true;
               _loc2_++;
            }
         }
         this.postUpdateVisibility();
         this.fixArrows(this.m_cardsPerPage);
      }
      
      protected function getCardWithRollover(param1:Object) : GridSlot
      {
         var _loc2_:GridSlot = null;
         for each(_loc2_ in this.m_cards)
         {
            if(_loc2_.rollOverTarget == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      protected function onRollOver(param1:MouseEvent) : void
      {
         var _loc3_:MovieClip = null;
         this.disposeTooltips();
         var _loc2_:GridSlot = this.getCardWithRollover(param1.target);
         this.m_itemTooltip = _loc2_.fillOutTooltip();
         if(null != this.m_itemTooltip)
         {
            _loc3_ = _loc2_.slot;
            this.m_screen.addChild(this.m_itemTooltip);
            this.m_itemTooltip.x = _loc3_.x + this.m_screen.anchor_mc.x + _loc3_.width * _loc2_.tooltipAnchorPositionX;
            this.m_itemTooltip.y = _loc3_.y + this.m_screen.anchor_mc.y + _loc3_.height * _loc2_.tooltipAnchorPositionY;
            this.m_itemTooltip.visible = true;
            this.m_itemTooltip.mouseEnabled = false;
            this.m_itemTooltip.mouseChildren = false;
            this.m_itemTooltip.alpha = 0;
            TweenLite.to(this.m_itemTooltip,0.5,{"alpha":1});
         }
      }
      
      protected function onRollOut(param1:MouseEvent) : void
      {
         if(Boolean(this.m_itemTooltip) && this.m_screen.contains(this.m_itemTooltip))
         {
            this.m_screen.removeChild(this.m_itemTooltip);
            this.m_itemTooltip.destroy();
         }
         this.m_itemTooltip = null;
      }
      
      protected function onConfigureForItem(param1:WorldEvent) : void
      {
      }
      
      public function hide() : void
      {
         var _loc1_:GridSlot = null;
         for each(_loc1_ in this.m_cards)
         {
            _loc1_.slot.visible = false;
         }
      }
      
      public function show() : void
      {
         var _loc1_:GridSlot = null;
         for each(_loc1_ in this.m_cards)
         {
            _loc1_.slot.visible = true;
         }
         this.fixArrows(this.m_cardsPerPage);
      }
      
      public function get cards() : Array
      {
         return this.m_cards;
      }
   }
}

