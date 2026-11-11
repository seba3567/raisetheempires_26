package core.gameobjects
{
   import as3isolib.geom.Pt;
   
   public class ItemImage
   {
      
      public var image:Object;
      
      public var url:String;
      
      public var offset:Pt = null;
      
      public var anchor:Pt = null;
      
      public var skew:Pt = null;
      
      public var numAnimations:int = 0;
      
      public var drawOrderIndex:int = 0;
      
      public var maskUrl:String = null;
      
      public var color:uint = 0;
      
      public var additionalImages:Array = null;
      
      public function ItemImage(param1:Object = null)
      {
         super();
         this.image = param1;
      }
   }
}

