package displays.screens
{
   import core.managers.tutorialManager.TutorialManager;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class CategoryDialog extends SlotDialog
   {
      
      protected var m_categoryWindow:MovieClip;
      
      protected var m_tooltip:ItemTooltip = null;
      
      protected var m_iconLoaders:Array;
      
      protected var m_categoryButtons:Array = null;
      
      protected var m_categoryIndex:int = 0;
      
      protected var m_numCategories:int = 0;
      
      public function CategoryDialog(param1:String = "")
      {
         super(param1);
         this.contentWidth = this.m_categoryWindow.width;
         this.contentHeight = this.m_categoryWindow.height;
         m_origOffsetX = this.m_categoryWindow.x;
         m_origOffsetY = this.m_categoryWindow.y;
         addChild(this.m_categoryWindow);
      }
      
      protected function initCategoryButtons() : void
      {
         var _loc3_:XML = null;
         var _loc4_:CategoryDialogTab = null;
         var _loc1_:XMLList = this.getCategories();
         this.m_numCategories = _loc1_.length();
         this.m_categoryButtons = new Array();
         var _loc2_:int = 0;
         while(_loc2_ < this.m_numCategories)
         {
            _loc3_ = _loc1_[_loc2_];
            _loc4_ = new CategoryDialogTab(this.m_categoryWindow["tab" + _loc2_],_loc2_,_loc3_,this.onClick);
            m_buttonSounds.addButton(_loc4_.overlay,ButtonSound.DEFAULT);
            if(Boolean(m_initData) && Boolean(m_initData.disableStoreTabs) && this.getTabIndexFromLabel(m_initData.tab) != _loc2_)
            {
               _loc4_.enabled = false;
            }
            if(_loc3_.@label == "New")
            {
               _loc4_.showNewText(true);
            }
            this.m_categoryButtons.push(_loc4_);
            _loc2_++;
         }
      }
      
      protected function selectCategoryButton(param1:int) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.m_numCategories)
         {
            this.m_categoryButtons[_loc2_].selected = false;
            this.dispatchCategoryHighlightEvent(_loc2_);
            _loc2_++;
         }
         if(param1 < this.m_numCategories)
         {
            this.m_categoryButtons[param1].selected = true;
            TextFieldUtil.processTextField(this.m_categoryWindow.selected_tf,ZGameUtils.ZlocT("Dialogs",this.m_categoryButtons[param1].xml.@displayKey));
            this.showCategory(param1);
         }
      }
      
      protected function showCategory(param1:int) : void
      {
         this.removeTiles();
         this.m_categoryIndex = param1;
         m_tileSet = 0;
         m_data = new Array();
         var _loc2_:XML = this.m_categoryButtons[param1].xml;
         this.addItemsToCategories(param1,_loc2_);
         addAllComponents(0);
         if(Boolean(m_initData) && m_initData.hasOwnProperty("focusGameItemCode"))
         {
            gotoTileSetFromGameItemCode(m_initData.focusGameItemCode);
         }
         else
         {
            setCurrentTileSet(m_tileSet);
         }
      }
      
      override protected function removeTiles() : void
      {
         if(null != this.m_tooltip)
         {
            this.m_tooltip.parent.removeChild(this.m_tooltip);
            this.m_tooltip.destroy();
            this.m_tooltip = null;
         }
         super.removeTiles();
      }
      
      override public function onShow() : void
      {
         this.m_iconLoaders = new Array();
         this.m_categoryWindow.exit_bt.addEventListener(MouseEvent.MOUSE_UP,this.onCloseClick,false,0,true);
         initDialog();
         if(Boolean(m_initData) && Boolean(m_initData.tab))
         {
            this.selectCategoryButton(this.getTabIndexFromLabel(m_initData.tab));
         }
         else
         {
            this.selectCategoryButton(this.getStoredTab());
         }
         if(Boolean(m_initData) && Boolean(m_initData.disableStoreTabs))
         {
            ZGameUtils.disableButton(this.m_categoryWindow.exit_bt,this.onCloseClick);
         }
      }
      
      protected function getTabIndexFromLabel(param1:String) : Number
      {
         var _loc4_:XML = null;
         var _loc2_:XMLList = this.getCategories();
         var _loc3_:Number = 0;
         for each(_loc4_ in _loc2_)
         {
            if(_loc4_.@label == param1)
            {
               return _loc3_;
            }
            _loc3_++;
         }
         return this.getStoredTab();
      }
      
      protected function getCategories() : XMLList
      {
         return null;
      }
      
      protected function dispatchCategoryHighlightEvent(param1:int) : void
      {
      }
      
      protected function dispatchCategoryClickEvent(param1:int) : void
      {
      }
      
      protected function addItemsToCategories(param1:int, param2:XML) : void
      {
         this.addItems(param2);
      }
      
      protected function addItems(param1:XML) : void
      {
      }
      
      protected function getStoredTab() : int
      {
         return 0;
      }
      
      protected function setStoredTab(param1:int) : void
      {
         this.dispatchCategoryClickEvent(param1);
      }
      
      protected function onCloseClick(param1:MouseEvent) : void
      {
         var _loc2_:CategoryDialogTab = null;
         this.removeTiles();
         this.m_categoryWindow.exit_bt.removeEventListener(MouseEvent.CLICK,this.onCloseClick);
         for each(_loc2_ in this.m_categoryButtons)
         {
            _loc2_.destroy();
         }
         this.m_categoryButtons = null;
         if(param1)
         {
            param1.stopPropagation();
         }
         close();
      }
      
      protected function onClick(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         if(param1 != null)
         {
            _loc2_ = this.indexOfTabContaining(param1.target as DisplayObject);
            if(_loc2_ != this.m_categoryIndex)
            {
               this.setStoredTab(_loc2_);
               this.selectCategoryButton(_loc2_);
            }
         }
         if(Boolean(m_initData) && Boolean(m_initData.motd))
         {
            TutorialManager.instance.removeArrows();
         }
      }
      
      protected function indexOfTabContaining(param1:DisplayObject) : int
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.m_categoryButtons.length)
         {
            if(this.m_categoryButtons[_loc2_].clip.contains(param1))
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
   }
}

