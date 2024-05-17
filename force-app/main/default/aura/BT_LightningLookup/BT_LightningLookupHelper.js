({
  searchHelper: function (component, event, getInputkeyWord) {
    // call the apex class method 

    // var productfamily=component.get("v.prodctfamly");
    // if(productfamily == '--None--'){
    //   productfamily = productfamily.replace(/--/g, '');
    //   console.log({productfamily});

    // }
    // Set message to Loading... before during apex callout... Once response received change it accordingly...
    let fieldName = component.get("v.fieldName");
    if (fieldName == 'pricebook') {
      var prodId = component.get("v.productId"); // Changed from prodId to productId
      console.log(`productId: ${prodId}`);
      if (prodId) {
        component.set("v.Message", 'Loading...');
        var action = component.get("c.fetchPricebook");
        action.setParams({
          PId: component.get('v.productId'),
        });
        action.setCallback(this, function (response) {
          // $A.util.removeClass(component.find("mySpinner"), "slds-show");
          var state = response.getState();
          console.log(`State: ${state} and ${JSON.stringify(response.getReturnValue())}`);
          if (state === "SUCCESS") {
            var storeResponse = response.getReturnValue();
            console.log('storeResponse: ', JSON.stringify(storeResponse));
            if (storeResponse && storeResponse.length == 0) {
              component.set("v.Message", 'No Result Found...');
            } else {
              component.set("v.Message", '');
            }
            component.set("v.listOfSearchRecords", storeResponse);
          }
        });
        $A.enqueueAction(action);
      } else {
        component.set("v.Message", 'Select Product first...');
      }
    }
    else {
      let callingcmp = component.get("v.callingcmp");
      console.log(`calling component: ${callingcmp}`);

      component.set("v.Message", 'Loading...');
      var action = component.get("c.getProductRecords");
      action.setStorable();
      // set param to method  
      action.setParams({
        'searchKeyWord': getInputkeyWord,
        'ObjectName': component.get("v.objectAPIName"),
        'filter': component.get("v.filter"),
        'parentId': component.get("v.parentId"),
        'prodctfamly': component.get("v.prodctfamly")
      });
      // // set a callBack  
      // console.log( component.get("v.filter"));  
      // console.log( component.get("v.prodctfamly"));



      action.setCallback(this, function (response) {
        $A.util.removeClass(component.find("mySpinner"), "slds-show");
        var state = response.getState();
        if (state === "SUCCESS") {
          var storeResponse = response.getReturnValue();
          // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
          if (storeResponse.length == 0) {
            component.set("v.Message", 'No Result Found...');
          } else {
            component.set("v.Message", '');
          }

          // for(var i in storeResponse){
          //   delete storeResponse[i].PricebookEntries;
          // }
          // console.log('storeResponse filter : ', storeResponse);
          // set searchResult list with return value from server.
          component.set("v.listOfSearchRecords", storeResponse);
        }

      });
      // console.log(component.get("v.parentId") + '----------------------------->>>>>>>>');
      // enqueue the Action  
      $A.enqueueAction(action);
      console.log('listof record-->', component.get("v.listOfSearchRecords").length);


    }

  }

})