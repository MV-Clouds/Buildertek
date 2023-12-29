({
    doInit: function (component, event, helper) {
        try {
          component.set("v.isLoading", true);
            var pageReference = component.get("v.pageReference");
            //var bomIdFromParentCmp = pageReference.attributes.attributes.recordId;
            var urlBomId = pageReference.state.buildertek__bomRecordId;
        
            if (urlBomId != null && urlBomId != undefined && urlBomId != "") {
              component.set("v.recordId", urlBomId);
            }
    
            console.log('Record ID : ', component.get("v.recordId"));
        
            // helper.checkFabricationTaxes(component, event, helper);
            component.set("v.massUpdateEnable", false);
            var pageNumber = component.get("v.PageNumber");
            var pageSize = component.get("v.pageSize");

            helper.fetchTakeOffLinesData(component, event, helper);
            helper.setColumns(component);
            // helper.getFieldSetFields(component,event);
            // helper.getPoLinesList(component, event, helper,pageNumber,pageSize);
        
            window.setTimeout(
              $A.getCallback(function () {
                helper.getPoLinesList(component, event, helper, pageNumber, pageSize);
              }),
              1500
            );

            window.setTimeout(function () {
                var workspaceAPI = component.find("workspace");
                workspaceAPI
                  .getFocusedTabInfo()
                  .then(function (response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.setTabLabel({
                      tabId: focusedTabId,
                      label: "BOM Lines",
                    });
                    workspaceAPI.setTabIcon({
                      tabId: focusedTabId,
                      icon: "custom:custom70",
                    });
                  })
                  .catch(function (error) {
                    // console.log("sub tab error::", error);
                    // alert(error);
                  });
              }, 100);
        
            var billOfMeterialId = component.get("v.recordId");
            component.set("v.bomId", billOfMeterialId);
        
            //  helper.getPoList(component, event, helper);
            // component.set("v.isLoading", false);
        } catch (error) {
            console.log('error in DoInti : ', error.stack);
            component.set("v.isLoading", false);
        }
      },

      handleRecordLoaded: function(component, event, helper) {

        console.log(component.get("v.BTBOMtype.Name"));
        var BOMName = component.get("v.BTBOMtype")["Name"];
        component.set("v.BOMName", BOMName)
      },

      massUpdateLines: function(component, event, helper){
        // component.set("v.isLoading", true);
        try {
          var headerIndex = event.getSource().get("v.title");
          var massupdateIndex = component.get("v.massupdateIndex");
          console.log('headerIndex :: ', headerIndex);
          var groupData = component.get("v.dataByGroup");

          if(!groupData[headerIndex].massUpdate){
            component.set("v.isLoading", true);

            console.log('enable mass update');
            groupData[headerIndex].massUpdate = true;
            component.set("v.dataByGroup", groupData);
            massupdateIndex.push(headerIndex);
            component.set("v.massupdateIndex", massupdateIndex);
            window.setTimeout(
              $A.getCallback(function () {
                component.set("v.isLoading", false);
              }),
              3000
            );
          }
          else{
            
            helper.MassUpdateHelper(component, event, helper, headerIndex, massupdateIndex);

          }
          // if(component.get("v.massUpdateEnable")){
          //   console.log('Update Records');
          //   helper.MassUpdateHelper(component, event, helper);
          // }
          // else{
          //   console.log('Enable mass Update');
          //   component.set("v.massUpdateEnable", true);

          //   var TotalRecord = component.get("v.totalBOMlines");
          //   var spinnerTimeOut = TotalRecord > 200 ? 10000 : TotalRecord * 40;
          //   spinnerTimeOut = TotalRecord < 30 ? 1200 : spinnerTimeOut;
          //   window.setTimeout(
          //     $A.getCallback(function () {
          //       component.set("v.isLoading", false);
          //     }),
          //     spinnerTimeOut
          //   );
          // }
        } catch (error) {
            console.log('Error in massUpdateLines : ', error.stack);
            component.set("v.isLoading", false);
        }
      },

      onMassUpdateCancel: function(component, event, helper){
        try {
          var headerIndex = event.getSource().get("v.title");
          console.log('headerIndex :: ', headerIndex);

          var groupData = component.get("v.dataByGroup");
          groupData[headerIndex].massUpdate = false;
          component.set("v.dataByGroup", groupData);

          var massupdateIndex = component.get("v.massupdateIndex");
          massupdateIndex = massupdateIndex.filter(ele => ele !== headerIndex)
          component.set("v.massupdateIndex", massupdateIndex);


          // component.set("v.massUpdateEnable", false);
          // component.set("v.isLoading", true);
          // window.setTimeout(
          //     $A.getCallback(function () {
          //       component.set("v.isLoading", false);
          //     }),
          //     3000
          //   );

        } catch (error) {
          console.log('Error in onMassUpdateCancel : ', error.stack);
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

      recordEditLoaded: function(component, event, helper){
        console.log('recordEditLoaded');
      },

      handleLookUpEvent: function(component, event, helper){
        try {
          var selectedRecordId = event.getParam("selectedRecordId");
          var index = event.getParam('index');
          console.log('selectedRecordId : ', selectedRecordId);
        } catch (error) {
          console.log('error im child to parent call : ', error.stack);
        } 
      },
})