package displays.screens
{
   import core.entities.ProgressBar;
   import core.gameobjects.CrewTemplateWrapper;
   import core.gameobjects.GameItem;
   import core.managers.CrewManager;
   import core.ui.Tooltip;
   import fl.containers.UILoader;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.resource.SWFResource;
   
   public class CrewGatherOwnerComplete extends CrewGather
   {
      
      private static var LEVEL_X_OFFSET:int = 10;
      
      private var m_progressBar:ProgressBar;
      
      public function CrewGatherOwnerComplete(param1:IEntity, param2:CrewTemplateWrapper, param3:GameItem, param4:Array)
      {
         super(param1,param2,param3,param4,CrewGatherSlotOwnerComplete);
      }
      
      override protected function showConfirmButton() : Boolean
      {
         return false;
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         this.initProgressBar(param1.getAssetClass("progressBar"));
      }
      
      override protected function getTitleText() : String
      {
         return ZGameUtils.ZlocT("Dialogs","CrewDialogOwnerCompleteTitle",getStringTokens());
      }
      
      override protected function getDescriptionText() : String
      {
         return ZGameUtils.ZlocT("Dialogs","CrewDialogOwnerCompleteDesc",getStringTokens());
      }
      
      override protected function get dialogPaddingTop() : uint
      {
         return 120;
      }
      
      override protected function deinitDialog() : void
      {
         super.deinitDialog();
         if(this.m_progressBar)
         {
            if(this.m_progressBar.parent)
            {
               this.m_progressBar.parent.removeChild(this.m_progressBar);
            }
            Tooltip.unsubscribe(this.m_progressBar);
            this.m_progressBar.destroy();
            this.m_progressBar = null;
         }
      }
      
      private function initProgressBar(param1:Class) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc7_:uint = 0;
         var _loc8_:uint = 0;
         var _loc2_:Object = CrewManager.getOwnerTendProgressBarInfo(owner);
         if(_loc2_)
         {
            this.m_progressBar = this.createBar(param1);
            if(this.m_progressBar)
            {
               _loc3_ = 1;
               if(_loc2_.nextMinTends >= 0)
               {
                  _loc7_ = _loc2_.tends - _loc2_.currMinTends;
                  _loc8_ = _loc2_.nextMinTends - _loc2_.currMinTends;
                  _loc3_ = _loc7_ / _loc8_;
                  _loc3_ = Math.min(1,_loc3_);
                  _loc3_ = Math.max(0,_loc3_);
                  this.m_progressBar.updateProgressBarPercentage(String(_loc2_.tends),_loc3_);
                  _loc4_ = "CrewTendTooltip";
               }
               else
               {
                  this.m_progressBar.updateProgressBarPercentage(String(_loc2_.tends),1);
                  _loc4_ = "CrewTendTooltipHighestRewardLevel";
               }
               _loc5_ = ZGameUtils.ZlocT("Dialogs",_loc4_,{
                  "tendsCurrent":_loc2_.tends,
                  "tendsNext":_loc2_.nextMinTends
               });
               Tooltip.subscribe(this.m_progressBar,_loc5_);
               _loc6_ = _loc2_.tendLevel ? int(_loc2_.tendLevel) : 1;
               TextFieldUtil.processTextField(this.m_progressBar.mc.level_tf,String(_loc6_));
            }
         }
      }
      
      private function createBar(param1:Class) : ProgressBar
      {
         var _loc3_:ProgressBar = null;
         var _loc2_:UILoader = mc.icon;
         if(!_loc2_ || !param1)
         {
            return null;
         }
         _loc3_ = new ProgressBar(param1);
         mc.icon.addChild(_loc3_);
         var _loc4_:Number = -((_loc3_.width - mc.icon.width) * 0.5);
         var _loc5_:Number = mc.icon.height - _loc3_.height * 0.5;
         _loc3_.x = _loc4_ + LEVEL_X_OFFSET;
         _loc3_.y = _loc5_;
         return _loc3_;
      }
   }
}

