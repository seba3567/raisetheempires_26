package displays.screens.pickUnitsScreen
{
   import core.ZGameStats;
   import core.ZGlobal;
   import core.gamemode.battle.BattleDispatcher;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.screens.ItemTooltip;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class TitanEntrySlot extends GridSlot
   {
      
      protected var m_iconLoaders:Array = null;
      
      protected var m_button:ZGameButton = null;
      
      public function TitanEntrySlot(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:int, param5:int, param6:Number)
      {
         super(param1,param2,param3);
         slot.x = param4 * (sizerWidth * param6);
         slot.y = param5 * (sizerHeight * param6);
         this.filloutStats();
      }
      
      override protected function get className() : String
      {
         return "TitanCard";
      }
      
      public function get titanExist() : int
      {
         return 1;
      }
      
      override public function fillOutTooltip() : ItemTooltip
      {
         return null;
      }
      
      override protected function doOnClick(param1:MouseEvent) : void
      {
         ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_GENERIC_BUTTON_CLICKED,{"counter":"mech_deployment"}));
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_TITAN_MODE,true));
      }
      
      protected function filloutStats() : void
      {
         this.m_iconLoaders = new Array();
         slot.remove_bt.visible = false;
         this.m_button = new ZGameButton(slot.add_bt,this.doOnClick);
         this.m_button.text = ZGameUtils.ZlocT("Dialogs","CombatSetupTitanDeployAction");
         slot.unitCard_mc.strengthBar_mc.visible = false;
         slot.unitCard_mc.strengthValue_tf.visible = false;
         if(slot.unitCard_mc.tierRating_mc)
         {
            slot.unitCard_mc.tierRating_mc.visible = false;
         }
         if(ZGlobal.player.titanName)
         {
            TextFieldUtil.processTextField(slot.unitCard_mc.itemName_tf,ZGlobal.player.titanName);
         }
         else
         {
            TextFieldUtil.processTextField(slot.unitCard_mc.itemName_tf,ZGameUtils.ZlocT("Dialogs","CombatSetupTitanDeployTitle"));
         }
         this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/units/Units_Land_Mega.swf/Unit_Land_MegaUnit_02_Legs_Anim_Red_SW_icon.png"),slot.unitCard_mc.icon));
      }
      
      override public function dispose() : void
      {
         var _loc1_:ImageLoader = null;
         for each(_loc1_ in this.m_iconLoaders)
         {
            _loc1_.destroy();
         }
         this.m_iconLoaders = null;
         if(this.m_button)
         {
            this.m_button.dispose();
            this.m_button = null;
         }
         super.dispose();
      }
   }
}

