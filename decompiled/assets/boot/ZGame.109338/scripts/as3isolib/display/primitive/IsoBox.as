package as3isolib.display.primitive
{
   import as3isolib.enum.RenderStyleType;
   import as3isolib.geom.IsoMath;
   import as3isolib.geom.Pt;
   import as3isolib.graphics.IBitmapFill;
   import as3isolib.graphics.IFill;
   import as3isolib.graphics.IStroke;
   import flash.display.Graphics;
   import flash.geom.Matrix;
   
   public class IsoBox extends IsoPrimitive
   {
      
      public function IsoBox(param1:Object = null)
      {
         super(param1);
      }
      
      override public function set stroke(param1:IStroke) : void
      {
         strokes = [param1,param1,param1,param1,param1,param1];
      }
      
      override protected function validateGeometry() : Boolean
      {
         return width <= 0 && length <= 0 && height <= 0 ? false : true;
      }
      
      override protected function drawGeometry() : void
      {
         var _loc12_:Matrix = null;
         var _loc1_:Graphics = mainContainer.graphics;
         _loc1_.clear();
         var _loc2_:Pt = IsoMath.isoToScreen(new Pt(0,0,0));
         var _loc3_:Pt = IsoMath.isoToScreen(new Pt(width,0,0));
         var _loc4_:Pt = IsoMath.isoToScreen(new Pt(width,length,0));
         var _loc5_:Pt = IsoMath.isoToScreen(new Pt(0,length,0));
         var _loc6_:Pt = IsoMath.isoToScreen(new Pt(0,0,height));
         var _loc7_:Pt = IsoMath.isoToScreen(new Pt(width,0,height));
         var _loc8_:Pt = IsoMath.isoToScreen(new Pt(width,length,height));
         var _loc9_:Pt = IsoMath.isoToScreen(new Pt(0,length,height));
         _loc1_.moveTo(_loc2_.x,_loc2_.y);
         var _loc10_:IFill = fills.length >= 6 ? IFill(fills[5]) : DEFAULT_FILL;
         if((Boolean(_loc10_)) && styleType != RenderStyleType.WIREFRAME)
         {
            _loc10_.begin(_loc1_);
         }
         var _loc11_:IStroke = strokes.length >= 6 ? IStroke(strokes[5]) : DEFAULT_STROKE;
         if(_loc11_)
         {
            _loc11_.apply(_loc1_);
         }
         _loc1_.lineTo(_loc3_.x,_loc3_.y);
         _loc1_.lineTo(_loc4_.x,_loc4_.y);
         _loc1_.lineTo(_loc5_.x,_loc5_.y);
         _loc1_.lineTo(_loc2_.x,_loc2_.y);
         if(_loc10_)
         {
            _loc10_.end(_loc1_);
         }
         _loc1_.moveTo(_loc2_.x,_loc2_.y);
         _loc10_ = fills.length >= 5 ? IFill(fills[4]) : DEFAULT_FILL;
         if((Boolean(_loc10_)) && styleType != RenderStyleType.WIREFRAME)
         {
            _loc10_.begin(_loc1_);
         }
         _loc11_ = strokes.length >= 5 ? IStroke(strokes[4]) : DEFAULT_STROKE;
         if(_loc11_)
         {
            _loc11_.apply(_loc1_);
         }
         _loc1_.lineTo(_loc5_.x,_loc5_.y);
         _loc1_.lineTo(_loc9_.x,_loc9_.y);
         _loc1_.lineTo(_loc6_.x,_loc6_.y);
         _loc1_.lineTo(_loc2_.x,_loc2_.y);
         if(_loc10_)
         {
            _loc10_.end(_loc1_);
         }
         _loc1_.moveTo(_loc2_.x,_loc2_.y);
         _loc10_ = fills.length >= 4 ? IFill(fills[3]) : DEFAULT_FILL;
         if((Boolean(_loc10_)) && styleType != RenderStyleType.WIREFRAME)
         {
            _loc10_.begin(_loc1_);
         }
         _loc11_ = strokes.length >= 4 ? IStroke(strokes[3]) : DEFAULT_STROKE;
         if(_loc11_)
         {
            _loc11_.apply(_loc1_);
         }
         _loc1_.lineTo(_loc3_.x,_loc3_.y);
         _loc1_.lineTo(_loc7_.x,_loc7_.y);
         _loc1_.lineTo(_loc6_.x,_loc6_.y);
         _loc1_.lineTo(_loc2_.x,_loc2_.y);
         if(_loc10_)
         {
            _loc10_.end(_loc1_);
         }
         _loc1_.moveTo(_loc5_.x,_loc5_.y);
         _loc10_ = fills.length >= 3 ? IFill(fills[2]) : DEFAULT_FILL;
         if((Boolean(_loc10_)) && styleType != RenderStyleType.WIREFRAME)
         {
            if(_loc10_ is IBitmapFill)
            {
               _loc12_ = IBitmapFill(_loc10_).matrix ? IBitmapFill(_loc10_).matrix : new Matrix();
               _loc12_.tx += _loc5_.x;
               _loc12_.ty += _loc5_.y;
               if(IBitmapFill(_loc10_).repeat)
               {
               }
               IBitmapFill(_loc10_).matrix = _loc12_;
            }
            _loc10_.begin(_loc1_);
         }
         _loc11_ = strokes.length >= 3 ? IStroke(strokes[2]) : DEFAULT_STROKE;
         if(_loc11_)
         {
            _loc11_.apply(_loc1_);
         }
         _loc1_.lineTo(_loc9_.x,_loc9_.y);
         _loc1_.lineTo(_loc8_.x,_loc8_.y);
         _loc1_.lineTo(_loc4_.x,_loc4_.y);
         _loc1_.lineTo(_loc5_.x,_loc5_.y);
         if(_loc10_)
         {
            _loc10_.end(_loc1_);
         }
         _loc1_.moveTo(_loc3_.x,_loc3_.y);
         _loc10_ = fills.length >= 2 ? IFill(fills[1]) : DEFAULT_FILL;
         if((Boolean(_loc10_)) && styleType != RenderStyleType.WIREFRAME)
         {
            if(_loc10_ is IBitmapFill)
            {
               _loc12_ = IBitmapFill(_loc10_).matrix ? IBitmapFill(_loc10_).matrix : new Matrix();
               _loc12_.tx += _loc5_.x;
               _loc12_.ty += _loc5_.y;
               if(IBitmapFill(_loc10_).repeat)
               {
               }
               IBitmapFill(_loc10_).matrix = _loc12_;
            }
            _loc10_.begin(_loc1_);
         }
         _loc11_ = strokes.length >= 2 ? IStroke(strokes[1]) : DEFAULT_STROKE;
         if(_loc11_)
         {
            _loc11_.apply(_loc1_);
         }
         _loc1_.lineTo(_loc4_.x,_loc4_.y);
         _loc1_.lineTo(_loc8_.x,_loc8_.y);
         _loc1_.lineTo(_loc7_.x,_loc7_.y);
         _loc1_.lineTo(_loc3_.x,_loc3_.y);
         if(_loc10_)
         {
            _loc10_.end(_loc1_);
         }
         _loc1_.moveTo(_loc6_.x,_loc6_.y);
         _loc10_ = fills.length >= 1 ? IFill(fills[0]) : DEFAULT_FILL;
         if((Boolean(_loc10_)) && styleType != RenderStyleType.WIREFRAME)
         {
            if(_loc10_ is IBitmapFill)
            {
               _loc12_ = IBitmapFill(_loc10_).matrix ? IBitmapFill(_loc10_).matrix : new Matrix();
               _loc12_.tx += _loc6_.x;
               _loc12_.ty += _loc6_.y;
               if(IBitmapFill(_loc10_).repeat)
               {
               }
               IBitmapFill(_loc10_).matrix = _loc12_;
            }
            _loc10_.begin(_loc1_);
         }
         _loc11_ = strokes.length >= 1 ? IStroke(strokes[0]) : DEFAULT_STROKE;
         if(_loc11_)
         {
            _loc11_.apply(_loc1_);
         }
         _loc1_.lineTo(_loc7_.x,_loc7_.y);
         _loc1_.lineTo(_loc8_.x,_loc8_.y);
         _loc1_.lineTo(_loc9_.x,_loc9_.y);
         _loc1_.lineTo(_loc6_.x,_loc6_.y);
         if(_loc10_)
         {
            _loc10_.end(_loc1_);
         }
      }
   }
}

