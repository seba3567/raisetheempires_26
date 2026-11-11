package displays.screens.contractScreen
{
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.resource.SWFResource;
   
   public class MissionContractComingSoonSlot extends GridSlot
   {
      
      private var m_iconLoader:ImageLoader = null;
      
      public function MissionContractComingSoonSlot(param1:SWFResource, param2:MovieClip, param3:int, param4:int)
      {
         super(param1,param2,screen);
         slot.x = param3 * sizerWidth;
         slot.y = param4 * sizerHeight;
         this.init();
      }
      
      override protected function get className() : String
      {
         return "UnitCard";
      }
      
      override public function get tooltipAnchorPositionY() : Number
      {
         return 0;
      }
      
      protected function init() : void
      {
         slot.unitCard_mc.icon.filters = [];
         slot.unitCard_mc.gotoAndStop("powerup");
         slot.unitCard_mc.bg_mc_plan.visible = false;
         slot.unitCard_mc.bg_mc_locked.visible = false;
         slot.unitCard_mc.bg_mc_soon.visible = true;
         slot.unitCard_mc.bg_mc_sf_ready.visible = false;
         slot.unitCard_mc.highlightSelect_mc.visible = false;
         slot.unitCard_mc.soon_tf.visible = true;
         TextFieldUtil.processTextField(slot.unitCard_mc.soon_tf,ZGameUtils.ZlocT("Dialogs","MissionCardComingSoon"));
         slot.unitCard_mc.build_bt.visible = false;
         slot.unitCard_mc.buy_bt.visible = false;
         slot.unitCard_mc.deploy_bt.visible = false;
         slot.unitCard_mc.locked_tf.visible = false;
         slot.unitCard_mc.header_tf.visible = false;
         slot.unitCard_mc.count_mc.visible = false;
         slot.unitCard_mc.itemName_tf.visible = false;
         this.m_iconLoader = ImageLoaderFactory.CreateImageLoader("assets/game/consumables/ConsumablesUI.swf/StrikeTeams_ComingSoon_96.png",slot.unitCard_mc.icon_soon);
      }
      
      override public function dispose() : void
      {
         if(this.m_iconLoader != null)
         {
            this.m_iconLoader.destroy();
            this.m_iconLoader = null;
         }
         super.dispose();
      }
      
      override public function isSpecialSlot() : Boolean
      {
         return true;
      }
   }
}

