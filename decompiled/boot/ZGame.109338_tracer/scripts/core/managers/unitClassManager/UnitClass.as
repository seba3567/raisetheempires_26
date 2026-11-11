package core.managers.unitClassManager
{
   import utils.ZGameUtils;
   
   public class UnitClass
   {
      
      private var m_xml:XML = null;
      
      public function UnitClass(param1:XML)
      {
         super();
         this.m_xml = param1;
      }
      
      public function getIconURL() : String
      {
         return this.m_xml.@icon;
      }
      
      public function getAltIconURL() : String
      {
         return this.m_xml.@altIcon;
      }
      
      public function getSmIconURL() : String
      {
         return this.m_xml.@iconSm;
      }
      
      public function getGoodAgainst() : String
      {
         return this.m_xml.@goodAgainst;
      }
      
      public function get ignoreForWarning() : Boolean
      {
         return this.m_xml.@ignoreForWarning != undefined;
      }
      
      public function getTooltip() : String
      {
         return ZGameUtils.ZlocT("Tooltips",this.m_xml.@tooltip.toString());
      }
      
      public function getName() : String
      {
         return ZGameUtils.ZlocT("Items","type_" + this.m_xml.@name);
      }
      
      public function getTheatre() : String
      {
         return this.m_xml.@theatre;
      }
   }
}

