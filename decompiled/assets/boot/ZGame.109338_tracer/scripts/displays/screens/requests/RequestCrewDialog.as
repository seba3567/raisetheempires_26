package displays.screens.requests
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.ExperimentsManager;
   import entity.GameDataComponent;
   import transactions.TRequestCrew;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   
   public class RequestCrewDialog extends RequestDialog
   {
      
      public static const DIALOG_TITLE:String = "CrewRequestTitle";
      
      public static const DIALOG_BODY:String = "CrewRequestBody";
      
      public static const DIALOG_TOASTER:String = "CrewRequestToaster";
      
      private var m_objId:int;
      
      private var m_buildingName:String;
      
      private var m_building:GameItem;
      
      private var m_buildingFriendlyName:String;
      
      private var m_friends:Array = getAllFriends(ExperimentsManager.EXPERIMENT_REQUEST2_MFS_CREW);
      
      private var m_gameData:GameDataComponent;
      
      private var m_locTitle:String;
      
      private var m_locBody:String;
      
      public function RequestCrewDialog(param1:int, param2:String, param3:int)
      {
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc9_:uint = 0;
         var _loc4_:Boolean = false;
         this.m_objId = param1;
         this.m_buildingName = param2;
         this.m_building = ZGlobal.gameSettings.getItemByName(param2,GameItem) as GameItem;
         this.m_buildingFriendlyName = this.m_building.getFriendlyName(GameItem.SENTENCE_FRIENDLYNAME);
         var _loc8_:IEntity = ZGlobal.game.getObjectByID(this.m_objId);
         if(_loc8_ != null)
         {
            this.m_gameData = GameDataComponent.getGameDataComponent(_loc8_);
            if(this.m_gameData.userData.oldCrewInfo)
            {
               _loc4_ = true;
            }
            _loc9_ = 0;
            while(_loc9_ < this.m_friends.length)
            {
               if(this.m_gameData.userData.crewInfo != undefined && this.m_friends[_loc9_] != null)
               {
                  if(this.m_gameData.userData.crewInfo.indexOf(this.m_friends[_loc9_].zid) >= 0)
                  {
                     delete this.m_friends[_loc9_];
                  }
               }
               _loc9_++;
            }
         }
         if(_loc4_)
         {
            _loc5_ = "RebuildCrewRequestTitle";
            _loc6_ = "RebuildCrewRequestBody";
            _loc7_ = "RebuildCrewRequestToaster";
         }
         else
         {
            _loc5_ = "CrewRequestTitle";
            _loc6_ = "CrewRequestBody";
            _loc7_ = "CrewRequestToaster";
         }
         this.m_locTitle = ZGameUtils.ZlocT("Dialogs",_loc5_,{"building":this.m_buildingFriendlyName});
         this.m_locBody = ZGameUtils.ZlocT("Dialogs",_loc6_,{
            "count":param3,
            "building":this.m_buildingFriendlyName
         });
         super(this.m_friends,this.m_locTitle,this.m_locBody,_loc7_,this.m_building.getImageObject().url,RequestDialog.TYPE_CREW);
      }
      
      override protected function sendRequest(param1:Array) : void
      {
         TransactionManager.addTransaction(new TRequestCrew(param1,this.m_objId,this.m_buildingName,RequestDialog.TYPE_CREW));
      }
   }
}

