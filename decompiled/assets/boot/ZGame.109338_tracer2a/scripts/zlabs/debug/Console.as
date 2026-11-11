package zlabs.debug
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import zlabs.Zlab;
   import zlabs.core.IPBObject;
   import zlabs.core.PBGroup;
   import zlabs.core.PBSet;
   import zlabs.entity.IEntity;
   import zlabs.entity.IEntityComponent;
   import zlabs.serialization.TypeUtility;
   
   public class Console
   {
      
      protected static var _stats:Stats;
      
      protected static var commands:Object = {};
      
      protected static var commandList:Array = [];
      
      protected static var commandListOrdered:Boolean = false;
      
      public static var verbosity:int = 0;
      
      public function Console()
      {
         super();
      }
      
      public static function registerCommand(param1:String, param2:Function, param3:String = null) : void
      {
         if(param2 == null)
         {
            Logger.error(Console,"registerCommand","Command \'" + param1 + "\' has no callback!");
         }
         if(!param1 || param1.length == 0)
         {
            Logger.error(Console,"registerCommand","Command has no name!");
         }
         if(param1.indexOf(" ") != -1)
         {
            Logger.error(Console,"registerCommand","Command \'" + param1 + "\' has a space in it, it will not work.");
         }
         var _loc4_:ConsoleCommand = new ConsoleCommand();
         _loc4_.name = param1;
         _loc4_.callback = param2;
         _loc4_.docs = param3;
         if(commands[param1.toLowerCase()])
         {
            Logger.warn(Console,"registerCommand","Replacing existing command \'" + param1 + "\'.");
         }
         commands[param1.toLowerCase()] = _loc4_;
         commandList.push(_loc4_);
         commandListOrdered = false;
      }
      
      public static function getCommandList() : Array
      {
         ensureCommandsOrdered();
         return commandList;
      }
      
      public static function processLine(param1:String) : void
      {
         var potentialCommand:ConsoleCommand;
         var args:Array = null;
         var line:String = param1;
         ensureCommandsOrdered();
         args = line.split(" ");
         if(args.length == 0)
         {
            return;
         }
         potentialCommand = commands[args[0].toString().toLowerCase()];
         if(!potentialCommand)
         {
            Logger.warn(Console,"processLine","No such command \'" + args[0].toString() + "\'!");
            return;
         }
         try
         {
            potentialCommand.callback.apply(null,args.slice(1));
         }
         catch(e:Error)
         {
            Logger.error(Console,args[0],"Error: " + e.toString() + " - " + e.getStackTrace());
         }
      }
      
      public static function init() : void
      {
         registerCommand("help",function(param1:String = null):void
         {
            var _loc3_:ConsoleCommand = null;
            ensureCommandsOrdered();
            Logger.print(Console,"Keyboard shortcuts: ");
            Logger.print(Console,"[SHIFT]-TAB - Cycle through autocompleted commands.");
            Logger.print(Console,"PGUP/PGDN   - Page log view up/down a page.");
            Logger.print(Console,"");
            Logger.print(Console,"Commands:");
            var _loc2_:int = 0;
            while(_loc2_ < commandList.length)
            {
               _loc3_ = commandList[_loc2_] as ConsoleCommand;
               if(!(Boolean(param1) && Boolean(param1.length > 0) && _loc3_.name.substr(0,param1.length) != param1))
               {
                  Logger.print(Console,"   " + _loc3_.name + " - " + (_loc3_.docs ? _loc3_.docs : ""));
               }
               _loc2_++;
            }
         },"[prefix] - List known commands, optionally filtering by prefix.");
         registerCommand("version",function():void
         {
         },"Echo PushButton Engine version information.");
         registerCommand("fps",function():void
         {
            if(!_stats)
            {
               _stats = new Stats();
               Zlab.mainStage.addChild(_stats);
               Logger.print(Console,"Enabled FPS display.");
            }
            else
            {
               Zlab.mainStage.removeChild(_stats);
               _stats = null;
            }
         },"Toggle an FPS/Memory usage indicator.");
         registerCommand("verbose",function(param1:int):void
         {
            Console.verbosity = param1;
            Logger.print(Console,"Verbosity set to " + param1);
         },"Set verbosity level of console output.");
         registerCommand("listDisplayObjects",function():void
         {
            var _loc1_:int = Console._listDisplayObjects(Zlab.mainStage,0);
            Logger.print(Console," " + _loc1_ + " total display objects.");
         },"Outputs the display list.");
         registerCommand("tree",function():void
         {
            var _loc1_:int = Console._listPBObjects(Zlab.rootGroup,0);
            Logger.print(Console," " + _loc1_ + " total PBObjects.");
         },"List all the PBObjects in the game.");
         registerCommand("profiler",function():void
         {
            var _loc1_:int = Console._listPBObjects(Zlab.rootGroup,0);
            Logger.print(Console," " + _loc1_ + " total PBObjects.");
         },"Show local runtime profiler.");
      }
      
      protected static function ensureCommandsOrdered() : void
      {
         if(commandListOrdered == true)
         {
            return;
         }
         if(commands.help == null)
         {
            init();
         }
         commandListOrdered = true;
         commandList.sort(function(param1:ConsoleCommand, param2:ConsoleCommand):int
         {
            if(param1.name > param2.name)
            {
               return 1;
            }
            return -1;
         });
      }
      
      protected static function _listDisplayObjects(param1:DisplayObject, param2:int) : int
      {
         if(!param1)
         {
            return 0;
         }
         Logger.print(Console,Console.generateIndent(param2) + param1.name + " (" + param1.x + "," + param1.y + ") visible=" + param1.visible);
         var _loc3_:DisplayObjectContainer = param1 as DisplayObjectContainer;
         if(!_loc3_)
         {
            return 1;
         }
         var _loc4_:int = 1;
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_.numChildren)
         {
            _loc4_ += _listDisplayObjects(_loc3_.getChildAt(_loc5_),param2 + 1);
            _loc5_++;
         }
         return _loc4_;
      }
      
      protected static function _listPBObjects(param1:IPBObject, param2:int) : int
      {
         var _loc9_:Array = null;
         var _loc10_:IEntityComponent = null;
         if(!param1)
         {
            return 0;
         }
         var _loc3_:String = " (" + TypeUtility.getObjectClassName(param1) + ")";
         if(Boolean(param1.name) || Boolean(param1.alias))
         {
            Logger.print(Console,Console.generateIndent(param2) + param1.name + _loc3_ + (param1.alias != null ? " alias = " + param1.alias : ""));
         }
         else
         {
            Logger.print(Console,Console.generateIndent(param2) + "[anonymous]" + _loc3_);
         }
         var _loc4_:PBSet = param1 as PBSet;
         var _loc5_:PBGroup = param1 as PBGroup;
         var _loc6_:IEntity = param1 as IEntity;
         var _loc7_:int = 1;
         var _loc8_:int = 0;
         if(_loc4_)
         {
            _loc8_ = 0;
            while(_loc8_ < _loc4_.length)
            {
               _loc7_ += _listPBObjects(_loc4_.getItem(_loc8_),param2 + 1);
               _loc8_++;
            }
         }
         else if(_loc5_)
         {
            _loc8_ = 0;
            while(_loc8_ < _loc5_.length)
            {
               _loc7_ += _listPBObjects(_loc5_.getItem(_loc8_),param2 + 1);
               _loc8_++;
            }
         }
         else if(_loc6_)
         {
            _loc9_ = _loc6_.lookupComponentsByType(IEntityComponent);
            _loc8_ = 0;
            while(_loc8_ < _loc9_.length)
            {
               _loc10_ = _loc9_[_loc8_] as IEntityComponent;
               _loc3_ = " (" + TypeUtility.getObjectClassName(_loc10_) + ")";
               Logger.print(Console,Console.generateIndent(param2 + 1) + _loc10_.name + _loc3_);
               _loc8_++;
            }
         }
         return _loc7_;
      }
      
      protected static function generateIndent(param1:int) : String
      {
         var _loc2_:String = "";
         var _loc3_:int = 0;
         while(_loc3_ < param1)
         {
            _loc2_ += "  ";
            _loc3_++;
         }
         return _loc2_;
      }
   }
}

final class ConsoleCommand
{
   
   public var name:String;
   
   public var callback:Function;
   
   public var docs:String;
   
   public function ConsoleCommand()
   {
      super();
   }
}
