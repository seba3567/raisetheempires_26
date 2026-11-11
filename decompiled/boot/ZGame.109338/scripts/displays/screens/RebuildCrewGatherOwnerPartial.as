package displays.screens
{
   import core.ZGlobal;
   import core.entities.components.behaviors.states.BehaviorState;
   import core.gameobjects.CrewTemplateWrapper;
   import core.gameobjects.GameItem;
   import core.managers.CrewManager;
   import displays.ImageLoaderFactory;
   import flash.events.Event;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   
   public class RebuildCrewGatherOwnerPartial extends CrewGatherOwnerPartial
   {
      
      protected var _crewBackgroundSWFURL:String;
      
      private var m_rebuildTimeComplete:Boolean = false;
      
      public function RebuildCrewGatherOwnerPartial(param1:IEntity, param2:CrewTemplateWrapper, param3:GameItem, param4:Array, param5:Object, param6:BehaviorState, param7:String)
      {
         CARD_SPACING_HORIZONTAL = 17;
         this._crewBackgroundSWFURL = param7;
         super(param1,param2,param3,param4,param5,false,RebuildCrewGatherSlotOwnerPartial);
      }
      
      public function onDurationComplete() : void
      {
         this.m_rebuildTimeComplete = true;
         Logger.print(this,"JMR onDurationComplete");
         updateElements();
         this.updateDescription();
         m_mc.progressBar_mc.visible = false;
         m_mc.progress_tf.visible = false;
         m_mc.progressTitle_tf.visible = false;
         hideEmptyCards();
      }
      
      private function updateDescription() : void
      {
         TextFieldUtil.processTextField(m_mc.description_tf,this.getDescriptionText());
      }
      
      public function onDurationProgress(param1:Number, param2:Number, param3:Number) : void
      {
         var _loc4_:Number = 1 - param2 * (1 - param1) / param3;
         this.updateAutoRebuildDurationTimer(_loc4_,param3);
      }
      
      private function updateAutoRebuildDurationTimer(param1:Number, param2:Number) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         if(m_mc)
         {
            _loc3_ = ZGameTimeUtil.instance.getTimeString((1 - param1) * param2,false);
            _loc4_ = ZGameUtils.ZlocTP("Dialogs","mayhem_rebuild_label_simple");
            TextFieldUtil.processTextField(m_mc.progress_tf,_loc4_ + ": " + _loc3_);
            m_mc.progressBar_mc.loadBar_mc.width = m_mc.progressBar_mc.loadBase_mc.width * param1;
         }
      }
      
      override protected function onConfirmFinish() : void
      {
         Logger.print(this,"JMR: CrewGatherOwnerPartial onConfirmFinish");
         if(this.m_rebuildTimeComplete)
         {
            Logger.print(this,"JMR: rebuild complete while dialog open, finish button will just close the dialog");
            dispatchEvent(new Event(CrewResizablePopUp.CLOSED));
         }
         else if(numStaff >= m_wrapper.numPositions)
         {
            Logger.print(this,"JMR: Restoring old crew");
            CrewManager.restoreOldCrewInfo(owner);
            dispatchEvent(new Event(CrewResizablePopUp.BUILT));
         }
      }
      
      override protected function getDescriptionText() : String
      {
         var _loc1_:String = null;
         if(this.canFinishBuilding())
         {
            _loc1_ = ZGameUtils.ZlocTP("Dialogs","RebuildCrewDialogComplete");
         }
         else
         {
            _loc1_ = ZGameUtils.ZlocTP("Dialogs",m_textInfo.desc,getStringTokens());
         }
         return _loc1_;
      }
      
      override protected function canFinishBuilding() : Boolean
      {
         return this.m_rebuildTimeComplete || numStaff >= m_wrapper.numPositions;
      }
      
      override protected function getAsset() : String
      {
         return this._crewBackgroundSWFURL;
      }
      
      override protected function get dialogHeight() : int
      {
         return 554;
      }
      
      override protected function get dialogWidth() : int
      {
         return 727;
      }
      
      override protected function get dialogPaddingBottom() : uint
      {
         return 0;
      }
      
      override protected function get dialogPaddingTop() : uint
      {
         return 185;
      }
      
      override protected function get dialogPaddingRight() : uint
      {
         return 0;
      }
      
      override protected function get dialogPaddingLeft() : uint
      {
         return 140;
      }
      
      override protected function get resize() : Boolean
      {
         return false;
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
            _loc3_ = ZGlobal.gameSettings.getImageByName(m_gameItem.name,"icon");
            ImageLoaderFactory.CreateImageLoader(_loc3_,m_mc.icon);
         }
         var _loc1_:String = getTitleText();
         TextFieldUtil.processTextField(m_mc.title_tf,_loc1_);
         var _loc2_:String = this.getDescriptionText();
         TextFieldUtil.compactTextField(m_mc.description_tf,_loc2_);
         TextFieldUtil.compactTextField(m_mc.progressTitle_tf,ZGameUtils.ZlocTP("Dialogs","RebuildCrewDialogTip"));
      }
      
      override protected function createSlotCards(param1:Class) : Array
      {
         var _loc3_:int = 0;
         var _loc4_:RebuildCrewGatherSlotOwnerPartial = null;
         var _loc2_:Array = new Array();
         while(_loc3_ < m_wrapper.numPositions)
         {
            _loc4_ = new m_slotClass(this,param1,_loc3_,m_wrapper);
            m_slotContainer.addChild(_loc4_);
            _loc2_.push(_loc4_);
            _loc3_++;
         }
         return _loc2_;
      }
   }
}

