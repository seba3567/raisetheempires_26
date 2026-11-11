package displays.screens.partsGather
{
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.entities.components.BuildingSpatialComponent;
   import core.gameobjects.GameItem;
   import core.managers.UnitDropManager;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import core.worlds.islandworld.components.CineCameraComponent;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.SurveillanceScanResultPopup;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   import zlabs.utils.MathUtils;
   
   public class SurveillanceScanPartsGather extends BuildingPartsGather
   {
      
      private var m_imageLoader:ImageLoader = null;
      
      public function SurveillanceScanPartsGather(param1:EventDispatcher, param2:String, param3:String, param4:IEntity)
      {
         super(param1,param2,param3,param4);
      }
      
      public static function display(param1:EventDispatcher, param2:String, param3:String, param4:IEntity) : void
      {
         WindowManager.instance.push(new SurveillanceScanPartsGather(param1,param2,param3,param4));
      }
      
      override protected function initDialog() : void
      {
         super.initDialog();
         this.m_imageLoader = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName("SurveillanceTower","icon"),m_partsWindow.icon);
         this.m_imageLoader.smooth = true;
      }
      
      override protected function setTitleText() : void
      {
         TextFieldUtil.processTextField(m_partsWindow.title_tf,ZGameUtils.ZlocT("Quests","quest_QMU02_tooltip"));
      }
      
      override protected function setDescriptionText() : void
      {
         TextFieldUtil.compactTextField(m_partsWindow.description_tf,ZGameUtils.ZlocT("Quests","quest_QMU02_hint"));
      }
      
      override protected function deinitDialog() : void
      {
         if(this.m_imageLoader)
         {
            this.m_imageLoader.destroy();
            this.m_imageLoader = null;
         }
      }
      
      override protected function onFinishClick(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:GameItem = null;
         var _loc4_:int = 0;
         if(canFinish())
         {
            if(UnitDropManager.instance.numUnrevealedUnits > 0)
            {
               _loc2_ = 0;
               while(_loc2_ < m_slotData.length)
               {
                  _loc3_ = m_slotData[_loc2_].partItem;
                  _loc4_ = int(m_slotData[_loc2_].requiredCount);
                  ZGlobal.player.removeInventoryItem(_loc3_.code,_loc4_);
                  _loc2_++;
               }
            }
            this.completePartsItem();
         }
      }
      
      override protected function completePartsItem() : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:IEntity = null;
         var _loc6_:BuildingSpatialComponent = null;
         var _loc7_:Pt = null;
         var _loc8_:CineCameraComponent = null;
         super.completePartsItem();
         var _loc1_:Array = UnitDropManager.instance.revealAll();
         if(_loc1_.length > 0)
         {
            _loc2_ = ZGameUtils.ZlocT("Dialogs","Found_unit_Title");
            _loc3_ = ZGameUtils.ZlocT("Dialogs","Found_unit_Desc");
            _loc4_ = ZGameUtils.ZlocT("Dialogs","Found_unit_Button");
         }
         else
         {
            _loc2_ = ZGameUtils.ZlocT("Dialogs","NotFound_unit_Title");
            _loc3_ = ZGameUtils.ZlocT("Dialogs","NotFound_unit_Desc");
            _loc4_ = ZGameUtils.ZlocT("Dialogs","NotFound_unit_Button");
         }
         PopupManager.instance.push(new SurveillanceScanResultPopup(_loc2_,_loc3_,_loc4_));
         if(_loc1_.length > 0)
         {
            _loc5_ = ZGlobal.game.getObjectByID(_loc1_[0]);
            if(_loc5_)
            {
               _loc6_ = BuildingSpatialComponent(_loc5_.lookupComponentByType(BuildingSpatialComponent));
               if(_loc6_)
               {
                  _loc7_ = new Pt(_loc6_.position.x,_loc6_.position.y);
                  _loc7_ = MathUtils.worldToTile(_loc7_,ZGlobal.cellSize);
                  _loc8_ = ViewManager.instance.getComponentFromView(IslandWorld.ID,CineCameraComponent) as CineCameraComponent;
                  _loc8_.moveTo(_loc7_);
               }
            }
         }
      }
   }
}

