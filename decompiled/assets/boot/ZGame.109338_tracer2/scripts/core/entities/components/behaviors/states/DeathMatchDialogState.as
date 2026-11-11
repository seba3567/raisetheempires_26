package core.entities.components.behaviors.states
{
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.managers.deathMatchManager.DeathMatchManager;
   
   public class DeathMatchDialogState extends DialogState
   {
      
      public function DeathMatchDialogState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function showDialog() : void
      {
         DeathMatchManager.instance.launchLobby();
      }
   }
}

