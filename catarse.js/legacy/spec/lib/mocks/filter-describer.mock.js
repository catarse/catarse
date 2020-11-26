beforeAll(function(){
  FilterDescriberMock = function(filterMain, filterDropdown, filterNumberRange, filterDateRange, prop){
    var describer = [
      { //full_text_index
        component: filterMain,
        data: {
          vm: prop(),
          placeholder: 'Busque por projeto, email, Ids do usuário e do apoio...'
        }
      },
      { //state
        component: filterDropdown,
        data: {
          label: 'Com o estado',
          name: 'state',
          vm: prop(),
          options: [
            {value: '', option: 'Qualquer um'},
            {value: 'paid', option: 'paid'},
            {value: 'refused', option: 'refused'},
            {value: 'pending', option: 'pending'},
            {value: 'pending_refund', option: 'pending_refund'},
            {value: 'refunded', option: 'refunded'},
            {value: 'chargeback', option: 'chargeback'},
            {value: 'deleted', option: 'deleted'}
          ]
        }
      },
      { //gateway
        component: filterDropdown,
        data: {
          label: 'gateway',
          name: 'gateway',
          vm: prop(),
          options: [
            {value: '', option: 'Qualquer um'},
            {value: 'Pagarme', option: 'Pagarme'},
            {value: 'MoIP', option: 'MoIP'},
            {value: 'PayPal', option: 'PayPal'},
            {value: 'Credits', option: 'Créditos'}
          ]
        }
      },
      { //value
        component: filterNumberRange,
        data: {
          label: 'Valores entre',
          first: prop(),
          last: prop()
        }
      },
      { //created_at
        component: filterDateRange,
        data: {
          label: 'Período do apoio',
          first: prop(),
          last: prop()
        }
      }
    ];

    return describer;
  };
});
