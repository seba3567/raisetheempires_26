package core.ui.menuitem
{
   import core.managers.MOTDManager.MessageOfTheDayManager;
   import core.ui.Tooltip;
   import flash.display.BitmapData;
   import flash.events.MouseEvent;
   import utils.ZGameUtils;
   
   public class MOTDPromoUIItem extends PromoMenuItem
   {
      
      public static const ITEM_ID:String = "MOTDPromoUIItem";
      
      private const MOTD_NAME:String = "motd_scrolling";
      
      public function MOTDPromoUIItem()
      {
         swfPath = "assets/game/quests/Quests_Icons_0.swf/MOTDScreens_64.png";
         toolTipFileName = "MessageOfTheDay";
         toolTipText = "motd_view";
         visible = false;
         tweenTimeSeconds = 2;
         super(ITEM_ID,false,false);
         priority = 4;
      }
      
      override public function show(param1:Boolean = false) : void
      {
         super.show(param1);
      }
      
      override protected function onLoadComplete(param1:String, param2:BitmapData) : void
      {
         super.onLoadComplete(param1,param2);
         var _loc3_:String = ZGameUtils.ZlocT(toolTipFileName,toolTipText);
         Tooltip.subscribe(m_uiloader,_loc3_);
      }
      
      override protected function onClicked(param1:MouseEvent) : void
      {
         super.onClicked(param1);
         MessageOfTheDayManager.instance.hudOpenMOTD();
      }
   }
}

