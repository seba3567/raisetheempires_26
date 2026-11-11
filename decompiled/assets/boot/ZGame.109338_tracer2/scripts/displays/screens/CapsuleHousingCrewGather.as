package displays.screens
{
   import Engine.Managers.TransactionManager;
   import ZQuest.Init.QuestSettingsInit;
   import core.ZGlobal;
   import core.gameobjects.CrewTemplateWrapper;
   import core.gameobjects.GameItem;
   import core.managers.ExperimentsManager;
   import core.managers.questManager.ZGameQuest;
   import core.player.Player;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import entity.GameDataComponent;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import transactions.TStaffPosition;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class CapsuleHousingCrewGather extends CrewGatherOwnerPartial
   {
      
      private static const NUM_REWARD_SLOTS:int = 3;
      
      private var m_owner:IEntity;
      
      protected var m_crewBackgroundSWFURL:String;
      
      protected var m_quest:String = null;
      
      protected var m_reward_loaders:Array = new Array();
      
      public function CapsuleHousingCrewGather(param1:IEntity, param2:CrewTemplateWrapper, param3:GameItem, param4:String, param5:Array, param6:Object, param7:String, param8:Boolean = false, param9:Class = null)
      {
         this.m_crewBackgroundSWFURL = param7;
         this.m_owner = param1;
         this.m_quest = param4;
         super(param1,param2,param3,param5,param6,param8,param9);
      }
      
      override protected function getAsset() : String
      {
         return this.m_crewBackgroundSWFURL;
      }
      
      override protected function get resize() : Boolean
      {
         return false;
      }
      
      override protected function getGridLayout(param1:int) : Point
      {
         return new Point(4,1);
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         this.setupUI();
      }
      
      override protected function initSlotCards(param1:Point, param2:Point) : void
      {
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc3_:Number = 0;
         var _loc4_:Number = 70;
         var _loc5_:Boolean = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_REPLACE_CREW) == ExperimentsManager.VARIANT_VALUE_REPLACE_CREW_ON;
         var _loc6_:Array = [-195,55,22,54];
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         loop0:
         while(_loc8_ < param1.y)
         {
            _loc9_ = 0;
            while(true)
            {
               if(_loc9_ >= param1.x)
               {
                  _loc4_ += param2.y + _loc7_;
                  _loc3_ = 0;
                  _loc8_++;
                  continue loop0;
               }
               _loc10_ = _loc9_ + param1.x * _loc8_;
               if(_loc5_ && ZGlobal.isHome())
               {
                  this.updateSlotCardForReplaceability(m_slotCards[_loc10_],_loc10_,m_slotCards.length);
               }
               _loc3_ += param2.x + _loc6_[_loc9_];
               m_slotCards[_loc10_].x = _loc3_;
               m_slotCards[_loc10_].y = _loc4_;
               if(++_loc10_ >= m_slotCards.length)
               {
                  break;
               }
               _loc9_++;
            }
            return;
         }
      }
      
      private function setupUI() : void
      {
         var _loc3_:MovieClip = null;
         var _loc4_:ZGameQuest = null;
         var _loc5_:Object = null;
         var _loc6_:Array = null;
         var _loc7_:int = 0;
         var _loc8_:String = null;
         var _loc9_:ImageLoader = null;
         var _loc1_:Array = [m_mc.pointer0_mc,m_mc.pointer1_mc,m_mc.pointer2_mc,m_mc.pointer3_mc];
         var _loc2_:int = 0;
         for each(_loc3_ in _loc1_)
         {
            TextFieldUtil.compactTextField(_loc3_.generic_tf,ZGameUtils.ZlocT("Dialogs","CapsuleHousingCrewPopulation"));
            if(Boolean(m_crewInfo) && Boolean(_loc2_ < m_crewInfo.length) && m_crewInfo[_loc2_] != null)
            {
               _loc3_.gotoAndStop(1);
            }
            else
            {
               _loc3_.gotoAndStop(2);
            }
            _loc2_++;
         }
         TextFieldUtil.compactTextField(m_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","CapsuleHousingCrewPopupDesc"));
         TextFieldUtil.compactTextField(m_mc.hint_tf,ZGameUtils.ZlocT("Dialogs","CapsuleHousingCrewHint"));
         if(Boolean(this.m_quest) && !canFinishBuilding())
         {
            TextFieldUtil.compactTextField(m_mc.rewards_mc.instructions_tf,ZGameUtils.ZlocT("Dialogs","CapsuleHousingRewardDesc"));
            _loc4_ = QuestSettingsInit.getInstance().getItemByName(this.m_quest) as ZGameQuest;
            _loc5_ = _loc4_.getRewardTextObject();
            _loc6_ = [m_mc.rewards_mc.rewardCard_01,m_mc.rewards_mc.rewardCard_02,m_mc.rewards_mc.rewardCard_03];
            _loc7_ = 0;
            for each(_loc8_ in _loc5_.rewardText)
            {
               if(_loc7_ >= NUM_REWARD_SLOTS)
               {
                  break;
               }
               _loc9_ = ImageLoaderFactory.CreateImageLoader(_loc5_.rewardIcons[_loc7_],_loc6_[_loc7_].icon);
               _loc9_.smooth = true;
               this.m_reward_loaders.push(_loc9_);
               TextFieldUtil.processTextField(_loc6_[_loc7_].value_tf,_loc5_.rewardPairs[_loc7_].count);
               TextFieldUtil.processTextField(_loc6_[_loc7_].title_tf,_loc5_.rewardPairs[_loc7_].reward);
               _loc7_++;
            }
            while(_loc7_ < NUM_REWARD_SLOTS)
            {
               _loc5_[_loc7_].visible = false;
               _loc7_++;
            }
         }
         else
         {
            m_mc.rewards_mc.visible = false;
         }
      }
      
      private function updateSlotCardForReplaceability(param1:Object, param2:int, param3:int) : void
      {
         var _loc4_:CrewGatherSlot = null;
         if(param1 is CrewGatherSlot && CrewGatherSlot(param1).enableReplaceableTooltip())
         {
            _loc4_ = CrewGatherSlot(param1);
            if(param2 < param3 - m_crewReplaceCount)
            {
               _loc4_.setButtonReplaceMode();
            }
            else
            {
               _loc4_.setButtonResendReplaceMode();
            }
         }
      }
      
      override protected function buyStaff(param1:int, param2:int) : void
      {
         var _loc4_:Boolean = false;
         var _loc5_:uint = 0;
         var _loc6_:uint = 0;
         var _loc7_:TStaffPosition = null;
         var _loc3_:GameDataComponent = GameDataComponent.getGameDataComponent(owner);
         if(_loc3_)
         {
            if(!_loc3_.userData || !(_loc3_.userData.crewInfo as Array) || !_loc3_.userData.crewInfo.length)
            {
               _loc3_.userData.crewInfo = [];
            }
            _loc5_ = uint(_loc3_.userData.crewInfo.length);
            _loc6_ = 0;
            while(_loc6_ < _loc5_)
            {
               if(null == _loc3_.userData.crewInfo[_loc6_])
               {
                  _loc3_.userData.crewInfo[_loc6_] = Player.FAKE_PLAYER_ID;
                  _loc4_ = true;
                  break;
               }
               _loc6_++;
            }
            if(!_loc4_)
            {
               _loc3_.userData.crewInfo.push(Player.FAKE_PLAYER_ID);
            }
            _loc7_ = new TStaffPosition(owner,param2,param1);
            TransactionManager.addTransaction(_loc7_);
            ZGlobal.player.cash -= param1;
            owner.eventDispatcher.dispatchEvent(new WorldEvent(GameDataComponent.CREW_UPDATED,{"crew":_loc3_.userData.crewInfo}));
         }
      }
      
      override protected function showConfirmButton() : Boolean
      {
         return !canFinishBuilding();
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:ImageLoader = null;
         for each(_loc1_ in this.m_reward_loaders)
         {
            _loc1_.destroy();
            _loc1_ = null;
         }
         this.m_reward_loaders = null;
         super.deinitDialog();
      }
      
      public function closeCrewGather() : void
      {
         closeWindow(null);
      }
   }
}

