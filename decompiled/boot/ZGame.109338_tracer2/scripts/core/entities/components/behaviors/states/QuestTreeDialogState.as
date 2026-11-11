package core.entities.components.behaviors.states
{
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.player.questTrees.QuestTree;
   
   public class QuestTreeDialogState extends DialogState
   {
      
      public function QuestTreeDialogState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function showDialog() : void
      {
         QuestTree.showScreen(data.@questTree,"worldObject");
      }
   }
}

