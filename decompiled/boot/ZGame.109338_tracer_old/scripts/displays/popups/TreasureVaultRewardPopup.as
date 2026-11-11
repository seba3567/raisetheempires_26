package displays.popups
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.TreasureVaultManager;
   import core.managers.WorldResourceManager;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.ZGameButton;
   import dispatchers.MessageDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.Rectangle;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import utils.getVisibleBounds;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class TreasureVaultRewardPopup extends GallantPopup
   {
      
      private var m_shareButton:ZGameButton;
      
      private var m_spinResults:Object = null;
      
      private var m_iconLoader:ImageLoader;
      
      private var m_loopEndFrameNo:int = 0;
      
      private var m_bUILoaded:Boolean = false;
      
      private var m_bUISetToSpinResults:Boolean = false;
      
      private var m_bTransactionReturned:Boolean = false;
      
      public function TreasureVaultRewardPopup()
      {
         Logger.print(TreasureVaultRewardPopup,"Loading PU_TreasureVault_Reward.swf");
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_TreasureVault_Reward.swf"));
         TreasureVaultManager.instance.addEventListener(TreasureVaultManager.SPIN_RESULTS,this.onSpinResults,false,0,true);
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         var resource:SWFResource = param1;
         try
         {
            this.m_bUILoaded = true;
            Logger.print(TreasureVaultRewardPopup,"Loaded PU_TreasureVault_Reward.swf");
            super.onLoadComplete(resource);
            if(this.m_bTransactionReturned == true)
            {
               this.populateUIWithSpinResults();
            }
         }
         catch(e:Error)
         {
            Logger.print(TreasureVaultRewardPopup,"Error occured in onLoadComplete: " + e.message);
         }
      }
      
      private function get mc() : MovieClip
      {
         return m_window.vaultReward_mc;
      }
      
      private function onShareButtonClicked(param1:MouseEvent) : void
      {
         var _loc3_:GameItem = null;
         var _loc2_:String = "";
         if(this.m_spinResults.loot.handler == "addLootToInventory")
         {
            _loc3_ = ZGlobal.gameSettings.getItemByCode(this.m_spinResults.loot.payload.code,GameItem) as GameItem;
            _loc2_ = _loc3_.getFriendlyName(GameItem.SENTENCE_FRIENDLYNAME);
         }
         else if(this.m_spinResults.loot.handler == "awardResources")
         {
            _loc2_ = WorldResourceManager.instance.getResourceFriendlyNameFromType(this.m_spinResults.loot.payload.name,GameItem.SENTENCE_FRIENDLYNAME,true);
         }
         ViralsManager.instance.sendFeed("TreasureVaultOpenedReward",{"item":_loc2_});
         close();
      }
      
      override protected function initializeScreen() : void
      {
         Logger.print(TreasureVaultRewardPopup,"initializeScreen");
         super.initializeScreen();
         this.mc.gotoAndStop("endLoop");
         this.m_loopEndFrameNo = this.mc.currentFrame;
         Logger.print(TreasureVaultRewardPopup,"m_loopEndFrameNo: " + this.m_loopEndFrameNo);
         this.mc.gotoAndPlay("startLoop");
         this.mc.addEventListener(Event.ENTER_FRAME,this.onFrame);
         m_origOffsetX = 0;
         m_origOffsetY = 0;
         this.mc.exit_bt.visible = false;
         var _loc1_:Rectangle = getVisibleBounds(this.mc);
         this.mc.exit_bt.visible = true;
         contentWidth = _loc1_.width;
         contentHeight = _loc1_.height;
         centerWithinStage(Zlab.mainStage);
         this.mc.exit_bt.addEventListener(MouseEvent.CLICK,this.exitButtonClicked,false,0,true);
         this.mc.exit_bt.enabled = false;
         this.mc.exit_bt.mouseEnabled = false;
         this.mc.exit_bt.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
         if(this.mc.share_mc.generic_tf)
         {
            this.m_shareButton = this.initButton(this.mc.share_mc,ZGameUtils.ZlocT("Dialogs","AcceptShare"),this.onShareButtonClicked);
            this.m_shareButton.hide();
         }
         TextFieldUtil.compactTextField(this.mc.title_tf,ZGameUtils.ZlocT("Dialogs","TreasureVaultCongratulationsTitle"));
         this.mc.title_tf.visible = false;
         TextFieldUtil.compactTextField(this.mc.discription_tf,ZGameUtils.ZlocT("Dialogs","TreasureVaultCongratulationsDesc"));
         this.mc.discription_tf.visible = false;
      }
      
      override protected function deinitDialog() : void
      {
         this.mc.removeEventListener(Event.ENTER_FRAME,this.onFrame);
         this.mc.exit_bt.removeEventListener(MouseEvent.CLICK,this.exitButtonClicked);
         if(this.m_shareButton)
         {
            this.m_shareButton.dispose();
            this.m_shareButton = null;
         }
         super.deinitDialog();
      }
      
      private function initButton(param1:MovieClip, param2:String = "", param3:Function = null) : ZGameButton
      {
         var _loc4_:ZGameButton = new ZGameButton(param1,param3,1.1,true);
         _loc4_.compactText(param2,{
            "maxLines":1,
            "minScale":0.5,
            "onFail":"return"
         });
         _loc4_.show();
         _loc4_.enable();
         return _loc4_;
      }
      
      private function exitButtonClicked(param1:MouseEvent) : void
      {
         close();
      }
      
      private function onFrame(param1:Event) : void
      {
         if(this.m_spinResults)
         {
            if(this.mc.currentFrame == this.mc.framesLoaded)
            {
               this.mc.removeEventListener(Event.ENTER_FRAME,this.onFrame);
               this.mc.stop();
               if(this.m_shareButton)
               {
                  this.m_shareButton.enable();
               }
               this.mc.exit_bt.enabled = true;
               this.mc.exit_bt.mouseEnabled = true;
               this.mc.exit_bt.filters = null;
            }
         }
         else if(this.mc.currentFrame >= this.m_loopEndFrameNo)
         {
            this.mc.gotoAndPlay("startLoop");
         }
      }
      
      private function populateUIWithSpinResults() : void
      {
         var _loc1_:GameItem = null;
         var _loc2_:String = null;
         if(this.m_bUISetToSpinResults == true)
         {
            return;
         }
         this.m_bUISetToSpinResults = true;
         Logger.print(TreasureVaultManager,"m_spinResults.loot: " + this.m_spinResults.loot);
         if(this.m_spinResults.loot)
         {
            Logger.print(TreasureVaultManager,"m_spinResults.loot.handler: " + this.m_spinResults.loot.handler);
            Logger.print(TreasureVaultManager,"m_spinResults.loot.loot: " + this.m_spinResults.loot.loot);
            Logger.print(TreasureVaultManager,"m_spinResults.loot.payload.yield: " + this.m_spinResults.loot.payload.yield);
            Logger.print(TreasureVaultManager,"m_spinResults.loot.payload.name: " + this.m_spinResults.loot.payload.name);
         }
         Logger.print(TreasureVaultRewardPopup,"setting UI with spin results");
         this.m_shareButton.show();
         this.mc.title_tf.visible = true;
         this.mc.discription_tf.visible = true;
         if(this.m_spinResults.loot)
         {
            if(this.m_spinResults.loot.handler == "addLootToInventory")
            {
               MessageDispatcher.instance.dispatchEvent(new WorldEvent(MessageDispatcher.ITEM_GIFT,this.m_spinResults.loot.payload));
               this.m_iconLoader = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(this.m_spinResults.loot.loot,"icon"),this.mc.item1_mc.icon);
               _loc1_ = ZGlobal.gameSettings.getItemByCode(this.m_spinResults.loot.payload.code,GameItem) as GameItem;
               TextFieldUtil.compactTextField(this.mc.item1_mc.item_tf,_loc1_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
            }
            else if(this.m_spinResults.loot.handler == "awardResources")
            {
               MessageDispatcher.instance.dispatchEvent(new WorldEvent(MessageDispatcher.RESOURCE_GIFT,this.m_spinResults.loot.payload));
               this.m_iconLoader = ImageLoaderFactory.CreateImageLoader(WorldResourceManager.instance.getResourceImageURLByType(this.m_spinResults.loot.loot,WorldResourceManager.XTRA_LARGE_ICON),this.mc.item1_mc.icon);
               TextFieldUtil.compactTextField(this.mc.item1_mc.item_tf,WorldResourceManager.instance.getResourceFriendlyNameFromType(this.m_spinResults.loot.payload.name,GameItem.MENU_FRIENDLYNAME,true));
            }
            if(Boolean(this.m_spinResults.loot.payload.yield) && this.m_spinResults.loot.payload.yield > 1)
            {
               _loc2_ = "x" + String(this.m_spinResults.loot.payload.yield);
               TextFieldUtil.compactTextField(this.mc.item1_mc.quantity_tf,_loc2_);
               this.mc.item1_mc.quantity_tf.visible = true;
            }
            else
            {
               this.mc.item1_mc.quantity_tf.visible = false;
            }
         }
         else
         {
            Logger.print(TreasureVaultManager,"Loot not found in transaction results");
         }
      }
      
      private function onSpinResults(param1:WorldEvent) : void
      {
         Logger.print(TreasureVaultManager,"Spin Transaction Returned");
         TreasureVaultManager.instance.removeEventListener(TreasureVaultManager.SPIN_RESULTS,this.onSpinResults);
         this.m_spinResults = param1.eventData;
         this.m_bTransactionReturned = true;
         if(this.m_bUILoaded == false)
         {
            return;
         }
         this.populateUIWithSpinResults();
      }
   }
}

