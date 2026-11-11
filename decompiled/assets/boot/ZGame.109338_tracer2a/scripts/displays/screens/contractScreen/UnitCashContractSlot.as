package displays.screens.contractScreen
{
   import core.ZGlobal;
   import core.gameobjects.UnitItem;
   import core.ui.Style;
   import core.ui.ZGameButton;
   import core.ui.feedbacktext.CashFeedbackText;
   import displays.ImageLoaderFactory;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.text.TextFormat;
   import utils.TextFieldUtil;
   import zlabs.entity.IEntity;
   import zlabs.resource.SWFResource;
   
   public class UnitCashContractSlot extends UnitContractSlot
   {
      
      public function UnitCashContractSlot(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:EventDispatcher, param5:int, param6:int, param7:IEntity, param8:UnitItem, param9:Number)
      {
         super(param1,param2,param3,param4,param5,param6,param7,param8,param9);
      }
      
      override protected function setUpButton() : void
      {
         slot.build_bt.visible = false;
         slot.build_bt.mouseEnabled = false;
         slot.emp_bt.visible = true;
         slot.emp_bt.mouseEnabled = true;
         m_buildBtn = new ZGameButton(slot.emp_bt,onSelectButton);
         m_buildBtn.text = ZLoc.t("Dialogs","BuyForAmount",{"amount":item.cash});
      }
      
      override protected function setupCosts() : void
      {
         var _loc4_:TextFormat = null;
         var _loc1_:Array = [slot.detail_mc.resourceIcon0,slot.detail_mc.resourceIcon1,slot.detail_mc.resourceIcon2];
         var _loc2_:Array = [slot.detail_mc.resource0_tf,slot.detail_mc.resource1_tf,slot.detail_mc.resource2_tf];
         var _loc3_:* = 0;
         TextFieldUtil.processTextField(_loc2_[_loc3_],Math.abs(item.cash).toString());
         m_imageLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(CashFeedbackText.MEDIUM_ICON_URL),_loc1_[_loc3_]));
         _loc2_[_loc3_].visible = true;
         _loc2_[_loc3_].mouseEnabled = false;
         if(!ZGlobal.player.canBuyCash(item.cash,false))
         {
            _loc4_ = new TextFormat();
            _loc4_.color = Style.COLOR_UNSUFFICIENT_RESOURCES;
            _loc2_[_loc3_].setTextFormat(_loc4_);
         }
         _loc3_++;
         while(_loc3_ < _loc2_.length)
         {
            _loc2_[_loc3_++].visible = false;
         }
      }
   }
}

