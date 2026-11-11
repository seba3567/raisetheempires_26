package displays.screens
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.gameobjects.CrewTemplateWrapper;
   import core.gameobjects.GameItem;
   import core.managers.CrewManager;
   import core.player.Player;
   import displays.ImageLoaderFactory;
   import displays.screens.requests.RequestCrewDialog;
   import entity.GameDataComponent;
   import flash.events.Event;
   import transactions.TStaffPosition;
   import utils.TextFieldUtil;
   import zlabs.entity.IEntity;
   import zlabs.entity.PropertyReference;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   
   public class CrewGather extends CrewResizablePopUp
   {
      
      protected var m_gameItem:GameItem;
      
      private var m_owner:IEntity;
      
      public function CrewGather(param1:IEntity, param2:CrewTemplateWrapper, param3:GameItem, param4:Array, param5:Class)
      {
         this.m_owner = param1;
         this.m_gameItem = param3;
         super(param2,param4,param5);
      }
      
      override protected function getAsset() : String
      {
         return "assets/displays/dialogs/PU_Crew.swf";
      }
      
      public function get owner() : IEntity
      {
         return this.m_owner;
      }
      
      protected function getStringTokens() : Object
      {
         return {"building":this.m_gameItem.getSentenceNameLocalizationObject()};
      }
      
      protected function getTitleText() : String
      {
         return "";
      }
      
      protected function getDescriptionText() : String
      {
         return "";
      }
      
      override protected function setupText() : void
      {
         var _loc3_:String = null;
         if(m_mc.key_mc)
         {
            m_mc.key_mc.visible = false;
         }
         if(m_mc.icon)
         {
            _loc3_ = ZGlobal.gameSettings.getImageByName(this.m_gameItem.name,"icon");
            ImageLoaderFactory.CreateImageLoader(_loc3_,m_mc.icon);
         }
         var _loc1_:String = this.getTitleText();
         TextFieldUtil.compactTextField(m_mc.title_tf,_loc1_);
         var _loc2_:String = this.getDescriptionText();
         TextFieldUtil.compactTextField(m_mc.description_tf,_loc2_);
      }
      
      override protected function getButtonTextKey() : String
      {
         return canFinishBuilding() ? "CrewDialogButtonFinishBuilding" : "CrewDialogButtonHireFriends";
      }
      
      override protected function showHireController() : void
      {
         var _loc1_:PropertyReference = null;
         var _loc2_:int = 0;
         super.showHireController();
         if(!ZGlobal.isVisiting())
         {
            if(WindowManager.isFullScreen())
            {
               WindowManager.toggleFullScreen();
            }
            _loc1_ = new PropertyReference("@Data.id");
            _loc2_ = this.m_owner.getProperty(_loc1_) as int;
            PopupManager.instance.push(new RequestCrewDialog(_loc2_,this.m_gameItem.name,m_wrapper.numPositions - numStaff));
         }
      }
      
      override protected function buyStaff(param1:int, param2:int) : void
      {
         ZGlobal.player.cash -= param1;
         TransactionManager.addTransaction(new TStaffPosition(this.m_owner,param2,param1),true);
         CrewManager.instance.dispatchEvent(new WorldEvent(GameDataComponent.ZLINGSHOT_CREW_ADDED,{
            "id":"crew",
            "staffer":Player.FAKE_PLAYER_ID,
            "object_id":GameDataComponent.getGameDataComponent(this.owner).userData.id
         }));
      }
      
      override protected function onConfirmFinish() : void
      {
         dispatchEvent(new Event(CrewResizablePopUp.BUILT));
      }
      
      override protected function get dialogPaddingBottom() : uint
      {
         return 50;
      }
      
      override protected function get dialogPaddingTop() : uint
      {
         return 110;
      }
      
      override protected function get centerDescription() : Boolean
      {
         return false;
      }
      
      override protected function onWidthSet(param1:uint) : void
      {
         var _loc2_:int = dialogWidth - param1;
         if(mc.description_tf)
         {
            mc.description_tf.width += _loc2_ - 10;
         }
      }
      
      override protected function onSlotFullClicked(param1:WorldEvent) : void
      {
         var _loc2_:CrewGatherSlot = null;
         _loc2_ = param1.eventData.slot;
         if(_loc2_.crewActionMode == CrewGatherSlot.CREW_ACTION_MODE_REPLACE)
         {
            this.replaceCrew(param1.eventData.crewMember);
         }
      }
      
      private function replaceCrew(param1:Player) : void
      {
         if(WindowManager.isFullScreen())
         {
            WindowManager.toggleFullScreen();
         }
         var _loc2_:PropertyReference = new PropertyReference("@Data.id");
         var _loc3_:int = this.m_owner.getProperty(_loc2_) as int;
         PopupManager.instance.push(new RequestCrewDialog(_loc3_,this.m_gameItem.name,m_crewInfo.length - numStaff));
         CrewManager.setCrewInfoReplace(this.owner,param1.uid);
         closeWindow(null);
      }
   }
}

