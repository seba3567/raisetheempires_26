package displays.popups
{
   import Engine.Managers.TransactionManager;
   import ZQuest.Managers.QuestManager;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.QuestBuildableManager;
   import core.managers.questManager.ZGameQuestManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import transactions.TBuyItem;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class GoldenStatuePopUp3 extends ZGamePopUp
   {
      
      public static const COMPLETE:String = "qbcompleted3";
      
      public static const OILITEM:String = "B895";
      
      public static const WOODITEM:String = "B896";
      
      public static const QUEST_ID:String = "QB005";
      
      protected var manager:ZGameQuestManager;
      
      private var m_initialised:Boolean = false;
      
      protected var m_eventDispatcher:EventDispatcher = null;
      
      protected var nextButton:ZGameButton;
      
      protected var oilSupply:ZGameButton;
      
      protected var woodSupply:ZGameButton;
      
      public function GoldenStatuePopUp3(param1:EventDispatcher)
      {
         this.m_eventDispatcher = param1;
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_QuestBuildable.swf"));
      }
      
      public static function display(param1:EventDispatcher) : void
      {
         WindowManager.instance.push(new GoldenStatuePopUp3(param1));
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         PopupManager.instance.notifyLoadComplete(this);
      }
      
      private function get screen() : MovieClip
      {
         return m_window.quest3_mc;
      }
      
      override public function onShow() : void
      {
         super.onShow();
         this.setupWindow();
      }
      
      private function setupWindow() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(Boolean(m_window) && !this.m_initialised)
         {
            m_window.crew_mc.visible = false;
            m_window.quest2_mc.visible = false;
            m_window.quest3_mc.visible = true;
            m_window.quest4_mc.visible = false;
            this.initDialog();
            _loc1_ = this.x;
            _loc2_ = this.y;
            centerWithinStage(Zlab.mainStage);
            if(this.x < 0 || this.y < 0)
            {
               this.x = _loc1_;
               this.y = _loc2_;
            }
            addChild(m_window);
         }
      }
      
      override protected function initDialog() : void
      {
         this.screen.exit_bt.addEventListener(MouseEvent.CLICK,this.onExit);
         this.nextButton = new ZGameButton(this.screen.accept_bt,this.onNextClicked);
         this.oilSupply = new ZGameButton(this.screen.supply1_mc.supply_bt,this.onOilClicked);
         this.woodSupply = new ZGameButton(this.screen.supply2_mc.supply_bt,this.onWoodClicked);
         this.manager = QuestManager.getInstance() as ZGameQuestManager;
         this.manager.addEventListener(ZGameQuestManager.QUEST_COMPLETE,this.onQuestComplete,false,0,true);
         this.draw();
      }
      
      protected function draw() : void
      {
         var _loc1_:ImageLoader = ImageLoaderFactory.CreateImageLoader((ZGlobal.gameSettings.getItemByCode(QuestBuildableManager.GOLDEN_STATUE,GameItem) as GameItem).getCachedImage("screenicon").url,this.screen.bigIcon);
         _loc1_.smooth = true;
         TextFieldUtil.compactTextField(this.screen.title_tf,ZGameUtils.ZlocT("Dialogs","QuestBuildable_Q5_Title"));
         TextFieldUtil.compactTextField(this.screen.generic_tf,ZGameUtils.ZlocT("Dialogs","QuestBuildable_Q5_Desc_1"));
         TextFieldUtil.compactTextField(this.screen.accept_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","QuestBuildable_Q5_Button_2"));
         var _loc2_:ImageLoader = ImageLoaderFactory.CreateImageLoader((ZGlobal.gameSettings.getItemByCode(OILITEM,GameItem) as GameItem).getCachedImage("icon").url,this.screen.supply1_mc.icon_mc);
         _loc2_.smooth = true;
         var _loc3_:ImageLoader = ImageLoaderFactory.CreateImageLoader((ZGlobal.gameSettings.getItemByCode(WOODITEM,GameItem) as GameItem).getCachedImage("icon").url,this.screen.supply2_mc.icon_mc);
         _loc3_.smooth = true;
         TextFieldUtil.compactTextField(this.screen.supply1_mc.progress_tf,ZGameUtils.ZlocT("Dialogs","QuestBuildable_Q5_Item_1",{"total":200}));
         TextFieldUtil.compactTextField(this.screen.supply2_mc.progress_tf,ZGameUtils.ZlocT("Dialogs","QuestBuildable_Q5_Item_2",{"total":200}));
         TextFieldUtil.compactTextField(this.screen.supply1_mc.supply_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","QuestBuildable_Q5_Button_1"));
         TextFieldUtil.compactTextField(this.screen.supply2_mc.supply_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","QuestBuildable_Q5_Button_1"));
         if(ZGlobal.player.getNumberOfInventoryItems(OILITEM) >= 1)
         {
            this.screen.supply1_mc.check_mc.visible = true;
            this.screen.supply1_mc.progress_tf.visible = false;
            this.screen.supply1_mc.supply_bt.visible = false;
            this.oilSupply.disable(false);
         }
         else
         {
            this.screen.supply1_mc.check_mc.visible = false;
            this.screen.supply1_mc.progress_tf.visible = true;
            this.screen.supply1_mc.supply_bt.visible = true;
            this.oilSupply.enable();
         }
         if(ZGlobal.player.getNumberOfInventoryItems(WOODITEM) >= 1)
         {
            this.screen.supply2_mc.check_mc.visible = true;
            this.screen.supply2_mc.progress_tf.visible = false;
            this.screen.supply2_mc.supply_bt.visible = false;
            this.woodSupply.disable(false);
         }
         else
         {
            this.screen.supply2_mc.check_mc.visible = false;
            this.screen.supply2_mc.progress_tf.visible = true;
            this.screen.supply2_mc.supply_bt.visible = true;
            this.woodSupply.enable();
         }
         if(ZGlobal.player.didCompleteQuest("QB005"))
         {
            this.nextButton.enable();
         }
         else
         {
            this.nextButton.disable_visual(false);
         }
      }
      
      private function onOilClicked(param1:MouseEvent) : void
      {
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode(OILITEM,GameItem) as GameItem;
         if(ZGlobal.player.canBuy(_loc2_,true))
         {
            ZGlobal.player.buyItem(_loc2_,false,1);
            ZGlobal.player.addToInventory(OILITEM,1,true);
            TransactionManager.addTransaction(new TBuyItem(OILITEM,false,1),true);
            this.screen.supply1_mc.check_mc.visible = true;
            this.screen.supply1_mc.progress_tf.visible = false;
            this.screen.supply1_mc.supply_bt.visible = false;
            this.oilSupply.disable(false);
         }
         this.draw();
      }
      
      private function onWoodClicked(param1:MouseEvent) : void
      {
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode(WOODITEM,GameItem) as GameItem;
         if(ZGlobal.player.canBuy(_loc2_,true))
         {
            ZGlobal.player.buyItem(_loc2_,false,1);
            ZGlobal.player.addToInventory(WOODITEM,1,true);
            TransactionManager.addTransaction(new TBuyItem(WOODITEM,false,1),true);
            this.screen.supply2_mc.check_mc.visible = true;
            this.screen.supply2_mc.progress_tf.visible = false;
            this.screen.supply2_mc.supply_bt.visible = false;
            this.woodSupply.disable(false);
         }
         this.draw();
      }
      
      protected function onQuestComplete(param1:WorldEvent) : void
      {
         this.draw();
      }
      
      private function onNextClicked(param1:MouseEvent) : void
      {
         this.m_eventDispatcher.dispatchEvent(new Event(COMPLETE));
         this.close();
      }
      
      private function onExit(param1:MouseEvent) : void
      {
         this.close();
      }
      
      override protected function close(param1:Event = null) : void
      {
         deinitDialog();
         super.close();
      }
   }
}

