({
	fetchLayoutDetails : function(component, event, helper) {
		var SiteType = component.get('v.siteType');
        console.log('SiteType'+SiteType);
        
        var action = component.get("c.fetchLayoutAndComponents");
        action.setParams({"SiteType": SiteType, "Preview": component.get('v.previewMode'), "SiteId": component.get('v.siteId')});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var layoutRecord = response.getReturnValue();
                if(layoutRecord && layoutRecord.layoutDetails){
                    var layoutDetails = layoutRecord.layoutDetails;
                    component.set("v.layoutType", layoutDetails.RecordType.Name);
                    component.set("v.previewSiteType", layoutDetails.Site_Type__c);
                    
                    var siteSections = layoutRecord.siteSections;
                    if (siteSections) {
                        if (siteSections.Header) {
                            this.createDynamicComponents(component, event, helper, siteSections.Header, 'HeaderCmp', false);
                        }
                        
                        if (siteSections.Column2) {
                            this.createDynamicComponents(component, event, helper, siteSections.Column2, 'Col2', true);
                        }
                        
                        if (siteSections.Column1) {
                            this.createDynamicComponents(component, event, helper, siteSections.Column1, 'Col1', true);
                        }
                        
                        if (siteSections.Column3) {
                            this.createDynamicComponents(component, event, helper, siteSections.Column3, 'Col3', true);
                        }
                        
                        if (siteSections.Column4) {
                            this.createDynamicComponents(component, event, helper, siteSections.Column4, 'Col4', true);
                        }
                    }
                }
            }
        });
        $A.enqueueAction(action);
	},
    
    createDynamicComponents: function(component, event, helper, sectionRecords, cmponentDiv, border) {
        //not nullundefined
        if (sectionRecords) {
            for (var eachSection in sectionRecords) {
                if (sectionRecords[eachSection].Text__c) {
                    this.createComponentUtility(component, undefined , cmponentDiv, border, sectionRecords[eachSection], sectionRecords[eachSection].Text__c);
                } else if (sectionRecords[eachSection].Custom_Widget__r.Widget_API_Name__c) {
                    var compNm = sectionRecords[eachSection].Custom_Widget__r.Widget_API_Name__c;
                    this.createComponentUtility(component, 'c:'+compNm, cmponentDiv, border, sectionRecords[eachSection], '');
                }
            }
        }
    },
    
    createComponentUtility: function(component, componentName, auraCmpDivName, border, widgetObject, Text) {
        console.log(component.get('v.siteType'));
        $A.createComponent(
            componentName ? componentName : 'lightning:formattedRichText', 
            {"siteName" : component.get("v.previewSiteType"),
             "autoplay" : widgetObject.Autoplay__c ? widgetObject.Autoplay__c : '' ,
             "numOfCards" : widgetObject.Number_of_Cards__c ? widgetObject.Number_of_Cards__c : '',
             "autoplaySpeed" : widgetObject.Autoplay_Speed__c ? widgetObject.Autoplay_Speed__c : '',
             "customHeight" : widgetObject.Height_in_Pixel__c ? widgetObject.Height_in_Pixel__c : '',
             "value" : Text ? Text : ''
            }
             ,
            function(newComponent, status, errorMessage) {
                if (status === "SUCCESS") {
                    console.log('isBlank component'+newComponent);
                    $A.createComponent(
                            "c:VG_ComponentWrapper", {
                                "boxValue" :newComponent,
                                "border" : border,
                                "customHeight" : widgetObject.Height_in_Pixel__c ? widgetObject.Height_in_Pixel__c : ''
                            },
                            function(newComponent1, status, errorMessage) {
                                if (status === 'SUCCESS') {
                                    var body = component.get('v.'+auraCmpDivName);
                                    body.push(newComponent1);
                                    component.set('v.'+auraCmpDivName, body);
                                }
                        });
                    
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            });
    }
})