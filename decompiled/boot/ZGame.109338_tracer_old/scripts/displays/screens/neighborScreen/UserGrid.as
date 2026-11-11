package displays.screens.neighborScreen
{
   import Engine.MathUtil;
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.managers.AlliancesManager;
   import core.managers.ExperimentsManager;
   import core.player.Friend;
   import core.player.Player;
   import dispatchers.ExperienceDispatcher;
   import dispatchers.NeighborsDispatcher;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.screens.gridScreen.GridScreen;
   import displays.screens.gridScreen.GridSlot;
   import events.ExperienceUpdatedEvent;
   import events.FriendBarEvent;
   import events.RepositionEvent;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import sound.ButtonSound;
   import utils.ZGameUtils;
   import zgame.assets.ui.FriendBar.*;
   import zlabs.Zlab;
   import zlabs.resource.SWFResource;
   
   public class UserGrid extends GridScreen
   {
      
      private static const MAX_NEIGHBOR_SLOTS_VISIBLE:int = 12;
      
      private static const CONTEXT_MENU_X_OFFSET:int = -10;
      
      private static const CONTEXT_MENU_Y_OFFSET:int = -20;
      
      protected var m_target:MovieClip = null;
      
      protected var m_neighbors:Array = new Array();
      
      protected var m_owner:Object = null;
      
      protected var m_actualNeighbors:Array = new Array();
      
      protected var m_friendsLoaded:Boolean = false;
      
      protected var m_cardWidth:int = 0;
      
      protected var m_imageLoader:ImageLoader = null;
      
      protected var m_contextMenu:MovieClip;
      
      protected var m_contextSlot:Object = null;
      
      protected var m_storedPosition:int = 0;
      
      protected var m_numSlots:int = 7;
      
      public function UserGrid(param1:MovieClip, param2:Array, param3:Object)
      {
         super();
         this.m_target = param1;
         this.m_owner = param3;
         this.configureForWidth(this.m_owner.neighborGridWidth);
         setDimensions(this.numSlots,1);
         this.loadNeighbors(param2);
      }
      
      protected function get maxVisibleSlots() : int
      {
         return MAX_NEIGHBOR_SLOTS_VISIBLE;
      }
      
      protected function configureForWidth(param1:Number) : void
      {
         var _loc2_:Number = Number(this.target.slot_0.width);
         this.m_numSlots = Math.min(Math.floor(param1 / _loc2_),this.maxVisibleSlots);
         this.target.mask_mc.width = this.m_numSlots * _loc2_;
         this.target.slot_0.x = this.target.mask_mc.x + (this.m_numSlots - 1) * _loc2_;
         this.target.arrowRt_bt.x = this.target.arrowSingleRt_bt.x = this.target.mask_mc.x + this.target.mask_mc.width + 4;
      }
      
      public function onResize() : void
      {
         var _loc1_:int = width;
         var _loc2_:int = m_cardsPerPage;
         var _loc3_:int = clickPosition;
         this.configureForWidth(this.m_owner.neighborGridWidth);
         setDimensions(this.numSlots,1);
         if(width != _loc1_ || m_cardsPerPage != _loc2_)
         {
            disposeCards();
            m_clickPosition = 0;
            this.loadNeighbors(this.neighbors);
            if(this.m_storedPosition != 0)
            {
               this.slide(this.m_storedPosition,false);
            }
         }
      }
      
      public function uiWidth() : Number
      {
         return this.m_numSlots * this.target.slot_0.width;
      }
      
      private function onBarResize(param1:RepositionEvent) : void
      {
         this.disposeMenu();
      }
      
      protected function get numSlots() : int
      {
         return this.m_numSlots;
      }
      
      override protected function load(param1:MovieClip, param2:SWFResource) : void
      {
         m_cards = new Array();
         super.load(param1,param2);
         screen.mask_mc.visible = true;
         setAnchor(param1.slot_0.x,param1.slot_0.y);
         screen.arrowSingleRt_bt.addEventListener(MouseEvent.CLICK,this.onSingleRightClick,false,0,true);
         screen.arrowSingleLt_bt.addEventListener(MouseEvent.CLICK,this.onSingleLeftClick,false,0,true);
         m_buttonSounds.addButton(screen.arrowSingleRt_bt,ButtonSound.DEFAULT);
         m_buttonSounds.addButton(screen.arrowSingleLt_bt,ButtonSound.DEFAULT);
         ExperienceDispatcher.instance.addEventListener(ExperienceUpdatedEvent.EXPERIENCE,this.recreateCards);
         UIDispatcher.instance.addEventListener(RepositionEvent.REPOSITION_FRIENDBAR,this.onBarResize);
         this.startTendTimeout();
      }
      
      override protected function close() : void
      {
         super.close();
         Zlab.processManager.removeScheduledObject(this);
         screen.arrowSingleRt_bt.removeEventListener(MouseEvent.CLICK,this.onSingleRightClick);
         screen.arrowSingleLt_bt.removeEventListener(MouseEvent.CLICK,this.onSingleLeftClick);
         ExperienceDispatcher.instance.removeEventListener(ExperienceUpdatedEvent.EXPERIENCE,this.recreateCards);
         UIDispatcher.instance.removeEventListener(RepositionEvent.REPOSITION_FRIENDBAR,this.onBarResize);
      }
      
      public function get neighbors() : Array
      {
         return this.m_actualNeighbors;
      }
      
      override public function get numCards() : int
      {
         return this.m_neighbors.length;
      }
      
      protected function get target() : MovieClip
      {
         return this.m_target;
      }
      
      override protected function getMultFactor() : Number
      {
         return 1;
      }
      
      override protected function hasSpecialCard() : Boolean
      {
         return false;
      }
      
      protected function shouldBeCustomCard(param1:Object) : Boolean
      {
         return false;
      }
      
      protected function createCustomCard(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:int) : GridSlot
      {
         return null;
      }
      
      override protected function createCard(param1:SWFResource, param2:MovieClip, param3:int, param4:int, param5:int = 0) : GridSlot
      {
         var _loc6_:int = -param5 * (this.m_cardWidth * this.getMultFactor());
         var _loc7_:GridSlot = null;
         if(this.m_neighbors[param5] as Boolean != null)
         {
            _loc7_ = new InviteNeighborSlot(param1,param2,screen,_loc6_);
         }
         else if(this.shouldBeCustomCard(this.m_neighbors[param5]))
         {
            _loc7_ = this.createCustomCard(param1,param2,screen,param5);
         }
         else
         {
            _loc7_ = new this.gridSlotClass(param1,param2,screen,_loc6_,this.m_neighbors[param5],this.slotClass,param5);
            if(!NeighborSlot(_loc7_).empty && _loc7_.hasContextMenu)
            {
               _loc7_.slot.addEventListener(MouseEvent.CLICK,this.onCardClicked);
               _loc7_.slot.addEventListener(MouseEvent.ROLL_OVER,this.onCardOver);
               _loc7_.slot.addEventListener(MouseEvent.ROLL_OUT,this.onCardOut);
            }
         }
         if(this.m_cardWidth == 0)
         {
            this.m_cardWidth = _loc7_.sizerWidth;
         }
         return _loc7_;
      }
      
      public function loadCardImages() : void
      {
         var _loc3_:GridSlot = null;
         var _loc4_:NeighborSlot = null;
         var _loc1_:uint = m_clickPosition + m_cardsPerPage;
         var _loc2_:uint = uint(m_clickPosition);
         while(_loc2_ < _loc1_)
         {
            _loc3_ = m_cards[_loc2_];
            _loc4_ = _loc3_ as NeighborSlot;
            if(_loc4_)
            {
               _loc4_.loadImage();
            }
            _loc2_++;
         }
      }
      
      public function getNeighborSlot(param1:String) : NeighborSlot
      {
         var _loc2_:GridSlot = null;
         var _loc3_:NeighborSlot = null;
         for each(_loc2_ in m_cards)
         {
            _loc3_ = _loc2_ as NeighborSlot;
            if(_loc3_)
            {
               if(_loc3_.uid == param1)
               {
                  return _loc3_;
               }
            }
         }
         return null;
      }
      
      private function onCardClicked(param1:MouseEvent) : void
      {
         if(Boolean(this.m_contextMenu) && Boolean(this.m_contextMenu.visible) && this.m_contextMenu.mc.neighborSlot == param1.currentTarget.neighborSlot)
         {
            this.menuClicked();
         }
         this.updateContextMenu(param1);
      }
      
      private function onCardOver(param1:MouseEvent) : void
      {
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = false;
         var _loc2_:Object = ZGlobal.player.neighbors[param1.currentTarget.neighborSlot.uid];
         if(!AlliancesManager.isLevelOk() || !AlliancesManager.isExperimentEnabled() || Boolean(_loc2_) && Boolean(!_loc2_.clanInit))
         {
            return;
         }
         if(Boolean(_loc2_) && param1.currentTarget.neighborSlot.uid > 0)
         {
            _loc3_ = _loc2_.clanId == null || _loc2_.clanId == "";
            _loc4_ = AlliancesManager.instance.clanName == null || AlliancesManager.instance.clanName == "";
            if(Boolean(param1.currentTarget.clanDataInit) && Boolean(param1.currentTarget.popup_mc))
            {
               this.setupTooltip(param1);
               if(_loc3_ && _loc4_)
               {
                  param1.currentTarget.popup_mc.visible = false;
               }
               else
               {
                  param1.currentTarget.popup_mc.visible = true;
               }
            }
            else
            {
               param1.currentTarget.popup_mc = new popup_mc();
               param1.currentTarget.popup_mc.title_tf.visible = false;
               param1.currentTarget.popup_mc.add_bt.visible = false;
               param1.currentTarget.popup_mc.generic2_tf.visible = false;
               param1.currentTarget.popup_mc.addEventListener(MouseEvent.ROLL_OUT,this.onAllianceCardOut,false,0,true);
               param1.currentTarget.neighborSlot.configureTooltip(param1.currentTarget.neighborSlot.uid,param1.currentTarget);
               param1.currentTarget.clanDataInit = true;
               param1.currentTarget.popup_mc.visible = true;
               this.setupTooltip(param1);
            }
         }
      }
      
      private function onAllianceCardOut(param1:MouseEvent) : void
      {
         if(param1.currentTarget)
         {
            param1.currentTarget.visible = false;
         }
      }
      
      private function onCardOut(param1:MouseEvent) : void
      {
         var _loc2_:DisplayObjectContainer = null;
         if(Boolean(param1.relatedObject) && (param1.relatedObject.parent == param1.currentTarget.popup_mc || param1.relatedObject == param1.currentTarget.popup_mc))
         {
            return;
         }
         if(param1.currentTarget.popup_mc)
         {
            param1.currentTarget.popup_mc.removeEventListener(MouseEvent.ROLL_OUT,this.onAllianceCardOut);
            param1.currentTarget.popup_mc.visible = false;
            _loc2_ = screen.parent.parent.parent;
            _loc2_.removeChild(param1.currentTarget.popup_mc);
            param1.currentTarget.popup_mc = null;
         }
      }
      
      private function setupTooltip(param1:MouseEvent) : void
      {
         var _loc2_:DisplayObjectContainer = null;
         _loc2_ = screen.parent.parent.parent;
         var _loc3_:int = param1.currentTarget.width / 3;
         if(param1.currentTarget.centerMarker_mc)
         {
            _loc3_ = int(param1.currentTarget.centerMarker_mc.x);
         }
         param1.currentTarget.popup_mc.x = screen.parent.parent.x + (param1.currentTarget.parent.x + param1.currentTarget.x) + _loc3_;
         param1.currentTarget.popup_mc.y = screen.parent.parent.y + (param1.currentTarget.parent.y + param1.currentTarget.y) + 10;
         _loc2_.addChild(param1.currentTarget.popup_mc);
      }
      
      protected function disposeMenu() : void
      {
         if(this.m_contextMenu)
         {
            this.m_contextMenu.removeEventListener(MouseEvent.ROLL_OUT,this.onOutMenu);
            this.m_contextMenu.dispose();
            this.m_contextMenu = null;
         }
      }
      
      protected function createContextMenu(param1:MouseEvent) : void
      {
      }
      
      private function onSingleRightClick(param1:MouseEvent) : void
      {
         this.slide(-1);
      }
      
      private function onSingleLeftClick(param1:MouseEvent) : void
      {
         this.slide(1);
      }
      
      override protected function slide(param1:int, param2:Boolean = true) : void
      {
         var _loc4_:int = 0;
         var _loc3_:int = MathUtil.clamp(clickPosition + param1,0,this.numCards - width);
         if(clickPosition != _loc3_)
         {
            clickPosition = _loc3_;
            _loc4_ = slotAnchorPosition + clickPosition * this.m_cardWidth;
            if(param2)
            {
               this.m_storedPosition = clickPosition;
               TweenLite.to(screen.anchor_mc,0.2,{"x":_loc4_});
            }
            else
            {
               screen.anchor_mc.x = _loc4_;
            }
            this.fixArrows(Math.abs(param1));
         }
         NeighborsDispatcher.instance.dispatchEvent(new FriendBarEvent(FriendBarEvent.MOVE,param1));
      }
      
      override protected function fixArrows(param1:int) : void
      {
         if(clickPosition == 0)
         {
            screen.arrowRt_bt.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
            screen.arrowRt_bt.mouseEnabled = false;
            screen.arrowSingleRt_bt.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
            screen.arrowSingleRt_bt.mouseEnabled = false;
         }
         else
         {
            screen.arrowRt_bt.filters = null;
            screen.arrowRt_bt.mouseEnabled = true;
            screen.arrowSingleRt_bt.filters = null;
            screen.arrowSingleRt_bt.mouseEnabled = true;
         }
         if(clickPosition >= this.numCards - width)
         {
            screen.arrowLt_bt.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
            screen.arrowLt_bt.mouseEnabled = false;
            screen.arrowSingleLt_bt.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
            screen.arrowSingleLt_bt.mouseEnabled = false;
         }
         else
         {
            screen.arrowLt_bt.filters = null;
            screen.arrowLt_bt.mouseEnabled = true;
            screen.arrowSingleLt_bt.filters = null;
            screen.arrowSingleLt_bt.mouseEnabled = true;
         }
      }
      
      override protected function onRollOver(param1:MouseEvent) : void
      {
      }
      
      override protected function onRollOut(param1:MouseEvent) : void
      {
      }
      
      protected function addVarients(param1:Array) : void
      {
      }
      
      private function loadNeighbors(param1:Array) : void
      {
         this.m_neighbors = param1;
         this.populateNeighbors(this.m_neighbors);
         this.load(this.m_target,null);
      }
      
      protected function populateNeighbors(param1:Array, param2:Boolean = true) : void
      {
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_SKIP_NEIGHBOR_PRUNE) == 0)
         {
            this.removeUnfriendlyNeighbors(param1);
         }
         this.m_actualNeighbors = param1.slice();
         this.addLocalPlayerToNeighbors(param1);
         this.addEmptySlots(param1);
      }
      
      protected function pruneNeighbors(param1:Array) : Array
      {
         var _loc3_:* = undefined;
         var _loc2_:Array = new Array();
         for each(_loc3_ in param1)
         {
            if(_loc3_ != true)
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
      
      protected function addEmptySlots(param1:Array) : void
      {
      }
      
      protected function inviteNeighborToken() : Boolean
      {
         return true;
      }
      
      protected function removeUnfriendlyNeighbors(param1:Array) : void
      {
      }
      
      protected function addLocalPlayerToNeighbors(param1:Array) : void
      {
      }
      
      private function getPlayerIndex(param1:Player) : int
      {
         var _loc2_:int = int(this.m_neighbors.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if(this.m_neighbors[_loc3_] as Friend)
            {
               if(param1.uid == this.m_neighbors[_loc3_].uid)
               {
                  break;
               }
            }
            _loc3_++;
         }
         return _loc3_;
      }
      
      private function getSortedIndex(param1:Number) : int
      {
         var _loc2_:int = int(this.m_neighbors.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if(this.m_neighbors[_loc3_] as Friend)
            {
               if(param1 >= this.m_neighbors[_loc3_].m_xp)
               {
                  break;
               }
            }
            _loc3_++;
         }
         return _loc3_;
      }
      
      protected function doesLocalPlayerChangePosition(param1:int) : Boolean
      {
         var _loc2_:int = this.getPlayerIndex(ZGlobal.player);
         var _loc3_:int = this.getSortedIndex(param1);
         return _loc2_ != _loc3_;
      }
      
      protected function findNeighborById(param1:String) : Friend
      {
         var _loc2_:Friend = null;
         var _loc3_:int = 0;
         while(_loc3_ < this.neighbors.length)
         {
            if(this.neighbors[_loc3_].id == param1)
            {
               _loc2_ = this.neighbors[_loc3_];
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      protected function onOutSlot(param1:MouseEvent) : void
      {
         if(!param1.relatedObject || param1.relatedObject.parent != this.m_contextMenu.mc)
         {
            this.disposeMenu();
         }
         this.unfocusSlot();
      }
      
      protected function onOutMenu(param1:MouseEvent) : void
      {
         this.menuClicked();
      }
      
      protected function menuClicked() : void
      {
         this.disposeMenu();
         this.unfocusSlot();
      }
      
      protected function unfocusSlot() : void
      {
         if(this.m_contextSlot)
         {
            this.m_contextSlot.removeEventListener(MouseEvent.ROLL_OUT,this.onOutSlot);
            this.m_contextSlot = null;
         }
      }
      
      public function onVisitClick(param1:NeighborSlot, param2:String) : void
      {
      }
      
      public function onAttackClick(param1:NeighborSlot, param2:Boolean) : void
      {
      }
      
      public function onPillageClick(param1:NeighborSlot) : void
      {
      }
      
      public function onGiftClick(param1:NeighborSlot) : void
      {
      }
      
      public function onRequestResourceClick(param1:NeighborSlot) : void
      {
      }
      
      public function onMarketClick(param1:NeighborSlot) : void
      {
      }
      
      public function recreateCards(param1:ExperienceUpdatedEvent) : void
      {
      }
      
      public function onAllianceClick(param1:NeighborSlot) : void
      {
      }
      
      public function onAllianceJoinClick(param1:NeighborSlot) : void
      {
      }
      
      public function updateCardStatus() : void
      {
         var _loc1_:GridSlot = null;
         for each(_loc1_ in m_cards)
         {
            if(_loc1_ as NeighborSlot)
            {
               NeighborSlot(_loc1_).configureAppearance();
            }
         }
      }
      
      public function updateCardRareIcon() : void
      {
         var _loc1_:GridSlot = null;
         for each(_loc1_ in m_cards)
         {
            if(_loc1_ as NeighborSlot)
            {
               NeighborSlot(_loc1_).configureRareIcon();
            }
         }
      }
      
      public function updateCardBountyIcon() : void
      {
         var _loc1_:GridSlot = null;
         for each(_loc1_ in m_cards)
         {
            if(_loc1_ as NeighborSlot)
            {
               NeighborSlot(_loc1_).configureBountyIcon();
            }
         }
      }
      
      protected function startTendTimeout() : void
      {
      }
      
      protected function get slotClass() : Class
      {
         return FriendSlot;
      }
      
      protected function get gridSlotClass() : Class
      {
         return NeighborSlot;
      }
      
      private function updateContextMenu(param1:MouseEvent) : void
      {
         var _loc2_:DisplayObjectContainer = null;
         this.disposeMenu();
         this.createContextMenu(param1);
         if(this.m_contextMenu)
         {
            _loc2_ = screen.parent.parent.parent;
            _loc2_.addChild(this.m_contextMenu);
            this.m_contextMenu.x = screen.parent.parent.x + (param1.currentTarget.parent.x + param1.currentTarget.x) + param1.currentTarget.width * 0.5;
            this.m_contextMenu.y = screen.parent.parent.y + (param1.currentTarget.parent.y + param1.currentTarget.y) + param1.currentTarget.height * 0.5 + CONTEXT_MENU_Y_OFFSET;
            this.m_contextMenu.addEventListener(MouseEvent.ROLL_OUT,this.onOutMenu,false,0,true);
            this.m_contextSlot = param1.currentTarget;
            this.m_contextSlot.addEventListener(MouseEvent.ROLL_OUT,this.onOutSlot,false,0,true);
         }
      }
   }
}

