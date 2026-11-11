package zlabs.debug
{
   import flash.display.Sprite;
   import flash.events.KeyboardEvent;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldType;
   import flash.text.TextFormat;
   import flash.ui.Keyboard;
   import zlabs.Zlab;
   import zlabs.ZlabUtil;
   import zlabs.core.InputKey;
   import zlabs.rendering.rendering2D.ui.PBScrollBar;
   
   public class LogViewer extends Sprite implements ILogAppender
   {
      
      protected var _messageQueue:Array = [];
      
      protected var _maxLength:uint = 200000;
      
      protected var _truncating:Boolean = false;
      
      protected var _width:uint = 500;
      
      protected var _height:uint = 150;
      
      protected var _consoleHistory:Array = [];
      
      protected var _historyIndex:uint = 0;
      
      protected var _output:TextField;
      
      protected var _input:TextField;
      
      protected var _scrollBar:PBScrollBar;
      
      protected var tabCompletionPrefix:String = "";
      
      protected var tabCompletionCurrentStart:int = 0;
      
      protected var tabCompletionCurrentEnd:int = 0;
      
      protected var tabCompletionCurrentOffset:int = 0;
      
      public function LogViewer()
      {
         super();
         this.layout();
         this.addListeners();
         name = "Console";
         Console.registerCommand("clear",this.onClearCommand,"Clears the console history.");
      }
      
      protected function layout() : void
      {
         if(!this._output)
         {
            this.createOutputField();
         }
         if(!this._input)
         {
            this.createInputField();
         }
         if(!this._scrollBar)
         {
            this.createScrollBar();
         }
         this.resize();
         this._scrollBar.tf = this._output;
         addChild(this._output);
         addChild(this._input);
         addChild(this._scrollBar);
         graphics.clear();
         graphics.beginFill(6710886,0.95);
         graphics.drawRoundRect(0,0,this._width,this._height,5);
         graphics.endFill();
         graphics.beginFill(16777215,1);
         graphics.drawRoundRect(4,4,this._width - 8,this._height - 30,5);
         graphics.endFill();
      }
      
      protected function addListeners() : void
      {
         this._input.addEventListener(KeyboardEvent.KEY_DOWN,this.onInputKeyDown,false,1,true);
      }
      
      protected function removeListeners() : void
      {
         this._input.removeEventListener(KeyboardEvent.KEY_DOWN,this.onInputKeyDown);
      }
      
      protected function onClearCommand() : void
      {
         this._output.htmlText = "";
      }
      
      protected function resize() : void
      {
         this._output.x = 5;
         this._output.y = 0;
         this._input.x = 5;
         if(stage)
         {
            this._width = stage.stageWidth - 1;
            this._height = stage.stageHeight / 3 * 2;
         }
         this._scrollBar.extents = new Rectangle(0,0,8,this._height - 32);
         this._scrollBar.x = this._width - this._scrollBar.extents.width - 5;
         this._scrollBar.y = 5;
         this._output.height = this._height - 30;
         this._output.width = this._width - (this._scrollBar.width + 1);
         this._input.height = 18;
         this._input.width = this._width - 10;
         this._input.y = this._output.height + 7;
      }
      
      protected function createScrollBar() : PBScrollBar
      {
         this._scrollBar = new PBScrollBar();
         return this._scrollBar;
      }
      
      protected function createOutputField() : TextField
      {
         this._output = new TextField();
         this._output.type = TextFieldType.DYNAMIC;
         this._output.multiline = true;
         this._output.wordWrap = true;
         this._output.condenseWhite = false;
         var _loc1_:TextFormat = this._output.getTextFormat();
         _loc1_.font = "_typewriter";
         _loc1_.size = 11;
         _loc1_.color = 0;
         this._output.setTextFormat(_loc1_);
         this._output.defaultTextFormat = _loc1_;
         this._output.htmlText = "";
         this._output.embedFonts = false;
         this._output.name = "ConsoleOutput";
         return this._output;
      }
      
      protected function createInputField() : TextField
      {
         this._input = new TextField();
         this._input.type = TextFieldType.INPUT;
         this._input.border = true;
         this._input.borderColor = 16777215;
         this._input.multiline = false;
         this._input.wordWrap = false;
         this._input.condenseWhite = false;
         this._input.background = true;
         this._input.backgroundColor = 16777215;
         var _loc1_:TextFormat = this._input.getTextFormat();
         _loc1_.font = "_typewriter";
         _loc1_.size = 11;
         _loc1_.color = 0;
         this._input.setTextFormat(_loc1_);
         this._input.defaultTextFormat = _loc1_;
         this._input.restrict = "^`";
         this._input.name = "ConsoleInput";
         return this._input;
      }
      
      protected function setHistory(param1:String) : void
      {
         var old:String = param1;
         this._input.text = old;
         Zlab.callLater(function():void
         {
            _input.setSelection(_input.length,_input.length);
         });
      }
      
      protected function onInputKeyDown(param1:KeyboardEvent) : void
      {
         var list:Array = null;
         var isFirst:Boolean = false;
         var oldfr:* = undefined;
         var i:int = 0;
         var potentialMatch:String = null;
         var event:KeyboardEvent = param1;
         if(event.keyCode != Keyboard.TAB && event.keyCode != Keyboard.SHIFT)
         {
            this.tabCompletionPrefix = this._input.text;
            this.tabCompletionCurrentStart = -1;
            this.tabCompletionCurrentOffset = 0;
         }
         if(event.keyCode == Keyboard.ENTER)
         {
            if(this._input.text.length <= 0)
            {
               this.addLogMessage("CMD",">",this._input.text);
               return;
            }
            this.processCommand();
         }
         else if(event.keyCode == Keyboard.UP)
         {
            if(this._historyIndex > 0)
            {
               this.setHistory(this._consoleHistory[--this._historyIndex]);
            }
            else if(this._consoleHistory.length > 0)
            {
               this.setHistory(this._consoleHistory[0]);
            }
            event.preventDefault();
         }
         else if(event.keyCode == Keyboard.DOWN)
         {
            if(this._historyIndex < this._consoleHistory.length - 1)
            {
               this.setHistory(this._consoleHistory[++this._historyIndex]);
            }
            else if(this._historyIndex == this._consoleHistory.length - 1)
            {
               this._input.text = "";
            }
            event.preventDefault();
         }
         else if(event.keyCode == Keyboard.PAGE_UP)
         {
            this._output.scrollV -= Math.floor(this._output.height / this._output.getLineMetrics(0).height);
         }
         else if(event.keyCode == Keyboard.PAGE_DOWN)
         {
            this._output.scrollV += Math.floor(this._output.height / this._output.getLineMetrics(0).height);
         }
         else if(event.keyCode == Keyboard.TAB)
         {
            list = Console.getCommandList();
            isFirst = false;
            if(this.tabCompletionCurrentStart == -1)
            {
               this.tabCompletionPrefix = this._input.text.toLowerCase();
               this.tabCompletionCurrentStart = int.MAX_VALUE;
               this.tabCompletionCurrentEnd = -1;
               i = 0;
               while(i < list.length)
               {
                  if(list[i].name.substr(0,this.tabCompletionPrefix.length).toLowerCase() == this.tabCompletionPrefix)
                  {
                     if(i < this.tabCompletionCurrentStart)
                     {
                        this.tabCompletionCurrentStart = i;
                     }
                     if(i > this.tabCompletionCurrentEnd)
                     {
                        this.tabCompletionCurrentEnd = i;
                     }
                     isFirst = true;
                  }
                  i++;
               }
               this.tabCompletionCurrentOffset = this.tabCompletionCurrentStart;
            }
            if(this.tabCompletionCurrentEnd != -1)
            {
               if(!isFirst)
               {
                  if(event.shiftKey)
                  {
                     --this.tabCompletionCurrentOffset;
                  }
                  else
                  {
                     ++this.tabCompletionCurrentOffset;
                  }
                  if(this.tabCompletionCurrentOffset < this.tabCompletionCurrentStart)
                  {
                     this.tabCompletionCurrentOffset = this.tabCompletionCurrentEnd;
                  }
                  else if(this.tabCompletionCurrentOffset > this.tabCompletionCurrentEnd)
                  {
                     this.tabCompletionCurrentOffset = this.tabCompletionCurrentStart;
                  }
               }
               potentialMatch = list[this.tabCompletionCurrentOffset].name;
               this._input.text = potentialMatch;
               this._input.setSelection(potentialMatch.length + 1,potentialMatch.length + 1);
            }
            oldfr = stage.stageFocusRect;
            stage.stageFocusRect = false;
            Zlab.callLater(function():void
            {
               stage.focus = _input;
               stage.stageFocusRect = oldfr;
            });
         }
         else if(event.keyCode == InputKey.TILDE.keyCode)
         {
            parent.removeChild(this);
            this.deactivate();
         }
         event.stopImmediatePropagation();
      }
      
      protected function truncateOutput() : void
      {
         if(this._output.text.length > this.maxLength)
         {
            this._output.text = this._output.text.slice(-this.maxLength);
            if(!this._truncating)
            {
               this._truncating = true;
               Logger.warn(this,"truncateOutput","You have exceeded " + this._maxLength + " characters in LogViewerAS. " + "It will now only show the latest " + this._maxLength + " characters of the log.");
            }
         }
      }
      
      protected function processCommand() : void
      {
         this.addLogMessage("CMD",">",this._input.text);
         Console.processLine(this._input.text);
         this._consoleHistory.push(this._input.text);
         this._historyIndex = this._consoleHistory.length;
         this._input.text = "";
      }
      
      public function addLogMessage(param1:String, param2:String, param3:String) : void
      {
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc4_:String = LogColor.getColor(param1);
         if(Console.verbosity < 2)
         {
            _loc6_ = param2.lastIndexOf("::");
            if(_loc6_ != -1)
            {
               param2 = param2.substr(_loc6_ + 2);
            }
         }
         var _loc5_:String = (Console.verbosity > 0 ? param1 + ": " : "") + param2 + " - " + param3;
         if(this._output)
         {
            _loc7_ = "<p><font size=\"" + this._input.getTextFormat().size + "\" color=\"" + _loc4_ + "\"><b>" + ZlabUtil.escapeHTMLText(_loc5_) + "</b></font></p>";
            this._output.htmlText += _loc7_;
            this.truncateOutput();
            this._output.scrollV = this._output.maxScrollV;
            this._scrollBar.progress = 1;
         }
      }
      
      public function get maxLength() : uint
      {
         return this._maxLength;
      }
      
      public function set maxLength(param1:uint) : void
      {
         this._maxLength = param1;
         this.truncateOutput();
      }
      
      public function activate() : void
      {
         this.layout();
         this._input.text = "";
         this.addListeners();
         Zlab.mainStage.focus = this._input;
      }
      
      public function deactivate() : void
      {
         this.removeListeners();
         Zlab.mainStage.focus = null;
      }
   }
}

