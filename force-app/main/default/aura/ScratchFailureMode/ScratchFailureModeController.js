({
    doInit : function( component, event, helper ) {
        var nameOfCmp = component.get("v.componentName");
        
        
        if((nameOfCmp === 'IGU') || (nameOfCmp === 'CHW') || (nameOfCmp === 'PMUpdate')){
            var wrapData = component.get("v.NameOfFailureModesSelected");
            for(var r in wrapData){
                if((wrapData[r] === 'Non-Tinting - Intermittent Tinting') || (wrapData[r] === 'Non-Tinting')){
                    component.set("v.showNonTint",true);
                }
                if(wrapData[r] === 'Obstruction in Field of View - Spontaneous Breakage'){
                    component.set("v.showBreak",true);
                }
                if((wrapData[r] === 'OOS Scratches - S1/S4') || (wrapData[r] === 'OOS Scratches - S3 / Other')){
                    component.set("v.showScratch",true);
                }
                if((wrapData[r] === 'Non-Uniformity - Within Lite') || (wrapData[r] === 'Non-Uniformity - L2L')){
                    component.set("v.nonUniformity",true);
                }
                
            }
            component.set("v.updateBlock",true)
        }else{
            var selectedFM = component.get("v.NameOfFailureModesSelected");
            for(var r in selectedFM){
                if((selectedFM[r] === 'Non-Tinting - Intermittent Tinting') || (selectedFM[r] === 'Non-Tinting')){
                    component.set("v.showNonTint",true);
                }
                if(selectedFM[r] === 'Obstruction in Field of View - Spontaneous Breakage'){
                    
                    component.set("v.showBreak",true);
                   
                }
                if((selectedFM[r] === 'OOS Scratches - S1/S4') || (selectedFM[r] === 'OOS Scratches - S3 / Other')){
                    component.set("v.showScratch",true);
                }
                if((selectedFM[r] === 'Non-Uniformity - Within Lite') || (selectedFM[r] === 'Non-Uniformity - L2L')){
                    component.set("v.nonUniformity",true);
                }
            }
            component.set("v.insertBlock",true)
        }
        
       // console.log('======4==='+JSON.stringify(component.get("v.selectedIssue")));
    },
    saveSelection : function(component, event, helper) {
        var nameOfCmp = component.get("v.componentName");
        var selectedIssueRec = component.get("v.selectedIssue");
        if((nameOfCmp === 'IGU') || (nameOfCmp === 'CHW') || (nameOfCmp === 'PMUpdate')){
            if(component.get("v.showNonTint")){
                if((selectedIssueRec.Replaced_SWC__c === '') || (selectedIssueRec.Replaced_WC__c === '')
                   || (selectedIssueRec.Replaced_IGU_Cable__c === '')){
                    helper.showToastMessage( 'error', 'Error!', 'Please Provide Deatils' );
                    return;
                }
            }
            if(component.get("v.showBreak")){
                if((selectedIssueRec.Lite_Damaged__c === '')){
                    helper.showToastMessage( 'error', 'Error!', 'Please Provide Deatils' );
                    return;
                }
            }
            if(component.get("v.showScratch")){
                if((selectedIssueRec.From_approx_10ft_3_m__c === '') || (selectedIssueRec.Uniform_background_lighting_that_simulat__c === '')
                   || (selectedIssueRec.Vertically_positioned_at_90_deg_viewing__c === '')){
                    helper.showToastMessage( 'error', 'Error!', 'Please Provide Deatils' );
                    return;
                }
            }
            if(component.get("v.nonUniformity")){
                if((selectedIssueRec.Visible_BB_Damage__c === '')){
                    helper.showToastMessage( 'error', 'Error!', 'Please Provide Deatils' );
                    return;
                }
            }
        }else{
            var wrapper = component.get("v.LogIssueWrapper");
            if(component.get("v.showNonTint")){
                if((wrapper.replacedSWC === '') || (wrapper.replacedWC === '')
                  || (wrapper.replacedIGU === '') ){
                    helper.showToastMessage( 'error', 'Error!', 'Please Provide Deatils' );
                    return;
                }
                else
                {
                    component.set("v.ValuesProvided",true);
                }
                
            }
            if(component.get("v.showBreak")){
                if((wrapper.liteDamage === '')){
                    helper.showToastMessage( 'error', 'Error!', 'Please Provide Deatils' );
                                  
                    return;
                }
                else
                {
                    component.set("v.ValuesProvided",true);
                }
            }
            if(component.get("v.showScratch")){
                if((wrapper.inspected10ft === '') || (wrapper.backGrundLghtIGU === '')
                  || (wrapper.verticallyPositionedIGU === '') ){
                    helper.showToastMessage( 'error', 'Error!', 'Please Provide Deatils' );
                                  
                    return;
                }
                else
                {
                    component.set("v.ValuesProvided",true);
                }
            }
            if(component.get("v.nonUniformity")){
                if((wrapper.Visible_BB_Damage__c === '')){
                   helper.showToastMessage( 'error', 'Error!', 'Please Provide Deatils' );
                                  
                    return;
                }
                else
                {
                    component.set("v.ValuesProvided",true);
                }
            }
        }
        helper.saveSelection(component, event, helper);
    },
    closeModal : function( component, event, helper ) {
        helper.closeModal( component );
    },
    
    
})