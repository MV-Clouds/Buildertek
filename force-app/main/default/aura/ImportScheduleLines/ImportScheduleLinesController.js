({
    doInit: function (component, event, helper) {
        component.set("v.isOpen", true);
        var url = location.href;
        var baseURL = url.substring(0, url.indexOf('--', 0));
        console.log('baseURL', baseURL);
        component.set("v.BaseURLs", baseURL);
        var myPageRef = component.get("v.pageReference");
        var recordId;
        if (myPageRef) {
            recordId = myPageRef.state.buildertek__RecordId;
        }

        if (recordId) {
            component.set("v.RecordId", recordId)
            component.set("v.isNewGantt", myPageRef.state.buildertek__isFromNewGantt)
            //recordId = component.get("v.RecordId");
            /*if(!recordId){
                recordId = myPageRef.attributes.recordId
            }*/
        }
    },

    CreateRecord: function (component, event, helper) {
        // debugger;
        component.set("v.Spinner", true);
        component.set("v.showMessage", true);
        var fileInput = component.find("file").get("v.files");
        if (fileInput == null) {
            component.set("v.Spinner", false);
            component.set("v.showMessage", false);
            component.set("v.showError", true);
        } else {
            //component.set("v.Spinner", false);
            var file = fileInput[0];
            if (file) {
                component.set("v.showError", false);
                var reader = new FileReader();
                reader.readAsText(file, "UTF-8");
                reader.onload = function (evt) {
                    var csv = evt.target.result;
                    console.log( 'csv ----> ' + csv);
                    debugger;
                    var result = helper.CSV2JSON(component, event, helper, csv);
                    if (result != undefined && result != '') {
                        window.setTimeout(
                            $A.getCallback(function () {
                                helper.CreateAccount(component, result);
                            }), 100
                        );
                    } else {
                        var CircularDependencyName = component.get("v.CircularDependencyName");
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: 'Error',
                            message: 'Circular Dependency due to \''+CircularDependencyName+'\' Record',
                            duration: ' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                        component.set("v.Spinner", false);
                    }
                }
                reader.onerror = function (evt) {
                    console.log("error reading file");
                }
            }
        }
    },

    handleFilesChange: function (component, event, helper) {
        component.set("v.startdateError", false)
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
        // helper.parseFile(component,event.getSource().get("v.files")[0]);
    },

    closeModel: function (component, event, helper) {
        component.set("v.isOpen", false);
        var baseURL = component.get("v.BaseURLs");
        var recordId = component.get("v.RecordId");
        var url = location.href;
        var baseURL = url.substring(0, url.indexOf('--', 0));
        if (component.get('v.isNewGantt')) {
            // window.open('/'+recordId, "_top");
            var workspaceAPI = component.find("workspace");
            if (workspaceAPI.getFocusedTabInfo()) {
                workspaceAPI.getFocusedTabInfo().then(function (response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.closeTab({ tabId: focusedTabId });
                })
                    .catch(function (error) {
                        console.log(error);
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": recordId,
                            "slideDevName": "detail"
                        });
                        navEvt.fire();
                        //window.open(baseURL + '.lightning.force.com/lightning/r/buildertek__Schedule__c/' + escape(recordId) + '/view', '_top');
                    });
            } else {
                window.open('/' + recordId, "_top");
                //window.open(baseURL + '.lightning.force.com/lightning/r/buildertek__Schedule__c/' + escape(recordId) + '/view', '_top');
            }
            //window.open(baseURL + '.lightning.force.com/lightning/r/buildertek__Schedule__c/' + escape(recordId) + '/view', '_top');
        } else {
            window.open('/apex/BT_Task_Manager?recordId=' + escape(recordId), '_self')
        }

        // window.open(baseURL + '.lightning.force.com/lightning/r/buildertek__Schedule__c/' + escape(recordId) + '/view', '_self');
    },
    downloadCsv: function (component, event, helper) {
        var csv = helper.convertArrayOfObjectsToCSV(component, event, helper);
        if (csv == null) { return; }
        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; //
        hiddenElement.download = 'Import Schedules.csv'; // CSV file Name* you can change it.[only name not .csv]
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
    },
})