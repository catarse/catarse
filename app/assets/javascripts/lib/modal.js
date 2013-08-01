Skull.Modal = {

  openModalClick: function(event) {
    var $link = $(event.currentTarget);
    var $modal = $link.data('target');

    this.addBlackBackground();
    this.showModal($modal);

    if($link.data('path') != undefined && $.trim($link.data('path')) != "") {
      $.get($link.data('path')).success(function(data) {
        $('.skull-modal-body', $modal).html(data);
      })
    }

    $('.skull-modal-close', $modal).on('click', this.closeModalClick);

    return false;
  },

  showModal: function(target_selector) {
    $(target_selector).fadeIn('fast');
  },

  closeModalClick: function(event) {
    var $link = $(event.currentTarget);
    var $modal = $link.parent().parent().closest('.skull-modal');

    $modal.fadeOut('fast');

    this.removeBlackBackground();
  },

  addBlackBackground: function() {
    $('body').prepend('<div class="skull-modal-blackbg"></div>');
  },

  removeBlackBackground: function() {
    if($('.skull-modal-blackbg').length > 0) {
      $('.skull-modal-blackbg').fadeOut('fast').remove();
    }
  }
}
