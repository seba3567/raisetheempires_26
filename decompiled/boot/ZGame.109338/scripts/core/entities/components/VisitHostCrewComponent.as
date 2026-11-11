package core.entities.components
{
   import core.ZGlobal;
   import core.entities.components.behaviors.states.BehaviorState;
   import core.entities.components.behaviors.states.CrewDialogState;
   import core.gameobjects.CrewTemplateWrapper;
   import core.managers.CrewManager;
   import displays.screens.CrewGatherVisitorComplete;
   import displays.screens.CrewGatherVisitorPartial;
   import zlabs.displays.popups.SWFPopUp;
   import zlabs.entity.IEntity;
   import zlabs.managers.WindowManager;
   
   public class VisitHostCrewComponent extends VisitHostComponent
   {
      
      private var m_crewTemplateName:String;
      
      private var m_crewTemplateWrapper:CrewTemplateWrapper;
      
      public function VisitHostCrewComponent(param1:int)
      {
         super(param1);
      }
      
      public function get crewTemplateName() : String
      {
         if(!this.m_crewTemplateName)
         {
            if(gameItem)
            {
               this.m_crewTemplateName = gameItem.getCrewTemplateName();
            }
         }
         return this.m_crewTemplateName;
      }
      
      public function get crewTemplateWrapper() : CrewTemplateWrapper
      {
         if(!this.m_crewTemplateWrapper)
         {
            this.m_crewTemplateWrapper = this.crewTemplateName ? ZGlobal.gameSettings.getCrewTemplateWrapper(this.crewTemplateName) : null;
         }
         return this.m_crewTemplateWrapper;
      }
      
      private function showCompleteCrewDialog() : void
      {
         var _loc3_:SWFPopUp = null;
         var _loc1_:Object = CrewManager.getCrewInfo(owner,null,true);
         var _loc2_:Object = CrewManager.getOldCrewInfo(owner);
         if(!_loc2_)
         {
            if(_loc1_)
            {
               _loc3_ = new CrewGatherVisitorComplete(owner,this.crewTemplateWrapper,gameItem,_loc1_.crew);
               WindowManager.instance.push(_loc3_);
            }
         }
      }
      
      private function showPartialCrewDialog() : void
      {
         var _loc3_:SWFPopUp = null;
         var _loc1_:Object = CrewManager.getCrewInfo(owner,null,true);
         var _loc2_:Object = CrewManager.getOldCrewInfo(owner);
         if(!_loc2_)
         {
            if(_loc1_)
            {
               _loc3_ = new CrewGatherVisitorPartial(owner,this.crewTemplateWrapper,gameItem,_loc1_.crew);
               WindowManager.instance.push(_loc3_);
            }
         }
      }
      
      override protected function onHelpLimitReached() : void
      {
         if(Boolean(fsmc) && fsmc.isBuilt)
         {
            this.showCompleteCrewDialog();
         }
      }
      
      override protected function handleHelp() : Boolean
      {
         var _loc1_:BehaviorState = null;
         if(!ZGlobal.player.visitorEnergy || helpLimitReached || !CrewManager.isPlayerInCrew(owner,ZGlobal.player.uid))
         {
            if(fsmc)
            {
               if(fsmc.isBuilt)
               {
                  this.showCompleteCrewDialog();
               }
               else
               {
                  this.showPartialCrewDialog();
               }
            }
            return true;
         }
         if(canOwnerBeHelped())
         {
            return super.handleHelp();
         }
         if(fsmc)
         {
            if(fsmc.isBuilt)
            {
               this.showCompleteCrewDialog();
            }
            else
            {
               _loc1_ = sm.currentState as BehaviorState;
               if(_loc1_ as CrewDialogState)
               {
                  this.showPartialCrewDialog();
               }
            }
         }
         return true;
      }
      
      override protected function onHandleHelp(param1:IEntity, param2:Boolean) : Boolean
      {
         if(param2)
         {
            if(CrewManager.isCrewBuilding(param1))
            {
               if(!CrewManager.isPlayerInCrew(param1,ZGlobal.player.uid))
               {
                  this.showCompleteCrewDialog();
                  return false;
               }
            }
         }
         return true;
      }
   }
}

