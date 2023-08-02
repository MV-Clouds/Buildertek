trigger siteLayoutPublishControl on Site_Layout__c (before Insert, before Update) {

    Set<String> allPublishedSiteTypes = new Set<String>();
    
    for (Site_Layout__c allPublished : [
        SELECT Site_Type__c 
        FROM Site_Layout__c 
        WHERE Status__c = 'Published'
    ]) {
        allPublishedSiteTypes.add(allPublished.Site_Type__c);
    }
    
    
    for (Site_Layout__c eachLayout : Trigger.New) {
        if (String.isNotBlank(eachLayout.Site_Type__c) && eachLayout.Status__c == 'Published'
            && allPublishedSiteTypes.contains(eachLayout.Site_Type__c)) {
                eachLayout.addError('There is already a published Site with the same Site Type.');
        }
    }
}