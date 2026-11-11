package displays.popups
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.ItemImage;
   import core.managers.ExperimentsManager;
   import core.player.Player;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import fl.containers.UILoader;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import sound.SoundEvent;
   import utils.BitArray;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class LevelUp extends ZGamePopUp
   {
      
      private static var PVP_UNLOCK_CODE:String = "PVPUnlockCode";
      
      private static var DOMINANCE_UNLOCK_CODE:String = "DominanceUnlockCode";
      
      private var m_share:ZGameButton;
      
      protected var m_level:int;
      
      private var m_buyableItems:Array = null;
      
      private var m_decoItems:Array = null;
      
      private var m_unitItems:Array = null;
      
      private var m_contractItems:Array = null;
      
      private var m_loaders:Array = new Array();
      
      private var m_pvpItems:Array = new Array();
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var m_initialized:Boolean = false;
      
      public function LevelUp(param1:int, param2:Array, param3:Array, param4:Array, param5:Array, param6:Array, param7:Boolean = true)
      {
         this.m_level = param1;
         this.m_buyableItems = param2;
         this.m_decoItems = param3;
         this.m_unitItems = param4;
         this.m_contractItems = param5;
         if(this.shouldAddPVPSurfacing && this.isPVPUnlockLevel)
         {
            this.addPVPItem(PVP_UNLOCK_CODE);
         }
         if(this.shouldAddDominationSurfacing && this.isDominanceUnlockLevel)
         {
            this.addPVPItem(DOMINANCE_UNLOCK_CODE);
         }
         super(this.getAssetURL());
      }
      
      protected function addPVPItem(param1:String) : void
      {
         this.m_pvpItems.push(param1);
      }
      
      protected function get shouldAddPVPSurfacing() : Boolean
      {
         return true;
      }
      
      protected function get shouldAddDominationSurfacing() : Boolean
      {
         return true;
      }
      
      protected function getAssetURL() : String
      {
         return ZGlobal.getAssetURL("assets/displays/dialogs/PU_LevelUp.swf");
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         PopupManager.instance.notifyLoadComplete(this);
      }
      
      override public function onShow() : void
      {
         super.onShow();
         this.setupScreen();
         SoundEvent.getSoundEvent("levelUp").play();
      }
      
      protected function get mc() : MovieClip
      {
         return m_window.levelup_mc;
      }
      
      protected function get titleKey() : String
      {
         return "NewLevel";
      }
      
      protected function get descKey() : String
      {
         return "LevelShareDesc";
      }
      
      protected function get unlockedHeaderKey() : String
      {
         return "Unlocked";
      }
      
      protected function setupScreen() : void
      {
         if(!m_window || this.m_initialized)
         {
            return;
         }
         this.m_initialized = true;
         initDialog();
         var _loc1_:String = ZGameUtils.ZlocT("Levels","Level" + this.m_level);
         TextFieldUtil.compactTextField(this.mc.congratulations_tf,ZGameUtils.ZlocT("Dialogs",this.titleKey,{"level":this.m_level}));
         TextFieldUtil.compactTextField(this.mc.canpurchase_tf,ZGameUtils.ZlocT("Dialogs",this.unlockedHeaderKey));
         TextFieldUtil.compactTextField(this.mc.cgItem_tf,ZGameUtils.ZlocT("Dialogs",this.descKey));
         TextFieldUtil.compactTextField(this.mc.note_tf,ZGameUtils.ZlocT("Dialogs","FeedPublishDesc"));
         this.m_share = new ZGameButton(this.mc.share_bt,this.onShareClick);
         this.m_share.compactText(ZGameUtils.ZlocT("Dialogs","LevelShare"),{
            "maxLines":1,
            "minScale":0.4,
            "onFail":"return"
         });
         this.mc.exit_bt.addEventListener(MouseEvent.CLICK,this.onCancelClick);
         var _loc2_:uint = this.getNumItems();
         var _loc3_:Array = this.getCards(_loc2_);
         var _loc4_:int = int(_loc3_.length);
         var _loc5_:int = 0;
         _loc5_ = this.addCards(_loc5_,this.m_pvpItems,_loc3_,_loc4_);
         _loc5_ = this.addCards(_loc5_,this.m_buyableItems,_loc3_,_loc4_);
         _loc5_ = this.addCards(_loc5_,this.m_unitItems,_loc3_,_loc4_);
         _loc5_ = this.addCards(_loc5_,this.m_contractItems,_loc3_,_loc4_);
         _loc5_ = this.addCards(_loc5_,this.m_decoItems,_loc3_,_loc4_);
         while(_loc5_ < _loc4_)
         {
            this.addUnitToCard(null,_loc3_[_loc5_]);
            _loc5_++;
         }
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_buttonSounds.addButton(this.m_share.m_overlay,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.mc.exit_bt,ButtonSound.DEFAULT);
         addChild(m_window);
      }
      
      private function getNumItems() : uint
      {
         var _loc1_:uint = this.m_pvpItems.length + this.m_buyableItems.length + this.m_unitItems.length + this.m_contractItems.length + this.m_decoItems.length;
         return Math.min(_loc1_,4);
      }
      
      protected function get isPVPUnlockLevel() : Boolean
      {
         return this.m_level == ZGlobal.gameSettings.getInt("PVPMinLevel");
      }
      
      protected function get isDominanceUnlockLevel() : Boolean
      {
         return this.m_level == ZGlobal.gameSettings.getInt("DominanceMinLevel");
      }
      
      protected function getCards(param1:uint) : Array
      {
         var _loc2_:MovieClip = this.mc;
         if(param1 % 2 == 0)
         {
            _loc2_.odd_mc.visible = false;
            _loc2_.even_mc.visible = true;
            return [_loc2_.even_mc.item_2,_loc2_.even_mc.item_3,_loc2_.even_mc.item_1,_loc2_.even_mc.item_4];
         }
         _loc2_.odd_mc.visible = true;
         _loc2_.even_mc.visible = false;
         return [_loc2_.odd_mc.item_2,_loc2_.odd_mc.item_1,_loc2_.odd_mc.item_3];
      }
      
      private function addCards(param1:int, param2:Array, param3:Array, param4:int) : int
      {
         var _loc5_:String = null;
         for each(_loc5_ in param2)
         {
            if(param1 > param4 - 1)
            {
               break;
            }
            if(this.addUnitToCard(_loc5_,param3[param1]))
            {
               param1++;
            }
         }
         return param1;
      }
      
      protected function addUnitToCard(param1:String, param2:MovieClip) : Boolean
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:GameItem = null;
         var _loc6_:BitArray = null;
         var _loc7_:ItemImage = null;
         if(param1)
         {
            _loc3_ = null;
            if(param1 == PVP_UNLOCK_CODE)
            {
               _loc4_ = ZGlobal.gameSettings.getString("PVPLevelUpIcon");
               _loc3_ = ZGlobal.getAssetURL(_loc4_);
               TextFieldUtil.compactTextField(param2.itemName_tf,ZGameUtils.ZlocT("Dialogs","PVPLevelUpUnlockLabel"));
            }
            else if(param1 == DOMINANCE_UNLOCK_CODE)
            {
               _loc4_ = ZGlobal.gameSettings.getString("DominationLevelUpIcon");
               _loc3_ = ZGlobal.getAssetURL(_loc4_);
               TextFieldUtil.processTextField(param2.itemName_tf,ZGameUtils.ZlocT("Dialogs","DominationLevelUpUnlockLabel"));
            }
            else
            {
               _loc5_ = ZGlobal.gameSettings.getItemByCode(param1,GameItem) as GameItem;
               _loc6_ = ZGlobal.player.checkGate(_loc5_);
               if(_loc6_.isBitSet(Player.GATE_FAILURE_QUEST))
               {
                  return false;
               }
               if(ZGameTimeUtil.instance.isLimitedEdition(_loc5_.xml))
               {
                  return false;
               }
               if(!ExperimentsManager.instance.validateItem(_loc5_.xml))
               {
                  return false;
               }
               _loc7_ = _loc5_.getCachedImage("icon");
               if(null != _loc7_)
               {
                  _loc3_ = _loc7_.url;
               }
               else
               {
                  _loc3_ = _loc5_.getContractImageURL(ZGlobal.player.rareResourceType);
               }
               TextFieldUtil.compactTextField(param2.itemName_tf,_loc5_.getFriendlyName(GameItem.MENU_FRIENDLYNAME),{
                  "minScale":0.6,
                  "fontSize":16
               });
            }
            this.loadURLImage(_loc3_,param2.icon);
         }
         else if(param2)
         {
            param2.itemName_tf.text = "";
         }
         return true;
      }
      
      protected function loadURLImage(param1:String, param2:UILoader) : void
      {
         var _loc3_:ImageLoader = ImageLoaderFactory.CreateImageLoader(param1,param2);
         if(_loc3_)
         {
            this.m_loaders.push(_loc3_);
         }
      }
      
      private function onShareClick(param1:MouseEvent) : void
      {
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,GenericPopup.ACCEPT));
         close();
      }
      
      private function onCancelClick(param1:MouseEvent) : void
      {
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,GenericPopup.CANCEL));
         close();
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:ImageLoader = null;
         super.deinitDialog();
         this.mc.exit_bt.removeEventListener(MouseEvent.CLICK,this.onCancelClick);
         for each(_loc1_ in this.m_loaders)
         {
            _loc1_.destroy();
         }
         this.m_loaders = null;
         this.m_share.dispose();
         this.m_share = null;
         this.m_buttonSounds.release();
         this.m_buttonSounds = null;
      }
   }
}

