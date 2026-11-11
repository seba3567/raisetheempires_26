package core.resource
{
   import core.gameobjects.GameItem;
   
   public class ResourceInfo
   {
      
      private var m_type:String;
      
      private var m_xtraSmallIcon:String;
      
      private var m_smallIcon:String;
      
      private var m_mediumIcon:String;
      
      private var m_largeIcon:String = null;
      
      private var m_xtraLargeIcon:String = null;
      
      private var m_visitIcon:String = null;
      
      private var m_pickupSoundEvent:String;
      
      private var m_isRare:Boolean;
      
      private var m_showInWallet:Boolean;
      
      private var m_marketPrice:int;
      
      private var m_giftableItemName:String;
      
      private var m_tooltipKey:String;
      
      private var m_color:int;
      
      private var m_startingAmount:int = 0;
      
      private var m_lootImages:Array = null;
      
      private var m_productionInputIcon:String = null;
      
      private var m_productionFactoryIcon:String = null;
      
      private var m_productionOutputIcon:String = null;
      
      private var m_productionPromptToken:String = null;
      
      public function ResourceInfo(param1:String, param2:Boolean = false, param3:String = "", param4:String = "", param5:Boolean = false, param6:int = 0, param7:String = "", param8:int = 16777215, param9:String = "")
      {
         super();
         this.m_type = param1;
         this.m_isRare = param2;
         this.m_mediumIcon = param3;
         this.m_pickupSoundEvent = param4;
         this.m_showInWallet = param5;
         this.m_marketPrice = param6;
         this.m_tooltipKey = param7;
         this.m_color = param8;
         this.m_giftableItemName = param9;
      }
      
      public function get type() : String
      {
         return this.m_type;
      }
      
      public function get xtraSmallIcon() : String
      {
         return this.m_xtraSmallIcon;
      }
      
      public function set xtraSmallIcon(param1:String) : void
      {
         this.m_xtraSmallIcon = param1;
      }
      
      public function get smallIcon() : String
      {
         return this.m_smallIcon;
      }
      
      public function set smallIcon(param1:String) : void
      {
         this.m_smallIcon = param1;
      }
      
      public function get mediumIcon() : String
      {
         return this.m_mediumIcon;
      }
      
      public function set mediumIcon(param1:String) : void
      {
         this.m_mediumIcon = param1;
      }
      
      public function get largeIcon() : String
      {
         return this.m_largeIcon;
      }
      
      public function set largeIcon(param1:String) : void
      {
         this.m_largeIcon = param1;
      }
      
      public function get xtraLargeIcon() : String
      {
         return this.m_xtraLargeIcon;
      }
      
      public function set xtraLargeIcon(param1:String) : void
      {
         this.m_xtraLargeIcon = param1;
      }
      
      public function get visitIcon() : String
      {
         return this.m_visitIcon;
      }
      
      public function set visitIcon(param1:String) : void
      {
         this.m_visitIcon = param1;
      }
      
      public function get productionInputIcon() : String
      {
         return this.m_productionInputIcon;
      }
      
      public function set productionInputIcon(param1:String) : void
      {
         this.m_productionInputIcon = param1;
      }
      
      public function get productionFactoryIcon() : String
      {
         return this.m_productionFactoryIcon;
      }
      
      public function set productionFactoryIcon(param1:String) : void
      {
         this.m_productionFactoryIcon = param1;
      }
      
      public function get productionOutputIcon() : String
      {
         return this.m_productionOutputIcon;
      }
      
      public function set productionOutputIcon(param1:String) : void
      {
         this.m_productionOutputIcon = param1;
      }
      
      public function get productionPromptToken() : String
      {
         return this.m_productionPromptToken;
      }
      
      public function set productionPromptToken(param1:String) : void
      {
         this.m_productionPromptToken = param1;
      }
      
      public function get pickupSoundEvent() : String
      {
         return this.m_pickupSoundEvent;
      }
      
      public function get isRare() : Boolean
      {
         return this.m_isRare;
      }
      
      public function get showInWallet() : Boolean
      {
         return this.m_showInWallet;
      }
      
      public function get marketPrice() : int
      {
         return this.m_marketPrice;
      }
      
      public function get giftableItemName() : String
      {
         return this.m_giftableItemName;
      }
      
      public function get tooltipKey() : String
      {
         return this.m_tooltipKey;
      }
      
      public function get tooltipType() : String
      {
         return Boolean(this.m_tooltipKey) && this.m_tooltipKey != "" ? GameItem.RESOURCE_TOOLTIP : GameItem.NO_TOOLTIP;
      }
      
      public function get color() : int
      {
         return this.m_color;
      }
      
      public function set startingAmount(param1:int) : void
      {
         this.m_startingAmount = param1;
      }
      
      public function get startingAmount() : int
      {
         return this.m_startingAmount;
      }
      
      public function set lootImages(param1:Array) : void
      {
         this.m_lootImages = param1;
      }
      
      public function get lootImages() : Array
      {
         return this.m_lootImages;
      }
   }
}

