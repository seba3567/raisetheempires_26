package Engine.Managers
{
   import Engine.Classes.EasterEggs.CreditsEasterEgg;
   import Engine.Display.StrokeTextField;
   import Engine.Interfaces.IEasterEgg;
   import flash.events.KeyboardEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class EasterEggManager
   {
      
      protected static var m_instance:EasterEggManager = null;
      
      protected var m_enabledEasterEggs:Vector.<IEasterEgg> = new Vector.<IEasterEgg>();
      
      protected var m_keysEntered:Array = [];
      
      protected var m_easterEggMode:Boolean = false;
      
      protected var m_easterEggText:TextField;
      
      public function EasterEggManager()
      {
         super();
         this.addEasterEgg(new CreditsEasterEgg());
      }
      
      public static function get instance() : EasterEggManager
      {
         if(m_instance == null)
         {
            m_instance = new EasterEggManager();
         }
         return m_instance;
      }
      
      protected function addEasterEgg(param1:IEasterEgg) : void
      {
         this.m_enabledEasterEggs.push(param1);
      }
      
      protected function removeEasterEgg(param1:String) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.m_enabledEasterEggs.length)
         {
            if(this.m_enabledEasterEggs[_loc2_].code == param1)
            {
               this.m_enabledEasterEggs.splice(_loc2_,1);
               break;
            }
            _loc2_++;
         }
      }
      
      public function processKeyStroke(param1:KeyboardEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         if(param1.keyCode == 192 && this.m_easterEggMode == false)
         {
            this.enterEasterEggMode();
         }
         else if(this.m_easterEggMode && param1.keyCode == 8)
         {
            this.m_keysEntered.pop();
            this.updateText();
         }
         else if(this.m_easterEggMode && param1.keyCode == 13)
         {
            if(this.m_keysEntered.length > 0)
            {
               _loc2_ = this.m_keysEntered.join("");
               this.easterEgg(_loc2_);
            }
            this.exitEasterEggMode();
         }
         else if(this.m_keysEntered.length > 50)
         {
            this.exitEasterEggMode();
         }
         else if(this.m_easterEggMode)
         {
            _loc3_ = String.fromCharCode(param1.charCode);
            this.m_keysEntered.push(_loc3_);
            this.updateText();
         }
      }
      
      protected function updateText() : void
      {
         if(this.m_easterEggText != null)
         {
            this.m_easterEggText.text = "Code: " + this.m_keysEntered.join("");
         }
      }
      
      protected function enterEasterEggMode() : void
      {
         this.m_keysEntered = [];
         this.m_easterEggMode = true;
         var _loc1_:TextFormat = new TextFormat(null,12,16777215,true);
         this.m_easterEggText = new StrokeTextField(0,0.8);
         this.m_easterEggText.setTextFormat(_loc1_);
         this.m_easterEggText.background = true;
         this.m_easterEggText.backgroundColor = 16777215;
         this.m_easterEggText.y = 10;
         this.m_easterEggText.x = 10;
         this.updateText();
         GlobalEngine.stage.addChild(this.m_easterEggText);
      }
      
      protected function exitEasterEggMode() : void
      {
         this.m_keysEntered = [];
         this.m_easterEggMode = false;
         GlobalEngine.stage.removeChild(this.m_easterEggText);
      }
      
      protected function easterEgg(param1:String) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.m_enabledEasterEggs.length)
         {
            if(this.m_enabledEasterEggs[_loc2_].code == param1)
            {
               this.m_enabledEasterEggs[_loc2_].execute();
               break;
            }
            _loc2_++;
         }
      }
   }
}

