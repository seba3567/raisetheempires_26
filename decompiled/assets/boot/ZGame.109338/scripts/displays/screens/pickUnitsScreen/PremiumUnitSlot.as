package displays.screens.pickUnitsScreen
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.PriceTestManager;
   import core.player.Player;
   import core.ui.Style;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GenericPopup;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.text.TextFormat;
   import utils.BitArray;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class PremiumUnitSlot extends UnitSlot implements IActionableSlot
   {
      
      public function PremiumUnitSlot(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:int, param5:int, param6:UnitItem, param7:Number)
      {
         super(param1,param2,param3,param4,param5,param6,false,0,param7);
      }
      
      public static function checkPremiumGate(param1:GameItem) : Boolean
      {
         var _loc2_:Boolean = false;
         var _loc3_:Object = null;
         var _loc4_:BitArray = null;
         if(!ZGlobal.player.canBuyCash(param1.cash,true))
         {
            return false;
         }
         _loc2_ = param1.usesCash() && param1.buyable;
         _loc3_ = {"forCashPurchase":_loc2_};
         _loc4_ = ZGlobal.player.checkGate(param1,_loc3_);
         if(_loc4_.isBitSet(Player.GATE_FAILURE_LEVEL))
         {
            PopupManager.instance.push(new GenericPopup(ZGameUtils.ZlocT("Dialogs","ImpulseLevel",{"amount":param1.requiredLevel})));
            return false;
         }
         if(_loc4_.isBitSet(Player.GATE_FAILURE_NEIGHBORS))
         {
            PopupManager.instance.push(new GenericPopup(ZGameUtils.ZlocT("Dialogs","ImpulseNeighbors",{"amount":param1.requiredNeighbors})));
            return false;
         }
         if(_loc4_.isBitSet(Player.GATE_FAILURE_DOMINANCE))
         {
            PopupManager.instance.push(new GenericPopup(ZGameUtils.ZlocT("Dialogs","ImpulseDominance",{"amount":param1.requiredDominanceRank})));
            return false;
         }
         return true;
      }
      
      public static function setupPremiumSlot(param1:GridSlot, param2:GameItem) : ImageLoader
      {
         var _loc8_:TextFormat = null;
         var _loc9_:int = 0;
         var _loc3_:MovieClip = param1.slot;
         if(_loc3_.unitCard_mc.cost_tf)
         {
            TextFieldUtil.processTextField(_loc3_.unitCard_mc.cost_tf,String(param2.cash));
            if(ZGlobal.player.cash < param2.cash)
            {
               _loc8_ = _loc3_.unitCard_mc.cost_tf.getTextFormat();
               _loc8_.color = Style.COLOR_UNSUFFICIENT_FUNDS;
               _loc3_.unitCard_mc.cost_tf.setTextFormat(_loc8_);
            }
         }
         var _loc4_:Number = PriceTestManager.instance.costMultiplierByType("unitsalediscount");
         if(_loc4_ < 1 && !ZGameTimeUtil.instance.isLimitedEdition(param2.xml))
         {
            _loc9_ = (1 - _loc4_) * 100;
            TextFieldUtil.processTextField(_loc3_.unitCard_mc.discount_tf,ZGameUtils.ZlocT("Dialogs","PercentOffExclaim",{"amount":_loc9_}));
         }
         else
         {
            TextFieldUtil.processTextField(_loc3_.unitCard_mc.discount_tf,"");
         }
         var _loc5_:Object = param2.buyable && param2.usesCash();
         var _loc6_:Object = {"forCashPurchase":_loc5_};
         var _loc7_:BitArray = ZGlobal.player.checkGate(param2,_loc6_);
         ZGameUtils.hideIfExists(_loc3_.unitCard_mc.levelInfo_tf);
         ZGameUtils.hideIfExists(_loc3_.unitCard_mc.levelInfo_tf_dominance);
         ZGameUtils.hideIfExists(_loc3_.unitCard_mc.locked_mc);
         ZGameUtils.hideIfExists(_loc3_.unitCard_mc.locked_mc_dominance);
         if(_loc7_.isBitSet(Player.GATE_FAILURE_LEVEL) || _loc7_.isBitSet(Player.GATE_FAILURE_DOMINANCE))
         {
            if(_loc7_.isBitSet(Player.GATE_FAILURE_LEVEL))
            {
               ZGameUtils.showIfExists(_loc3_.unitCard_mc.locked_mc);
               ZGameUtils.showIfExists(_loc3_.unitCard_mc.levelInfo_tf);
               if(_loc3_.unitCard_mc.levelInfo_tf)
               {
                  TextFieldUtil.processTextField(_loc3_.unitCard_mc.levelInfo_tf,ZGameUtils.ZlocT("Dialogs","LevelRequired",{"num":param2.requiredLevel}));
               }
            }
            else
            {
               ZGameUtils.showIfExists(_loc3_.unitCard_mc.locked_mc_dominance);
               ZGameUtils.showIfExists(_loc3_.unitCard_mc.levelInfo_tf_dominance);
               if(_loc3_.unitCard_mc.levelInfo_tf_dominance)
               {
                  TextFieldUtil.processTextField(_loc3_.unitCard_mc.levelInfo_tf_dominance,param2.requiredDominanceRank.toString());
               }
            }
            ZGameUtils.hideIfExists(_loc3_.unitCard_mc.cost_tf);
            ZGameUtils.hideIfExists(_loc3_.unitCard_mc.cashIcon_mc);
            if(param1 is IActionableSlot)
            {
               IActionableSlot(param1).hideButton();
            }
            _loc3_.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
         }
         else
         {
            ZGameUtils.showIfExists(_loc3_.unitCard_mc.cost_tf);
            ZGameUtils.showIfExists(_loc3_.unitCard_mc.cashIcon_mc);
            if(param1 is IActionableSlot)
            {
               IActionableSlot(param1).showButton();
            }
         }
         return ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/Cash_24.png"),_loc3_.unitCard_mc.cashIcon_mc);
      }
      
      override protected function get className() : String
      {
         return "PremiumUnitCard";
      }
      
      override protected function doOnClick(param1:MouseEvent) : void
      {
         if(param1.target == slot.buy_bt)
         {
            if(checkPremiumGate(m_unitItem))
            {
               UIDispatcher.instance.dispatchEvent(new WorldEvent(PURCHASE,this));
            }
         }
      }
      
      override protected function filloutStats() : void
      {
         super.filloutStats();
         m_iconLoaders.push(setupPremiumSlot(this,m_unitItem));
      }
      
      override protected function get usingCash() : Boolean
      {
         return true;
      }
      
      public function showButton() : void
      {
         slot.buy_bt.visible = true;
         slot.unitCard_mc.discount_tf.visible = true;
      }
      
      public function hideButton() : void
      {
         slot.buy_bt.visible = false;
         slot.unitCard_mc.discount_tf.visible = false;
      }
   }
}

