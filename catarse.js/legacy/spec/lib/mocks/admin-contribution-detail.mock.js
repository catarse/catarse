beforeAll(function(){
  ContributionDetailMockery = function(j,attrs){
    var attrs = attrs || {},
        contributions = [],
        i;

    for(i = 0; i < j; i++){
      var data = {
        id : i,
        contribution_id : i,
        user_id : i,
        project_id : i,
        reward_id : i,
        payment_id : i,
        permalink : 'project_'+i,
        project_name : 'Project '+i,
        project_img : 'project' + i + '_thumb.jpg',
        user_name : 'User '+i,
        user_profile_img : 'avatar_'+i+'.jpg',
        email : 'user@user'+i+'.com',
        key : i,
        value : 50,
        installments : 1,
        installment_value : 50,
        state : 'paid',
        anonymous : false,
        payer_email : 'payer'+i+'@email.com',
        gateway : 'MoIP',
        gateway_id : null,
        gateway_fee : null,
        gateway_data : {},
        payment_method : 'desconhecido',
        project_state : 'successful',
        has_rewards : true,
        pending_at : '2015-01-16T17:25:56.611561',
        paid_at : '2015-01-16T17:25:56.611561',
        refused_at : null,
        pending_refund_at : null,
        refunded_at : null,
        created_at : '2015-01-15T17:25:56.611561'
      };
      data = _.extend(data, attrs);
      contributions.push(data);
    }
    return contributions;
  };

  jasmine.Ajax.stubRequest(new RegExp("("+apiPrefix + '\/contribution_details)'+'(.*)')).andReturn({
    'responseText' : JSON.stringify(ContributionDetailMockery(nContributions))
  });

});
