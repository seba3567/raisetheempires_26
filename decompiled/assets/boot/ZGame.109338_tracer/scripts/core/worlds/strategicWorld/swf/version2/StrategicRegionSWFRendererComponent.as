package core.worlds.strategicWorld.swf.version2
{
   import core.ZGlobal;
   import core.gameobjects.IslandGroupItem;
   import core.views.ViewManager;
   import core.worlds.strategicWorld.StrategicMap;
   import core.worlds.strategicWorld.StrategicWorld;
   import dispatchers.StrategicDispatcher;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.entity.EntityComponent;
   import zlabs.events.WorldEvent;
   
   public class StrategicRegionSWFRendererComponent extends EntityComponent implements IStrategicScope, ISelectableRegion
   {
      
      private static const STATE_NORMAL:uint = 0;
      
      private static const STATE_HOVER:uint = 1;
      
      private var m_islandGroupItem:IslandGroupItem = null;
      
      private var m_clip:MovieClip = null;
      
      private var m_states:Array = null;
      
      private var m_bitmapData:BitmapData = null;
      
      private var m_clickFunction:Function = null;
      
      private var m_home:Boolean = false;
      
      private var m_focus:Boolean = false;
      
      private var m_active:Boolean = false;
      
      public function StrategicRegionSWFRendererComponent(param1:IslandGroupItem, param2:Boolean)
      {
         super();
         this.m_islandGroupItem = param1;
         this.m_active = param2;
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         var _loc1_:StrategicSWF2RendererComponent = ViewManager.instance.getComponentFromView(StrategicWorld.ID,StrategicSWF2RendererComponent) as StrategicSWF2RendererComponent;
         _loc1_.loadRegionClip(this.m_islandGroupItem,this.onClipLoaded);
      }
      
      public function hitTest() : Boolean
      {
         if(this.m_bitmapData.hitTest(new Point(0,0),1,new Point(this.m_states[STATE_NORMAL].mouseX,this.m_states[STATE_NORMAL].mouseY)))
         {
            return true;
         }
         return false;
      }
      
      public function set focus(param1:Boolean) : void
      {
         if(param1)
         {
            if(!this.m_focus)
            {
               this.showState(STATE_HOVER);
               StrategicDispatcher.instance.dispatchEvent(new WorldEvent(StrategicDispatcher.ISLAND_SCOPE_ENTER,this.m_active ? null : this));
               StrategicDispatcher.instance.addEventListener(StrategicDispatcher.ISLAND_FORCE_EXIT,this.onForceExit);
               if(this.m_active)
               {
                  StrategicDispatcher.instance.dispatchEvent(new WorldEvent(StrategicDispatcher.ISLAND_ACTIVE_FOCUS,true));
               }
            }
         }
         else
         {
            if(this.m_focus)
            {
               this.showState(STATE_NORMAL);
               if(this.m_active)
               {
                  StrategicDispatcher.instance.dispatchEvent(new WorldEvent(StrategicDispatcher.ISLAND_ACTIVE_FOCUS,false));
               }
            }
            StrategicDispatcher.instance.removeEventListener(StrategicDispatcher.ISLAND_FORCE_EXIT,this.onForceExit);
         }
         this.m_focus = param1;
      }
      
      public function click() : void
      {
         this.m_clickFunction();
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         StrategicDispatcher.instance.removeEventListener(StrategicDispatcher.ISLAND_FORCE_EXIT,this.onForceExit);
         Zlab.processManager.removeScheduledObject(this);
         if(null != this.m_clip)
         {
            this.m_clip = null;
         }
         this.m_bitmapData = null;
         this.m_islandGroupItem = null;
         this.m_clickFunction = null;
      }
      
      private function onClipLoaded(param1:MovieClip) : void
      {
         var _loc2_:StrategicMap = null;
         if(null != param1)
         {
            this.m_clip = param1;
            if(ZGlobal.player.campaign.isHomeIslandGroup(this.m_islandGroupItem.code))
            {
               this.m_home = true;
            }
            this.m_clickFunction = this.onRegionClicked;
            this.m_states = new Array(2);
            this.m_states[STATE_NORMAL] = this.m_clip.normal;
            this.m_states[STATE_HOVER] = this.m_clip.hover;
            this.m_clip.done.visible = false;
            this.m_clip.celebrate.visible = false;
            this.allocateBitmapData();
            if(!this.m_focus)
            {
               this.showState(STATE_NORMAL);
            }
            if(ZGlobal.player.campaign.celebrationMap == this.m_islandGroupItem.code)
            {
               ZGlobal.player.campaign.celebrationMap = null;
               Zlab.processManager.schedule(2000,this,this.onPreFlagDelay);
            }
            else
            {
               _loc2_ = ZGlobal.player.campaign.getMap(this.m_islandGroupItem.code);
               if(_loc2_.progressIsland >= this.m_islandGroupItem.numIslands)
               {
                  this.m_clip.done.visible = true;
               }
            }
            if(this.m_islandGroupItem.uilocked)
            {
               this.m_clip.filters = [ZGameUtils.GrayScaleFilter];
            }
            else
            {
               this.m_clip.filters = [];
            }
         }
      }
      
      private function onForceExit(param1:Event) : void
      {
         this.focus = false;
         StrategicDispatcher.instance.removeEventListener(StrategicDispatcher.ISLAND_FORCE_EXIT,this.onForceExit);
      }
      
      private function onPreFlagDelay() : void
      {
         this.m_clip.celebrate.visible = true;
         Zlab.processManager.schedule(1100,this,this.onCelebrateEnd);
      }
      
      private function onCelebrateEnd() : void
      {
         this.m_clip.celebrate.visible = false;
         this.m_clip.done.visible = true;
      }
      
      private function showState(param1:uint) : void
      {
         var _loc2_:uint = this.m_states.length;
         var _loc3_:uint = 0;
         while(_loc3_ < _loc2_)
         {
            if(null == this.m_states[_loc3_])
            {
               Logger.error(this,"showState","missing " + _loc3_ + " from " + this.m_clip.name + ", " + this.m_clip.parent.name);
            }
            else
            {
               this.m_states[_loc3_].visible = _loc3_ == param1;
            }
            _loc3_++;
         }
      }
      
      private function allocateBitmapData() : void
      {
         if(null == this.m_bitmapData)
         {
            this.m_bitmapData = new BitmapData(this.m_states[STATE_NORMAL].width,this.m_states[STATE_NORMAL].height,true,0);
            this.m_bitmapData.draw(this.m_states[STATE_NORMAL]);
            StrategicDispatcher.instance.dispatchEvent(new WorldEvent(StrategicDispatcher.ISLAND_REGISTER,this));
         }
      }
      
      private function onRegionClicked() : void
      {
         StrategicDispatcher.instance.dispatchEvent(new WorldEvent(StrategicDispatcher.ISLAND_CLICKED,this.code));
      }
      
      public function get clip() : MovieClip
      {
         return this.m_clip;
      }
      
      public function get code() : String
      {
         return this.m_islandGroupItem.code;
      }
      
      public function get home() : Boolean
      {
         return this.m_home;
      }
   }
}

