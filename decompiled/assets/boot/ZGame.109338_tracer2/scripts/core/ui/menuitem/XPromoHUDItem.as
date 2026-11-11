package core.ui.menuitem
{
   import Engine.Managers.StatsManager;
   import core.managers.ExperimentsManager;
   import core.ui.Tooltip;
   import flash.display.BitmapData;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import utils.ZGameUtils;
   
   public class XPromoHUDItem extends PromoMenuItem
   {
      
      private var m_data:Object;
      
      public function XPromoHUDItem(param1:Object)
      {
         this.m_data = param1;
         swfPath = this.m_data.ui.offer_image;
         toolTipFileName = "MessageOfTheDay";
         toolTipText = this.m_data.ui.offer_text;
         visible = false;
         tweenTimeSeconds = 2;
         var _loc2_:String = this.m_data.id.toString();
         super(_loc2_);
         priority = 2;
      }
      
      override public function show(param1:Boolean = false) : void
      {
         super.show(param1);
         StatsManager.countSample(100,"hud_icon","xpromo","view",this.m_data.id,"","",elapsedSinceShow);
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
         if(this.m_data.state)
         {
            if(this.m_data.state == "NEW" && ExperimentsManager.instance.getExperimentVariant("empires_xpromo_sametab") == 2)
            {
               navigateToURL(new URLRequest(this.m_data.ui.play_url),"_top");
            }
            else
            {
               navigateToURL(new URLRequest(this.m_data.ui.play_url),null);
            }
         }
         StatsManager.countSample(100,"hud_icon","xpromo","click",this.m_data.id,"","",elapsedSinceShow);
      }
   }
}

