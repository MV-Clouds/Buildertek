({
    getOwnerNameAndCompanyName: function(component, recordId) {
        var action = component.get("c.getOwnerNameAndCompanyName");
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                console.log('response: ' + JSON.stringify(response));
                //whatever is before the - is the response
                var ownerName = response.split('-')[0];
                var companyName = response.split('-')[1];
                if (ownerName != null && ownerName != '') {
                    console.log('ownerName: ' + ownerName);
                    component.set('v.orgName', ownerName);
                }
                if (companyName != null && companyName != '' && companyName != 'null') {
                    console.log('companyName: ' + companyName);
                    component.set('v.companyName', companyName);
                }
            } else {
                console.log('Error in getting owner name and company name');
            }
        });
        $A.enqueueAction(action);
    },

    standardFileUploderFileChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        var fileId = '';
    
        var existingMapData = component.get('v.selectedfilesFill');
        var newFilesList = event.getParam('files');
        console.log('newFilesList', newFilesList);

        var resultMapArray = [];

        newFilesList.forEach(function(newMap) {
            var resultMap = {
                "Id": newMap.contentVersionId,
                "ContentDocumentId": newMap.documentId,
                "Title": newMap.name.substring(0, newMap.name.lastIndexOf(".")), 
                "ContentSize":  0, 
                "ContentBodyId": newMap.contentBodyId,
                "FileType": newMap.mimeType.split("/")[1],
                "VersionData": '0',
                "FormattedSize": '0KB',
                "isChecked": true 
            };

            resultMapArray.push(resultMap);
        });
        var selected = component.get("v.selectedFile") || [];
        selected.push(...resultMapArray);
        component.set("v.selectedFile", selected);
        console.log('resultMapArray', selected);

        var fileCount = newFilesList.length;
        var files = '';
        var mapData = existingMapData || [];
    
        if (fileCount > 0) {
            for (var i = 0; i < fileCount; i++) {
                fileName = newFilesList[i]['name'].substring(0, newFilesList[i]['name'].lastIndexOf("."));
                fileId = newFilesList[i].documentId;
    
                var obj = {};
                obj['Name'] = fileName;
                obj['Id'] = fileId;
    
                mapData.push(obj);
            }
            files = mapData.map(function(file) {
                return file.Name;
            }).join(', ');
        } else {
            files = fileName;
        }
    
        component.set('v.selectedfilesFill', mapData);
        var fileIds = component.get("v.selectedFillIds") || [];
        mapData.forEach(function(data) {
            // Check if data.Id is not in fileIds before pushing
            if (!fileIds.includes(data.Id)) {
                fileIds.push(data.Id);
            }
        });
        component.set("v.selectedFillIds", fileIds);
        console.log('fileIds 2:->', fileIds);
        console.log('mapData 2 :-->',component.get('v.selectedfilesFill'));
    },

    clearPillValues :function(component,event,heplper){
        var selectedPillId = event.getSource().get("v.name"); 
        var AllPillsList = component.get("v.selectedfilesFill") || [];    
        var selectedFillIds = component.get("v.selectedFillIds") || [];
    
        // Use Array.findIndex to find the index of the selected pill in the list
        var pillIndex = AllPillsList.findIndex(function(pill) {
            return pill.Id === selectedPillId;
        });
    
        if (pillIndex !== -1) {
            // Add the Id to selectedFillIds if not already present
            if (!selectedFillIds.includes(selectedPillId)) {
                selectedFillIds.push(selectedPillId);
            }
    
            // Remove the pill from selected files
            AllPillsList.splice(pillIndex, 1);
    
            // Remove the Id from selectedFillIds
            var fillIdIndex = selectedFillIds.indexOf(selectedPillId);
            if (fillIdIndex !== -1) {
                selectedFillIds.splice(fillIdIndex, 1);
            }
    
            // Update the selected files and selectedFillIds attributes
            component.set("v.selectedfilesFill", AllPillsList);
            component.set("v.selectedFillIds", selectedFillIds);
    
            console.log('Pill removed. Updated selected files:', AllPillsList);
            console.log('Updated selectedFillIds:', selectedFillIds);
            var selectedFiles = component.get("v.selectedFile") || [];
            var selectedFillIdsSet = new Set(selectedFillIds);

            // Filter selectedFiles based on matching selectedFillIds
            var filteredSelectedFiles = selectedFiles.filter(function(file) {
                return selectedFillIdsSet.has(file.ContentDocumentId);
                });

            // Update the attribute with the filtered list
            component.set("v.selectedFile", filteredSelectedFiles);
        } else {
            console.log('Pill not found in the list.');
        }
        
    },
})