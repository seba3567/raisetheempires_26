package displays.screens.leaderboard
{
   import core.ZGameStats;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import utils.TextFieldUtil;
   import zlabs.events.WorldEvent;
   
   public class TabController
   {
      
      private var m_container:Array = null;
      
      private var m_tab:MovieClip = null;
      
      private var m_title:String = null;
      
      private var m_stat:String = null;
      
      private var m_clickCallback:Function = null;
      
      private var m_index:int = 0;
      
      private var m_clicked:Boolean = false;
      
      public function TabController(param1:MovieClip, param2:int, param3:String, param4:Function, param5:Array, param6:String)
      {
         super();
         this.m_tab = param1;
         this.m_index = param2;
         this.m_title = param3;
         this.m_clickCallback = param4;
         this.m_container = param5;
         this.m_stat = param6 + "_tab";
         this.m_container.push(this);
         this.m_tab.gotoAndStop(1);
         if(this.m_container.length == 1)
         {
            this.onClick(null);
         }
         this.m_tab.addEventListener(MouseEvent.MOUSE_OVER,this.onOver,false,0,true);
         this.m_tab.addEventListener(MouseEvent.MOUSE_OUT,this.onOut,false,0,true);
         this.m_tab.addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
      }
      
      public function dispose() : void
      {
         this.m_tab.removeEventListener(MouseEvent.MOUSE_OVER,this.onOver);
         this.m_tab.removeEventListener(MouseEvent.MOUSE_OUT,this.onOut);
         this.m_tab.removeEventListener(MouseEvent.CLICK,this.onClick);
         this.m_title = null;
         this.m_container = null;
         this.m_tab = null;
      }
      
      public function selectTab() : void
      {
         var _loc1_:TabController = null;
         for each(_loc1_ in this.m_container)
         {
            _loc1_.reset();
         }
         this.m_tab.gotoAndStop(3);
         if(this.m_tab.tab_icon_container)
         {
            this.m_tab.tab_icon_container.icon_mc.filters = [new GlowFilter(16777113,1,13,13,1.5)];
         }
         this.m_clicked = true;
         this.m_clickCallback(this.m_index);
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         this.selectTab();
         if(param1 != null)
         {
            ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_GENERIC_BUTTON_CLICKED,{
               "counter":"leaderboard",
               "kingdom":this.m_stat,
               "phylum":"click"
            }));
         }
      }
      
      private function onOver(param1:MouseEvent) : void
      {
         this.m_tab.gotoAndStop(2);
         if(this.m_tab.tab_icon_container)
         {
            this.m_tab.tab_icon_container.icon_mc.filters = [new GlowFilter(16777113,1,13,13,1.5)];
         }
         TextFieldUtil.compactTextField(this.m_tab.tooltip_mc.tip_tf,this.m_title,{"minScale":0.6});
      }
      
      private function onOut(param1:MouseEvent) : void
      {
         if(!this.m_clicked)
         {
            this.m_tab.gotoAndStop(1);
            if(this.m_tab.tab_icon_container)
            {
               this.m_tab.tab_icon_container.icon_mc.filters = [];
            }
         }
         else
         {
            this.m_tab.gotoAndStop(3);
         }
      }
      
      private function reset() : void
      {
         this.m_tab.gotoAndStop(1);
         this.m_clicked = false;
         if(this.m_tab.tab_icon_container)
         {
            this.m_tab.tab_icon_container.icon_mc.filters = [];
         }
      }
   }
}

