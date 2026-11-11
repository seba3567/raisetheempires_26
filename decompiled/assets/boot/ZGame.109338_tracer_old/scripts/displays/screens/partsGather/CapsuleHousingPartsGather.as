package displays.screens.partsGather
{
   import ZLocalization.LocalizationObjectToken;
   import ZQuest.Init.QuestSettingsInit;
   import core.managers.questManager.ZGameQuest;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.events.EventDispatcher;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.managers.WindowManager;
   
   public class CapsuleHousingPartsGather extends BuildingPartsGather
   {
      
      public static const FINISHED:String = "finished";
      
      private static const NUM_REWARD_SLOTS:int = 3;
      
      protected var m_desc2:String = null;
      
      protected var m_rewardDesc:String = null;
      
      protected var m_quest:String = null;
      
      protected var m_reward_loaders:Array = new Array();
      
      public function CapsuleHousingPartsGather(param1:EventDispatcher, param2:String, param3:String, param4:String, param5:IEntity, param6:String = "", param7:String = null, param8:String = null)
      {
         m_desc = param4 ? param4 : "BuildingPartsGatherDescription";
         this.m_desc2 = param7 ? param7 : "BuildingPartsGatherDescription";
         m_title = param6.length != 0 ? param6 : "BuildingPartsGatherTitle";
         this.m_rewardDesc = param8 ? param8 : "QuestRewards";
         this.m_quest = param3;
         super(param1,param2,param4,param5,param6);
      }
      
      public static function display(param1:EventDispatcher, param2:String, param3:String, param4:String, param5:IEntity, param6:String = "", param7:String = null, param8:String = null) : void
      {
         WindowManager.instance.push(new CapsuleHousingPartsGather(param1,param2,param3,param4,param5,param6,param7,param8));
      }
      
      override protected function setDescriptionText() : void
      {
         var _loc2_:ZGameQuest = null;
         var _loc3_:Object = null;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:ImageLoader = null;
         var _loc1_:LocalizationObjectToken = m_partsItem.getSentenceNameLocalizationObject("singular",false);
         TextFieldUtil.compactTextField(m_partsWindow.hint_tf,ZGameUtils.ZlocT("Dialogs",this.m_desc2));
         if(!canFinish())
         {
            TextFieldUtil.compactTextField(m_partsWindow.generic_tf,ZGameUtils.ZlocT("Dialogs",m_desc,{"item":_loc1_}));
         }
         else
         {
            TextFieldUtil.compactTextField(m_partsWindow.generic_tf,ZGameUtils.ZlocT("Dialogs","BuildingPartsGatherComplete"));
         }
         if(this.m_quest != null)
         {
            _loc2_ = QuestSettingsInit.getInstance().getItemByName(this.m_quest) as ZGameQuest;
            _loc3_ = _loc2_.getRewardTextObject();
            _loc4_ = [m_partsWindow.rewards_mc.rewardCard_01,m_partsWindow.rewards_mc.rewardCard_02,m_partsWindow.rewards_mc.rewardCard_03];
            _loc5_ = 0;
            TextFieldUtil.compactTextField(m_partsWindow.rewards_mc.instructions_tf,ZGameUtils.ZlocT("Dialogs",this.m_rewardDesc));
            for each(_loc6_ in _loc3_.rewardText)
            {
               if(_loc5_ >= NUM_REWARD_SLOTS)
               {
                  break;
               }
               _loc7_ = ImageLoaderFactory.CreateImageLoader(_loc3_.rewardIcons[_loc5_],_loc4_[_loc5_].icon);
               _loc7_.smooth = true;
               this.m_reward_loaders.push(_loc7_);
               TextFieldUtil.processTextField(_loc4_[_loc5_].value_tf,_loc3_.rewardPairs[_loc5_].count);
               TextFieldUtil.processTextField(_loc4_[_loc5_].title_tf,_loc3_.rewardPairs[_loc5_].reward);
               _loc5_++;
            }
            while(_loc5_ < NUM_REWARD_SLOTS)
            {
               _loc3_[_loc5_].visible = false;
               _loc5_++;
            }
         }
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
   }
}

