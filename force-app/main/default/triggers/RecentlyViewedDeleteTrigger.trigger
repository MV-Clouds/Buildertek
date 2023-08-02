trigger RecentlyViewedDeleteTrigger on EC_UserData__c  (after insert) {
Integer cnt = [select count() from EC_UserData__c where
                 RecordType.DeveloperName = 'Recently_Viewed' and User__c = :userInfo.getUserId()
                ];
    System.debug(' @@ count '+cnt);
     if (cnt > 4) {
  

    EC_UserData__c UserData = [select id  from EC_UserData__c where
                                        RecordType.DeveloperName = 'Recently_Viewed'
                                            and User__c = :userInfo.getUserId() order by  LastModifiedDate ASC LIMIT 1];
 System.debug(' @@ count '+UserData);
    delete UserData;
  }

}