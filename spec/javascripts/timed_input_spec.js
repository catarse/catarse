describe("TimedInput", function() {
  var ViewClass, view;

  beforeEach(function() {
    ViewClass = Skull.View.extend(_.extend({ el: 'test' }, Skull.TimedInput));
    view = new ViewClass();
  });

  describe("setupTimedInput", function() {
    beforeEach(function() {
      spyOn(view.$el, "keyup");
      view.setupTimedInput();
    });

    it("should bind the setTimer to the keyup event of $el", function() {
      expect(view.$el.keyup).wasCalledWith(view.setTimer);
    });
  });

  describe("setTimer", function() {
    beforeEach(function() {
      spyOn(window, "setTimeout").andCallFake(function(callback, timeout){
        callback();
        return 123;
      });
      spyOn(view.$el, "trigger");
    });
    
    describe("when there is already a timer set", function() {
      beforeEach(function() {
        view.timeoutID = 456;
        spyOn(window, "clearTimeout");
        view.setTimer();
      });

      it("should cancell the previous timeout before setting a new one", function() {
        expect(window.clearTimeout).wasCalledWith(456);
      });

      it("should store the timeoutID", function() {
        expect(view.timeoutID).toEqual(123);
      });
    });

    describe("when there is no timer set", function() {
      beforeEach(function() {
        view.setTimer('event');
      });

      it("should call the trigger the timedKeyup inside callback", function() {
        expect(view.$el.trigger).wasCalledWith('timedKeyup', 'event');
      });

      it("should call the setTimeout", function() {
        expect(window.setTimeout).wasCalledWith(jasmine.any(Function), view.timeout);
      });

      it("should store the timeoutID", function() {
        expect(view.timeoutID).toEqual(123);
      });
    });  
  });  
});  

