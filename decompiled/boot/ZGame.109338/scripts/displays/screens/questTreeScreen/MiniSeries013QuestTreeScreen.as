package displays.screens.questTreeScreen
{
   import zlabs.Zlab;
   
   public class MiniSeries013QuestTreeScreen extends MiniSeries008QuestTreeScreen
   {
      
      public function MiniSeries013QuestTreeScreen(param1:String)
      {
         super(param1);
      }
      
      override protected function deinitDialog() : void
      {
         Zlab.processManager.removeScheduledObject(this);
         super.deinitDialog();
      }
      
      override protected function updateProgress() : void
      {
         super.updateProgress();
         var _loc1_:Number = numCompleted() / m_questTree.steps;
         screen.panelBottomAssets_mc.progressBar_mc.loadBar_mc.width = screen.panelBottomAssets_mc.progressBar_mc.loadBase_mc.width * _loc1_;
      }
      
      override protected function createNode(param1:XML, param2:int) : Node
      {
         var _loc3_:String = param1.@screenId;
         return new MiniSeries013Node(screen.panelBottomAssets_mc[_loc3_],null,param1,m_questTree.id,param2,onImageLoaded);
      }
      
      override protected function onUpdateTotalKills() : void
      {
         this.updateTotalKills();
         Zlab.processManager.schedule(2000,this,this.onUpdateTotalKills);
      }
      
      override protected function updateTotalKills() : void
      {
      }
   }
}

