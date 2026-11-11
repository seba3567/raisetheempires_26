package displays.screens.questTreeScreen
{
   import displays.popups.MOTDCountdownClock;
   import flash.utils.Dictionary;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class MysteryCrateQuestTreeScreen extends QuestTreeScreen
   {
      
      public function MysteryCrateQuestTreeScreen(param1:String)
      {
         super(param1);
      }
      
      override protected function initializeUI() : void
      {
         this.contentWidth = screen.bg_mc.width;
         this.contentHeight = screen.bg_mc.height;
         TextFieldUtil.processTextField(screen.title_tf,ZGameUtils.ZlocT("QuestTrees",m_questTree.title));
         TextFieldUtil.processTextField(screen.time_tf,ZGameUtils.ZlocT("QuestTrees","TimeLeft"));
         TextFieldUtil.processTextField(screen.popupBox_tf,ZGameUtils.ZlocT("QuestTrees",m_questTree.popup));
         m_clock = new MOTDCountdownClock(screen.clock_mc,m_questTree.xml,true);
      }
      
      override protected function getNodeNames() : Array
      {
         return ["icon0","icon1","icon2","icon3","icon4","icon5","icon6"];
      }
      
      override protected function getLines() : Dictionary
      {
         var _loc1_:Dictionary = new Dictionary();
         _loc1_["icon0"] = null;
         _loc1_["icon1"] = createLink("icon0",tree["line1"]);
         _loc1_["icon3"] = createLink("icon1",tree["line3"]);
         _loc1_["icon4"] = createLink("icon2",tree["line4"]);
         _loc1_["icon2"] = createLink("icon1",tree["line2"]);
         _loc1_["icon5"] = createLink("icon2",tree["line5"]);
         return _loc1_;
      }
   }
}

