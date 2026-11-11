package displays.screens.supportUnitContractScreen
{
   import core.ZGlobal;
   import core.gameobjects.ConsumableItem;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import displays.ImageLoaderFactory;
   import displays.screens.ItemTooltip;
   import displays.screens.contractScreen.UnitContractSlot;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import utils.TextFieldUtil;
   import zlabs.entity.IEntity;
   import zlabs.resource.SWFResource;
   
   public class SupportUnitContractSlot extends UnitContractSlot
   {
      
      private var m_consumableItem:ConsumableItem = null;
      
      public function SupportUnitContractSlot(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:EventDispatcher, param5:int, param6:int, param7:IEntity, param8:UnitItem, param9:Number, param10:Dictionary)
      {
         this.m_consumableItem = ZGlobal.gameSettings.getItemByCode(param8.secondaryAbility,ConsumableItem) as ConsumableItem;
         super(param1,param2,param3,param4,param5,param6,param7,param8,param9,param10);
      }
      
      override protected function populateCard() : void
      {
         super.populateCard();
         slot.detail_mc.secondAbility_tf.visible = true;
         TextFieldUtil.compactTextField(slot.detail_mc.secondAbility_tf,this.m_consumableItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME),{
            "maxLines":4,
            "fontSize":12
         });
         ImageLoaderFactory.CreateImageLoader(this.m_consumableItem.getCachedImage("icon").url,slot.detail_mc.against_mc.against0);
      }
      
      override public function get rollOverTarget() : MovieClip
      {
         return slot.detail_mc.against_mc;
      }
      
      override public function fillOutTooltip() : ItemTooltip
      {
         return new ItemTooltip(GameItem.SUPPORT_UNIT_TOOLTIP,item);
      }
      
      override public function get tooltipAnchorPositionX() : Number
      {
         return 0.6;
      }
      
      override public function get tooltipAnchorPositionY() : Number
      {
         return 0.7;
      }
      
      override protected function get detailsHeader() : String
      {
         return ZLoc.t("Dialogs","ContractAbility");
      }
   }
}

