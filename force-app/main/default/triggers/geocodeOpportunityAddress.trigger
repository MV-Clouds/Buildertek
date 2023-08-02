trigger geocodeOpportunityAddress on Opportunity (after insert, after update) {
 //bulkify trigger in case of multiple accounts
  for (Opportunity opportunity : trigger.new) {
  
   // check if Billing Address has been updated
    Boolean addressChangedFlag = false;
    if (Trigger.isUpdate) {
      Opportunity oldOpportunity = Trigger.oldMap.get(opportunity.Id);
      if ((opportunity.Project_Address__c != oldOpportunity.Project_Address__c) ||
      (opportunity.Project_City__c != oldOpportunity.Project_City__c) ||
      (opportunity.Project_Country__c != oldOpportunity.Project_Country__c) ||
      (opportunity.Project_Zip_Code__c != oldOpportunity.Project_Zip_Code__c)) {
         
        addressChangedFlag = true;
         
        System.debug(LoggingLevel.DEBUG, '***Address changed for - ' + oldOpportunity.Name);
     }
    }
    // if address is null or has been changed, geocode it
    if ((opportunity.GeoLocation__Latitude__s == null) || (addressChangedFlag == true)) {
      System.debug(LoggingLevel.DEBUG, '***Geocoding Account - ' + opportunity.Name);
       if(!system.isFuture()) {
          OpportunityGeocodeAddress.DoAddressGeocode(opportunity.id);
        }
    }
  }
}