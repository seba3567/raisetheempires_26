package displays.popups.quest
{
   import ZQuest.Init.QuestSettingsInit;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.ItemImage;
   import core.managers.MegaseriesManager;
   import core.managers.RUXManager;
   import core.managers.questManager.ZGameQuest;
   import core.managers.questManager.ZGameQuestManager;
   import core.player.questTrees.QuestTree;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import utils.getVisibleBounds;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class QuestPopup extends ZGamePopUp
   {
      
      private var m_textObj:Object = null;
      
      protected var m_id:String = null;
      
      protected var m_acceptBt:ZGameButton = null;
      
      private var m_initialized:Boolean;
      
      protected var m_isQuestTree:Boolean;
      
      protected var m_avatarLoader:ImageLoader;
      
      protected var questTree:QuestTree = null;
      
      protected var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      public function QuestPopup(param1:String, param2:Boolean = false)
      {
         this.m_id = param1;
         this.m_textObj = this.getTextObject(this.m_id);
         var _loc3_:String = null;
         var _loc4_:String = ZGlobal.player.questTrees.getQuestTreeNameForQuest(this.m_id);
         var _loc5_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(this.m_id as String) as ZGameQuest;
         if(this.m_id.indexOf(RUXManager.questPrefix) == 0)
         {
            this.m_isQuestTree = false;
            _loc3_ = RUXManager.questAsset;
         }
         else if(_loc4_)
         {
            this.m_isQuestTree = true;
            this.questTree = ZGlobal.player.questTrees.getQuestTree(_loc4_);
            _loc3_ = this.questTree.detailsUrl;
         }
         else if(MegaseriesManager.instance.isMegaseriesQuest(this.m_id))
         {
            this.m_isQuestTree = false;
            _loc3_ = MegaseriesManager.instance.getAssetPopupFile(MegaseriesManager.instance.isMegaseriesQuest(this.m_id));
         }
         else if(MegaseriesManager.instance.isMegaseriesReward(this.id) != null && MegaseriesManager.instance.isMegaseriesReward(this.id) != "MS01")
         {
            this.m_isQuestTree = false;
            _loc3_ = MegaseriesManager.instance.getAssetPopupFile(MegaseriesManager.instance.isMegaseriesReward(this.m_id));
         }
         else if(Boolean(_loc5_) && _loc5_.isAllianceQuest)
         {
            this.m_isQuestTree = false;
            _loc3_ = "assets/displays/dialogs/PU_AllianceQuests.swf";
         }
         else
         {
            this.m_isQuestTree = false;
            _loc3_ = "assets/displays/dialogs/PU_Quests.swf";
         }
         super(ZGlobal.getAssetURL(_loc3_));
      }
      
      protected function enableAcceptButtonArt(param1:Boolean) : void
      {
         var _loc2_:MovieClip = this.screen;
         _loc2_.accept_bt.visible = param1;
         _loc2_.accept_bt.mouseEnabled = param1;
         _loc2_.accept_bt.useHandCursor = param1;
         _loc2_.accept_bt.buttonMode = param1;
      }
      
      protected function shouldShowAcceptButton() : Boolean
      {
         return true;
      }
      
      protected function getWindowClass(param1:SWFResource) : Class
      {
         return null;
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         var _loc2_:Class = this.getWindowClass(param1);
         if(_loc2_)
         {
            m_window = new _loc2_();
         }
         PopupManager.instance.notifyLoadComplete(this);
      }
      
      override public function onShow() : void
      {
         if(m_window)
         {
            super.onShow();
            this.setUpQuestUI();
         }
      }
      
      public function get id() : String
      {
         return this.m_id;
      }
      
      protected function get textObj() : Object
      {
         return this.m_textObj;
      }
      
      protected function set textObj(param1:Object) : void
      {
         this.m_textObj = param1;
      }
      
      protected function get screen() : MovieClip
      {
         return null;
      }
      
      protected function getTextObject(param1:String) : Object
      {
         return null;
      }
      
      protected function setUpQuestUI() : void
      {
         var _loc1_:Rectangle = null;
         if(this.m_initialized)
         {
            return;
         }
         this.m_initialized = true;
         if(this.screen.bg_mc)
         {
            _loc1_ = getVisibleBounds(this.screen.bg_mc);
         }
         else
         {
            _loc1_ = getVisibleBounds(this.screen);
         }
         if(_loc1_)
         {
            this.contentWidth = _loc1_.width;
            this.contentHeight = _loc1_.height;
         }
         this.setupDialogType();
         this.initDialog();
         addChild(m_window);
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      protected function getAcceptButtonPackageAndLabel(param1:ZGameQuest) : Object
      {
         return {
            "pkg":"Dialogs",
            "label":"Accept"
         };
      }
      
      override protected function initDialog() : void
      {
         var _loc3_:Object = null;
         var _loc5_:QuestTree = null;
         var _loc6_:ImageLoader = null;
         super.initDialog();
         var _loc1_:MovieClip = this.screen;
         TextFieldUtil.compactTextField(_loc1_.title_tf,this.textObj.title,{
            "maxLines":1,
            "minScale":0.5,
            "onFail":"return"
         });
         if(_loc1_.popupBox_tf)
         {
            TextFieldUtil.compactTextField(_loc1_.popupBox_tf,this.m_textObj.desc);
         }
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         _loc1_.exit_bt.addEventListener(MouseEvent.CLICK,this.onCancelClick);
         this.m_buttonSounds.addButton(_loc1_.exit_bt,ButtonSound.DEFAULT);
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(this.id) as ZGameQuest;
         _loc3_ = this.getAcceptButtonPackageAndLabel(_loc2_);
         if(this.shouldShowAcceptButton())
         {
            this.enableAcceptButtonArt(true);
            this.m_acceptBt = new ZGameButton(_loc1_.accept_bt,this.onAcceptClick);
            this.m_acceptBt.text = ZGameUtils.ZlocT(_loc3_.pkg,_loc3_.label);
            this.m_buttonSounds.addButton(this.m_acceptBt.m_overlay,ButtonSound.DEFAULT);
         }
         else
         {
            this.enableAcceptButtonArt(false);
         }
         var _loc4_:String = ZGlobal.player.questTrees.getQuestTreeNameForQuest(this.m_id);
         if((Boolean(_loc4_)) && Boolean(_loc1_.bgLoader))
         {
            _loc5_ = ZGlobal.player.questTrees.getQuestTree(_loc4_);
            if(_loc5_.backgroundURL)
            {
               _loc6_ = ImageLoaderFactory.CreateImageLoader(_loc5_.backgroundURL,_loc1_.bgLoader.innerFrame_mc);
               _loc6_.smooth = true;
            }
         }
      }
      
      override protected function deinitDialog() : void
      {
         super.deinitDialog();
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         var _loc1_:MovieClip = this.screen;
         if(_loc1_)
         {
            if(_loc1_.exit_bt)
            {
               _loc1_.exit_bt.removeEventListener(MouseEvent.CLICK,this.onCancelClick);
            }
         }
         if(this.m_acceptBt)
         {
            this.m_acceptBt.dispose();
            this.m_acceptBt = null;
         }
         if(this.m_avatarLoader)
         {
            this.m_avatarLoader.destroy();
            this.m_avatarLoader = null;
         }
      }
      
      protected function onAcceptClicked() : void
      {
      }
      
      protected function setupDialogType() : void
      {
         var _loc3_:String = null;
         var _loc4_:GameItem = null;
         var _loc5_:ItemImage = null;
         var _loc1_:String = null;
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(this.id) as ZGameQuest;
         if(this.m_isQuestTree)
         {
            if(_loc2_.advisorQuestPopupIconOverride != null && _loc2_.advisorQuestPopupIconOverride.length > 0)
            {
               _loc1_ = ZGlobal.getAssetURL(_loc2_.advisorQuestPopupIconOverride);
            }
            else
            {
               _loc1_ = ZGameQuestManager.instance.getButtonIconPath(this.id);
            }
         }
         else
         {
            _loc3_ = null;
            if(_loc2_.advisorId)
            {
               _loc3_ = _loc2_.advisorId;
            }
            else
            {
               _loc3_ = "a01";
            }
            _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc3_,GameItem) as GameItem;
            _loc5_ = _loc4_.getCachedImage("questHappy");
            if(_loc5_)
            {
               _loc1_ = _loc5_.url;
            }
         }
         if(_loc1_)
         {
            this.m_avatarLoader = ImageLoaderFactory.CreateImageLoader(_loc1_,m_window.uiloader_mc);
            this.m_avatarLoader.smooth = true;
         }
      }
      
      protected function onAcceptClick(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.stopImmediatePropagation();
         this.onAcceptClicked();
         close();
      }
      
      protected function onCancelClick(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.stopImmediatePropagation();
         close();
      }
   }
}

