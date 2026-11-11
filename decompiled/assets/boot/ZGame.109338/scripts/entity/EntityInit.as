package entity
{
   import as3isolib.display.scene.IIsoScene;
   import as3isolib.geom.Pt;
   import core.gameobjects.IItem;
   import core.managers.assetLoadTracker.AssetLoadTracker;
   import rendering.renderingIso.QuadSpatialManager;
   import zlabs.core.PBGroup;
   import zlabs.entity.IEntity;
   
   public class EntityInit
   {
      
      public var m_item:IItem = null;
      
      public var m_object:Object = null;
      
      public var m_isoScene:IIsoScene = null;
      
      public var m_spatialComponent:QuadSpatialManager = null;
      
      public var m_entity:IEntity = null;
      
      public var m_position:Pt = new Pt(0,0,0);
      
      public var m_assetLoadTracker:AssetLoadTracker = null;
      
      public var m_fromLoad:Boolean = true;
      
      public var m_group:PBGroup = null;
      
      public var m_generateId:Boolean = false;
      
      public var m_delayId:Boolean = false;
      
      public function EntityInit()
      {
         super();
      }
   }
}

