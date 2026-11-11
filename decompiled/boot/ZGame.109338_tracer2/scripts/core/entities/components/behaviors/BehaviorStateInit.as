package core.entities.components.behaviors
{
   import core.entities.components.states.Machine;
   import core.gameobjects.GameItem;
   
   public class BehaviorStateInit
   {
      
      public var m_machine:Machine = null;
      
      public var m_gameItem:GameItem = null;
      
      public var m_stateData:XML = null;
      
      public var m_behaviorData:XML = null;
      
      public var m_gameObject:Object = null;
      
      public function BehaviorStateInit()
      {
         super();
      }
   }
}

