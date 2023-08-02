Trigger IssueTrigger on Issue__c ( After Insert, After Update, Before Insert, Before Update ) {
    
    if( WorkOrderTriggerHandler.runcurrentTrigger( 'IssueTrigger' ) ) {
        
        if( IssueTriggerHelper.isTriggerAlreadyExecuted == FALSE ) {
            Organization org = [ SELECT IsSandbox FROM Organization limit 1 ];
            Box_Setting__mdt boxsettings = [ SELECT Enable_Box_in_Sandbox__c
                                            FROM Box_Setting__mdt 
                                            WHERE DeveloperName = 'Box_Setting' LIMIT 1 
                                           ];
            
            if( Trigger.isAfter ) {
                if( Trigger.isInsert ) {
                    IssueTriggerHelper.createProductsConsumed( Trigger.new, null );
                }
                else if( Trigger.isUpdate ) {
                    if(IssueTriggerHelper.productConsumedDeducted == FALSE)
                    {
                        IssueTriggerHelper.createProductsConsumed( Trigger.new,Trigger.oldmap ); 
                    }
                    
                    IssueTriggerHelper.UpdateWorkOrderLineItems( Trigger.new,Trigger.oldmap );
                }
                
                if( !FeatureManagement.checkPermission( 'Disable_Box_Creation' ) || Test.isRunningTest() ) {
                    if( !org.IsSandbox || ( boxsettings.Enable_Box_in_Sandbox__c && org.IsSandbox ) ||Test.isRunningTest() ) {
                        IssueTriggerHelper.checkissueForBoxFolderCreation( Trigger.new, Trigger.oldMap );
                    }  
                }
            }
            
            if( Trigger.isBefore ) {
                if( Trigger.isInsert ) {
                    if( IssueTriggerHelper.areIssuesCreatedFromLC == FALSE ) {
                        IssueTriggerHelper.populateAssetDataBeforeInsert(Trigger.new );
                    }
                    
                    IssueTriggerHelper.populateIGUCSSUnderWarrantybeforeinsert( Trigger.new );
                    // ADDED TO UPDATED THE WORKORDER ID IF WORK ORDER IS NOT SELECTED WHILE CREATING ISSUES.
                    IssueTriggerHelper.updateWorkOrderId( Trigger.new );
                    IssueTriggerHelper.updateproducts(Trigger.new);
                }
                else if( Trigger.isUpdate ) {
                    if( IssueTriggerHelper.areIssuesCreatedFromLC == FALSE ) {
                        IssueTriggerHelper.populateAssetDataBeforeUpdate( Trigger.old, Trigger.new );
                    }
                    
                    IssueTriggerHelper.populateIGUCSSUnderWarrantybeforeupdate( Trigger.oldmap,Trigger.new );   
                    // ADDED TO UPDATED THE WORKORDER ID IF WORK ORDER IS NOT SELECTED WHILE CREATING ISSUES.
                    IssueTriggerHelper.updateWorkOrderId(Trigger.new);
                    IssueTriggerHelper.updateproducts(Trigger.new);
                }    
            }
        }
    }
}