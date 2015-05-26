Skull.TimedInput = {
  timeout: 1000,

  setupTimedInput: function(){
    this.$el.keyup(this.setTimer);
  },

  setTimer: function(event){
    var that = this;
    if(this.timeoutID){
      window.clearTimeout(this.timeoutID);
    }
    this.timeoutID = window.setTimeout(function(){
      that.$el.trigger('timedKeyup', event);
    }, this.timeout);
  },
};