(function (factory) {
    if (typeof exports === 'object') {
        // Node/CommonJS
        factory(require('jquery'), require('underscore'));
    } else {
        // Browser globals
        factory(jQuery, _);
    }
}(function ($, _) {
  // Return a function that will add a new character to a string and include a mask character if this is the case
  function addChar(position, maskChar) {
    return function(char){
      return function(string){
        if(string.length === position && char !== maskChar){
          return (string + maskChar);
        }
        return string;
      };
    };
  }

  // Return an array containing a definition of which are the fixed characters in the mask using the format:
  // [[position, character]]
  // All characters in maskChars are ignored (for they are replaced by user input)
  function readMaskDefinition(maskCharDefinitions){
    return function(maskDefinition){
      return _.compact(_.map(maskDefinition, function(letter, index){
        return (letter in maskCharDefinitions ? null : [index, letter]);
      }));
    };
  }

  // Apply the mask defintion using an array of partially applied addChar functions
  // composing them and reading the new character that will be added to a given string
  // It should be partially applied using the maskDefinition 
  // to be called only with string and new char on a keypress event
  function applyMask(maskDefinition){
    var maskFunctions = _.map(maskDefinition, function(maskChar){ return addChar(maskChar[0], maskChar[1]); });
    return function(string, newChar){
      var addNewCharFunctions = _.map(maskFunctions, function(el){ return el(newChar); });
      var applyMaskFunctions = _.reduce(addNewCharFunctions, function(memo, f){ 
        return (_.isFunction(memo) ? _.compose(f, memo) : f); 
      });
      return applyMaskFunctions(string);
    };
  }

  // Decide if a character is allowed in a position within a given maskDefinition
  function isCharAllowed(maskCharDefinitions){
    return function(maskDefinition){
      return function(position, newChar){
        if(position >= maskDefinition.length){
          return false;
        }

        var maskChar = maskDefinition.charAt(position);
        if(maskChar in maskCharDefinitions){
          return maskCharDefinitions[maskChar].test(newChar);
        }
        else{
          return (newChar === maskChar || isCharAllowed(maskCharDefinitions)(maskDefinition)(position+1, newChar));
        }
      };
    };
  }

  $.fixedMask = {
    maskCharDefinitions: {
      '9' : /\d/,
      'A' : /[a-zA-Z]/
    }
  };

  // Define some functions that depend on global definitions during plugin load
  $.fixedMask.readMask = readMaskDefinition($.fixedMask.maskCharDefinitions);
  $.fixedMask.isCharAllowed = isCharAllowed($.fixedMask.maskCharDefinitions);
    
  $.fn.extend({
    fixedMask: function(mask){
      return this.each(function() {
        var input = $(this);

        if(mask !== 'off'){
          // Define some functions that depend on maskDefinition during plugin setup
          var maskDefinition = mask || input.data('fixed-mask');
          var applyInputMask = applyMask($.fixedMask.readMask(maskDefinition));
          var restrictInput = $.fixedMask.isCharAllowed(maskDefinition);

          function restrictChars(event){
            var chr = String.fromCharCode(event.which);
            return restrictInput(input.prop('selectionStart'), chr);
          }

          function reformat(){
            input.val(_.reduce(input.val(), function(memo, chr){
              if(restrictInput(memo.length, chr)){
                memo = applyInputMask(memo, chr) + chr;
              }
              return memo;
            }, ''));
          }

          // Initial formatting
          reformat();

          // Bind events
          input.
            on('input.fixedmask', reformat);
        }
        else{
          // Bind events
          input.
            off('keypress.fixedmask').
            off('input.fixedmask');
        }
      });
    }
  });
}));
