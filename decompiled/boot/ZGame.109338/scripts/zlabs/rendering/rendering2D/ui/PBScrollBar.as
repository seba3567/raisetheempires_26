package zlabs.rendering.rendering2D.ui
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import zlabs.ZlabUtil;
   
   public class PBScrollBar extends Sprite
   {
      
      protected var _extents:Rectangle;
      
      protected var _dragExtents:Rectangle;
      
      protected var _track:Sprite;
      
      protected var _thumb:Sprite;
      
      protected var _tf:TextField;
      
      private var _progress:Number;
      
      public function PBScrollBar()
      {
         super();
         this.init();
      }
      
      protected function init() : void
      {
         this._extents = new Rectangle(0,0,5,100);
         this._track = new Sprite();
         this._thumb = new Sprite();
         this._track.buttonMode = this._thumb.buttonMode = true;
         this._track.useHandCursor = this._thumb.useHandCursor = true;
         addChild(this._track);
         addChild(this._thumb);
         this.addListeners();
         this.refresh();
      }
      
      protected function addListeners() : void
      {
         this._track.addEventListener(MouseEvent.CLICK,this.onTrackClick,false,0,true);
         this._thumb.addEventListener(MouseEvent.MOUSE_DOWN,this.onThumbDown,false,0,true);
         this._thumb.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp,false,0,true);
      }
      
      protected function calcThumbProgress() : void
      {
         this._progress = this._thumb.y / (this._dragExtents.height - this._thumb.height);
      }
      
      protected function scrollTextField() : void
      {
         if(!this._tf)
         {
            return;
         }
         this._tf.scrollV = this._tf.maxScrollV * this._progress;
      }
      
      protected function startDragging() : void
      {
         stage.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp,false,0,true);
         stage.addEventListener(Event.ENTER_FRAME,this.onDragging,false,0,true);
         this._dragExtents = new Rectangle(0,0,0,this._extents.height - this._thumb.height - 1);
         this._thumb.startDrag(false,this._dragExtents);
      }
      
      protected function stopDragging() : void
      {
         stage.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         stage.removeEventListener(Event.ENTER_FRAME,this.onDragging);
         this._thumb.stopDrag();
      }
      
      protected function onTrackClick(param1:MouseEvent) : void
      {
         this.stopDragging();
         this._progress = param1.localY / (this._extents.height - this._thumb.height);
         this.refresh();
         this.scrollTextField();
      }
      
      protected function onThumbDown(param1:MouseEvent) : void
      {
         this.startDragging();
      }
      
      protected function onMouseUp(param1:MouseEvent) : void
      {
         this.stopDragging();
      }
      
      protected function onDragging(param1:Event) : void
      {
         this.calcThumbProgress();
         this.scrollTextField();
      }
      
      public function refresh() : void
      {
         if(Boolean(this._tf) && this._tf.maxScrollV > 1)
         {
            this._track.graphics.clear();
            this._track.graphics.beginFill(15658734,0);
            this._track.graphics.drawRect(this._extents.x,this._extents.y,this._extents.width,this._extents.height);
            this._track.graphics.endFill();
            this._thumb.graphics.clear();
            this._thumb.graphics.beginFill(13421772);
            this._thumb.graphics.drawRoundRect(this._extents.x + 1,this._extents.y + 1,this._extents.width - 2,this._extents.height / 10,this._extents.width,this._extents.width);
            this._thumb.graphics.endFill();
            this._thumb.y = ZlabUtil.clamp((this._extents.height - this._extents.height / 10) * this._progress - 1,0,this._extents.height - this._thumb.height - 1);
         }
         else
         {
            this._track.graphics.clear();
            this._thumb.graphics.clear();
         }
      }
      
      public function get extents() : Rectangle
      {
         return this._extents;
      }
      
      public function set extents(param1:Rectangle) : void
      {
         this._extents = param1;
         this.refresh();
      }
      
      public function get progress() : Number
      {
         return this._progress;
      }
      
      public function set progress(param1:Number) : void
      {
         this._progress = param1;
         this.refresh();
      }
      
      public function get tf() : TextField
      {
         return this._tf;
      }
      
      public function set tf(param1:TextField) : void
      {
         this._tf = param1;
      }
   }
}

