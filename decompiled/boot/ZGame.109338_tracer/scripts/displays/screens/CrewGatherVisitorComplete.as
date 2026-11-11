package displays.screens
{
   import core.gameobjects.CrewTemplateWrapper;
   import core.gameobjects.GameItem;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   
   public class CrewGatherVisitorComplete extends CrewGather
   {
      
      public function CrewGatherVisitorComplete(param1:IEntity, param2:CrewTemplateWrapper, param3:GameItem, param4:Array)
      {
         super(param1,param2,param3,param4,CrewGatherSlotVisitorComplete);
      }
      
      override protected function getTitleText() : String
      {
         return ZGameUtils.ZlocT("Dialogs","CrewDialogTitleVisitor",getStringTokens());
      }
      
      override protected function getDescriptionText() : String
      {
         return ZGameUtils.ZlocT("Dialogs","CrewDialogDescVisitorComplete");
      }
      
      override protected function showConfirmButton() : Boolean
      {
         return false;
      }
   }
}

