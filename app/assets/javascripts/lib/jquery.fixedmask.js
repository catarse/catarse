/*
    jQuery Fixed Size Input Mask Plugin
    Copyright (c) 2007 - 2014 Diogo Biazus
    Licensed under the MIT license (http://digitalbush.com/projects/masked-input-plugin/#license)
    Version: 1.0.0
*/
!function(factory) {
    "object" == typeof exports ? factory(require("jquery"), require("underscore")) : factory(jQuery, _);
}(function($, _) {
    function addChar(position, maskChar) {
        return function(char) {
            return function(string) {
                return string.length === position && char !== maskChar ? string + maskChar : string;
            };
        };
    }
    function readMaskDefinition(maskCharDefinitions) {
        return function(maskDefinition) {
            return _.compact(_.map(maskDefinition, function(letter, index) {
                return letter in maskCharDefinitions ? null : [ index, letter ];
            }));
        };
    }
    function applyMask(maskDefinition) {
        var maskFunctions = _.map(maskDefinition, function(maskChar) {
            return addChar(maskChar[0], maskChar[1]);
        });
        return function(string, newChar) {
            var addNewCharFunctions = _.map(maskFunctions, function(el) {
                return el(newChar);
            }), applyMaskFunctions = _.reduce(addNewCharFunctions, function(memo, f) {
                return _.isFunction(memo) ? _.compose(f, memo) : f;
            });
            return applyMaskFunctions(string);
        };
    }
    function isCharAllowed(maskCharDefinitions) {
        return function(maskDefinition) {
            return function(position, newChar) {
                if (position === maskDefinition.length) return !1;
                var maskChar = maskDefinition.charAt(position);
                return maskChar in maskCharDefinitions ? maskCharDefinitions[maskChar].test(newChar) : newChar === maskChar || isCharAllowed(maskCharDefinitions)(maskDefinition)(position + 1, newChar);
            };
        };
    }
    $.fixedMask = {
        maskCharDefinitions: {
            "9": /\d/,
            A: /[a-zA-Z]/
        }
    }, $.fixedMask.readMask = readMaskDefinition($.fixedMask.maskCharDefinitions), $.fixedMask.isCharAllowed = isCharAllowed($.fixedMask.maskCharDefinitions), 
    $.fn.extend({
        fixedMask: function(mask) {
            return this.each(function() {
                function restrictChars(event) {
                    var chr = String.fromCharCode(event.which);
                    return restrictInput(input.prop("selectionStart"), chr);
                }
                function reformat() {
                    input.val(_.reduce(input.val(), function(memo, chr) {
                        return restrictInput(memo.length, chr) && (memo = applyInputMask(memo, chr) + chr), 
                        memo;
                    }, ""));
                }
                var input = $(this), maskDefinition = mask || input.data("fixed-mask"), applyInputMask = applyMask($.fixedMask.readMask(maskDefinition)), restrictInput = $.fixedMask.isCharAllowed(maskDefinition);
                input.keypress(restrictChars).on("input", reformat);
            });
        }
    });
});