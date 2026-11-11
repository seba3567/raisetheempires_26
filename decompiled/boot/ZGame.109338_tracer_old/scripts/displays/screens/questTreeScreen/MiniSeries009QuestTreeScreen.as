package displays.screens.questTreeScreen
{
   import core.ZGlobal;
   import core.gameobjects.UnitItem;
   import flash.geom.Rectangle;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import utils.getVisibleBounds;
   
   public class MiniSeries009QuestTreeScreen extends QuestTreeScreen
   {
      
      public function MiniSeries009QuestTreeScreen(param1:String)
      {
         super(param1);
      }
      
      override protected function initializeUI() : void
      {
         var _loc1_:Rectangle = null;
         super.initializeUI();
         _loc1_ = getVisibleBounds(screen.background_mc);
         this.contentWidth = _loc1_.width;
         this.contentHeight = _loc1_.height;
         var _loc2_:Array = m_questTree.xml.ui.mainScreen.@name_tf.toString().split(":");
         TextFieldUtil.processTextField(screen.tree_mc1.name_tf,ZGameUtils.ZlocT(_loc2_[0],_loc2_[1]));
         _loc2_ = m_questTree.xml.ui.mainScreen.@name_tf2.toString().split(":");
         TextFieldUtil.processTextField(screen.tree_mc1.name_tf2,ZGameUtils.ZlocT(_loc2_[0],_loc2_[1]));
         _loc2_ = m_questTree.xml.ui.mainScreen.@reward_tf.toString().split(":");
         TextFieldUtil.processTextField(screen.tree_mc1.reward_tf,ZGameUtils.ZlocT(_loc2_[0],_loc2_[1]));
         var _loc3_:UnitItem = ZGlobal.gameSettings.getItemByCode(m_questTree.xml.ui.mainScreen.@rewardGameItem.toString(),UnitItem) as UnitItem;
         TextFieldUtil.processTextField(screen.tree_mc1.strength_mc.strength_tf,_loc3_.getStrength(null,null).toString());
      }
   }
}

