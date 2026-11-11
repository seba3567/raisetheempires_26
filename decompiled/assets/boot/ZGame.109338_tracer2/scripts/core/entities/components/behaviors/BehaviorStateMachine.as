package core.entities.components.behaviors
{
   import core.entities.components.behaviors.states.BehaviorState;
   import core.entities.components.states.Machine;
   import zlabs.entity.IEntity;
   
   public class BehaviorStateMachine extends Machine
   {
      
      private var m_referenceItemName:String;
      
      private var m_researchItemName:String;
      
      private var m_builtState:String = null;
      
      private var m_activatedState:String = null;
      
      private var m_validCrewState:String = null;
      
      private var m_visitorHelpRequestTransition:Boolean = false;
      
      private var m_visitorHelpRedeemTransition:Boolean = false;
      
      public var m_multiHarvestTransition:Boolean = false;
      
      private var m_remoteStateChange:Boolean;
      
      private var m_resourceType:String = null;
      
      private var m_multiplier:int = 0;
      
      private var m_upgradeState:String = null;
      
      private var m_crewState:String = null;
      
      public function BehaviorStateMachine(param1:String, param2:XMLList, param3:String = null)
      {
         super();
         this.m_builtState = param2.@builtState;
         this.m_activatedState = param2.@activatedState;
         if(param2.@validCrewState != undefined)
         {
            this.m_validCrewState = param2.@validCrewState;
         }
         if(param2.@upgradeState != undefined)
         {
            this.m_upgradeState = param2.@upgradeState;
         }
         if(param2.@crewState != undefined)
         {
            this.m_crewState = param2.@crewState;
         }
         this.storeReferenceData(param1,param3);
      }
      
      public function storeReferenceData(param1:String, param2:String = null) : void
      {
         this.m_referenceItemName = param1;
         this.m_researchItemName = param2;
      }
      
      public function get referenceItemName() : String
      {
         return this.m_referenceItemName;
      }
      
      public function get researchItemName() : String
      {
         return this.m_researchItemName;
      }
      
      public function set referenceItemName(param1:String) : void
      {
         this.m_referenceItemName = param1;
      }
      
      public function set researchItemName(param1:String) : void
      {
         this.m_researchItemName = param1;
      }
      
      public function get builtState() : String
      {
         return this.m_builtState;
      }
      
      public function get activatedState() : String
      {
         return this.m_activatedState;
      }
      
      public function isCurrentStateBuilt() : Boolean
      {
         var _loc1_:int = parseInt(currentStateName);
         var _loc2_:int = parseInt(this.m_builtState);
         return _loc1_ >= _loc2_;
      }
      
      public function isCurrentStateActivated() : Boolean
      {
         var _loc1_:int = parseInt(currentStateName);
         var _loc2_:int = parseInt(this.m_activatedState);
         return _loc1_ >= _loc2_;
      }
      
      public function get validCrewState() : String
      {
         return this.m_validCrewState;
      }
      
      public function get inVisitorHelpRequestTransition() : Boolean
      {
         return this.m_visitorHelpRequestTransition;
      }
      
      public function get inVisitorHelpRedeemTransition() : Boolean
      {
         return this.m_visitorHelpRedeemTransition;
      }
      
      public function get inMultiHarvestTransition() : Boolean
      {
         return this.m_multiHarvestTransition;
      }
      
      public function get inRemoteStateChange() : Boolean
      {
         return this.m_remoteStateChange;
      }
      
      public function performHelpRedeemRequest(param1:IEntity, param2:String) : void
      {
         this.m_visitorHelpRedeemTransition = true;
         (currentState as BehaviorState).onVisitorHelpRedeemed(param1,param2);
         this.m_visitorHelpRedeemTransition = false;
      }
      
      public function performVisitorHelpRequest() : void
      {
         this.m_visitorHelpRequestTransition = true;
         (currentState as BehaviorState).onVisitorHelped();
         this.m_visitorHelpRequestTransition = false;
      }
      
      public function canVisitorHelp() : Boolean
      {
         var _loc1_:BehaviorState = currentState as BehaviorState;
         return Boolean(_loc1_) && _loc1_.canVisitorHelp();
      }
      
      public function canRedeemHelp() : Boolean
      {
         var _loc1_:BehaviorState = currentState as BehaviorState;
         return Boolean(_loc1_) && _loc1_.canRedeemHelp();
      }
      
      public function updateStateFromRemote(param1:String) : void
      {
         this.m_remoteStateChange = true;
         currentStateName = param1;
         this.m_remoteStateChange = false;
      }
      
      public function set resourceType(param1:String) : void
      {
         this.m_resourceType = param1;
      }
      
      public function get resourceType() : String
      {
         return this.m_resourceType;
      }
      
      public function set multiplier(param1:int) : void
      {
         this.m_multiplier = param1;
      }
      
      public function get multiplier() : int
      {
         return this.m_multiplier;
      }
      
      public function get upgradeState() : String
      {
         return this.m_upgradeState;
      }
      
      public function get crewState() : String
      {
         return this.m_crewState;
      }
   }
}

