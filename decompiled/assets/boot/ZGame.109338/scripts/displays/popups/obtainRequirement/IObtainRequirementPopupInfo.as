package displays.popups.obtainRequirement
{
   import core.gameobjects.GameItem;
   
   public interface IObtainRequirementPopupInfo
   {
      
      function onAskButton() : void;
      
      function onPurchase() : void;
      
      function get requirementGameItem() : GameItem;
      
      function get buyQuantity() : Number;
      
      function get resourceAmount() : Number;
      
      function get dialogTitleText() : String;
      
      function get dialogSubtitleText() : String;
      
      function get askTitleText() : String;
      
      function get askDescText() : String;
      
      function get askButtonText() : String;
      
      function get askIconURL() : String;
      
      function get buyTitleText() : String;
      
      function get buyDescText() : String;
      
      function get buyCost() : Number;
      
      function get buyButtonText() : String;
      
      function get buyIconURL() : String;
      
      function get goNowTitleText() : String;
      
      function get goNowDescText() : String;
      
      function get goNowButtonText() : String;
      
      function get goNowIconURL() : String;
   }
}

