package displays.screens
{
   import displays.screens.blackMarket.BlackMarketTradeSlot;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class BlackMarketTooltip extends Sprite
   {
      
      private var m_tooltip:MovieClip = null;
      
      public function BlackMarketTooltip(param1:String, param2:String = null)
      {
         super();
         this.loadTooltip(param1,param2);
         this.mouseEnabled = false;
         this.mouseChildren = false;
      }
      
      private function loadTooltip(param1:String, param2:String = null) : void
      {
         this.m_tooltip = this.createTooltipClip(param1);
         switch(param1)
         {
            case BlackMarketTradeSlot.ICON:
               this.m_tooltip.gotoAndStop(4);
               this.populateIconTooltip(param2);
               break;
            case BlackMarketTradeSlot.ASK:
               this.populateAskTooltip();
               break;
            case BlackMarketTradeSlot.BUY:
               this.populateBuyTooltip(param2);
               break;
            case BlackMarketTradeSlot.PLACE:
               this.populatePlaceTooltip(param2);
               break;
            case BlackMarketTradeSlot.TRADE:
               this.populateTradeTooltip();
               break;
            default:
               this.populateScrapTooltip();
         }
         addChild(this.m_tooltip);
      }
      
      private function populateIconTooltip(param1:String) : void
      {
         TextFieldUtil.processTextField(this.m_tooltip.title_tf,param1);
         TextFieldUtil.processTextField(this.m_tooltip.description_tf,ZGameUtils.ZlocT("Tooltips","BlackMarket_part_tooltip"));
      }
      
      private function populateAskTooltip() : void
      {
         TextFieldUtil.processTextField(this.m_tooltip.description_tf,ZGameUtils.ZlocT("Tooltips","BlackMarket_ask_tooltip"));
      }
      
      private function populateBuyTooltip(param1:String) : void
      {
         TextFieldUtil.processTextField(this.m_tooltip.description_tf,ZGameUtils.ZlocT("Tooltips","BlackMarket_buy_tooltip",{"itemName":param1}));
      }
      
      private function populatePlaceTooltip(param1:String) : void
      {
         TextFieldUtil.processTextField(this.m_tooltip.description_tf,ZGameUtils.ZlocT("Tooltips","BlackMarket_place_tooltip",{"itemName":param1}));
      }
      
      private function populateTradeTooltip() : void
      {
         TextFieldUtil.processTextField(this.m_tooltip.description_tf,ZGameUtils.ZlocT("Tooltips","BlackMarket_trade_tooltip"));
      }
      
      private function populateScrapTooltip() : void
      {
         TextFieldUtil.processTextField(this.m_tooltip.title_tf,ZGameUtils.ZlocT("Tooltips","BlackMarket_scrap_tooltip"));
         TextFieldUtil.processTextField(this.m_tooltip.description_tf,ZGameUtils.ZlocT("Tooltips","BlackMarket_scrap_tooltip"));
      }
      
      private function createTooltipClip(param1:String = null) : MovieClip
      {
         return new AssetGroupTooltip();
      }
      
      public function destroy() : void
      {
         removeChild(this.m_tooltip);
         this.m_tooltip = null;
      }
   }
}

