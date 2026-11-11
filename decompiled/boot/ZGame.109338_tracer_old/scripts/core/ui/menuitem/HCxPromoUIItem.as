package core.ui.menuitem
{
   import Engine.Managers.StatsManager;
   import core.managers.ExperimentsManager;
   import core.managers.MOTDManager.MessageOfTheDayManager;
   import core.ui.Tooltip;
   import flash.display.BitmapData;
   import flash.events.MouseEvent;
   import utils.ZGameUtils;
   
   public class HCxPromoUIItem extends PromoMenuItem
   {
      
      public static const ITEM_ID:String = "HCxPromoUIItem";
      
      public static const GAME_ID:String = "115";
      
      public static const XPROMO_ID:int = 598;
      
      private const MOTD_NAME:String = "motd_hiddenchronicles_xpromo_hud_Dec2011";
      
      public function HCxPromoUIItem()
      {
         var _loc1_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_HIDDEN_CHRONICLES_XPROMO_HUD);
         swfPath = "assets/game/quests/Quests_Icons_0.swf/HiddenChroniclesHudIcon_64.png";
         toolTipFileName = "MessageOfTheDay";
         toolTipText = "motd_HiddenChronicles_Xpromo_HUD_toolTip";
         visible = false;
         tweenTimeSeconds = 2;
         super(ITEM_ID);
         priority = 2;
      }
      
      override public function show(param1:Boolean = false) : void
      {
         super.show(param1);
         StatsManager.countSample(100,"hud_icon","xpromo","view",GAME_ID,this.MOTD_NAME,"",elapsedSinceShow);
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
         MessageOfTheDayManager.instance.openMOTDPopupByName(this.MOTD_NAME,false);
         StatsManager.countSample(100,"hud_icon","xpromo","click",GAME_ID,this.MOTD_NAME,"",elapsedSinceShow);
      }
   }
}

