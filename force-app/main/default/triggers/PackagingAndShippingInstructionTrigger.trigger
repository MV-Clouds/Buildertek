trigger PackagingAndShippingInstructionTrigger on Packaging_and_Shipping_Instruction__c (before Insert, before update, after Update) {
 	
    if(Trigger.isBefore && Trigger.isInsert){
        PackShippingInstructionTriggerHandler.doBeforeCreatingForm(Trigger.new);
        
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        Profile Pm_Profile = [Select Id, Name from Profile where Id =: UserInfo.getProfileId()];
        for(Packaging_and_Shipping_Instruction__c packagingRec : trigger.new){
            if(Pm_Profile.Name == 'Project Manager'){
                packagingRec.OwnerId = UserInfo.getUserId();
                //system.debug(UserInfo.getUserId() + '  ' + UserInfo.getProfileId() );
            }
            
        }
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){
        List<Packaging_and_Shipping_Instruction__c> packagingRecList = new List<Packaging_and_Shipping_Instruction__c>();
        for(Packaging_and_Shipping_Instruction__c packagingRec : trigger.new){
            if (Trigger.oldMap.get(packagingRec.Id).Is_Form_Approved__c != packagingRec.Is_Form_Approved__c && packagingRec.Is_Form_Approved__c == True && packagingRec.Is_Active__c == True) {
                packagingRecList.add(packagingRec);
            }
        }
        if(packagingRecList.size() > 0){
            PackShippingInstructionTriggerHandler.doAfterUpdateShipmentForm(packagingRecList);
        }
        
    }
    
}