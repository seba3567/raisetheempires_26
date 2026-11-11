package zlabs.rendering.rendering2D.spritesheet
{
   import flash.geom.Rectangle;
   import zlabs.debug.Logger;
   
   public class FixedSizeDivider implements ISpriteSheetDivider
   {
      
      public var width:int = 32;
      
      public var height:int = 32;
      
      public var horizontalSpacing:int = 0;
      
      public var verticalSpacing:int = 0;
      
      private var _owningSheet:SpriteSheetComponent;
      
      public function FixedSizeDivider()
      {
         super();
      }
      
      public function set owningSheet(param1:SpriteSheetComponent) : void
      {
         if(this._owningSheet)
         {
            Logger.warn(this,"set OwningSheet","Already assigned to a sheet, reassigning may result in unexpected behavior.");
         }
         this._owningSheet = param1;
      }
      
      public function get frameCount() : int
      {
         if(!this._owningSheet)
         {
            throw new Error("OwningSheet must be set before calling this!");
         }
         return Math.floor(this._owningSheet.imageData.width / this.width) * Math.floor(this._owningSheet.imageData.height / this.height);
      }
      
      public function getFrameArea(param1:int) : Rectangle
      {
         if(!this._owningSheet)
         {
            throw new Error("OwningSheet must be set before calling this!");
         }
         var _loc2_:int = param1 % Math.floor(this._owningSheet.imageData.width / this.width);
         var _loc3_:int = Math.floor(param1 / Math.floor(this._owningSheet.imageData.width / this.width));
         return new Rectangle(_loc2_ * (this.width + this.horizontalSpacing),_loc3_ * (this.height + this.verticalSpacing),this.width,this.height);
      }
      
      public function clone() : ISpriteSheetDivider
      {
         var _loc1_:FixedSizeDivider = new FixedSizeDivider();
         _loc1_.width = this.width;
         _loc1_.height = this.height;
         return _loc1_;
      }
   }
}

