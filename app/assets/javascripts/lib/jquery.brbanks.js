(function($){
  $.fn.extend({
    brbanks: function(options) {
      var root = this;

      local = {
        selector: this,
        bankDivSelector: '.brbanks-banks',
        banks: [],

        parseToList: function(banks_data) {
          that = this;
          $.each(banks_data, function(i,item){
            that.banks.push(item.id + ' - ' + item.name)
          });

          that.inserListOnData();
        },

        inserListOnData: function() {
          this.selector.data('banks', this.banks);
        },

        loadBanksOnSelector: function(callback) {
          var that = this;
          $.getJSON("https://brbanks.herokuapp.com", function(data){
            that.parseToList(data);
            callback(that);
          });
        },

        buildBankDiv: function() {
          var div = $("<div class='brbanks-banks' style='display: none;'></div>")
          var ul = $("<ul></ul>")

          $.each(this.selector.data('banks'), function(i, item){
            ul.append($('<li>'+item+'</li>'));
          });

          div.prepend(ul);
          return div;
        }
      }

      showUpBanks = function(that) {
        that.selector.focusin(function(){
          if($(that.bankDivSelector).length <= 0) {
            var div = that.buildBankDiv();
            that.selector.parent().append(div);
            div.show();
          } else {
            $(that.bankDivSelector).show();
          };

          $('ul li', that.bankDivSelector).click(function(element){
            root.val($(element.currentTarget).text());
            $(that.bankDivSelector).hide();
          })
        });

        $(document).mouseup(function(e){
          if(!$(that.bankDivSelector).is(e.target) && !that.selector.is(e.target)) {
            $(that.bankDivSelector).hide();
            $('ul li', that.bankDivSelector).css({display: 'block'});

            if($.inArray($(that.selector).val(), that.banks) < 0) {
              $(that.selector).val('');
            };
          }
        });
      };

      enableFilterOnBanks = function(that) {
        that.selector.keyup(function(){
          var value = that.selector.val();
          var regexPattern = new RegExp(value, 'i');

          $('ul li', that.bankDivSelector).filter(function(){
            if(regexPattern.test($(this).text())) {
              $(this).fadeIn();
            } else {
              $(this).css({'display':'none'});
              $(this).fadeOut();
            }
          });
          //$.each($('ul li', that.bankDivSelector), function(i, item){
          //  if(regexPattern.test($(item).text())){
          //    $(item).css({'display':'block'})
          //  } else {
          //    $(item).css({'display':'none'})
          //  }
          //});
        });
      };

      local.loadBanksOnSelector(function(that) {
        showUpBanks(that);
        enableFilterOnBanks(that);
      });
    }
  });
})(jQuery);
