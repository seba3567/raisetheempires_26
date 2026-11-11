package core.ui.menuitem
{
   import Engine.Managers.StatsManager;
   import core.managers.MOTDManager.MessageOfTheDayManager;
   import core.ui.Tooltip;
   import flash.display.BitmapData;
   import flash.events.MouseEvent;
   import utils.CriteriaUtil;
   import utils.ZGameUtils;
   
   public class LEHudUIItem extends PromoMenuItem
   {
      
      private var m_motdName:String = this.getMOTDName();
      
      private var m_setName:String;
      
      public var m_xml:XML;
      
      public function LEHudUIItem(param1:XML)
      {
         var _loc2_:Array = null;
         swfPath = param1.@icon.toString();
         this.m_motdName = param1.@motdName.toString();
         this.m_setName = param1.@setName.toString();
         this.m_xml = new XML(param1.criteria.toXMLString());
         _loc2_ = param1.@tooltip.toString().split(":");
         if(_loc2_.length > 1)
         {
            toolTipFileName = _loc2_[0];
            toolTipText = _loc2_[1];
         }
         else
         {
            toolTipFileName = "MessageOfTheDay";
            toolTipText = param1.@tooltip.toString();
         }
         visible = false;
         tweenTimeSeconds = 2;
         var _loc3_:String = param1.@classId.toString();
         super(_loc3_,false,false);
         priority = 3;
      }
      
      override public function show(param1:Boolean = false) : void
      {
         super.show(param1);
      }
      
      override protected function onLoadComplete(param1:String, param2:BitmapData) : void
      {
         super.onLoadComplete(param1,param2);
         var _loc3_:String = ZGameUtils.ZlocT(toolTipFileName,toolTipText);
         Tooltip.subscribe(m_uiloader,_loc3_);
      }
      
      override protected function onClicked(param1:MouseEvent) : void
      {
         super.onClicked(param1);
         if(this.m_motdName)
         {
            MessageOfTheDayManager.instance.openMOTDPopupByName(this.m_motdName,false);
            StatsManager.countSample(100,"hud_icon",this.m_setName,"icon_clicked","","","",elapsedSinceShow);
         }
      }
      
      private function getMOTDName() : String
      {
         var _loc2_:XML = null;
         var _loc1_:Array = MessageOfTheDayManager.instance.getMOTDSet(this.m_setName);
         for each(_loc2_ in _loc1_)
         {
            if(CriteriaUtil.meetsCriteria(_loc2_.criteria))
            {
               return _loc2_.@name.toString();
            }
         }
         return null;
      }
   }
}

