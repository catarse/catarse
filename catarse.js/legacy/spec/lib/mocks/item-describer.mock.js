beforeAll(function(){
  ItemDescriberMock = function(adminUser, adminProject, adminContribution, paymentStatus){
    //TO-DO: Implement opts to build custom describers
    return [
      {
        component: adminUser,
        wrapperClass: '.w-col.w-col-4'
      },
      {
        component: adminProject,
        wrapperClass: '.w-col.w-col-4'
      },
      {
        component: adminContribution,
        wrapperClass: '.w-col.w-col-2'
      },
      {
        component: paymentStatus,
        wrapperClass: '.w-col.w-col-2'
      }
    ];
  };
});
