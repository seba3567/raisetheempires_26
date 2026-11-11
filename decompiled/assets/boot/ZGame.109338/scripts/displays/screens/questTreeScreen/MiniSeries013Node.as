package displays.screens.questTreeScreen
{
   import displays.popups.quest.MiniSeries008DetailsPopup;
   import displays.popups.quest.QuestDetailsPopup;
   import flash.display.MovieClip;
   import flash.utils.Dictionary;
   
   public class MiniSeries013Node extends MiniSeries008Node
   {
      
      public function MiniSeries013Node(param1:MovieClip, param2:Dictionary, param3:XML, param4:String, param5:int, param6:Function)
      {
         super(param1,param2,param3,param4,param5,param6);
      }
      
      override protected function createQuestDetailsPopup(param1:String) : QuestDetailsPopup
      {
         return new MiniSeries008DetailsPopup(param1);
      }
   }
}

