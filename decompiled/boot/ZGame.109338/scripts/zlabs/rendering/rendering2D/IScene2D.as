package zlabs.rendering.rendering2D
{
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import zlabs.core.ObjectType;
   import zlabs.rendering.rendering2D.ui.IUITarget;
   
   public interface IScene2D
   {
      
      function set sceneAlignment(param1:SceneAlignment) : void;
      
      function get sceneAlignment() : SceneAlignment;
      
      function get layerCount() : int;
      
      function getLayer(param1:int, param2:Boolean = false) : DisplayObjectSceneLayer;
      
      function set sceneView(param1:IUITarget) : void;
      
      function get sceneView() : IUITarget;
      
      function add(param1:DisplayObjectRenderer) : void;
      
      function remove(param1:DisplayObjectRenderer) : void;
      
      function invalidate(param1:DisplayObjectRenderer) : void;
      
      function invalidateRectangle(param1:Rectangle) : void;
      
      function getRenderersUnderPoint(param1:Point, param2:Array, param3:ObjectType = null) : Boolean;
      
      function setWorldCenter(param1:Point) : void;
      
      function screenPan(param1:int, param2:int) : void;
      
      function set rotation(param1:Number) : void;
      
      function get rotation() : Number;
      
      function set position(param1:Point) : void;
      
      function get position() : Point;
      
      function set zoom(param1:Number) : void;
      
      function get zoom() : Number;
      
      function get sceneViewBounds() : Rectangle;
      
      function set trackLimitRectangle(param1:Rectangle) : void;
      
      function get trackLimitRectangle() : Rectangle;
      
      function transformWorldToScene(param1:Point) : Point;
      
      function transformSceneToWorld(param1:Point) : Point;
      
      function transformSceneToScreen(param1:Point) : Point;
      
      function transformScreenToScene(param1:Point) : Point;
      
      function transformWorldToScreen(param1:Point) : Point;
      
      function transformScreenToWorld(param1:Point) : Point;
      
      function sortSpatials(param1:Array) : void;
   }
}

