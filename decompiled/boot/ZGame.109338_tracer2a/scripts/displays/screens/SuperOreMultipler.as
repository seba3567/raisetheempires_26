package displays.screens
{
   import core.ZGlobal;
   import core.managers.WorldResourceManager;
   import core.ui.UIManager;
   import core.ui.ZGameButton;
   import core.ui.menuitem.PlayerStatsUIItem;
   import dispatchers.UIDispatcher;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import displays.screens.partsGather.PartsGatherGrid;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.displays.popups.PopUpBase;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class SuperOreMultipler extends ZGamePopUp
   {
      
      protected var m_type:String = null;
      
      protected var m_multiplier:uint = 0;
      
      protected var m_partsWindow:PartsGatherGrid;
      
      protected var m_itemCode:String;
      
      protected var m_eventDispatcher:EventDispatcher = null;
      
      protected var m_entity:IEntity = null;
      
      public function SuperOreMultipler(param1:EventDispatcher, param2:String, param3:IEntity, param4:String, param5:uint)
      {
         this.m_eventDispatcher = param1;
         this.m_entity = param3;
         this.m_type = param4;
         this.m_multiplier = param5;
         this.m_itemCode = param2;
         super(ZGlobal.getAssetURL("assets/displays/screens/OreMine_Multiplier.swf"));
      }
      
      public static function display(param1:EventDispatcher, param2:String, param3:IEntity, param4:String = "", param5:uint = 0) : PopUpBase
      {
         var _loc6_:PopUpBase = new SuperOreMultipler(param1,param2,param3,param4,param5);
         WindowManager.instance.push(_loc6_);
         return _loc6_;
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         var _loc2_:Class = param1.getAssetClass("PartsDialog");
         m_window = new _loc2_();
         this.m_partsWindow = new PartsGatherGrid(m_window,this.m_itemCode,this.m_type,4,"SuperOreMultiplierPartsItem");
         TextFieldUtil.compactTextField(m_window.multiplier_tf,"x" + this.m_multiplier);
         this.m_partsWindow.setTitleText(ZGameUtils.ZlocT("Dialogs","SuperOreMine_Multiplier_Title",{
            "type":ZGameUtils.ZlocT("Items",this.m_type + "_menuName"),
            "multiplier":this.m_multiplier
         }));
         var _loc3_:String = ZGameUtils.ZlocT("Dialogs","SuperOreMine_Multiplier_Body",{"type":ZGameUtils.ZlocT("Items",this.m_type + "_menuName")});
         this.m_partsWindow.setDescriptionText(_loc3_);
         ImageLoaderFactory.CreateImageLoader(WorldResourceManager.instance.getResourceImageURLByType(this.m_type,WorldResourceManager.XTRA_LARGE_ICON),m_window.bigIcon);
         addChild(m_window);
         m_origOffsetX = m_window.x;
         m_origOffsetY = m_window.y;
         centerWithinStage(Zlab.mainStage);
         m_window.exit_bt.addEventListener(MouseEvent.CLICK,this.onExitButtonClick,false,0,true);
         m_window.back_bt.visible = true;
         var _loc4_:ZGameButton = new ZGameButton(m_window.back_bt,this.onBackClick);
         _loc4_.text = ZGameUtils.ZlocT("Dialogs","Back");
         TextFieldUtil.compactTextField(m_window.instructions_tf2,ZGameUtils.ZlocT("Dialogs","BuildingPartsInstructions"));
         UIDispatcher.instance.addEventListener(PartsGatherGrid.FINISHED,this.onFinished,false,0,true);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).toggleRarePanel(true);
         dispatchEvent(new Event(Event.COMPLETE));
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).moveToNewLayer(WindowManager.instance.container,0);
      }
      
      public function onBackClick(param1:MouseEvent) : void
      {
         this.onExitButtonClick(null);
         SuperOreScreen.display(this.m_eventDispatcher,this.m_itemCode,this.m_entity,null,this.m_type,0);
      }
      
      public function onFinished(param1:WorldEvent) : void
      {
         UIDispatcher.instance.removeEventListener(PartsGatherGrid.FINISHED,this.onFinished);
         ZGlobal.player.unlockResource(param1.eventData.type,this.m_multiplier);
         this.onExitButtonClick(null);
         SuperOreScreen.display(this.m_eventDispatcher,this.m_itemCode,this.m_entity,null,this.m_type,0);
      }
      
      protected function onExitButtonClick(param1:MouseEvent) : void
      {
         this.closeWindow(param1);
      }
      
      protected function closeWindow(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         m_window.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExitButtonClick);
         UIDispatcher.instance.removeEventListener(PartsGatherGrid.FINISHED,this.onFinished);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).toggleRarePanel(false);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).moveToNewLayer(UIManager.instance.uiDisplay,0);
         this.close();
      }
      
      override protected function close(param1:Event = null) : void
      {
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).toggleRarePanel(false);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).moveToNewLayer(UIManager.instance.uiDisplay,0);
         super.close();
      }
   }
}

