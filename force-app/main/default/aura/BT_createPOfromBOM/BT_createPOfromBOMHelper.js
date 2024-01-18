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
                    helper.formmateByGroup(component, event, helper, result);
                }
                else if(result.state == 'error'){
    
                }
                component.set("v.isSpinner", false);
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
            for(var i in Vendors){
                formatedData.push({"groupName" : Vendors[i], 'isCreatePOEnable' :  false, "sObjectList" : [] });
            }

            for(var i in BOMlines){
                for(var j in formatedData){
                    if(BOMlines[i].buildertek__Vendor__r == undefined || BOMlines[i].buildertek__Vendor__r.Name == undefined || BOMlines[i].buildertek__Vendor__r.Name == ''){
                        if(formatedData[j].groupName == 'No Vendor'){
                            formatedData[j].sObjectList = [...formatedData[j].sObjectList, BOMlines[i]];
                        }
                    }
                    else{
                        if(formatedData[j].groupName == BOMlines[i].buildertek__Vendor__r.Name){
                            formatedData[j].sObjectList = [...formatedData[j].sObjectList, BOMlines[i]];
                        }
                    }
                }
            }

            console.log('formatedData after sObject List : ', formatedData);
            component.set("v.GroupByVendors", formatedData)
            
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
        //   var SelecetdLinesId = component.get("v.createPOfromBOM");
            console.log(' ========= createPOHelper ======');
        component.set("v.isSpinner", true);

            var SelecetdLinesId = [];
            var vendorVsselectdLinesId = component.get("v.vendorVsselectdLinesId");
            if(vendorVsselectdLinesId.some(obj => obj['groupIndex'] == groupIndex)){
                SelecetdLinesId = vendorVsselectdLinesId[groupIndex].SelecetdLinesId;
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
                  helper.ToastMessageUtilityMethod(component, 'Success', 'PO Created Successfully.', 'success', 3000);
                  helper.getBOMlinesHelper(component, event, helper);
                  component.set("v.isSpinner", false);

                  var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        recordId: result.POiD,
                        slideDevName: "view",
                    });
                navEvt.fire();
              }
              else if(result.state == 'error'){
                  component.set("v.isSpinner", false);
                helper.ToastMessageUtilityMethod(component, '', 'Something Went Wrong', 'error', 3000);

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
