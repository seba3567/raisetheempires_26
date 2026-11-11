package displays.popups
{
   import core.ZGlobal;
   import core.managers.domination.DominationModeManager;
   import flash.display.MovieClip;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.resource.SWFResource;
   
   public class DominanceLevelUp extends LevelUp
   {
      
      private static var ATTACKFORCE_CODE:String = "attackForceItem";
      
      public function DominanceLevelUp(param1:int, param2:Array, param3:Array, param4:Array, param5:Array, param6:Array, param7:Boolean = true)
      {
         super(param1,param2,param3,param4,param5,param6,param7);
         addPVPItem(ATTACKFORCE_CODE);
      }
      
      override protected function getWindowInstance(param1:SWFResource) : MovieClip
      {
         var _loc2_:Class = param1.getAssetClass("levelup_mc");
         return new _loc2_();
      }
      
      override protected function getAssetURL() : String
      {
         return ZGlobal.getAssetURL("assets/displays/dialogs/PU_LevelUpDominance.swf");
      }
      
      override protected function get shouldAddPVPSurfacing() : Boolean
      {
         return false;
      }
      
      override protected function get shouldAddDominationSurfacing() : Boolean
      {
         return false;
      }
      
      override protected function get mc() : MovieClip
      {
         return m_window;
      }
      
      override protected function get titleKey() : String
      {
         return "DominanceNewLevel";
      }
      
      override protected function get descKey() : String
      {
         return "DominanceLevelShareDesc";
      }
      
      override protected function addUnitToCard(param1:String, param2:MovieClip) : Boolean
      {
         var _loc3_:uint = 0;
         var _loc4_:Object = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         if(param1 == ATTACKFORCE_CODE)
         {
            _loc3_ = DominationModeManager.instance.maxForceStrengthDefend;
            _loc4_ = {"force":_loc3_};
            _loc5_ = ZGameUtils.ZlocT("Dialogs","DominationAttackForceValue",_loc4_);
            TextFieldUtil.compactTextField(param2.itemName_tf,_loc5_);
            _loc6_ = ZGlobal.gameSettings.getString("DominationForceStrengthAttackIcon");
            loadURLImage(ZGlobal.getAssetURL(_loc6_),param2.icon);
            return true;
         }
         return super.addUnitToCard(param1,param2);
      }
      
      override protected function get unlockedHeaderKey() : String
      {
         return "DominanceUnlocked";
      }
      
      override protected function setupScreen() : void
      {
         super.setupScreen();
         if(this.mc)
         {
            TextFieldUtil.processTextField(this.mc.rank_tf,String(m_level));
         }
      }
   }
}

