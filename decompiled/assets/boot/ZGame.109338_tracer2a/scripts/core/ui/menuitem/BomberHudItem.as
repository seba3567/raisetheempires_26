package core.ui.menuitem
{
   import core.managers.miniGameManager.BomberGameManager;
   import core.ui.Tooltip;
   import flash.display.BitmapData;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import utils.ZGameUtils;
   
   public class BomberHudItem extends PromoMenuItem
   {
      
      public static const ITEM_ID:String = "BomberIcon";
      
      private const MOTD_NAME:String = "start_play";
      
      public function BomberHudItem()
      {
         swfPath = "assets/ui/Hud_BombingRun_01_64.png";
         toolTipFileName = "MessageOfTheDay";
         toolTipText = "motd_Bomber_Start";
         visible = false;
         tweenTimeSeconds = 2;
         super(ITEM_ID,false,false);
         priority = 1;
      }
      
      override public function show(param1:Boolean = false) : void
      {
         super.show(param1);
      }
      
      override protected function onLoadComplete(param1:String, param2:BitmapData) : void
      {
         super.onLoadComplete(param1,param2);
         var _loc3_:Point = new Point(-50,100);
         BomberGameManager.instance.hudIconMovie = m_uiloader;
         var _loc4_:String = ZGameUtils.ZlocT(toolTipFileName,toolTipText);
         Tooltip.subscribe(m_uiloader,_loc4_);
      }
      
      override protected function onClicked(param1:MouseEvent) : void
      {
         super.onClicked(param1);
         BomberGameManager.instance.startBomberGame();
      }
   }
}

