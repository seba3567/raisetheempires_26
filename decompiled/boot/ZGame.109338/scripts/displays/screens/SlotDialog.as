package displays.screens
{
   import core.gameobjects.GameItem;
   import core.managers.tutorialManager.TutorialManager;
   import core.ui.UIManager;
   import core.ui.menuitem.PlayerStatsUIItem;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.ZGameUtils;
   import zlabs.managers.WindowManager;
   
   public class SlotDialog extends ZGamePopUp
   {
      
      protected var m_data:Array = [];
      
      protected var m_tileSet:int = 0;
      
      protected var m_tiles:Array = new Array();
      
      protected var m_buildButtons:Array = new Array(this.getNumSlots());
      
      protected var m_unlockContractButtons:Array = new Array(this.getNumSlots());
      
      protected var m_rarePanelAlreadyVisible:Boolean = false;
      
      protected var m_initData:Object;
      
      protected var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      public function SlotDialog(param1:String)
      {
         super(param1);
      }
      
      override protected function initDialog() : void
      {
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         if(m_window)
         {
            this.m_buttonSounds.addButton(m_window.arrowLt_bt,ButtonSound.DEFAULT);
            this.m_buttonSounds.addButton(m_window.arrowRt_bt,ButtonSound.DEFAULT);
         }
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).toggleRarePanel(true);
         super.initDialog();
         dispatchEvent(new Event(Event.COMPLETE));
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).moveToNewLayer(WindowManager.instance.container,0);
      }
      
      override protected function deinitDialog() : void
      {
         if(m_window)
         {
            m_window.arrowLt_bt.removeEventListener(MouseEvent.CLICK,this.onLtArrowClick);
            m_window.arrowRt_bt.removeEventListener(MouseEvent.CLICK,this.onRtArrowClick);
         }
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).toggleRarePanel(false);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).moveToNewLayer(UIManager.instance.uiDisplay,0);
         super.deinitDialog();
      }
      
      protected function addTile(param1:MovieClip) : void
      {
         this.m_tiles.push(param1);
         this.m_buttonSounds.addButton(param1,ButtonSound.PANEL);
      }
      
      protected function fixArrows() : void
      {
         if(this.m_tileSet > 0)
         {
            ZGameUtils.enableButton(m_window.arrowLt_bt,this.onLtArrowClick);
         }
         else
         {
            ZGameUtils.disableButton(m_window.arrowLt_bt,this.onLtArrowClick);
         }
         var _loc1_:Boolean = false;
         if(Boolean(this.m_initData) && Boolean(this.m_initData.tab) && Boolean(this.m_initData.disableStoreTabs))
         {
            _loc1_ = true;
         }
         if((this.m_tileSet + 1) * this.getNumSlots() < this.m_data.length && !_loc1_)
         {
            ZGameUtils.enableButton(m_window.arrowRt_bt,this.onRtArrowClick);
         }
         else
         {
            ZGameUtils.disableButton(m_window.arrowRt_bt,this.onRtArrowClick);
         }
      }
      
      protected function gameItemCodeIsInData(param1:String) : Boolean
      {
         var _loc3_:GameItem = null;
         var _loc2_:Boolean = false;
         for each(_loc3_ in this.m_data)
         {
            if(_loc3_.code == param1)
            {
               _loc2_ = true;
               break;
            }
         }
         return _loc2_;
      }
      
      protected function gotoTileSetFromGameItemCode(param1:String) : void
      {
         var _loc2_:GameItem = null;
         var _loc3_:int = 0;
         if(this.gameItemCodeIsInData(param1))
         {
            _loc3_ = 0;
            while(_loc3_ < this.m_data.length)
            {
               _loc2_ = this.m_data[_loc3_];
               if(_loc2_.code == param1)
               {
                  this.setCurrentTileSet(int(_loc3_ / this.getNumSlots()));
                  break;
               }
               _loc3_++;
            }
         }
      }
      
      protected function setCurrentTileSet(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(param1 >= 0 && param1 * this.getNumSlots() < this.m_data.length)
         {
            this.removeTiles();
            this.m_tileSet = param1;
            _loc2_ = this.m_tileSet * this.getNumSlots();
            _loc3_ = 0;
            while(_loc3_ < this.getNumSlots())
            {
               this.addComponent(_loc3_,_loc2_);
               _loc3_++;
            }
         }
         this.fixArrows();
      }
      
      protected function onLtArrowClick(param1:MouseEvent) : void
      {
         if(Boolean(this.m_initData) && Boolean(this.m_initData.motd))
         {
            TutorialManager.instance.removeArrows();
         }
         this.setCurrentTileSet(this.m_tileSet - 1);
      }
      
      protected function onRtArrowClick(param1:MouseEvent) : void
      {
         if(Boolean(this.m_initData) && Boolean(this.m_initData.motd))
         {
            TutorialManager.instance.removeArrows();
         }
         this.setCurrentTileSet(this.m_tileSet + 1);
      }
      
      public function refreshLayout() : void
      {
         this.removeTiles();
         var _loc1_:int = this.m_tileSet * this.getNumSlots();
         var _loc2_:int = 0;
         while(_loc2_ < this.getNumSlots() && _loc1_ + _loc2_ < this.m_data.length)
         {
            this.addComponent(_loc2_,_loc1_);
            _loc2_++;
         }
         this.fixArrows();
      }
      
      protected function removeTiles() : void
      {
         this.preRemoveTiles();
         var _loc1_:int = 0;
         while(_loc1_ < this.getNumSlots())
         {
            if(this.m_tiles != null && this.m_tiles[_loc1_] != null)
            {
               this.m_tiles[_loc1_].visible = false;
               this.postRemoveTiles(_loc1_);
            }
            _loc1_++;
         }
      }
      
      protected function addAllComponents(param1:int) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.getNumSlots())
         {
            if(this.m_tiles[_loc2_] != null)
            {
               this.addComponent(_loc2_,param1);
            }
            _loc2_++;
         }
      }
      
      protected function addComponent(param1:int, param2:int = 0) : void
      {
         throw new Error("This function needs to be overriden");
      }
      
      protected function postRemoveTiles(param1:int) : void
      {
         if(this.m_buildButtons[param1])
         {
            this.m_buildButtons[param1].dispose();
            this.m_buildButtons[param1] = null;
         }
         if(this.m_unlockContractButtons[param1])
         {
            this.m_unlockContractButtons[param1].dispose();
            this.m_unlockContractButtons[param1] = null;
         }
      }
      
      protected function preRemoveTiles() : void
      {
      }
      
      protected function getNumSlots() : int
      {
         throw new Error("This function needs to be overriden");
      }
      
      protected function indexOfTileContaining(param1:DisplayObject) : int
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.m_tiles.length)
         {
            if(this.m_tiles[_loc2_].contains(param1))
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
   }
}

