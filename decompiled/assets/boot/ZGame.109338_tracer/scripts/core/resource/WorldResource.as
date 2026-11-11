package core.resource
{
   public class WorldResource
   {
      
      private var m_resourceInfo:ResourceInfo = null;
      
      private var m_amount:int;
      
      public function WorldResource(param1:ResourceInfo, param2:int)
      {
         super();
         this.m_resourceInfo = param1;
         this.m_amount = param2;
      }
      
      public function get amount() : int
      {
         return this.m_amount;
      }
      
      public function set amount(param1:int) : void
      {
         this.m_amount = param1;
      }
      
      public function get valid() : Boolean
      {
         return null != this.m_resourceInfo;
      }
      
      public function get type() : String
      {
         return this.m_resourceInfo.type;
      }
      
      public function get isRare() : Boolean
      {
         return this.m_resourceInfo.isRare;
      }
      
      public function get mediumIcon() : String
      {
         return this.m_resourceInfo.mediumIcon;
      }
      
      public function get smallIcon() : String
      {
         return this.m_resourceInfo.smallIcon;
      }
      
      public function get xLargeIcon() : String
      {
         return this.m_resourceInfo.xtraLargeIcon;
      }
      
      public function get visitIcon() : String
      {
         return this.m_resourceInfo.visitIcon;
      }
   }
}

