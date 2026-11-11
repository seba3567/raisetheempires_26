package displays.popups
{
   import core.ZGlobal;
   import flash.display.MovieClip;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class SocialLevelUp extends LevelUp
   {
      
      private var m_isSocialXpGood:Boolean = true;
      
      public function SocialLevelUp(param1:int, param2:Array, param3:Array, param4:Array, param5:Array, param6:Array, param7:Boolean = true, param8:Boolean = true)
      {
         super(param1,param2,param3,param4,param5,param6,param7);
         this.m_isSocialXpGood = param8;
      }
      
      public function isSocialXpGood() : Boolean
      {
         return this.m_isSocialXpGood;
      }
      
      override protected function getAssetURL() : String
      {
         return ZGlobal.getAssetURL("assets/displays/screens/PVP_LevelUp.swf");
      }
      
      override protected function get isPVPUnlockLevel() : Boolean
      {
         return false;
      }
      
      override protected function setupScreen() : void
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         super.setupScreen();
         if(m_window)
         {
            m_window.levelup_mc.redHeart_mc.visible = this.m_isSocialXpGood;
            m_window.levelup_mc.blackHearts_mc.visible = !this.m_isSocialXpGood;
            m_window.levelup_mc.whitePanel_mc.visible = this.m_isSocialXpGood;
            m_window.levelup_mc.blackPanel_mc.visible = !this.m_isSocialXpGood;
            _loc1_ = this.m_isSocialXpGood ? "NewGoodLevel" : "NewBadLevel";
            _loc2_ = this.m_isSocialXpGood ? "GoodLevelShare" : "BadLevelShare";
            TextFieldUtil.processTextField(m_window.levelup_mc.congratulations_tf,ZGameUtils.ZlocT("Dialogs",_loc1_,{"level":m_level}));
            TextFieldUtil.processTextField(m_window.levelup_mc.canpurchase_tf,ZGameUtils.ZlocT("Dialogs","SocialLevelReward"));
            TextFieldUtil.processTextField(m_window.levelup_mc.cgItem_tf,ZGameUtils.ZlocT("Dialogs",_loc2_));
         }
      }
      
      override protected function getCards(param1:uint) : Array
      {
         var _loc2_:MovieClip = m_window.levelup_mc;
         return [_loc2_.item_1];
      }
   }
}

