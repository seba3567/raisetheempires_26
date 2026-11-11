package
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol30")]
   public class PVPCombatStartModal extends MovieClip
   {
      
      public var generic_tf:TextField;
      
      public var message_tf:TextField;
      
      public var player_01:MovieClip;
      
      public var player_02:MovieClip;
      
      public var player_03:MovieClip;
      
      public var vs_tf:TextField;
      
      public function PVPCombatStartModal()
      {
         super();
         trace("Raise the empires: PVPCombatStartModal contructor called");
      }
   }
}

