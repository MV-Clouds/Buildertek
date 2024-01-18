({
    doInit : function(component, event, helper) {
        try {
            component.set("v.isSpinner", true);
            console.log('reordId', component.get("v.recordId"));

            helper.getFieldSetValues(component, event, helper);
            helper.getBOMlinesHelper(component, event, helper);
            helper.setTabIconHelper(component, event, helper);

        } catch (error) {
            console.log('error in doInit : ', error.stack);
        }
    },

    handleRecordLoaded: function(component, event, helper) {
        console.log(component.get("v.BTBOMtype.Name"));
        var BOMName = component.get("v.BTBOMtype")["Name"];
        component.set("v.BOMName", BOMName)
    },
    

    onClickCreatePOhadler: function(component, event, helper){
      try {
        var groupIndex = event.getSource().get("v.title");
        console.log('groupIndex :: ', groupIndex);
        var groupData = component.get("v.GroupByVendors");

        // When Create PO is Disabled
        if(!groupData[groupIndex].isCreatePOEnable){
          component.set("v.isLoading", true);

          groupData[groupIndex].isCreatePOEnable = true;
          component.set("v.GroupByVendors", groupData);
          
        }
        else{
          // When create PO is Enabled
          // var SelecetdLinesId = component.get("v.selectdLinesId");

          var SelecetdLinesId = [];
          var vendorVsselectdLinesId = component.get("v.vendorVsselectdLinesId");
          if(vendorVsselectdLinesId.some(obj => obj['groupIndex'] == groupIndex)){
              SelecetdLinesId = vendorVsselectdLinesId[toString(groupIndex)].SelecetdLinesId;
          }
          
          if(SelecetdLinesId.length == 0){
            // When User did not selectd any Line and click save Button....
            helper.ToastMessageUtilityMethod(component, '', 'Please select atlease one line for this Vendor to create PO.', 'error', 3000);
          }
          else{
            helper.createPOHelper(component, event, helper, groupIndex);
          }
        }
        
      } catch (error) {
        console.log('error in onClickCreatePOhadler : ', error.stack);
      }
    },

    onCancelCreatePOhadler: function(component, event, helper){
      try {
        component.set("v.isLoading", true);
        var groupIndex = event.getSource().get("v.title");
        // console.log('groupIndex :: ', groupIndex);

        var groupData = component.get("v.GroupByVendors");
        groupData[groupIndex].isCreatePOEnable = false;
        component.set("v.GroupByVendors", groupData);

        window.setTimeout(
            $A.getCallback(function () {
              component.set("v.isLoading", false);
            }),
            1500
          );

      } catch (error) {
        console.log('Error in onCancelCreatePOhadler : ', error.stack);
      }
    },

    redirect: function (component, event, helper) {
  
      var navEvt = $A.get("e.force:navigateToSObject");
      navEvt.setParams({
        recordId: component.get("v.recordId"),
        slideDevName: "related",
      });
      navEvt.fire();
  
      var workspaceAPI = component.find("workspace");
      workspaceAPI
        .getFocusedTabInfo()
        .then(function (response) {
          var focusedTabId = response.tabId;
          workspaceAPI.closeTab({
            tabId: focusedTabId,
          });
        })
        .catch(function (error) {
          // console.log("Error", error);
        });
    },

    checkboxChange: function(component, event, helper){
        try {
            var selectedCheckbox = event.getSource(); // Get the checkbox that fired the event
            var isChecked = selectedCheckbox.get("v.checked");
            var rowId = selectedCheckbox.get("v.id");
            var lineId = rowId.split("_")[0]
            var groupIndex = rowId.split("_")[1];
            var rowIndex = rowId.split("_")[2];

            
            // var SelecetdLinesId = component.get("v.selectdLinesId");
            // if(isChecked){
            //   SelecetdLinesId.push(lineId);
            //   component.set("v.selectdLinesId", SelecetdLinesId);
            // }
            // else{
            //   SelecetdLinesId = SelecetdLinesId.filter((ele) => ele !== lineId);
            //   component.set("v.selectdLinesId", SelecetdLinesId);
            // }
            
            var vendorVsselectdLinesId = component.get("v.vendorVsselectdLinesId");
            // create Vendor(group) againt Selected Line Ids Object.... 
            if(vendorVsselectdLinesId.length > 0){
              for(var i in vendorVsselectdLinesId){
                if(vendorVsselectdLinesId[i].groupIndex == groupIndex){
                  if(isChecked){
                    vendorVsselectdLinesId[i].SelecetdLinesId = [...vendorVsselectdLinesId[i].SelecetdLinesId, lineId];
                  }
                  else{
                    vendorVsselectdLinesId[i].SelecetdLinesId = vendorVsselectdLinesId[i].SelecetdLinesId.filter((ele) => ele !== lineId)
                  }
                }

                else if(!vendorVsselectdLinesId.some(obj => obj['groupIndex'] == groupIndex)){
                  // console.log('value not exist');
                  if(isChecked){
                    vendorVsselectdLinesId.push({'groupIndex' : groupIndex , 'SelecetdLinesId' : [lineId]});
                  }
                }
              }
            }
            else{
              if(isChecked){
                vendorVsselectdLinesId.push({'groupIndex' : groupIndex , 'SelecetdLinesId' : [lineId]});
              }
            }
            component.set("v.vendorVsselectdLinesId", vendorVsselectdLinesId);
            console.log('vendorVsselectdLinesId >> ', JSON.parse(JSON.stringify(component.get("v.vendorVsselectdLinesId"))));

        } catch (error) {
            console.log('error in checkboxChange : ', error.stack);
        }
    },

    selectAllcheckboxChange: function(component, event, helper){
        try {
            var selectedCheckbox = event.getSource(); // Get the checkbox that fired the event
            var groupId = selectedCheckbox.get("v.id");

            var groupIndex = groupId.split("_")[1];
            console.log('groupIndex : ', groupIndex);

            var isChecked = selectedCheckbox.get("v.checked");

            var RelatedChecboxes = document.querySelectorAll(`[data-groupindex="${groupIndex}"]`);
            // var RelatedChecboxes = component.find(groupIndex);
            console.log('RelatedChecboxes : ', RelatedChecboxes.length);

        } catch (error) {
            console.log('error in selectAllcheckboxChange : ', error.stack);
        }
    },

})
