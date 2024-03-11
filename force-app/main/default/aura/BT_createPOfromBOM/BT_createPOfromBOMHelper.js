({

    getFieldSetValues : function (component, event, helper){
        try {
            var action = component.get("c.getFieldSetValues");
            action.setCallback(this, function (response) {
                var result = response.getReturnValue();
                if(result.state == 'success'){
                    console.log('fieldSetvalues : ', JSON.parse([result.FieldSetValues]));
                    component.set('v.fieldSetValues', JSON.parse([result.FieldSetValues]));
                }
                else if(result.state == 'error'){
                    
                }
            });
            $A.enqueueAction(action);
            
        } catch (error) {
            console.log('error in getFieldSetValues : ', error.stack);
        }

    },

    getBOMlinesHelper: function(component, event, helper){
        try {
            var action = component.get("c.getBOMlines");
            action.setParams({
                BOMiD : component.get("v.recordId")
            })
            action.setCallback(this, function (response) {
                var result = response.getReturnValue();
                // console.log('response : ', result);
                if(result.state == 'success'){
                    if(result.BOMLines){
                        helper.formmateByGroup(component, event, helper, result);
                    }
                    else{
                        helper.ToastMessageUtilityMethod(component, 'Error', 'There are no BOM line available. Please create atleast one BOM line.', 'error', 3000);
                        component.set("v.isSpinner", false);
                    }
                }
                else if(result.state == 'error'){

                    component.set("v.isSpinner", false);
                    
                }
            });
            $A.enqueueAction(action);
        } catch (error) {
            console.log('error in getBOMlinesHelper : ', error.stack);
            
        }
    },

    formmateByGroup : function(component, event, helper, result) {
        try {

            var formatedData = [];
            var Vendors = JSON.parse(JSON.stringify(result.vendorList));
            var BOMlines = JSON.parse(JSON.stringify(result.BOMLines))
            // for(var i in Vendors){
            //     formatedData.push({"groupName" : Vendors[i], 'isCreatePOEnable' :  false, "sObjectList" : [] });
            // }

            // for(var i in BOMlines){
            //     for(var j in formatedData){
            //         if(BOMlines[i].buildertek__Vendor__r == undefined || BOMlines[i].buildertek__Vendor__r.Name == undefined || BOMlines[i].buildertek__Vendor__r.Name == ''){
            //             if(formatedData[j].groupName == 'No Vendor'){
            //                 formatedData[j].sObjectList = [...formatedData[j].sObjectList, BOMlines[i]];
            //             }
            //         }
            //         else{
            //             if(formatedData[j].groupName == BOMlines[i].buildertek__Vendor__r.Name){
            //                 formatedData[j].sObjectList = [...formatedData[j].sObjectList, BOMlines[i]];
            //             }
            //         }
            //     }
            // }

            Vendors.forEach(vendor => {
                formatedData.push({
                    "groupName": vendor,
                    "isCreatePOEnable": false,
                    "sObjectList": []
                });
            });
            
            BOMlines.forEach(line => {
                const vendorName = line.buildertek__Vendor__c ? line.buildertek__Vendor__r.Name : 'No Vendor';
                const group = formatedData.find(group => group.groupName === vendorName);
                if (group) {
                    group.sObjectList.push(line);
                }
            });

            console.log('formatedData after sObject List : ', formatedData);
            component.set("v.GroupByVendors", formatedData);

            component.set("v.isSpinner", false);
        } catch (error) {
            console.log('error in formmateByGroup : ', error.stack);
        }

    },

    setTabIconHelper: function(component, event, helper){
        try {
            window.setTimeout(function () {
                var workspaceAPI = component.find("workspace");
                workspaceAPI
                  .getFocusedTabInfo()
                  .then(function (response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.setTabLabel({
                      tabId: focusedTabId,
                      label: "Create PO",
                    });
                    workspaceAPI.setTabIcon({
                      tabId: focusedTabId,
                      icon: "custom:custom70",
                    });
                  })
                  .catch(function (error) {
                    console.log("sub tab error::", error);
                    // alert(error);
                  });
              }, 1000);
            
        } catch (error) {
            console.log('error in setTabIconHelper : ', error.stack);
            
        }
    
    },

    createPOHelper: function(component, event, helper, groupIndex){
        try {
        console.log(' ========= createPOHelper ======');
        component.set("v.isSpinner", true);

        var SelecetdLinesId = [];
        var vendorVsselectdLinesId = component.get("v.vendorVsselectdLinesId");
          for(var i in vendorVsselectdLinesId){
            if(vendorVsselectdLinesId[i].groupIndex == groupIndex){
              SelecetdLinesId = vendorVsselectdLinesId[i].SelecetdLinesId;
            }
        }

          var action = component.get("c.createPOfromBOM");
          action.setParams({
              BOMiD : component.get("v.recordId"),
              slectedLinesId : SelecetdLinesId
          })
          action.setCallback(this, function (response) {
              var result = response.getReturnValue();
              console.log('create PO Result : ', result);
              if(result.state == 'success'){
                  helper.ToastMessageUtilityMethod(component, 'Success', 'Purchase Order created successfully.', 'success', 3000);
                  helper.getBOMlinesHelper(component, event, helper);

                  component.set("v.vendorVsselectdLinesId", []);
                  
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        recordId: result.POid,
                        slideDevName: "related",
                    });
                    navEvt.fire();
              }
              else if(result.state == 'error'){
                component.set("v.isSpinner", false);
                if(result.isCustomeValidation){
                    helper.ToastMessageUtilityMethod(component, '', 'Custom validation error : ' + result.returnMessage, 'error', 6000);
                }
                else{
                    helper.ToastMessageUtilityMethod(component, '', 'Something Went Wrong', 'error', 3000);
                }
              }
              // console.log('response : ', result);
          });
          $A.enqueueAction(action);

            
        } catch (error) {
            console.log('error in createPOHelper : ', error.stack);
        }
    },

    ToastMessageUtilityMethod: function(component, Title, Message, Type, Duration){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : Title,
            message: Message,
            type: Type,
            duration: Duration,
        });
        toastEvent.fire();
    },

    
})