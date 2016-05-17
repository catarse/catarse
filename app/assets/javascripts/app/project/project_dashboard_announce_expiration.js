App.addChild('DashboardAnnounceExpiration', {
  el: '#dashboard-announce_expiration-tab',

  events:{
    "click a#show-modal": "showModal",
    "change #flexible_project_online_days": "updateExpirationDate",
    "click #cancel": "hideModal"
  },

  showModal: function () {
    $('.modal-backdrop').show();
  },

  hideModal: function () {
    $('.modal-backdrop').hide();
  },

  updateExpirationDate: function() {
    var days = parseInt($('#flexible_project_online_days').val());
    var expiration_date = new Date();
    expiration_date.setDate(expiration_date.getDate() + days);

    var dd = expiration_date.getDate();
    var mm = expiration_date.getMonth()+1; //January is 0!
    var yyyy = expiration_date.getFullYear();

    if(dd<10) {
        dd='0'+dd;
    }

    if(mm<10) {
        mm='0'+mm;
    }

    expiration_date = dd+'/'+mm+'/'+yyyy;
    $('.expire-date').html(expiration_date);
  }
});
