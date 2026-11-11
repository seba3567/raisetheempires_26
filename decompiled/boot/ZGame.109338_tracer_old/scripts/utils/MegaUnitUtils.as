package utils
{
   import ZQuest.Managers.QuestManager;
   import core.ZGlobal;
   import core.gameobjects.UnitItem;
   import core.gameobjects.VillainItem;
   import core.managers.questManager.ZGameQuestManager;
   import core.managers.questManager.ZGameTask;
   
   public class MegaUnitUtils
   {
      
      public function MegaUnitUtils()
      {
         super();
      }
      
      public static function isMegaUnitChild(param1:String) : Boolean
      {
         var _loc2_:UnitItem = ZGlobal.gameSettings.getItemByCode(param1,UnitItem) as UnitItem;
         return _loc2_.hasType(UnitItem.MEGA_UNIT) && !_loc2_.hasType("controller");
      }
      
      public static function getQuestTask(param1:String) : ZGameTask
      {
         var _loc3_:ZGameTask = null;
         var _loc4_:VillainItem = null;
         var _loc2_:Array = (QuestManager.getInstance() as ZGameQuestManager).getQuestTasks(null);
         for each(_loc3_ in _loc2_)
         {
            if(_loc3_.pveVillain)
            {
               _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc3_.pveVillain,VillainItem) as VillainItem;
               if(param1 == _loc4_.megaUnit())
               {
                  return _loc3_;
               }
            }
         }
         return null;
      }
      
      public static function getMegaUnitTemplateCode(param1:String) : String
      {
         var _loc2_:UnitItem = ZGlobal.gameSettings.getItemByCode(param1,UnitItem) as UnitItem;
         if(_loc2_.hasType(UnitItem.MEGA_UNIT))
         {
            param1 = _loc2_.megaTemplate;
         }
         return param1;
      }
   }
}

